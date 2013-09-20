package Circleator::FeatFunction::Label::position;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    my $start = $f->start();
    my $end = $f->end();
    return ($start == $end) ? $start : join('-', $start, $end);
  };
}


1;
