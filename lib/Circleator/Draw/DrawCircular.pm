#!/usr/bin/perl

package Circleator::Draw::DrawCircular;

# Circular drawing routines

use strict;
use Carp;
use Circleator::Draw::Draw;

# coordinate system conversions
use Math::Trig ':radial';
use Math::Trig ':pi';
use POSIX qw (floor);

our @ISA = ('Circleator::Draw::Draw');

# where Math::Trig places the origin by default
my $MATH_TRIG_ORIGIN_DEGREES = 90;
my $QUADRANTS = {
                 '0' => 'tr',
                 '1' => 'br',
                 '2' => 'bl',
                 '3' => 'tl',
                };

# ------------------------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------------------------

sub new {
    my($invocant) = @_;
    my $class = ref($invocant) || $invocant;
    my $self = {};
    return bless $self, $class;
}

# ------------------------------------------------------------------
# DrawI
# ------------------------------------------------------------------

sub origin_degrees {
    my($self) = @_;
    return $MATH_TRIG_ORIGIN_DEGREES;
}

sub draw_rect {
  my($self, $svg, $fmin, $fmax, $sf, $ef, $pathAtts, $innerScale, $outerScale) = @_;
  my $seqlen = $self->seqlen();

  my $is_circle = ($fmax - $fmin) >= $seqlen;
  $fmin += $seqlen if ($fmin < 0);
  
  # convert fmin and fmax to appropriate inner/outer points on the circle
  # inner circle:
  my $restore_scale = $self->set_scale($innerScale);
  my($ix1, $iy1) = $self->coord_to_circle($fmin, $sf, $seqlen);
  my($ix2, $iy2) = $self->coord_to_circle($fmax, $sf, $seqlen);
  &$restore_scale();
  
  # outer circle:
  my $restore_scale = $self->set_scale($outerScale);
  my($ox1, $oy1) = $self->coord_to_circle($fmin, $ef, $seqlen);
  my($ox2, $oy2) = $self->coord_to_circle($fmax, $ef, $seqlen);
  &$restore_scale();
  
  # inner and outer radii
  my $ir = $self->radius() * $sf;
  my $or = $self->radius() * $ef;
  
  # special case: feature fills the entire circle
  # TODO - check whether a different approach is faster when there are many such features
  if ($is_circle) {
    # in this case 2 concentric circles are drawn and the region between them is filled
    my $circlePathAtts = {};
    my $fillAtts = {};
    foreach my $att (keys %$pathAtts) {
      my $val = $pathAtts->{$att};
      if ($att =~ /^fill/i) {
	$fillAtts->{$att} = $val;
      } else {
	$circlePathAtts->{$att} = $val;
      }
    }
    # inner and outer circles
    my $mask_id = $self->new_svg_id();
    # in the mask white is used to allow pixels through, black is used to mask them out
    my $mask = $svg->mask('id' => $mask_id, 'maskUnits' => 'userSpaceOnUse', 'x' => 0, 'y' => 0, 'width' => $self->svg_width(), 'height' => $self->svg_height());
    $mask->rect( 'x' => 0, 'y' => 0, 'width' => $self->svg_width(), 'height' => $self->svg_height(), 'r' => $ir, 'fill' => 'white');
    $mask->circle( 'cx' => $self->xoffset(), 'cy' => $self->yoffset(), 'r' => $ir, 'fill' => 'black', %$circlePathAtts);
    # outer circle with masked fill
    $pathAtts->{'mask'} = 'url(#' . $mask_id . ')';
    $svg->circle( 'cx' => $self->xoffset(), 'cy' => $self->yoffset(), 'r' => $or, 'fill' => 'none', %$pathAtts);
    # inner circle with no fill
    $svg->circle( 'cx' => $self->xoffset(), 'cy' => $self->yoffset(), 'r' => $ir, 'fill' => 'none', %$circlePathAtts);
  } else {
    # x-axis rotation; irrelevant unless rx != ry
    my $xar = 0; 
    # this must be set to 1 if the arc will be more than 180 degrees
    my $mod_fmax = $self->transform($fmax);
    my $mod_fmin = $self->transform($fmin);
    my $large_arc_flag = ((($mod_fmax-$mod_fmin)/$seqlen) <= 0.5) ? '0' : '1';
    #    print STDERR "drawing arc fmin=$fmin fmax=$fmax mod_fmax=$mod_fmax mod_fmin=$mod_fmin seqlen=$seqlen large_arc_flag=$large_arc_flag\n";
    # positive angle sweep
    my $sweep_flag = '1';
    my $unsweep_flag = '0';
    my $inner_arc = "A$ir,$ir $xar,$large_arc_flag,$sweep_flag $ix2,$iy2 ";
    my $outer_arc = "A$or,$or $xar,$large_arc_flag,$unsweep_flag $ox1,$oy1 ";
    my $pa = {
	      'd' => 
	      "M$ix1,$iy1 " .
	      $inner_arc .
	      "L$ox2,$oy2 " .
	      $outer_arc .
	      "L$ix1,$iy1 "
	     };
    map { $pa->{$_} = $pathAtts->{$_}; } keys %$pathAtts;
    my $p = $svg->path(%$pa);
  }
}


