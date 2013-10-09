package Circleator::Util::Colors;

use strict;

use FileHandle;

$Circleator::Util::Colors::SVG_COLORS_H = undef;
$Circleator::Util::Colors::BREWER_COLORS_H = undef;

# ------------------------------------------------------------------
# Static methods
# ------------------------------------------------------------------

sub get_svg_colors_h {
  if (!defined($Circleator::Util::Colors::SVG_COLORS_H)) {
    my $sch = $Circleator::Util::Colors::SVG_COLORS_H = {};
    my $lnum = 0;
    while (my $line = <Circleator::Util::Colors::DATA>) {
      chomp($line);
      ++$lnum;
      if ($line =~ /^\s+\.(\S+) \{ background: rgb\(\s*(\d+)\s*\,\s*(\d+)\s*\,\s*(\d+)\s*\)/) {
        $sch->{$1} = [$2,$3,$4];
      } else {
        die "parse error at line $lnum of DATA segment: $line";
      }
    }
  }
  return $Circleator::Util::Colors::SVG_COLORS_H;
}

# Parse Brewer color palette file downloaded from http://mkweb.bcgsc.ca/brewer/swatches/brewer.txt
# and based on the colors at www.colorbrewer.org
# 
sub get_brewer_colors_h {
  my($logger, $conf_dir) = @_;

  if (!defined($Circleator::Util::Colors::BREWER_COLORS_H)) {
    my $ph = $Circleator::Util::Colors::BREWER_COLORS_H = {};
    my $brewer_file = File::Spec->catfile($conf_dir, 'brewer.txt');
    my $fh = FileHandle->new();
    $fh->open($brewer_file) || $logger->logdie("unable to read from Brewer color palette file $brewer_file");
    my $lnum = 0;
    while (my $line = <$fh>) {
      chomp($line);
      ++$lnum;
      next if ($line =~ /^\s*$/);
      next if ($line =~ /^\#/);
      if ($line =~ /^([^\-]+)\-(\d+)\-(qual|seq|div)\-(\d+|[a-z]) = (\d+)\,(\d+)\,(\d+) \#(\s+[\d\.]+)?\s*$/) {
        my($prefix, $ncols, $type, $seq, $r, $g, $b, $crit) = ($1, $2, $3, $4, $5, $6, $7, $8, $9);
        # change order to make a more sensible name (e.g., bupu-seq-9 vs. bupu-9-seq)
        my $name = join('-', $prefix, $type, $ncols);
        next if ($seq =~ /^[a-z]$/);
        my $p = $ph->{$name};
        $p = $ph->{$name} = { 'colors' => [], 'critical_num' => $crit, 'num_colors' => $ncols, 'type' => $type } if (!defined($p));
        my $sn = scalar(@{$p->{'colors'}}) + 1;
        # check the sequence number
        $logger->error("out of order color at line $lnum of $brewer_file ($seq not $sn): $line") if ($sn != $seq);
        push(@{$p->{'colors'}}, "rgb(" . join(',', ($r,$g,$b)) . ")");
      }
      else {
        $logger->logdie("error parsing line $lnum of $brewer_file: $line");
      }
    }
    $fh->close();

    # check that each palette contains the correct number of colors
    my @bp = grep(!/\-\d+\-\d+$/, keys %$ph);
    foreach my $bpn (@bp) {
      my $bp = $ph->{$bpn};
      my($colors, $num_colors, $cnum, $type) = map { $bp->{$_} } ('colors', 'num_colors', 'critical_num', 'type');
      my $nc = scalar(@$colors);
      $logger->error("Brewer palette $bpn only has $nc color(s), not $num_colors") if ($nc != $num_colors);

      # add _reverse_ of the palette, plus the individual colors
      my @rev_colors = reverse @$colors;
      $ph->{$bpn . "-rev"} = { 'colors' => \@rev_colors, 'critical_num' => $cnum, 'num_colors' => $num_colors, 'type' => $type };
    }
  }

  return $Circleator::Util::Colors::BREWER_COLORS_H;
}

sub get_brewer_palette {
  my($logger, $conf_dir, $name) = @_;
  my $bph = &get_brewer_colors_h($logger, $conf_dir);
  my $bp = $bph->{$name};
  $logger->error("could not find Brewer palette named '$name': available options are " . join(',', grep(!/\-\d+\-\d+$/, keys %$bph))) if (!defined($bp));
  return $bp;
}

sub get_brewer_color {
  my($logger, $conf_dir, $name) = @_;
  my $bph = &get_brewer_colors_h($logger, $conf_dir);
  my $bp = $bph->{$name};
  $logger->error("could not find Brewer color named '$name': available options are " . join(',', grep(/\-\d+\-\d+$/, keys %$bph))) if (!defined($bp));
  return $bp;
}

# Convert a Circleator color string to an [r,g,b] listref where r,g, and b are in the range [0,255]
#
sub string_to_rgb {
  my($logger, $conf_dir, $cspec) = @_;
  my $ch = &get_svg_colors_h();
  my $bph = &get_brewer_colors_h($logger, $conf_dir);

  # trim leading and trailing whitespace
  $cspec =~ s/^\s*(.*)\s*$/$1/;
  my $svg_c = $ch->{$cspec};
  my $b_c = $bph->{$cspec};

  # check if it's a predefined SVG color
  if (defined($svg_c)) {
    return $svg_c;
  }
  # or predefined color from the Brewer color palettes
  elsif (defined($b_c)) {
    return $b_c;
  }
  # HTML-style color spec like "#ff0000"
  elsif ($cspec =~ /^\#([0-9abcdef]{2})([0-9abcdef]{2})([0-9abcdef]{2})$/i) {
    my($r,$g,$b) = map { hex($_) } ($1,$2,$3);
    return [$r, $g, $b];
  } 
  # SVG color spec like "rgb(0,255,30)"
  elsif ($cspec =~ /^rgb\(\s*(\d+)\s*\,\s*(\d+)\s*\,\s*(\d+)\s*\)$/) {
    return [$1,$2,$3];
  }
  # don't know what it is
  else {
    return undef;
  }
}

1;

__DATA__
    .aliceblue { background: rgb(240, 248, 255) }
    .antiquewhite { background: rgb(250, 235, 215) }
    .aqua { background: rgb( 0, 255, 255); }
    .aquamarine { background: rgb(127, 255, 212) }
    .azure { background: rgb(240, 255, 255) }
    .beige { background: rgb(245, 245, 220) }
    .bisque { background: rgb(255, 228, 196) }
    .black { background: rgb( 0, 0, 0) }
    .blanchedalmond { background: rgb(255, 235, 205) }
    .blue { background: rgb( 0, 0, 255) }
    .blueviolet { background: rgb(138, 43, 226) }
    .brown { background: rgb(165, 42, 42) }
    .burlywood { background: rgb(222, 184, 135) }
    .cadetblue { background: rgb( 95, 158, 160) }
    .chartreuse { background: rgb(127, 255, 0) }
    .chocolate { background: rgb(210, 105, 30) }
    .coral { background: rgb(255, 127, 80) }
    .cornflowerblue { background: rgb(100, 149, 237) }
    .cornsilk { background: rgb(255, 248, 220) }
    .crimson { background: rgb(220, 20, 60) }
    .cyan { background: rgb( 0, 255, 255) }
    .darkblue { background: rgb( 0, 0, 139) }
    .darkcyan { background: rgb( 0, 139, 139) }
    .darkgoldenrod { background: rgb(184, 134, 11) }
    .darkgray { background: rgb(169, 169, 169) }
    .darkgreen { background: rgb( 0, 100, 0) }
    .darkgrey { background: rgb(169, 169, 169) }
    .darkkhaki { background: rgb(189, 183, 107) }
    .darkmagenta { background: rgb(139, 0, 139) }
    .darkolivegreen { background: rgb( 85, 107, 47) }
    .darkorange { background: rgb(255, 140, 0) }
    .darkorchid { background: rgb(153, 50, 204) }
    .darkred { background: rgb(139, 0, 0) }
    .darksalmon { background: rgb(233, 150, 122) }
    .darkseagreen { background: rgb(143, 188, 143) }
    .darkslateblue { background: rgb( 72, 61, 139) }
    .darkslategray { background: rgb( 47, 79, 79) }
    .darkslategrey { background: rgb( 47, 79, 79) }
    .darkturquoise { background: rgb( 0, 206, 209) }
    .darkviolet { background: rgb(148, 0, 211) }
    .deeppink { background: rgb(255, 20, 147) }
    .deepskyblue { background: rgb( 0, 191, 255) }
    .dimgray { background: rgb(105, 105, 105) }
    .dimgrey { background: rgb(105, 105, 105) }
    .dodgerblue { background: rgb( 30, 144, 255) }
    .firebrick { background: rgb(178, 34, 34) }
    .floralwhite { background: rgb(255, 250, 240) }
    .forestgreen { background: rgb( 34, 139, 34) }
    .fuchsia { background: rgb(255, 0, 255) }
    .gainsboro { background: rgb(220, 220, 220) }
    .ghostwhite { background: rgb(248, 248, 255) }
    .gold { background: rgb(255, 215, 0) }
    .goldenrod { background: rgb(218, 165, 32) }
    .gray { background: rgb(128, 128, 128) }
    .grey { background: rgb(128, 128, 128) }
    .green { background: rgb( 0, 128, 0) }
    .greenyellow { background: rgb(173, 255, 47) }
    .honeydew { background: rgb(240, 255, 240) }
    .hotpink { background: rgb(255, 105, 180) }
    .indianred { background: rgb(205, 92, 92) }
    .indigo { background: rgb( 75, 0, 130) }
    .ivory { background: rgb(255, 255, 240) }
    .khaki { background: rgb(240, 230, 140) }
    .lavender { background: rgb(230, 230, 250) }
    .lavenderblush { background: rgb(255, 240, 245) }
    .lawngreen { background: rgb(124, 252, 0) }
    .lemonchiffon { background: rgb(255, 250, 205) }
    .lightblue { background: rgb(173, 216, 230) }
    .lightcoral { background: rgb(240, 128, 128) }
    .lightcyan { background: rgb(224, 255, 255) }
    .lightgoldenrodyellow { background: rgb(250, 250, 210) }
    .lightgray { background: rgb(211, 211, 211) }
    .lightgreen { background: rgb(144, 238, 144) }
    .lightgrey { background: rgb(211, 211, 211) }
    .lightpink { background: rgb(255, 182, 193) }
    .lightsalmon { background: rgb(255, 160, 122) }
    .lightseagreen { background: rgb( 32, 178, 170) }
    .lightskyblue { background: rgb(135, 206, 250) }
    .lightslategray { background: rgb(119, 136, 153) }
    .lightslategrey { background: rgb(119, 136, 153) }
    .lightsteelblue { background: rgb(176, 196, 222) }
    .lightyellow { background: rgb(255, 255, 224) }
    .lime { background: rgb( 0, 255, 0) }
    .limegreen { background: rgb( 50, 205, 50) }
    .linen { background: rgb(250, 240, 230) }
    .magenta { background: rgb(255, 0, 255) }
    .maroon { background: rgb(128, 0, 0) }
    .mediumaquamarine { background: rgb(102, 205, 170) }
    .mediumblue { background: rgb( 0, 0, 205) }
    .mediumorchid { background: rgb(186, 85, 211) }
    .mediumpurple { background: rgb(147, 112, 219) }
    .mediumseagreen { background: rgb( 60, 179, 113) }
    .mediumslateblue { background: rgb(123, 104, 238) }
    .mediumspringgreen { background: rgb( 0, 250, 154) }
    .mediumturquoise { background: rgb( 72, 209, 204) }
    .mediumvioletred { background: rgb(199, 21, 133) }
    .midnightblue { background: rgb( 25, 25, 112) }
    .mintcream { background: rgb(245, 255, 250) }
    .mistyrose { background: rgb(255, 228, 225) }
    .moccasin { background: rgb(255, 228, 181) }
    .navajowhite { background: rgb(255, 222, 173) }
    .navy { background: rgb( 0, 0, 128) }
    .oldlace { background: rgb(253, 245, 230) }
    .olive { background: rgb(128, 128, 0) }
    .olivedrab { background: rgb(107, 142, 35) }
    .orange { background: rgb(255, 165, 0) }
    .orangered { background: rgb(255, 69, 0) }
    .orchid { background: rgb(218, 112, 214) }
    .palegoldenrod { background: rgb(238, 232, 170) }
    .palegreen { background: rgb(152, 251, 152) }
    .paleturquoise { background: rgb(175, 238, 238) }
    .palevioletred { background: rgb(219, 112, 147) }
    .papayawhip { background: rgb(255, 239, 213) }
    .peachpuff { background: rgb(255, 218, 185) }
    .peru { background: rgb(205, 133, 63) }
    .pink { background: rgb(255, 192, 203) }
    .plum { background: rgb(221, 160, 221) }
    .powderblue { background: rgb(176, 224, 230) }
    .purple { background: rgb(128, 0, 128) }
    .red { background: rgb(255, 0, 0) }
    .rosybrown { background: rgb(188, 143, 143) }
    .royalblue { background: rgb( 65, 105, 225) }
    .saddlebrown { background: rgb(139, 69, 19) }
    .salmon { background: rgb(250, 128, 114) }
    .sandybrown { background: rgb(244, 164, 96) }
    .seagreen { background: rgb( 46, 139, 87) }
    .seashell { background: rgb(255, 245, 238) }
    .sienna { background: rgb(160, 82, 45) }
    .silver { background: rgb(192, 192, 192) }
    .skyblue { background: rgb(135, 206, 235) }
    .slateblue { background: rgb(106, 90, 205) }
    .slategray { background: rgb(112, 128, 144) }
    .slategrey { background: rgb(112, 128, 144) }
    .snow { background: rgb(255, 250, 250) }
    .springgreen { background: rgb( 0, 255, 127) }
    .steelblue { background: rgb( 70, 130, 180) }
    .tan { background: rgb(210, 180, 140) }
    .teal { background: rgb( 0, 128, 128) }
    .thistle { background: rgb(216, 191, 216) }
    .tomato { background: rgb(255, 99, 71) }
    .turquoise { background: rgb( 64, 224, 208) }
    .violet { background: rgb(238, 130, 238) }
    .wheat { background: rgb(245, 222, 179) }
    .white { background: rgb(255, 255, 255) }
    .whitesmoke { background: rgb(245, 245, 245) }
    .yellow { background: rgb(255, 255, 0) }
    .yellowgreen { background: rgb(154, 205, 50) }
