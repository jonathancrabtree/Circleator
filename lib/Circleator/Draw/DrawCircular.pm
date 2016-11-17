#!/usr/bin/perl

package Circleator::Draw::DrawCircular;

# Circular drawing routines

use strict;
use Circleator::Draw::Draw;

# coordinate system conversions
use Math::Trig ':radial';
use Math::Trig ':pi';

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
  my($ix1, $iy1) = $self->bp_to_xy($fmin, $sf);
  my($ix2, $iy2) = $self->bp_to_xy($fmax, $sf);
  &$restore_scale();
  
  # outer circle:
  my $restore_scale = $self->set_scale($outerScale);
  my($ox1, $oy1) = $self->bp_to_xy($fmin, $ef);
  my($ox2, $oy2) = $self->bp_to_xy($fmax, $ef);
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
  my($x1, $y1) = $self->bp_to_xy($fmin, $sf);
  my($x2, $y2) = $self->bp_to_xy($fmax, $ef);
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
  my($x1, $y1) = $self->bp_to_xy($fmin, $sf);
  my($x2, $y2) = $self->bp_to_xy($fmin, $ef);
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
  my($self, $group, $seq, $contig_positions, $track, $all_tracks, $config) = @_;
  my $seqlen = $self->seqlen();
  my $args = $self->_draw_coordinate_labels_track_args($track);

  my($sf, $ef, $tickInterval, $labelInterval, $labelType, $labelUnits, $labelPrecision, $fontSize, $noCircle, $fmin, $fmax) = map { $args->{$_} } 
  ('start-frac', 'end-frac', 'tick-interval', 'label-interval', 'label-type', 'label-units', 'label-precision', 'font-size', 'no-circle', 'fmin', 'fmax');
  my $seqIntLen = ($fmax - $fmin);

  my $nTicks = defined($tickInterval) ? ($seqIntLen / $tickInterval) : 0;
  my $nLabels = defined($labelInterval) ? ($seqIntLen / $labelInterval) : 0;
  my $radial_height = $ef - $sf;
  my ($sw1, $sw2, $sw3) = map { $self->get_scaled_stroke_width($radial_height, 1, $_) } (200,100,400);

  # draw circle at $sf
  # TODO - not clear whether it's better to draw the entire circle or just the arc, if fmin-fmax != 0-seqlen
  my $r = $sf * $self->radius();
  $group->circle( 'cx' => $self->xoffset(), 'cy' => $self->yoffset(), 'r' => $r, 'stroke' => 'black', 'stroke-width' => $sw1, 'fill' => 'none' ) unless ($noCircle);

  # draw small ticks
  if ((defined($tickInterval)) && ($seqIntLen >= 0)) {
    my($first_tick_ind, $last_tick_ind) = $self->_get_interval_multiples_in_range($fmin, $fmax, $tickInterval);
    for (my $t = $first_tick_ind;$t <= $last_tick_ind;++$t) {
      my $pos = $tickInterval * $t;
      my($ix1, $iy1) = $self->bp_to_xy($pos, $sf);
      my($ox1, $oy1) = $self->bp_to_xy($pos, $ef);
      $group->line('x1' => $ix1, 'y1' => $iy1, 'x2' => $ox1, 'y2' => $oy1, 'stroke' => 'black', 'stroke-width' => $sw2);
    }
  }

  my $tef = $ef + ($ef - $sf);
  my $tef2 = $ef + (($ef - $sf) * 2);
  my $er = $tef2 * $self->radius();
  my $ft_offset = pi2 * $er * (($self->origin_degrees() + $self->rotate_degrees())/360.0);

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

  # large ticks and coordinate labels
  if ((defined($labelInterval)) && ($seqIntLen >= 0)) {
    my($first_label_ind, $last_label_ind) = $self->_get_interval_multiples_in_range($fmin, $fmax, $labelInterval);
    for (my $l = $first_label_ind;$l <= $last_label_ind; ++$l) {
      my $pos = $labelInterval * $l;
      my($ix1, $iy1) = $self->bp_to_xy($pos, $sf);
      my($ox1, $oy1) = $self->bp_to_xy($pos, $tef);
      my($oox1, $ooy1) = $self->bp_to_xy($pos, $tef2);
      
      # draw larger tick
      $group->line('x1' => $ix1, 'y1' => $iy1, 'x2' => $ox1, 'y2' => $oy1, 'stroke' => 'black', 'stroke-width' => $sw3);
      my $deg = $self->coord_to_degrees($pos);
      my $quad = $self->coord_to_quadrant($pos);
      $self->logger()->debug("mapped pos=$pos to deg=$deg quad=$quad") if ($self->debug_opt('coordinates'));
      
      # anchor left side labels at the end, right side labels at the start
      my $anchor = ($quad =~ /l$/) ? "end" : "start";
      # shift labels down if they're in the bottom quadrants
      $ooy1 += ($fontSize * $self->font_baseline_frac()) if ($quad =~ /^b/);
      my $coordLabel = $self->_format_coordinate($pos, $labelUnits, $labelPrecision);

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
  my($x1, $y1) = $self->bp_to_xy($fmin, $mf);
  my($x2, $y2) = $self->bp_to_xy($fmax, $mf);
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

sub xoffset { 
    my($self) = @_; 
    return $self->radius() + $self->pad_left(); 
}

sub yoffset { 
    my($self) = @_; 
    return $self->radius() + $self->pad_top(); 
}

sub svg_width {
    my($self) = @_;
    return ($self->radius() * 2) + $self->pad_left() + $self->pad_right();
}

sub svg_height {
    my($self) = @_;
    return ($self->radius() * 2) + $self->pad_top() + $self->pad_bottom();
}

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
sub bp_to_xy {
  my($self, $bp, $frac) = @_;
  my $seqlen = $self->seqlen();
  my $rho = $frac * $self->radius();
  my $deg = $self->coord_to_degrees($bp, -$self->origin_degrees());
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