# Scale stroke width based on track height (and, if applicable, number of tiers.)
#  t_height - track height expressed as a radial fraction between 0 and 1
#  n_tiers - number of tiers: either undef or a number >= 0
#  stroke_width - stroke width before scaling
#
sub get_scaled_stroke_width {
  my($self, $t_height, $n_tiers, $stroke_width) = @_;
  $n_tiers = 1 if (!defined($n_tiers));
  $self->logger()->logdie("invalid number of tiers ($n_tiers)") if ($n_tiers < 0);
  my $effective_t_height = $t_height / $n_tiers;
  # everything is based off the (arbitrary) resolution at which a stroke width of 1 looks decent
  my $effective_t_height_px = $effective_t_height * $self->radius();
  my $scale_factor = $effective_t_height_px / $self->target_stroke_width_ratio();
  my $scaled_stroke_width = ($stroke_width * $scale_factor);

  if ($scaled_stroke_width < 0) {
    confess "got negative scaled stroke width: t_height=$t_height n_tiers=$n_tiers, stroke_width=$stroke_width, scale_factor=$scale_factor\n";
    die;
  }

  return $scaled_stroke_width;
}

# $is_reversed - whether to draw arrow in counterclockwise direction
sub draw_curved_line {
  my($self, $svg, $fmin, $fmax, $is_reversed, $sf, $ef, $pathAtts, $innerScale, $outerScale) = @_;
  my $seqlen = $self->seqlen();

  $fmin += $seqlen if ($fmin < 0);
  $fmax += $seqlen if ($fmax < $fmin);

  # radius
  my $sr = $self->radius() * $sf;
  my $er = $self->radius() * $ef;

  # convert fmin and fmax to points on the circle
  my $restore_scale = $self->set_scale($innerScale);
  my($x1, $y1) = $self->coord_to_circle($fmin, $sf, $seqlen);
  my($x2, $y2) = $self->coord_to_circle($fmax, $ef, $seqlen);
  &$restore_scale();

  # x-axis rotation; irrelevant unless rx != ry
  my $xar = 0; 
  # this must be set to 1 if the arc will be more than 180 degrees
  my $mod_fmax = $self->transform($fmax);
  my $mod_fmin = $self->transform($fmin);
  my $large_arc_flag = ((($mod_fmax-$mod_fmin)/$seqlen) <= 0.5) ? '0' : '1';
  # positive angle sweep
  my $sweep_flag = '1';
  my $inner_arc = "A$sr,$er $xar,$large_arc_flag,$sweep_flag $x2,$y2 ";
  my $pa = { 'd' => "M$x1,$y1 " . $inner_arc };
  map { $pa->{$_} = $pathAtts->{$_}; } keys %$pathAtts;
  my $p = $svg->path(%$pa);
}

sub draw_radial_line {
  my($self, $svg, $fmin, $sf, $ef, $pathAtts) = @_;
  my $seqlen = $self->seqlen();
  my($x1, $y1) = $self->coord_to_circle($fmin, $sf, $seqlen);
  my($x2, $y2) = $self->coord_to_circle($fmin, $ef, $seqlen);
  $svg->line('x1' => $x1, 'y1' => $y1, 'x2' => $x2, 'y2' => $y2, %$pathAtts);
}

# TODO - Roll this into the general track labeling mechanism.

