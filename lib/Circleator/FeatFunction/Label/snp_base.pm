package Circleator::FeatFunction::Label::snp_base;

use Circleator::Parser::SNP;

my $SNP = Circleator::Parser::SNP->new();
my $SNP_TP = $SNP->tag_prefix();
my $SNP_TBTP = $SNP->target_base_tag_prefix();

# Generate label with the base at the SNP position
sub get_function {     
  my($track, $tname) = @_;
  my $query = $track->{'snp-query'};
  my $no_hit_label = $track->{'snp-no-hit-label'};
  my $same_as_ref_label = $track->{'snp-same-as-ref-label'};
  # TODO - generate error (that the user sees) if $query is not specified 
  
  return sub {
    my $f = shift;
    my @r_bases = $f->get_tag_values($SNP_TP . 'ref_base');
    return undef if (!$f->has_tag($SNP_TBTP . $query));
    my @q_bases = $f->get_tag_values($SNP_TBTP . $query);
    my $rb = $r_bases[0];
    my $qbs = join(',', @q_bases);
    
    if ($qbs =~ /^no hit$/i) {
      return $no_hit_label;
    } elsif ($qbs eq $rb) {
      return $same_as_ref_label;
    } else {
      return $qbs;
    }
  };       
}

1;

