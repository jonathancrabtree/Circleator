#!/usr/bin/perl

package Circleator::Draw::DrawLinear;

# Linear drawing routines

use strict;
use Circleator::Draw::Draw;

use Math::Trig ':pi';
use POSIX qw (floor);

our @ISA = ('Circleator::Draw::Draw');

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

sub init {
    my($self, $logger, $seqlen, $debug_opts, $options) = @_;
    $self->SUPER::init($logger, $seqlen, $debug_opts, $options);
    my $seq_width = $options->{'seq_width'};
    if (!defined($seq_width)) {
	my $radius = $self->radius();
	$seq_width = $radius * pi2;
    }
    $self->{'seq_width'} = $seq_width;
}

sub draw_rect {
  my($self, $svg, $fmin, $fmax, $sf, $ef, $atts, $innerScale, $outerScale) = @_;
  my $seqlen = $self->seqlen();
  my $is_circle = ($fmax - $fmin) >= $seqlen;

  my $restore_scale = $self->set_scale($innerScale);
  my($ix1, $iy1) = $self->bp_to_xy($fmin, $sf);
  my($ix2, $iy2) = $self->bp_to_xy($fmax, $sf);
  &$restore_scale();
  
  my $restore_scale = $self->set_scale($outerScale);
  my($ox1, $oy1) = $self->bp_to_xy($fmin, $ef);
  my($ox2, $oy2) = $self->bp_to_xy($fmax, $ef);
  &$restore_scale();

  my $w = $ix2 - $ix1;
  my $h = $iy2 - $oy2;

  # if the rectangle spans the entire sequence then don't draw the left and right sides
  # (this is analagous to drawing 2 concentric circles in the same case in circular drawing mode)
  if ($is_circle) {
      $svg->line('x1' => $ix1, 'y1' => $iy1, 'x2' => $ix2, 'y2' => $iy2, %$atts);
      $svg->line('x1' => $ox1, 'y1' => $oy1, 'x2' => $ox2, 'y2' => $oy2, %$atts);
  } else {
      $svg->rect('x' => $ix1, 'y' => $oy1, 'width' => $w, 'height' => $h, %$atts);
  }
}  

