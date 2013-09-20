package Circleator::Parser::SNP_Table;

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
  my($self, $file, $snp_ref) = @_;
  die "couldn't find SNP table file $file" if ((!-e $file) || (!-r $file));
  my $entries = [];
  my $ref_seqs = {};
  my $snps = {};

  my $fh = FileHandle->new();
  $fh->open($file)|| die "unable to read from SNP table file $file";
  my $lnum = 0;

  # parse header line
  # e.g., strain1:mol strain1:pos strain1:base strain2:mol strain2:pos strain2:base etc.
  my $header_line = <$fh>;
  ++$lnum;
  # header in example file has an extra column, but this eliminates it
  chomp($header_line);
  my @hf = split(/\t/, $header_line);
  my $n_hcols = scalar(@hf);
  $self->{'logger'}->debug("header line of $file has $n_hcols columns") if ($self->{'config'}->{'debug_opts'}->{'input'});

  # number of columns should be evenly divisible by 3
  my $num_strains = int($n_hcols / 3);
  if (($num_strains * 3) != $n_hcols) {
    $self->{'logger'}->logdie("header line of $file has $n_hcols columns, which is not evenly divisible by 3");
  }

  my $strain_names = [];
  # an index into $strain_names for the reference strain
  my $ref_strain_index = undef;
  my $col = 0;
  for (my $s = 0;$s < $num_strains;++$s) {
    my $mol_h = $hf[$col++];
    my($strain) = ($mol_h =~ /^(.*):mol$/);
    $self->{'logger'}->logdie("unexpected value at column $col of header line: $mol_h") if (!defined($strain));
    push(@$strain_names, $strain);
    my $pos_h = $hf[$col++];
    $self->{'logger'}->logdie("unexpected value at column $col of header line: $mol_h, not ${strain}:pos") if ($pos_h ne ($strain . ":pos"));
    my $base_h = $hf[$col++];
    $self->{'logger'}->logdie("unexpected value at column $col of header line: $mol_h, not ${strain}:base") if ($base_h ne ($strain . ":base"));
    $ref_strain_index = $s if ($strain eq $snp_ref);
  }
  $self->{'logger'}->logdie("snp-ref '$snp_ref' not found in $file") if (!defined($ref_strain_index));

  # parse the actual SNP data
  my $entries = [];
  my $ref_seqs = {};
  # SNPs indexed by reference position: used to check for duplicates
  my $snps = {};
  # prefixes used to define unique BioPerl attribute tags for SNP-related attributes
  my $tp = $self->tag_prefix();
  my $tbtp = $self->target_base_tag_prefix();
  my $num_snps = 0;
  my $num_ref_snps = 0;

 LINE:
  while (my $line = <$fh>) {
    ++$lnum;
    # skip blank lines
    next if ($line =~ /^\s*$/);
    my @f = split(/\t/, $line);
    chomp($f[-1]);
    my $nf = scalar(@f);
    $self->{'logger'}->logdie("wrong number of columns at line $lnum of $file: expected $n_hcols but found $nf") if ($nf != $n_hcols);
    my $col = 0;
    my $snp_info = [];
    ++$num_snps;

    for (my $s = 0;$s < $num_strains;++$s) {
      my $mol = $f[$col++];
      $self->{'logger'}->logdie("unexpected molecule id '$mol' at column $col of line $lnum") unless ($mol =~ /^(\S.*|)$/);
      my $pos = $f[$col++];
      # TODO - find out whether these represent a bug in the underlying SNP pipeline
      if ($pos < 0) {
        $self->{'logger'}->error("negative position '$pos' at column $col of line $lnum, skipping SNP");
        next LINE;
      }
      $self->{'logger'}->logdie("unexpected position '$pos' at column $col of line $lnum") unless ($pos =~ /^(\d+|)$/);
      my $base = $f[$col++];
      $self->{'logger'}->logdie("unexpected base '$base' at column $col of line $lnum") unless ($base =~ /^([ACGTUMRWSYKVHDBN\.\-]|)$/i);

      # if any 1 is blank then they must all be blank
      my $all_blank = 0;
      if (($mol eq '') && ($pos eq '') && ($base eq '')) {
        $all_blank = 1;
      } else {
        $self->{'logger'}->logdie("missing molecule id for $strain_names->[$s] at line $lnum") if ($mol eq '');
        $self->{'logger'}->logdie("missing position for $strain_names->[$s] at line $lnum") if ($pos eq '');
        $self->{'logger'}->logdie("missing base for $strain_names->[$s] at line $lnum") if ($base eq '');
      }
      push(@$snp_info, { 'all_blank' => $all_blank, 'mol' => $mol, 'pos' => $pos, 'base' => $base });
    }

    # skip if SNP doesn't appear in reference
    my $ref_snp_info = $snp_info->[$ref_strain_index];
    next if ($ref_snp_info->{'all_blank'});
    my($ref_mol, $ref_pos, $ref_base) = map {$ref_snp_info->{$_}} ('mol', 'pos', 'base');
    ++$num_ref_snps;

    # store SNP-associated data
    my $snp_data = {};

    # standardize SNP encoding 
    $snp_data->{$tp . 'ref_base'} = $snp_data->{$tp . 'refbase'} = $ref_base;
    $snp_data->{$tp . 'molecule'} = $ref_mol;
    $snp_data->{$tp . 'refpos'} = $ref_pos;

    for (my $s = 0;$s < $num_strains;++$s) {
      next if ($s == $ref_strain_index);
      my $snp_info = $snp_info->[$s];
      my($mol, $pos, $base, $all_blank) = map {$snp_info->{$_}} ('mol', 'pos', 'base', 'all_blank');
      next if ($all_blank); # TODO - check this
      $snp_data->{$tbtp . $strain_names->[$s]} = $base;
      $snp_data->{$tp . $strain_names->[$s] . '_mol'} = $mol;
      $snp_data->{$tp . $strain_names->[$s] . '_pos'} = $pos;
    }
    
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

    # TODO - in future this could be permitted in the case where the reference is "-" at all 
    # positions and the query positions are adjacent: in that case the query base string(s)
    # could be made multibase.
    if (defined($esnp)) {
      $self->{'logger'}->warn("skipping duplicate reference location ($snp_key) at line $lnum of $file");
      next;
    }

    # new SNP feature
    my $snp_feat = new Bio::SeqFeature::Generic(-start => $start, -end => $end, -strand => 1, -primary => 'SNP', -display_name => 'SNP.' . $start, -tag => $snp_data);
    if (!$ref_seq->add_SeqFeature($snp_feat)) {
      $self->{'logger'}->logdie("failed to add SNP feature to corresponding reference sequence for $snp_data->{'molecule'}");
    }
    $snps->{$snp_key} = $snp_feat;
  }
  $self->{'logger'}->info("parsed $num_ref_snps/$num_snps reference-anchored SNPs from $file");
  my @refseqs = map {$_->[0]} @$entries;
  $self->process_snps(\@refseqs);
  return $entries;
}

1;
