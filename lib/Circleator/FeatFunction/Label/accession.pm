package Circleator::FeatFunction::Label::accession;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    return $f->accession();
  };
}

1;