# Draws a circle at $sf and tick marks from $sf to $ef.  Outside $ef coordinate labels will be drawn.
# label_type must be one of the following:
#   horizontal - labels are draw horizontally 
#   spoke - labels are drawn as spokes radiating out from the outside of the circle
#   curved - labels are drawn wrapped around the outside of the circle
#
sub draw_coordinate_labels {
  my($self, $group, $seq, $contig_positions, $richseq, $track, $all_tracks, $config) = @_;
  $self->logger()->debug("draw_coordinate_labels begin");
  my $seqlen = $self->seqlen();
  my($feat_type, $glyph, $sf, $ef, $tickInterval, $labelInterval, $labelType, 
     $labelUnits, $labelPrecision, $fontSize, $noCircle,
     # optionally restrict the label and tick drawing to a specific interval defined by $fmin - $fmax
    $fmin, $fmax) = 
    map { $track->{$_} } ('feat-type', 'glyph', 'start-frac', 'end-frac', 'tick-interval', 
                          'label-interval', 'label-type', 'label-units', 'label-precision', 'font-size', 'no-circle', 'fmin', 'fmax');

  if (!defined($labelType)) {
    $labelType = $self->default_coord_label_type();
  } 
  if ($labelType !~ /^horizontal|spoke|curved$/) {
    $self->logger()->logdie("unsupported label_type of $labelType requested: only horizontal, spoke, and curved are supported");
  }
  $labelUnits = "Mb" if (!defined($labelUnits));
  $labelPrecision = "1" if (!defined($labelPrecision));

  $fmin = 0 if (!defined($fmin) || ($fmin < 0));
  $fmax = $seqlen if (!defined($fmax) || ($fmax > $seqlen));
  my $seqIntLen = ($fmax - $fmin);

  # TODO - print warnings if tickInterval and/or labelInterval result in either too few or too many ticks/labels
  my $nTicks = defined($tickInterval) ? ($seqIntLen / $tickInterval) : 0;
  my $nLabels = defined($labelInterval) ? ($seqIntLen / $labelInterval) : 0;
  my $radial_height = $ef - $sf;
  my ($sw1, $sw2, $sw3) = map { $self->get_scaled_stroke_width($radial_height, 1, $_) } (200,100,400);
  $fontSize = $self->default_ruler_font_size() if (!defined($fontSize));

  # draw circle at $sf
  # TODO - not clear whether it's better to draw the entire circle or just the arc, if fmin-fmax != 0-seqlen
  my $r = $sf * $self->radius();
  $group->circle( 'cx' => $self->xoffset(), 'cy' => $self->yoffset(), 'r' => $r, 'stroke' => 'black', 'stroke-width' => $sw1, 'fill' => 'none' ) unless ($noCircle);

  my $getTickOrLabelIndices = sub {
    my($fmin, $fmax, $interval) = @_;
    my $start_ind = floor($fmin / $interval);
    my $start_posn = $start_ind * $interval;
    ++$start_ind if ($start_posn < $fmin);
    my $end_ind = floor($fmax / $interval);
    $self->logger()->debug("converted fmin=$fmin, fmax=$fmax, interval=$interval to start_ind=$start_ind, end_ind=$end_ind") if ($self->debug_opt('coordinates'));
    return ($start_ind, $end_ind);
  };

  $self->logger()->debug("draw_coordinate_labels - tick drawing begin");
  if ((defined($tickInterval)) && ($seqIntLen >= 0)) {
    my($first_tick_ind, $last_tick_ind) = &$getTickOrLabelIndices($fmin, $fmax, $tickInterval);
    $self->logger()->debug("first_tick_ind=$first_tick_ind last_tick_ind=$last_tick_ind");
    for (my $t = $first_tick_ind;$t <= $last_tick_ind;++$t) {
      my $pos = $tickInterval * $t;
      my($ix1, $iy1) = $self->coord_to_circle($pos, $sf, $seqlen);
      my($ox1, $oy1) = $self->coord_to_circle($pos, $ef, $seqlen);
      $group->line('x1' => $ix1, 'y1' => $iy1, 'x2' => $ox1, 'y2' => $oy1, 'stroke' => 'black', 'stroke-width' => $sw2);
    }
  }
  $self->logger()->debug("draw_coordinate_labels - tick drawing done");

  my $tef = $ef + ($ef - $sf);
  my $tef2 = $ef + (($ef - $sf) * 2);
  my $er = $tef2 * $self->radius();

  # circular paths (left side and right side) for curved text layout
  my $circlePathId = undef;
  if ($labelType eq 'curved') {
    $circlePathId = "cp" . $self->new_svg_id();
    my($bx,$by,$tx,$ty) = ($self->xoffset(),$self->yoffset()+$er,$self->xoffset(),$self->yoffset()-$er);
    my($lx,$ly,$rx,$ry) = ($self->xoffset()-$er,$self->yoffset(),$self->xoffset()+$er,$self->yoffset());
    my $xar = -$self->origin_degrees();

    # circle starts at 9 o'clock and then goes for 450 degrees
    # this allows rendering labels that cross the origin.  90 degrees will be added to compensate
    my $cp = $group->path('id' => $circlePathId,
                          'd' =>
                          "M${lx},${ly} " .
                          "A$er,$er $xar,1,1 ${bx},${by} " .
                          "A$er,$er $xar,1,1 ${tx},${ty} ",
                          'fill' => "none",
                          'stroke' => "none");
  }

  my $ft_offset = pi2 * $er * (($self->origin_degrees() + $self->rotate_degrees())/360.0);

  $self->logger()->debug("draw_coordinate_labels - coordinate labeling begin");
  if ((defined($labelInterval)) && ($seqIntLen >= 0)) {
    my($first_label_ind, $last_label_ind) = &$getTickOrLabelIndices($fmin, $fmax, $labelInterval);
    for (my $l = $first_label_ind;$l <= $last_label_ind; ++$l) {
      my $pos = $labelInterval * $l;
      my($ix1, $iy1) = $self->coord_to_circle($pos, $sf, $seqlen);
      my($ox1, $oy1) = $self->coord_to_circle($pos, $tef, $seqlen);
      my($oox1, $ooy1) = $self->coord_to_circle($pos, $tef2, $seqlen);
      
      # draw larger tick
      $group->line('x1' => $ix1, 'y1' => $iy1, 'x2' => $ox1, 'y2' => $oy1, 'stroke' => 'black', 'stroke-width' => $sw3);
      my $deg = $self->coord_to_degrees($pos);
      my $quad = $self->coord_to_quadrant($pos);
      $self->logger()->debug("mapped pos=$pos to deg=$deg quad=$quad") if ($self->debug_opt('coordinates'));
      
      # anchor left side labels at the end, right side labels at the start
      my $anchor = ($quad =~ /l$/) ? "end" : "start";
      # shift labels down if they're in the bottom quadrants
      $ooy1 += ($fontSize * $self->font_baseline_frac()) if ($quad =~ /^b/);
      
      my $coordLabel = undef;
      if ($labelUnits =~ /^gb$/i) {
        $coordLabel = sprintf("%.${labelPrecision}f", $pos/1000000000.0) . "Gb";
      } elsif ($labelUnits =~ /^mb$/i) {
        $coordLabel = sprintf("%.${labelPrecision}f", $pos/1000000.0) . "Mb";
      } elsif ($labelUnits =~ /^kb$/i) {
        $coordLabel = sprintf("%.${labelPrecision}f", $pos/1000.0) . "kb";
      } else {
        $coordLabel = sprintf("%.${labelPrecision}f", $pos) . "bp";
      }
      
      if ($labelType eq 'horizontal') {
        $group->text('x' => $oox1, 'y' => $ooy1, 'text-anchor' => $anchor, 'font-size' => $fontSize, 'font-weight' => 'bold')->cdata($coordLabel);
      } elsif ($labelType eq 'spoke') {
        my $tg = $group->group( 'transform' => "translate($oox1, $ooy1)");
        my $tr = $deg - 90;
        $tr += 180 if ($quad =~ /l$/);
        $tg->text('x' => 0, 'y' => 0, 'text-anchor' => $anchor, 'font-size' => $fontSize, 'font-weight' => 'bold', 'transform' => "rotate($tr)")->cdata($coordLabel);
      } elsif ($labelType eq 'curved') {
        # select left or right path depending on quadrant
        my $cpid = undef;
        # calculate translation needed to put the label in the right place
        my $mod_pos = $self->transform($pos);
        $self->logger()->debug("converted pos=$pos to mod_pos=$mod_pos") if ($self->debug_opt('coordinates'));
        my $ft = pi2 * $er * ($mod_pos/$seqlen) + $ft_offset;
        my $txt = $group->text('x' => $ft, 'y' => 0, 'text-anchor' => 'middle', 'font-size' => $fontSize, 'font-weight' => 'bold');
        $txt->textPath('xlink:href' => "#" . $circlePathId)->cdata($coordLabel);
      }
    }
  }
  $self->logger()->debug("draw_coordinate_labels - coordinate labeling end");
  $self->logger()->debug("draw_coordinate_labels end");
}

