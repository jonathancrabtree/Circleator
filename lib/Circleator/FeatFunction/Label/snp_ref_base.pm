package Circleator::FeatFunction::Label::snp_ref_base;

use Circleator::Parser::SNP;

my $SNP = Circleator::Parser::SNP->new();
my $SNP_TP = $SNP->tag_prefix();
my $SNP_TBTP = $SNP->target_base_tag_prefix();

# Generate label with the reference sequence base at the SNP position
sub get_function {     
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    my @r_bases = $f->get_tag_values($SNP_TP . 'ref_base');
    return $r_bases[0];
  };       
}

1;

