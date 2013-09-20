package Circleator::FeatFunction::Label::rRNA_product;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    if ($f->has_tag('product')) {
      my @prods = $f->get_tag_values('product');
      my $rp = $prods[0];
      $rp =~ s/^(\d+S) ribosomal RNA/$1 rRNA/;
      return $rp;
    }
    return undef;
  };
}

1;
