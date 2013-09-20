package Circleator::FeatFunction::Label::primary_id;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    return $f->primary_id();
  };
}

1;
