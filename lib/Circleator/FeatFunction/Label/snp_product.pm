package Circleator::FeatFunction::Label::snp_product;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    my @prods = $f->get_tag_values('SNP_product');
    return $prods[0];
  };
}

1;
