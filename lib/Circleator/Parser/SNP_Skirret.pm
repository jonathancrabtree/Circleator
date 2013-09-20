package Circleator::Parser::SNP_Skirret;

use strict;
use FileHandle;
use Circleator::Parser::SNP;
our @ISA = qw(Circleator::Parser::SNP);

my $SKIRRET_COLUMNS = 
  [
    { 'name' => 'p1', 'regex' => '\^?\d+' },
    { 'name' => 'ref_base', 'regex' => '[ACGTUMRWSYKVHDBN\.]' },
    { 'name' => 'query_base', 'regex' => '[ACGTUMRWSYKVHDBN\.]' },
    { 'name' => 'p2', 'regex' => '\d+' },
    { 'name' => 'buff', 'regex' => '\d+' },
    { 'name' => 'dist', 'regex' => '\d+' },
    { 'name' => 'len_r', 'regex' => '\d+' },
    { 'name' => 'len_q', 'regex' => '\d+' },
    { 'name' => 'frm1', 'regex' => '\-?\d+' },
    { 'name' => 'frm2', 'regex' => '\-?\d+' },
    { 'name' => 'ref_contig', 'regex' => '\S+' },
    { 'name' => 'query_contig', 'regex' => '\S+' },
    { 'name' => 'gene_id', 'regex' => 'intergenic|\S+' },
    { 'name' => 'gene_start', 'regex' => 'NA|\d+' },
    { 'name' => 'gene_stop', 'regex' => 'NA|\d+' },
    { 'name' => 'position_in_gene', 'regex' => 'NA|\d+' },
    { 'name' => 'syn_nonsyn', 'regex' => 'NA|SYN|NSYN' },
    { 'name' => 'product', 'regex' => '[^\t]+' },
    { 'name' => 'gene_direction', 'regex' => 'NA|\-?1' },
    # TODO - refine these:
    { 'name' => 'ref_codon', 'regex' => 'NA|[ACGTUMRWSYKVHDBN\.]+' },
    { 'name' => 'ref_amino_acid', 'regex' => 'NA|[A-Z]|Stop' },
    { 'name' => 'query_codon', 'regex' => 'NA|[ACGTUMRWSYKVHDBN\.]+' },
    { 'name' => 'query_amino_acid', 'regex' => 'NA|[A-Z]|Stop' },
  ];

