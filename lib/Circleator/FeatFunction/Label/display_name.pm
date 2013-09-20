package Circleator::FeatFunction::Label::display_name;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    return $f->display_name();
  };
}

1;
