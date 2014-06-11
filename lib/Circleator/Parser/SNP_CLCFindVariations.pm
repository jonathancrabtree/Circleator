package Circleator::Parser::SNP_CLCFindVariations;

use strict;
use FileHandle;
use Circleator::Parser::SNP;
our @ISA = qw(Circleator::Parser::SNP);

# ------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------

# TODO - remove hard-coded cutoffs
my $PCT_CUTOFFS = [1,5,10,20,30,40,50];

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
  my($self, $file, $ref_seq_id) = @_;
  die "couldn't find clc_find_variations SNP file $file" if ((!-e $file) || (!-r $file));
  my $entries = [];
  my $ref_seqs = {};
  my $snps = {};
  
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
        # TODO - check that $ref_seq_id appears within $ref_seq_name somewhere
      } else {
        die "unable to parse reference sequence name at line $lnum of $file: $line";
      }
    } 
    # variations e.g., 
    #        3368   Difference   G  ->  A     A: 3644  C: 1     G: 7     T: 3     N: 0     -: 0   
    elsif ($line =~ /^\s+(\d+)\s+(Difference|Deletion|Insert|Nochange)\s+([ACTGN\-]+)\s+\-\>\s+([ACTGN\-]+)\s+(.*)$/) {
      my($pos, $type, $from, $to, $counts) = ($1, $2, $3, $4, $5);
      my $snp_data = {
        $tp . 'ref_base' => $from,
      };
      my $num_diffs = 0;
      my $num_targets = 0;

      # parse base counts
      my $count_list = [];
      while ($counts =~ /([ACTGN\-]+): (\d+)/g) {
        my($b, $c) = ($1, $2);
        push(@$count_list, [$b, $c]);
        my $ckey = $tp . $b . "_count";
        die "duplicate count for $ckey (count=$c) at line $lnum of $file" if (defined($snp_data->{$ckey}));
        $snp_data->{$ckey} = $c;
        $num_targets += $c;
        $num_diffs += $c unless ($b eq $from);
      }

      # now that $num_targets is known compute each count as percentage of the total
      my $new_count_list = [];
      foreach my $cp (@$count_list) {
        my($b, $c) = @$cp;
        my $cpct = sprintf("%0.2f", ($c / $num_targets) * 100.0);
	push(@$new_count_list, [$b, $c, $cpct]);
      }

      $count_list = $new_count_list;
      # sort by descending percentage
      my @desc_count_list = sort { $b->[1] <=> $a->[1] } @$count_list;

      # DEBUG
#      print STDERR "$counts\n";
#      print STDERR join(", ", map { join(":", @$_) } @desc_count_list) . "\n";
#      print STDERR "\n";

      my $ncl = scalar(@desc_count_list);
      for (my $i = 0;$i < $ncl;++$i) {
	  my $ord = $i+1;
	  my $dc = $desc_count_list[$i];
	  my($bases, $count, $pct) = @$dc;
	  $snp_data->{$tp . 'bases_' . $ord} = $bases;
	  $snp_data->{$tp . 'count_' . $ord} = $count;
	  $snp_data->{$tp . 'pct_' . $ord} = $pct;
      }

      # look at counts as percentage of the total
      # gt_counts:
      #  number of variants present at >X% where X in @$PCT_CUTOFFS
      # gte_lt_counts:
      #  number of variants present at >=X% and < Y% where X and Y are adjacent in @$PCT_CUTOFFS
#      my $gte_lt_counts = {};
      my $gt_counts = {};
#      map { $gte_lt_counts->{$_} = $gt_counts->{$_} = 0; } @$PCT_CUTOFFS;
      my $npc = scalar(@$PCT_CUTOFFS);

      foreach my $cp (@$count_list) {
        my($b, $c) = @$cp;
        my $cpct = sprintf("%0.2f", ($c / $num_targets) * 100.0);
	for (my $ci = 0;$ci < $npc;++$ci) {
	    my($min, $max) = map { $PCT_CUTOFFS->[$_] } ($ci, $ci+1);
#	    ++$gte_lt_counts->{$min} if (($cpct >= $min) && ($cpct < $max));
	    ++$gt_counts->{$min} if ($cpct > $min);
        }
      }
      
      for (my $ci = 0;$ci < $npc-1;++$ci) {
	  my($min, $max) = map { $PCT_CUTOFFS->[$_] } ($ci, $ci+1);
	  # e.g., num_variants_gte_10_lt_20%:
#	  $snp_data->{$tp . 'num_variants_gte_' . $min . '_lt_' . $max . '%'} = $gte_lt_counts->{$min};
#	  if ($gte_lt_counts->{$min} > 0) {
#	      print STDERR $tp . 'num_variants_gte_' . $min . '_lt_' . $max . '%' . " = " . $gte_lt_counts->{$min}. "\n";
#	  }
	  # e.g., num_variants_gt_10%:
	  $snp_data->{$tp . 'num_variants_gt_' . $min . '%'} = $gt_counts->{$min};
#	  if ($gt_counts->{$min} > 0) {
#	      print STDERR $tp . 'num_variants_gt_' . $min . '%' . " = " . $gt_counts->{$min}. "\n";
#	  }
      }

      $snp_data->{$tp . 'num_diffs'} = $num_diffs;
      $snp_data->{$tp . 'num_no_hits'} = 0;
      $snp_data->{$tp . 'num_targets'} = $num_targets;

      # get or create ref seq
      my $ref_seq = $ref_seqs->{$ref_seq_id};
    
      if (!defined($ref_seq)) {
        $ref_seq = $ref_seqs->{$ref_seq_id} = Bio::Seq::RichSeq->new(-seq => '', -id => $ref_seq_id, -alphabet => 'dna');
        push(@$entries, [$ref_seq, undef, undef]);
      }
      my $start = $pos;
      my $end = $start + length($from) - 1;
      
      # should be at most one line per reference position
      my $snp_key = join(':', $ref_seq_id, $pos);
      my $esnp = $snps->{$snp_key};
      $self->{'logger'}->logwarn("duplicate reference location ($snp_key) at line $lnum of $file") if (defined($esnp));
      
      # new SNP feature
      my $snp_feat = new Bio::SeqFeature::Generic(-start => $start, -end => $end, -strand => 1, -primary => 'SNP', -display_name => 'SNP.' . $start, -tag => $snp_data);
      if (!$ref_seq->add_SeqFeature($snp_feat)) {
        $self->{'logger'}->logdie("failed to add SNP feature to corresponding reference sequence for $ref_seq_id");
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
  
  return $entries;
}

1;