my $NUM_COLUMNS = scalar(@$SKIRRET_COLUMNS);

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
  die "couldn't find Skirret SNP file $file" if ((!-e $file) || (!-r $file));
  my $entries = [];
  # TODO - standardize on how this is done; does the parser add the features to the original seq (as in BSR.pm) or does the main program do that (as for the existing SNP parsers)?
  my $ref_seqs = {};
  my $snps = {};
  my $tp = $self->tag_prefix();
  my $tbtp = $self->target_base_tag_prefix();

  my $fh = FileHandle->new();
  $fh->open($file)|| die "unable to read from Skirret SNP file $file";
  my $lnum = 0;
  while (my $line = <$fh>) {
    chomp($line);
    ++$lnum;
    my @f = split(/\t/, $line);
    my $nf = scalar(@f);
    # HACK - some lines have an extra number appended to the end.  seems to only affect those that match in a gene
    if (($nf == ($NUM_COLUMNS+1)) && ($f[$NUM_COLUMNS] =~ /NA|\d+|num_homopolymer/)) {
      pop(@f);
      --$nf;
    }
    $self->{'logger'}->logdie("wrong number of columns ($nf instead of $NUM_COLUMNS) at line $lnum of $file: $line") if ($nf != $NUM_COLUMNS);

    # column names
    if ($lnum == 1) {
      for (my $c = 0;$c < $nf;++$c) {
        my $col = $SKIRRET_COLUMNS->[$c];
        my $col_name = $col->{'name'};
        $self->{'logger'}->logdie("name mismatch ($f[$c] instead of $col_name) for column $c at line $lnum of $file") if ($f[$c] ne $col_name);
      }
    }  
    # data
    else {
      my $snp_data = {};
      for (my $c = 0;$c < $nf;++$c) {
        my $col = $SKIRRET_COLUMNS->[$c];
        my $col_name = $col->{'name'};
        my $col_regex = '^' . $col->{'regex'} . '$';
        if ($f[$c] !~ /$col_regex/) {
          $self->{'logger'}->logdie("value for column $c ('$f[$c]') at line $lnum of $file does not match regex '$col_regex'");
        }
        $snp_data->{$tp . $col_name} = $f[$c];
      }

      # get or create ref seq
      my $ref_seq = $ref_seqs->{$snp_data->{$tp . 'ref_contig'}};
      if (!defined($ref_seq)) {
        $ref_seq = $ref_seqs->{$snp_data->{$tp . 'ref_contig'}} = Bio::Seq::RichSeq->new(-seq => '', -id => $snp_data->{$tp . 'ref_contig'}, -alphabet => 'dna');
        push(@$entries, [$ref_seq, undef, undef]);
      }
      # leading '^' indicates reverse-strand match used to infer SNP?
      if ($snp_data->{$tp . 'p1'} =~ /^\^/) {
        # TODO - check whether coordinates need to be adjusted for rev strand SNPs
        $snp_data->{$tp . 'p1'} =~ s/^\^//;
      }

      my $start = $snp_data->{$tp . 'p1'};
      my $end = $start + length($snp_data->{$tp . 'ref_base'}) - 1;
      # store query base
      $snp_data->{$tbtp . $snp_data->{$tp . 'query_contig'}} = $snp_data->{$tp . 'query_base'};

      # combine SNPs that are part of the same multi-base insertion
      my $snp_key = join(':', $snp_data->{$tp . 'ref_contig'}, $snp_data->{$tp . 'query_contig'}, $snp_data->{$tp . 'p1'});
      my $esnp = $snps->{$snp_key};

      # a SNP is already defined at this location:
      if (defined($esnp)) {
        my @r_bases = $esnp->get_tag_values($tp . 'ref_base');
        my @q_bases = $esnp->get_tag_values($tp . 'query_base');
        my @p2 = $esnp->get_tag_values($tp . 'p2');
        # start and end coords on _query_ sequence
        my ($e_start, $e_end) = split(/\-/, $p2[0]);
        $e_end = $e_start if (!defined($e_end));
        # TODO - check that all of the other fields are the same?
        # NOTE - unsure whether "reverse strand" multibase insertions will be listed in the same ascending order
        if ((($e_end+1) == ($snp_data->{$tp . 'p2'})) && ($snp_data->{$tp . 'ref_base'} eq '.') && ($r_bases[0] eq '.') && ($q_bases[0] !~ /\./)) {
          my $nqb = $q_bases[0] . $snp_data->{$tp . 'query_base'};
          map { $esnp->remove_tag($_); } ('query_base', $snp_data->{$tp . 'query_contig'}) if ($esnp->has_tag('query_base'));
          map { $esnp->add_tag_value($_, $nqb); } ('query_base', $snp_data->{$tp . 'query_contig'});
          $esnp->add_tag_value('query_base', $nqb);
          # update query sequence
          $esnp->remove_tag('p2') if ($esnp->has_tag('p2'));
          $esnp->add_tag_value('p2', join('-', $e_start, $e_end+1));
          next;
        } else {
          $self->{'logger'}->logdie("multiple SNPs with key=$snp_key, but does not appear to be a multibase insertion");
        }
      }
      # new SNP feature
      my $snp_feat = new Bio::SeqFeature::Generic(-start => $start, -end => $end, -strand => 1, -primary => 'SNP', -display_name => 'SNP.' . $start, -tag => $snp_data);
      if (!$ref_seq->add_SeqFeature($snp_feat)) {
        $self->{'logger'}->logdie("failed to add SNP feature to corresponding reference sequence for $snp_data->{$tp . 'query_contig'}");
      }
      $snps->{$snp_key} = $snp_feat;
    }
  }
  $fh->close();
  $self->{'logger'}->debug("parsed $lnum line(s) from Skirret SNP file $file") if ($self->{'config'}->{'debug_opts'}->{'input'});
  return $entries;
}

1;
