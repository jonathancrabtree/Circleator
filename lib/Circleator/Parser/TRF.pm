package Circleator::Parser::TRF;

use strict;
use FileHandle;

# Parser for Tandem Repeat Finder output

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
  my $trf_seqs = {};
  my $trf_version = undef;
  my $trf_seq = undef;
  my $entries = [];
  my $ref_seqs = {};

  my $fh = FileHandle->new();
  $fh->open($file)|| die "unable to read from TRF file $file";
  my $lnum = 0;
  while (my $line = <$fh>) {
    chomp($line);
    ++$lnum;

    # skip blank lines
    if ($line =~ /^\s*$/) {
      next;
    }
    # make sure this is really TRF output
    elsif (($lnum == 1) && ($line !~ /tandem repeats finder/i)) {
      $self->{'logger'}->die("unexpected content at line 1 of Tandem Repeats Finder file '$file': $line");
    }
    # record TRF version number
    elsif ($line =~ /^version ([\d\.]+)/i) {
      $trf_version = $1;
      $self->{'logger'}->debug("TRF version is $trf_version in $file") if ($self->{'config'}->{'debug_opts'}->{'input'});
      $self->{'logger'}->logdie("TRF version number found _after_ first sequence") if (scalar(keys %$trf_seqs) > 0);
    }
    elsif ($line =~ /Sequence:\s*(\S.*)\s*$/) {
      my $seq = $1;
      # get or create ref seq
      my $ref_seq = $ref_seqs->{$seq};
      if (!defined($ref_seq)) {
        $ref_seq = $ref_seqs->{$seq} = Bio::Seq::RichSeq->new(-seq => '', -id => $seq, -alphabet => 'dna');
        push(@$entries, [$ref_seq, undef, undef]);
      }

      $trf_seq = { 'seq_id' => $seq, 'ref_seq' => $ref_seq };
      $trf_seqs->{$seq} = $trf_seq;
    }
    elsif ($line =~ /Parameters:\s*(\d[\s\d]+)$/) {
      $self->{'logger'}->logdie("TRF Parameters precede Sequence declaration at line $lnum of $file") if (!defined($trf_seq));
      $trf_seq->{'parameters'} = $1;
    }

    # Indices of the repeat relative to the start of the sequence.
    # Period size of the repeat.
    # Number of copies aligned with the consensus pattern.
    # Size of consensus pattern (may differ slightly from the period size).
    # Percent of matches between adjacent copies overall.
    # Percent of indels between adjacent copies overall.
    # Alignment score.
    # Percent composition for each of the four nucleotides.
    # Entropy measure based on percent composition.
    #
    # e.g., 229 253 11 2.3 11 100 0 50 28 8 16 48 1.74 ATTTCAGTTAG ATTTCAGTTAGATTTCAGTTAGATT
    elsif ((defined($trf_seq) 
            && ($line =~ /^(\d+)\s(\d+)\s(\d+)\s([\d\.]+)\s(\d+)\s([\d\.]+)\s([\d\.]+)\s(\d+)\s([\d\.]+)\s([\d\.]+)\s([\d\.]+)\s([\d\.]+)\s([\d\.]+)\s([actgn]+)\s([actgn]+)$/i))) {
      my($start, $end, $period, $n, $psize, $pct_match, $pct_indel, $score, $pct_a, $pct_c, $pct_g, $pct_t, $entropy, $pattern, $seq) 
        = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15);

      # create new TRF feature
      my $trf_data = 
        {
         'period' => $period,
         'n_copies' => $n,
         'pattern_size' => $psize,
         'pct_match' => $pct_match,
         'pct_indel' => $pct_indel,
         'score' => $score,
         'pct_a' => $pct_a,
         'pct_c' => $pct_c,
         'pct_g' => $pct_g,
         'pct_t' => $pct_t,
         'entropy' => $entropy,
         'pattern' => $pattern,
         'seq' => $seq
        };

      # sanity checks
      $self->{'logger'}->logdie("pattern length disagreement at line $lnum of $file: $line") if ($psize != length($pattern));

      my $trf_feat = new Bio::SeqFeature::Generic(-start => $start, -end => $end, -strand => 1, -primary => 'TRF', -display_name => 'TRF.' . $start, -tag => $trf_data);
      if (!$trf_seq->{'ref_seq'}->add_SeqFeature($trf_feat)) {
        $self->{'logger'}->logdie("failed to add TRF feature to corresponding reference sequence for " . $trf_seq->{'ref_seq'});
      }
    }
    elsif (!defined($trf_seq)) {
      next;
    }
    else {
      $self->{'logger'}->logdie("unable to parse line $lnum of Tandem Repeats Finder file '$file': $line");
    }
  }

  return $entries;
}

1;
