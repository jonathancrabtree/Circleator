package Circleator::Parser::SNP_CLCFindVariations;

use strict;
use FileHandle;
use Circleator::Parser::SNP;
our @ISA = qw(Circleator::Parser::SNP);

# ------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------
sub new {
  my($invocant, $logger, $params) = @_;
  my $self = {};
  $self->{'logger'} = $logger;
  $self->{'config'} = $params->{'config'};
  die "logger must be defined" unless $logger;
  my $class = ref($invocant) || $invocant;
  bless $self, $class;
  return $self;
}

# ------------------------------------------------------------------
# Static (non-instance) methods
# ------------------------------------------------------------------

# TBD

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

sub parse_file {
  my($self, $file) = @_;
  die "couldn't find clc_find_variations SNP file $file" if ((!-e $file) || (!-r $file));
  my $entries = [];
  my $ref_seqs = {};
  my $variants = {};
  
  # prefixes used to define unique BioPerl attribute tags for SNP-related attributes
  my $tp = $self->tag_prefix();
  my $tbtp = $self->target_base_tag_prefix();

  my $fh = FileHandle->new();
  $fh->open($file)|| die "unable to read from clc_find_variations SNP file $file";
  my $lnum = 0;
  my $ref_seq_name = undef;

  while (my $line = <$fh>) {
    ++$lnum;
    last if (($lnum > 3) && ($line =~ /^\s*$/));
    
    # blank lines
    if (($lnum == 1) || ($lnum == 3)) {
      die "expected blank line at line $lnum of $file, found this instead: $line" unless ($line =~ /^\s*$/);
    }
    # ref sequence name
    elsif ($lnum == 2) {
      if ($line =~ /^(.*):$/) {
        $ref_seq_name = $1;
      } else {
        die "unable to parse reference sequence name at line $lnum of $file: $line";
      }
    } 
    # variations e.g., 
    #        3368   Difference   G  ->  A     A: 3644  C: 1     G: 7     T: 3     N: 0     -: 0   
    elsif ($line =~ /^\s+(\d+)\s+(Difference|Deletion|Insert|Nochange)\s+([ACTG\-]+)\s+\-\>\s+([ACTG\-]+)\s+(.*)$/) {
      my($pos, $type, $from, $to, $counts) = ($1, $2, $3, $4);
      my $snp_data = {};
      # parse base counts
      while ($counts =~ /([ACTG\-]+): (\d+)/m) {
        my($b, $c) = ($1, $2);
        my $ckey = . $tp. $b . "_count";
        die "duplicate count for $ckey at line $lnum of $file" if (defined($snp_data->{$ckey}));
        $snp_data->{$ckey} = $c;
        # DEBUG
        print STDERR "lnum $lnum $ckey -> $c\n";
      }

      # TODO
    
      # get or create ref seq
      my $ref_seq = $ref_seqs->{$snp_data->{$tp . 'molecule'}};
      if (!defined($ref_seq)) {
        $ref_seq = $ref_seqs->{$snp_data->{$tp . 'molecule'}} = Bio::Seq::RichSeq->new(-seq => '', -id => $snp_data->{$tp . 'molecule'}, -alphabet => 'dna');
        push(@$entries, [$ref_seq, undef, undef]);
      }
      my $start = $snp_data->{$tp . 'refpos'};
      my $end = $start + length($snp_data->{$tp . 'refbase'}) - 1;
      
      # should be at most one line per reference position
      my $snp_key = join(':', $snp_data->{$tp .'molecule'}, $snp_data->{$tp . 'refpos'});
      my $esnp = $snps->{$snp_key};
      $self->{'logger'}->logdie("duplicate reference location ($snp_key) at line $lnum of $file") if (defined($esnp));
      
      # new SNP feature
      my $snp_feat = new Bio::SeqFeature::Generic(-start => $start, -end => $end, -strand => 1, -primary => 'SNP', -display_name => 'SNP.' . $start, -tag => $snp_data);
      if (!$ref_seq->add_SeqFeature($snp_feat)) {
        $self->{'logger'}->logdie("failed to add SNP feature to corresponding reference sequence for $snp_data->{'molecule'}");
      }
      $snps->{$snp_key} = $snp_feat;
    }
    else {
      die "unable to parse line $lnum of $file: $line";
    }
  }
  
  # blank lines at the end
  while (my $line = <$fh>) {
    ++$lnum;
    die "expected blank line at line $lnum of $file, found this instead: $line" unless ($line =~ /^\s*$/);
  }
  
  my @refseqs = map {$_->[0]} @$entries;
  $self->process_snps(\@refseqs);
  return $entries;
}

1;
