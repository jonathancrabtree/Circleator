package Circleator::FeatFunction::Label::length_kb;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    my $start = $f->start();
    my $end = $f->end();
    my $length = undef;
    if ($end >= $start) {
	$length = $end - $start + 1;
    } else {
	my $seqlen = $f->entire_seq->length();
	$length = ($seqlen - $start) + $end + 1;
    }
    return sprintf("%0.1f", $length/1000) . "kb";
  };
}

1;
