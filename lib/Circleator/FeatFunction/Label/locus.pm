package Circleator::FeatFunction::Label::locus;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    if ($f->has_tag('locus_tag')) {
      my @prods = $f->get_tag_values('locus_tag');
      return $prods[0];
    }
    return undef;
  };
}

1;