# $is_reversed - whether to draw arrow in counterclockwise direction
sub draw_curved_arrow {
  my($self, $svg, $fmin, $fmax, $is_reversed, $sf, $ef, $pathAtts, $innerScale, $outerScale) = @_;
  my $seqlen = $self->seqlen();
  my $is_circle = ($fmax - $fmin) >= $seqlen;
  $fmin += $seqlen if ($fmin < 0);
  $fmax += $seqlen if ($fmax < $fmin);

  my $marker = $is_reversed ? "triangle-left" : "triangle-right";
  my $marker_posn = $is_reversed ? "start" : "end";
  $self->logger()->logdie("draw_curved_arrow has fmin($fmin) > fmax($fmax)") if ($fmin > $fmax);
  
  # radius
  my $mf = ($sf + $ef) / 2.0;
  my $mr = $self->radius() * $mf;

  # convert fmin and fmax to points on the circle
  my $restore_scale = $self->set_scale($innerScale);
  my($x1, $y1) = $self->coord_to_circle($fmin, $mf, $seqlen);
  my($x2, $y2) = $self->coord_to_circle($fmax, $mf, $seqlen);
  &$restore_scale();

  # special case: feature fills the entire circle
  if ($is_circle) {
    $svg->circle( 'cx' => $self->xoffset(), 'cy' => $self->yoffset(), 'r' => $mr, 'fill' => 'none', %$pathAtts);
    # TODO - add arrow at the appropriate location
    $self->logger()->logdie("draw_curved_arrow does not yet support features > seqlen");
  } 
  else {
    # x-axis rotation; irrelevant unless rx != ry
    my $xar = 0; 
    # this must be set to 1 if the arc will be more than 180 degrees
    my $mod_fmax = $self->transform($fmax);
    my $mod_fmin = $self->transform($fmin);
    my $large_arc_flag = ((($mod_fmax-$mod_fmin)/$seqlen) <= 0.5) ? '0' : '1';
#    print STDERR "drawing arc mod_fmax=$mod_fmax mod_fmin=$mod_fmin seqlen=$seqlen large_arc_flag=$large_arc_flag\n";
    # positive angle sweep
    my $sweep_flag = '1';
    my $inner_arc = "A$mr,$mr $xar,$large_arc_flag,$sweep_flag $x2,$y2 ";

    my $pa = { 'd' => "M$x1,$y1 " . $inner_arc, "marker-${marker_posn}" => "url(#${marker})" };
    map { $pa->{$_} = $pathAtts->{$_}; } keys %$pathAtts;
    my $p = $svg->path(%$pa);
  }
}

