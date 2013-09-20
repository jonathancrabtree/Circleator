#!/usr/bin/perl

package Circleator::SeqFunction::FlatFile;

use strict;
use Circleator::SeqFunction::SeqFunction;

our @ISA = qw(Circleator::SeqFunction::SeqFunction);

# Class that reads sequence-associated data to be plotted from a tab-delimited flat file.
# This class ignores the window-size and window-offset values that it is passed, instead
# using values parsed directly from the input file.  Each line of the input file must have
# the following format, with tabs separating fields:
#
# refseq_name    fmin    fmax    value    conf_low    conf_high
#
# refseq_name - may be omitted if only a single sequence is being plotted
# start - start coordinate in 0-indexed base-based coordinates
# end - end coordinate in 0-indexed base-based coordinates
# value - numeric value corresponding to the indicated sequence range
# conf_low - optional. specifies lower bound of confidence interval
# conf_high - optional. specifies lower bound of confidence interval

# ------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------
my $DEFAULT_SEQ_ID_REGEX = '^(.*)$';

# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------
sub new {
  my($invocant, $logger, $params) = @_;
  my $self = Circleator::SeqFunction::SeqFunction::new(@_);
  my $pnames = &get_params();
  foreach my $p (@$pnames) {
	$self->{$p} = $params->{$p};
  }
  $self->{'seq-id-regex'} = $DEFAULT_SEQ_ID_REGEX if (!defined($self->{'seq-id-regex'}));
  my $class = ref($invocant) || $invocant;
  bless $self, $class;
  return $self;
}

# ------------------------------------------------------------------
# Static (non-instance) methods
# ------------------------------------------------------------------
sub get_params {
  return ['file', 'seq-id-regex'];
}

sub get_range {
  return (undef,undef);
}

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

# Note that $window_size and $window_offset are ignored, as these
# parameters are specified implicitly in the provided data file.
#
sub get_values {
  my($self, $seqref, $seqlen, $contig_info, $window_size, $window_offset) = @_;
  my($contig_positions, $contig_orientations, $contig_lengths) = map {$contig_info->{$_}} ('positions', 'orientations', 'lengths');
  my($file, $seq_id_regex) = map { $self->{$_} } ('file', 'seq-id-regex');
  my $fh = FileHandle->new();
  $fh->open($file) || die "unable to read from $file";
  my $lnum = 0;
  my $values = [];
  my $seq_id_warnings = {};
  my $contig_position_warnings = {};

  while (my $line = <$fh>) {
	chomp($line);
	++$lnum;
	next if ($line =~ /^(\#|\/\/)/);
	my($refseq, $fmin, $fmax, $value, $conf_lo, $conf_high) = split(/\t/, $line);

	# apply contig offset if applicable
	if ($refseq =~ /\S/) {
      my($seq_id) = ($refseq =~ /$seq_id_regex/);
      if (!defined($seq_id)) {
        if (!defined($seq_id_warnings->{$seq_id})) {
          $self->{'logger'}->warn("couldn't parse seq id from '$refseq' at line $lnum of $file");
          $seq_id_warnings->{$seq_id} = 1;
        }
      } else {
		my $offset = $contig_positions->{$seq_id};
		my $orientation = $contig_orientations->{$seq_id};
		my $c_length = $contig_lengths->{$seq_id};
		if (!defined($offset)) {
          if (!defined($contig_position_warnings->{$seq_id})) {
          $self->{'logger'}->warn("unrecognized sequence id '$refseq' at line $lnum of $file");
            $contig_position_warnings->{$seq_id} = 1;
          }
          next;
		}

        if ($orientation == -1) {
          $fmin = $offset + ($c_length - $fmin);
          $fmax = $offset + ($c_length - $fmax);
        } else {
          $fmin += $offset;
          $fmax += $offset;
        }
      }
	}
    
	push(@$values, [$fmin, $fmax, $value, $conf_lo, $conf_high]);
  }

  $fh->close();

  # TODO - make this sort optional
  my @sorted = sort {$a->[0] <=> $b->[0]} @$values;
  return \@sorted;
}

1;
