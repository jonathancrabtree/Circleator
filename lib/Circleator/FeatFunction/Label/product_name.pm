package Circleator::FeatFunction::Label::product_name;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    if ($f->has_tag('product')) {
      my @prods = $f->get_tag_values('product');
      return $prods[0];
    }
    elsif ($f->has_tag('product_name')) {
      my @prods = $f->get_tag_values('product_name');
      return $prods[0];
    }
    return undef;
  };
}

1;
