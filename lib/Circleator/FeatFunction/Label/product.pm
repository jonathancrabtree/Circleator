package Circleator::FeatFunction::Label::product;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    if ($f->has_tag('product')) {
      my @prods = $f->get_tag_values('product');
      return $prods[0];
    }
    return undef;
  };
}

1;
