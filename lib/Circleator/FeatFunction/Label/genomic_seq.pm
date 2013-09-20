package Circleator::FeatFunction::Label::genomic_seq;

# reference base(s) derived directly from the underlying genomic sequence
sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    return $f->seq()->seq();
  };
}

1;

