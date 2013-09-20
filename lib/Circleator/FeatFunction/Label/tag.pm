package Circleator::FeatFunction::Label::tag;

sub get_function {
  my($track, $tname) = @_;
  # BioPerl tag name
  my $tag = $track->{'tag-name'};
  # string to use to join multiple tag values
  my $separator = $track->{'tag-value-separator'};
  # whether to use only the first value
  my $ignore_multiple_values = $track->{'tag-ignore-multiple-values'};

  # defaults
  $separator = ',' if (!defined($separator));

  return sub {
    my $f = shift;
    if (defined($tag) && ($f->has_tag($tag))) {
      my @vals = $f->get_tag_values($tag);
      if ($ignore_multiple_values) {
        return $vals[0];
      } else {
        return join($separator, @vals);
      }
    }
    return undef;
  };
}

1;
