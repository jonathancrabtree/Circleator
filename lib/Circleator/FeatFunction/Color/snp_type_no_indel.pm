package Circleator::FeatFunction::Color::snp_type_no_indel;

use Circleator::Parser::SNP;

my $SNP = Circleator::Parser::SNP->new();
my $SNP_TP = $SNP->tag_prefix();
my $SNP_TBTP = $SNP->target_base_tag_prefix();

# Assign color based on SNP type (SYN/NSYN/NA).  Requires query genome name.
sub get_function {
  my($track, $tname) = @_;

  my $query = $track->{'snp-query'};
  # TODO - generate error (that the user sees) if $query is not specified 
  my $no_hit_color = $track->{'snp-no-hit-color'} || 'none';
  my $same_as_ref_color = $track->{'snp-same-as-ref-color'} || 'none';
  my $unknown_color = $track->{'snp-unknown-color'} || 'black';
  my $intergenic_color = $track->{'snp-intergenic-color'} || 'black';
  my $syn_color = $track->{'snp-syn-color'} || 'green';
  my $nsyn_color = $track->{'snp-nsyn-color'} || 'red';
  my $multiple_color = $track->{'snp-multiple-color'} || 'orange';
  my $intronic_color = $track->{'snp-intronic-color'} || 'gray';  # gray
  my $other_color = $track->{'snp-other-color'} || '#6d4d2e'; # brown-ish
  my $readthrough_color = $track->{'snp-readthrough-color'} || '#d82bec'; # pink-ish

  return sub {
    my $f = shift;
    my $ftype = $f->primary_tag();
    die "snp_type can only be used on SNPs, not features of type $ftype" unless ($ftype eq 'SNP');
    my @r_bases = $f->get_tag_values($SNP_TP . 'ref_base');
    return 'none' if (!($f->has_tag($SNP_TBTP . $query)));
    my @q_bases = $f->get_tag_values($SNP_TBTP . $query);
    my $rb = $r_bases[0];

    # if either of these ends up set to 1 we expect there to be only 1 allele, but we don't explicitly check for it here:
    my $no_hit = 0;                # no hit for _any_ allele
    my $same_as_ref = 1;           # same as ref for _all_ alleles
    my $num_qb = scalar(@q_bases);
    my $rl = length($rb);

    foreach my $qb (@q_bases) {
      $same_as_ref = 0 if ($qb ne $rb);
      if ($qb =~ /^no hit$/i) {
        $no_hit = 1;
        next;
      }
    }
    
    return $no_hit_color if ($no_hit);
    return $same_as_ref_color if ($same_as_ref);

    # syn_nonsyn defined
    if ($f->has_tag($SNP_TP . 'syn_nonsyn')) {
      my @sns_vals = $f->get_tag_values($SNP_TP . 'syn_nonsyn');
      # handle multiple values
      my @vals = split(/\//, $sns_vals[0]);
      my $nv = scalar(@vals);
      if ($nv > 1) {
        return $multiple_color;
      }
      if ($sns_vals[0] =~ /^NSYN|nonsynonymous$/i) {
        return $nsyn_color;
      } 
      elsif ($sns_vals[0] =~ /^SYN|synonymous$/i) {
        return $syn_color;
      }
      elsif ($sns_vals[0] eq 'intronic') {
        return $intronic_color;
      }
      elsif ($sns_vals[0] eq 'intergenic') {
        return $intergenic_color;
      }
      elsif ($sns_vals[0] eq 'other') {
        return $other_color;
      }
      elsif ($sns_vals[0] eq 'readthrough') {
        return $readthrough_color;
      }
      elsif ($sns_vals[0] =~ /^NA/i) {
        die "no ref_base for SNP with id=" . $f->display_name() . "\n" if (!$f->has_tag($SNP_TP . 'ref_base'));
        # intergenic substitution
        return $intergenic_color;
      }
      die "Found SNP with id=" . $f->display_name() . " and syn_nonsyn !~ SYN|NSYN|NA (value='$sns_vals[0]')";
    }      
    # syn_nonsyn not defined
    else {
      return $unknown_color;
    }
  };
}
 
1;

