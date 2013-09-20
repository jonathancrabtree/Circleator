package Circleator::FeatFunction::Label::length_bp;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    my $start = $f->start();
    my $end = $f->end();
    my $length = $end - $start + 1;
    return $length . "bp";
  };
}

1;
