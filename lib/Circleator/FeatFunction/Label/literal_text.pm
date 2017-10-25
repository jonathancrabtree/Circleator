package Circleator::FeatFunction::Label::literal_text;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    return $track->{'text'};
  };
}

1;