sub draw_ruler_track {
  my($self, $group, $seq, $contig_positions, $track, $all_tracks, $config) = @_;
  my $seqlen = $self->seqlen();
  my $args = $self->_draw_ruler_track_args($track);

  my($sf, $ef, $tickInterval, $labelInterval, $labelType, $labelUnits, $labelPrecision, $fontSize, $noCircle, $fmin, $fmax) = map { $args->{$_} } 
  ('start-frac', 'end-frac', 'tick-interval', 'label-interval', 'label-type', 'label-units', 'label-precision', 'font-size', 'no-circle', 'fmin', 'fmax');
  my $seqIntLen = ($fmax - $fmin);

  my $nTicks = defined($tickInterval) ? ($seqIntLen / $tickInterval) : 0;
  my $nLabels = defined($labelInterval) ? ($seqIntLen / $labelInterval) : 0;
  my $radial_height = $ef - $sf;
  my ($sw1, $sw2, $sw3) = map { $self->get_scaled_stroke_width($radial_height, 1, $_) } (200,100,400);

  # draw line at $sf
  my($x1, $y1) = $self->bp_to_xy($fmin, $sf);
  my($x2, $y2) = $self->bp_to_xy($fmax, $sf);

  my $r = $sf * $self->radius();
  $group->line( 'x1' => $x1, 'y1' => $y1, 'x2' => $x2, 'y2' => $y2, 'stroke' => 'black', 'stroke-width' => $sw1, 'fill' => 'none' ) unless ($noCircle);

  my $getTickOrLabelIndices = sub {
    my($fmin, $fmax, $interval) = @_;
    my $start_ind = floor($fmin / $interval);
    my $start_posn = $start_ind * $interval;
    ++$start_ind if ($start_posn < $fmin);
    my $end_ind = floor($fmax / $interval);
    $self->logger()->debug("converted fmin=$fmin, fmax=$fmax, interval=$interval to start_ind=$start_ind, end_ind=$end_ind") if ($self->debug_opt('coordinates'));
    return ($start_ind, $end_ind);
  };

  if ((defined($tickInterval)) && ($seqIntLen >= 0)) {
    my($first_tick_ind, $last_tick_ind) = &$getTickOrLabelIndices($fmin, $fmax, $tickInterval);
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

  if ((defined($labelInterval)) && ($seqIntLen >= 0)) {
    my($first_label_ind, $last_label_ind) = &$getTickOrLabelIndices($fmin, $fmax, $labelInterval);

    for (my $l = $first_label_ind;$l <= $last_label_ind; ++$l) {
      my $pos = $labelInterval * $l;
      my($ix1, $iy1) = $self->bp_to_xy($pos, $sf);
      my($ox1, $oy1) = $self->bp_to_xy($pos, $tef);
      my($oox1, $ooy1) = $self->bp_to_xy($pos, $tef2);
      
      # draw larger tick
      $group->line('x1' => $ix1, 'y1' => $iy1, 'x2' => $ox1, 'y2' => $oy1, 'stroke' => 'black', 'stroke-width' => $sw3);
      my $coordLabel = $self->_format_coordinate($pos, $labelUnits, $labelPrecision);
      my $anchor = 'start';
      
      if ($labelType =~ /^(horizontal|curved)$/) {
        $group->text('x' => $oox1, 'y' => $ooy1, 'text-anchor' => $anchor, 'font-size' => $fontSize, 'font-weight' => 'bold')->cdata($coordLabel);
      } elsif ($labelType eq 'spoke') {
        my $tg = $group->group( 'transform' => "translate($oox1, $ooy1)");
        $tg->text('x' => 0, 'y' => 0, 'text-anchor' => $anchor, 'font-size' => $fontSize, 'font-weight' => 'bold', 'transform' => "rotate(-90)")->cdata($coordLabel);
      }
    }
  }
}

sub draw_label_track {
  my($self, $group, $seq, $contig_positions, $track, $all_tracks, $config) = @_;
  my $seqlen = $self->seqlen();
  my $args = $self->_draw_label_track_args($track);
  
  # track options
  my($tnum, $packer, $reverse_pack_order, $feat_type, $glyph, $sf, $ef, $opacity, $zIndex, $scolor, $fcolor, $tcolor, $stroke_width,
     # global overrides/defaults for label-specific properties
     $g_style, $g_anchor, $g_draw_link, $g_link_color, $g_label_type,
     $labels, $label_fn, $tier_gap_frac, $track_fhf, $track_ffam, $track_fs, $track_fw, $track_fwf) =
	 map { $args->{$_} } 
  ('tnum', 'packer', 'reverse-pack-order', 'feat-type', 'glyph', 'start-frac', 'end-frac', 'opacity', 
   'z-index', 'stroke-color', 'fill-color', 'text-color', 'stroke-width',
   # global overrides/defaults for label-specific properties
   # TODO - change naming convention to make this more clear
   'style', 'text-anchor', 'draw-link', 'link-color', 'label-type', 
   # label track-specific options
   'labels', 'label-function', 'tier-gap-frac', 'font-height-frac', 'font-family', 'font-style', 'font-weight', 'font-width-frac'
  );
  
  my($ltrack, $lfeat_list) = (undef, undef);
  my $labels = $self->_draw_label_track_get_labels($args);

  # TODO


}

# $is_reversed - whether to draw arrow in counterclockwise direction
sub draw_curved_line {
  my($self, $svg, $fmin, $fmax, $is_reversed, $sf, $ef, $pathAtts, $innerScale, $outerScale) = @_;
  # TODO
}

sub draw_radial_line {
  my($self, $svg, $fmin, $sf, $ef, $pathAtts) = @_;
  # TODO
}

# ------------------------------------------------------------------
# DrawLinear
# ------------------------------------------------------------------

sub seq_width { 
    my($self) = @_; 
    return $self->{'seq_width'}; 
}

sub xoffset { 
    my($self) = @_; 
    return $self->pad_left(); 
}

sub yoffset { 
    my($self) = @_; 
    return - $self->pad_bottom(); 
}

# In linear mode the width is equal to the circumference of the circle
sub svg_width {
    my($self) = @_;
    return int($self->seq_width() + $self->pad_left() + $self->pad_right());
}

sub svg_height {
    my($self) = @_;
    return $self->radius() + $self->pad_top() + $self->pad_bottom();
}

sub bp_to_xy {
  my($self, $bp, $frac) = @_;
  my $seqlen = $self->seqlen();
  my $radius = $self->radius();
  my $seq_frac = $bp / $seqlen;
  my $seq_width = $self->seq_width();
  my $svg_height = $self->svg_height();
  my $pad_bottom = $self->pad_bottom();
  my $pad_left = $self->pad_left();

  # y position - corresponds to radial distance in circular mode
  my $y = $svg_height - ($radius * $frac);
  
  # x position - corresponds to position on the circumference of the circle in circular mode
  my $x = $seq_frac * $seq_width;

  return ($x + $self->xoffset(), $y + $self->yoffset());
}

sub get_tier_font_height_frac_and_char_width_bp {
  my($self, $sf, $ef, $ntiers, $tier_gap_frac, $font_height_frac, $font_baseline_frac) = @_;
  my $seqlen = $self->seqlen();
  $font_baseline_frac = $self->font_baseline_frac() if (!defined($font_baseline_frac));
  $font_height_frac = 1 if (!defined($font_height_frac));
  my $height = $ef - $sf;
  my $tier_height = $height / $ntiers;
  my $fhf = ($tier_height * (1 - ($tier_gap_frac * 1.5))) * $font_height_frac;
  # approximate average width of a single character at radius = $sf (assuming only 1 tier)
  my $char_width_px = $fhf * $self->radius() * $font_baseline_frac;
  my $char_width_bp = ($char_width_px/$self->seq_width()) * $seqlen;
  return($fhf, $char_width_bp);
}

1;