# ------------------------------------------------------------------
# DrawCircular
# ------------------------------------------------------------------

# Map linear sequence coordinate to a number of degrees between 0 and 360
#
sub coord_to_degrees {
  my($self, $coord, $correction) = @_;
  my $seqlen = $self->seqlen();
  $correction = 0 if (!defined($correction));
  die "no transform defined" if (!defined($self->get_transform()));
  my $mod_coord = $self->transform($coord);
  my $deg = (($mod_coord/$seqlen) * 360.0);
  # take current rotation into account
  $deg += ($self->rotate_degrees() + $correction);
  # don't use %, because we want this to stay a floating point value
  while ($deg < 0) { $deg += 360; }
  while ($deg > 360) { $deg -= 360; }
  return $deg;
}

# Map linear coordinate plus distance from circle center (0-1) to a point on the circle.
#
sub coord_to_circle {
  my($self, $coord, $center_dist) = @_;
  my $seqlen = $self->seqlen();
  my $rho = $center_dist * $self->radius();
  my $deg = $self->coord_to_degrees($coord, -$self->origin_degrees());
  my $theta = Math::Trig::deg2rad($deg);
  my($x, $y, $z) = cylindrical_to_cartesian($rho, $theta, 0);
  return ($x + $self->xoffset(), $y + $self->yoffset());
}

# Convert linear sequence coordinate to a quadrant:
#  'tr' - top right
#  'tl' - top left
#  'bl' - bottom left
#  'br' - bottom right
#
sub coord_to_quadrant {
  my($self, $coord) = @_;
  my $seqlen = $self->seqlen();
  my $deg = $self->coord_to_degrees($coord);
  # don't use %, because we want this to stay a floating point value
  my $dn = $deg;
  while ($dn < 0) { $dn += 360; }
  while ($dn > 360) { $dn -= 360; }
  die "unexpected dn=$dn" if (($dn < 0) || ($dn > 360));
  my $quad = int($dn / 90.0) % 4;
  die "unexpected quad=$quad for dn=$dn" if (($quad <0) || ($quad > 3));
  return $QUADRANTS->{$quad};
}

1;
