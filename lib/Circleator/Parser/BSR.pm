package Circleator::Parser::BSR;

use strict;
use FileHandle;

$Circleator::Parser::BSR::DEFAULT_BSR_THRESHOLD = 0.4;

# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------
sub new {
    my($invocant, $logger, $params) = @_;
    my $self = {};
    $self->{'logger'} = $logger;
    die "logger must be defined" unless $logger;
    $logger->logdie("reference sequence must be defined") unless (defined($params->{'bpseq'}));
    # set the reference
    map { $self->{$_} = $params->{$_} } ('seq', 'seqlen', 'bpseq', 'strict_validation');
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
  my($self, $file, $genome1, $genome2) = @_;
  die "couldn't find BSR file $file" if ((!-e $file) || (!-r $file));
  $self->_index_ref_genes() unless (defined($self->{'ref_gene_index'}));
  my $rgi = $self->{'ref_gene_index'};

  my $fh = FileHandle->new();
  $fh->open($file)|| die "unable to read from BSR file $file";
  my $lnum = 0;
  while (my $line = <$fh>) {
    chomp($line);
    ++$lnum;
    my @f = split(/\t/, $line);
    my $nf = scalar(@f);

    # handle lines of the following form as a special case:
    #  NBH	1	NBH	1	0.0001	NBH	1	0.0001	
    # BSR will apparently produce these when when the ref polypeptide is too degenerate to match itself:
    # /translation="MFRKIXXXXXXXXXXXXXXXXXXXXXXXXXXFFFFFFFFFSVIE
    #               TVSFIS*"
    if ($line =~ /^NBH\t1\tNBH\t1\t\S+\tNBH\t1\t\S+\t$/) {
      $self->{'logger'}->warn("line $lnum of $file does not specify a reference gene: $line");
      next;
    }
    elsif ($nf != 9) {
      die "wrong number of fields ($nf) at line $lnum of $file";
    }
    my ($ref_gene, $ref_num, $q1_gene, $q1_num, $q1_bsr, $q2_gene, $q2_num, $q2_bsr, $product) = @f;
    # NBH = No BLAST Hit
    next if ($ref_gene eq 'NBH');

    # TODO - lookup $ref_gene in the reference and store $q1_bsr and $q2_bsr, warning if the new values disagree with the existing ones
    my $rg = $rgi->{$ref_gene};
    if (!defined($rg)) {
      my $msg = "couldn't find reference gene '$ref_gene' referenced in BSR file $file";
      if ($self->{'strict_validation'}) {
        $self->{'logger'}->logdie($msg);
      } else {
        $self->{'logger'}->error($msg);
      }
      next;
    }

    my $set_bsr_vals = sub {
      my($target_genome, $target_ratio, $target_gene, $target_num) = @_;
      my($rkey, $gkey, $nkey) = map { 'BSR_' . $target_genome . '_' . $_ } ('ratio', 'gene', 'num');
      my $set_values = 1;

      # check these aren't already defined
      if ($rg->has_tag($rkey)) {
          my @trl = $rg->get_tag_values($rkey);
          my @tgl = $rg->get_tag_values($gkey);
          my @tnl = $rg->get_tag_values($nkey);

          # if we've already seen this reference gene and the BSR results are the same, ignore it
          if (($trl[0] ne $target_ratio) || ($tgl[0] ne $target_gene) || ($tnl[0] != $target_num)) {
              if ($tgl[0] eq $target_gene) {
                  # if the results differ then take the one with the better score
                  # i.e., keep the original if it's better
                  my $wmsg = "multiple BSR results for $genome1/$ref_gene in $target_genome: R1=$tgl[0]/$trl[0] R2=$target_gene/$target_ratio.";
                  if ($target_ratio > $trl[0]) {
                    $set_values = 0;
                    $wmsg .= " Using R2.";
                  } else {
                    $wmsg .= " Using R1.";
                  }
                  $self->{'logger'}->warn($wmsg);
              } else {
                  $self->{'logger'}->logdie("conflicting BSR target genes found for ref=$genome1/$ref_gene: target1=$tgl[0] target2=$target_gene.");
              }
          }
      }
      if ($set_values) {
          $rg->add_tag_value($rkey, $target_ratio);
          $rg->add_tag_value($gkey, $target_gene);
          $rg->add_tag_value($nkey, $target_num);
      }
    };

    # store BSR results in attributes of ref gene $rg
    &$set_bsr_vals($genome1, $q1_bsr, $q1_gene, $q1_num, $genome1);
    &$set_bsr_vals($genome2, $q2_bsr, $q2_gene, $q2_num, $genome2);
  }
  $fh->close();
  $self->{'logger'}->info("BSR file $file: $lnum line(s), target_genomes=$genome1,$genome2");
}

sub _index_ref_genes {
  my($self) = @_;
  my($bpseq) = $self->{'bpseq'};
  my $ref_gene_hash = $self->{'ref_gene_index'} = {};
  
  my @sf = $bpseq->get_SeqFeatures();
  foreach my $sf (@sf) {
    my $pt = $sf->primary_tag();
    if ($pt eq 'gene') {
      if ($sf->has_tag('locus_tag')) {
        my @tv = $sf->get_tag_values('locus_tag');
        if (defined($ref_gene_hash->{$tv[0]})) {
          # TODO - declare error only if this gene is found in the BSR output
          $self->{'logger'}->die("duplicate locus tag '$tv[0]' in reference genome: can't map BSR results unambiguously");
        } else {
          $ref_gene_hash->{$tv[0]} = $sf;
        }
      }
    }
  }
}

1;

