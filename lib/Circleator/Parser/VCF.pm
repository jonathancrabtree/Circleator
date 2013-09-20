package Circleator::Parser::VCF;

use strict;
use FileHandle;
use Circleator::Parser::SNP;
use Vcf;

our @ISA = qw(Circleator::Parser::SNP);

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
  die "couldn't find VCF file $file" if ((!-e $file) || (!-r $file));
  my $entries = [];
  my $ref_seqs = {};
  my $tp = $self->tag_prefix();
  my $tbtp = $self->target_base_tag_prefix();

  my $vcf = Vcf->new('file' => $file);
  $vcf->parse_header();

  # number of variant lines in the VCF file
  my $vcf_count = 0;
  # number of SNP features created
  my $n_snp_feats = 0;

  # "Most thorough but slowest way how to get the data."
  while (my $x = $vcf->next_data_hash()) {
    # required columns
    my($chrom, $pos, $ref, $alt, $info, $id, $qual, $filter, $format, $gtypes) = 
      map {$x->{$_}} ('CHROM', 'POS', 'REF', 'ALT', 'INFO', 'ID', 'QUAL', 'FILTER', 'FORMAT', 'gtypes');

    # only simple SNPs or indels are supported, not the more complex structural variants that VCF can encode
    my $has_complex_ref = ($ref !~ /^[actgn]+$/i);
    my $has_complex_alt = 0;
    my $n_alt = scalar(@$alt);

    foreach my $av (@$alt) {
      $has_complex_alt = 1 if ($av !~ /^[actgn]+$/i);
    }

    if ($has_complex_ref || $has_complex_alt) {
      $self->{'logger'}->logdie("unsupported REF ($ref) or ALT value (" . join(',', @$alt) . ") at variant line $vcf_count of VCF file $file: only simple SNPs or indels are permitted");
    }

    # get or create ref seq
    my $ref_seq = $ref_seqs->{$chrom};
    if (!defined($ref_seq)) {
      $ref_seq = $ref_seqs->{$chrom} = Bio::Seq::RichSeq->new(-seq => '', -id => $chrom, -alphabet => 'dna');
      push(@$entries, [$ref_seq, undef, undef]);
    }

    # VCF POS is 1-based coordinate of the leftmost base in REF
    my $start = $pos;
    my $end = $start + length($ref) - 1;

    # create a single SNP even if there are multiple ALT values
    my $snp_data = 
      {
       'ID' => $id,
       'QUAL' => $qual,
       'FILTER' => $filter,
       $tp . 'ref_base' => $ref
      };
    map { $snp_data->{$_} = $info->{$_}; } keys %$info;
    
    # parse GATK 'set' field to determine which variants don't meet the filter thresholds
    my $filtered_genotypes = {};
    my $set = $info->{'set'};
    # doing it this way to deal with possibility of hyphens in sample/genotype names
    foreach my $gkey (keys %$gtypes) {
      my $kre = "filterIn${gkey}";
      if ($set =~ /$kre/) {
        $filtered_genotypes->{$gkey} = 1;
      }
    }

    # loop over genotypes
    foreach my $gkey (keys %$gtypes) {
      my $gtype = $gtypes->{$gkey};
      next if (defined($filtered_genotypes->{$gkey}));
      my($gt, $ad) = map { $gtype->{$_} } ('GT', 'AD');

      # TODO - is this correct/only way to identify samples in which variant is not present?
      next if (($gt =~ /^[0\.\/\|]*$/) || ($ad eq '.'));

      # query base
      # TODO - is it always the same in a merged VCF file?
      $snp_data->{$tbtp . $gkey} = $alt;
      # add genotype-specific info
      foreach my $fkey (@$format) {
        my $ginf = $gtype->{$fkey};
        if ($ginf =~ /,/) {
          my @ga = split(/\s*,\s*/, $ginf);
          $ginf = \@ga;
        }
        $snp_data->{$tbtp . $gkey . '_' . $fkey} = $ginf;
      }
    }

    my $jav = join(',', @$alt);
    my $snp_feat = new Bio::SeqFeature::Generic(-start => $start, -end => $end, -strand => 1, -primary => 'SNP', -display_name => 'SNP.' . $start . '.' . $jav, -tag => $snp_data);
    if (!$ref_seq->add_SeqFeature($snp_feat)) {
      $self->{'logger'}->logdie("failed to add SNP feature to corresponding reference sequence for $snp_data->{$tp . 'query_contig'}");
    }
    ++$n_snp_feats;
    ++$vcf_count;
  }
  $vcf->close();
  $self->{'logger'}->debug("parsed $vcf_count variant line(s) from VCF file $file, created $n_snp_feats SNP feature(s)") if ($self->{'config'}->{'debug_opts'}->{'input'});
  return $entries;
}

1;
