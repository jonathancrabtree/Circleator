package Circleator::FeatFunction::Color::regex_list;

sub get_function {
  my($track, $tname) = @_;
  # HACK
  my $ctype = ($tname =~ /fill/) ? "color1" : "color2";
  
  my @regexes = split(/\|/, $track->{$ctype . '-regexes'});
  my @colors = split(/\|/, $track->{$ctype . '-colors'});
  my @min_lens = split(/\|/, $track->{$ctype . '-min-lengths'});
  my @max_lens = split(/\|/, $track->{$ctype . '-max-lengths'});
  my $attribute = $track->{$ctype . '-attribute'} || 'display_name';
  my $default = $track->{$ctype . '-default'} || 'none';
  my $nr = scalar(@regexes);
  
  #     print STDERR "regex_list selected with colors=" . join(',', @colors) . ", attribute=$attribute, max_lens=" . join(',', @max_lens). ", default=$default\n";
  map { delete $track->{$ctype . '-' . $_} } ('regexes', 'colors', 'min-lengths', 'max-lengths', 'attribute');
  
  return sub {
    my $f = shift;
    #       print STDERR "getting color for " . $f->primary_id() . "/" . $f->display_name() . ", attribute=$attribute\n";
    my $att = undef;
    
    if ($attribute eq 'display_name') {
      $att = $f->display_name();
    } elsif ($attribute eq 'product') {
      if ($f->has_tag('product')) {
        my @tv = $f->get_tag_values('product');
        my $ntv = scalar(@tv);
        die "unexpected number of tag values $ntv for " . $f->display_name() if ($ntv != 1);
        $att = $tv[0];
      }
    } else {
      die "unknown attribute '$attribute'";
    }
    #       print STDERR "matching $att against regexes " . join(',', @regexes). " and colors " . join(',', @colors) . ", default=$default\n";
    
    my $color = undef;
    for (my $i = 0;$i < $nr;++$i) {
      my $regex = $regexes[$i];
      
      if ($att =~ /$regex/) {
        my $min = $min_lens[$i];
        my $max = $max_lens[$i];
        #           print STDERR "match to regex $regex, min=$min, max=$max\n";
        my $flen = $f->seq()->length();
        my $gt_min = ((!defined($min)) || ($min eq '') || ($flen >= $min));
        my $lt_max = ((!defined($max)) || ($max eq '') || ($flen <= $max));
        if ($gt_min && $lt_max) {
          $color = $colors[$i];
          #             print STDERR "set color $ctype to $colors[$i] for att='$att', flen=$flen\n";
          last;
        }
      }
    }
    $color = $default if (!defined($color) || ($color eq ''));
    return $color;
  };
}

1;

