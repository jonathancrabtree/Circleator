package Circleator::FeatFunction::Label::id;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    return $f->id();
  };
}

1;
