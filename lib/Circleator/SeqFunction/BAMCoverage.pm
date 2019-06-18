#!/usr/bin/perl

package Circleator::SeqFunction::BAMCoverage;

use strict;
use Circleator::SeqFunction::SeqFunction;
use POSIX qw(ceil);

our @ISA = qw(Circleator::SeqFunction::SeqFunction);

#use Bio::DB::Sam;


# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------
sub new {
    my($invocant, $logger, $params) = @_;
    my $self = Circleator::SeqFunction::SeqFunction::new(@_);
    $self->{'bam-files'} = $params->{'bam-files'};
    my $class = ref($invocant) || $invocant;
    bless $self, $class;
    return $self;
}

# ------------------------------------------------------------------
# Static (non-instance) methods
# ------------------------------------------------------------------

sub get_params {
    return ['bam-files'];
}

sub get_range {
    return (0, undef);
}

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

sub get_values {
    my($self, $seqref, $seqlen, $contig_info, $window_size, $window_offset) = @_;
    my($contig_positions, $contig_orientations, $contig_lengths) = map {$contig_info->{$_}} ('positions', 'orientations', 'lengths');
    my $windows_overlap = ($window_offset < $window_size);
    
    # read and sum all of the coverage data from the underlying BAM file(s).
    my $bam_files = $self->{'bam-files'};
    my $nbf = scalar(@$bam_files);
    $self->{'logger'}->warn("BAMCoverage given no SAM/BAM files to read.") if ($nbf == 0);

    # base counts indexed by ref seq position.  base counts will be summed over all the specified bam_files
    my $pileup = {};

    # NOTE - memory usage could be reduced by interleaving file reading and coverage calculation 
    #        or moving more of the calculation into an external wrapper

    foreach my $bf (@$bam_files) {
	my($file, $seqid, $seqregex) = map {$bf->{$_}} ('file', 'seqid', 'seqregex');

	# quick hack (but slow in terms of execution time) since samtools won't work correctly with the HMP files
	my $fh = FileHandle->new();
	# HACK - hard-coded paths
	my $cmd = "samtools mpileup $file |";
	$fh->open($cmd) || die "unable to execute $cmd";
	my $lnum = 0;
	my $nread = 0;
    my $refseq_warnings = {};

	while (my $line = <$fh>) {
	    ++$lnum;
	    my($refseq, $pos, $ref_base, $num_reads, $read_bases, $read_quals, $align_quals) = split(/\t/, $line);
	    next unless (defined($seqid) && ($refseq eq $seqid)) || (defined($seqregex) && ($refseq =~ /$seqregex/));
	    chomp($read_quals);
	    ++$nread;
        my $offset = $contig_positions->{$refseq};
        my $c_orientation = $contig_orientations->{$refseq};
        my $c_length = $contig_lengths->{$refseq};
        if (defined($offset)) {
          my $op = undef;
          if ($c_orientation == -1) {
            $op = $offset + ($c_length - $pos);
          } else {
            $op = $pos + $offset;
          }
          $pileup->{$op} += $num_reads;
        } elsif (!defined($refseq_warnings->{$refseq})) {
          $self->{'logger'}->warn("no offset found for $refseq");
          $refseq_warnings->{$refseq} = 1;
        }
	}
	$fh->close();
	$self->{'logger'}->info("parsed $nread/$lnum line(s) from $cmd");
    }

    my $values = [];

    # compute average coverage value over each window
    # TODO - factor out the code in common between here and SeqFunction::_get_seq_composition_function_values
    my $last_fmax = 0;
    my $num_windows = ceil($seqlen / $window_offset);
    my $end_char = $window_size + (($num_windows-1) * $window_offset);
    my $count = 0;
    my $total = 0;

    for (my $i = 0;$i < $end_char;++$i) {
	my $drop_char = 0;

	# don't wrap around if doing nonoverlapping windows
	if (($i >= $seqlen) && (!$windows_overlap)) {
	    $drop_char = 1;
	} 
	else {
	    # add the count for the next base to the current count
	    my $nl = $i % $seqlen;
	    $count += $pileup->{$nl};
	    ++$total;
	}

	# remove the count from the oldest base from the counts, if current count is above window size
	if (($total > $window_size) || $drop_char) {
	    my $ol = $i - $window_size;
	    $count -= $pileup->{$ol};
	    die "internal error, mpileup found count = $count at i=$i" if ($count < 0);
	    --$total;
	}

	# report current value, if we're at an even multiple of window_offset or at the end 
	if (((($i+1) >= $window_size) && ((($i+1) % $window_offset) == 0))) {
	    my $range_end = $i+1;
	    if ($range_end > $seqlen) {
		$range_end = $windows_overlap? ($range_end % $seqlen) : $seqlen;
	    }
	    my $n_bases = $range_end - $last_fmax;
	    my $avg = $count / $n_bases;
	    push(@$values, [$last_fmax, $range_end, $avg]);

	    # HACK - dump data into format readable by Circleator::SeqFunction::FlatFile
#	    print STDERR join("\t", undef, $last_fmax, $range_end, $avg) . "\n";

	    $last_fmax += $window_offset;
	}
    }

    return $values;
}

1;
