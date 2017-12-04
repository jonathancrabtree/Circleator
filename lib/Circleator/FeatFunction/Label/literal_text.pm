package Circleator::FeatFunction::Label::literal_text;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    my $text = $track->{'text'};

    # HACK - code duplicated from Circleator::Config::Standard
    $text =~ s/\&nbsp\;/ /g;
    $text =~ s/\&equals\;/=/g;
    $text =~ s/\&comma\;/,/g;

    return $text;
  };
}

1;
