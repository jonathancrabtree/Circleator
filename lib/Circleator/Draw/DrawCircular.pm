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

sub draw_label_track {
  my($self, $group, $seq, $contig_positions, $richseq, $track, $all_tracks, $config) = @_;
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
  my $labels = $self->_draw_label_track_get_labels($group, $seq, $contig_positions, $richseq, $track, $all_tracks, $config, $args);
  
  # run packing algorithm for a given font size (expressed as a tier count)
  my $do_pack = sub {
      my $num_tiers = shift;
      my($fhf, $cwbp) = $self->get_tier_font_height_frac_and_char_width_bp($sf, $ef, $num_tiers, $tier_gap_frac, $track_fhf, $track_fwf);
      
      # update pack_fmin, pack_fmax based on font size $fhf
      foreach my $label (@$labels) {
	  my($fmin, $fmax, $label_text) = map {$label->{$_}} ('fmin', 'fmax', 'text');
	  # do label width comparison in _transformed_ coordinate space, because font size is unaffected by the transformations
	  my $mod_fmin = $self->transform($fmin);
	  my $mod_fmax = $self->transform($fmax);
	  
	  # approximate label width in transformed coordinates
	  my $label_len = length($label_text);
	  my $approx_label_width_bp = $label_len * $cwbp;
	  
	  my $mod_width = $mod_fmax - $mod_fmin;
	  my $diff = $approx_label_width_bp - $mod_width;
	  my $mod_pack_fmin = $mod_fmin;
	  my $mod_pack_fmax = $mod_fmax;
	  if ($diff > 0) {
	      $mod_pack_fmin -= $diff * 0.5;
	      $mod_pack_fmax += $diff * 0.5;
	  }
	  my $mod_label_position = ($mod_pack_fmin + $mod_pack_fmax)/2;
	  
	  # now map back to original coordinates
	  # special case for out-of-range mod fmax
	  my $mod_fmax_out_of_range = ($mod_pack_fmax > $seqlen);
	  $mod_pack_fmax = $mod_pack_fmax % $seqlen if ($mod_fmax_out_of_range);
	  
	  my $pack_fmin = $self->invert_transform($mod_pack_fmin);
	  my $pack_fmax = $self->invert_transform($mod_pack_fmax);
	  $pack_fmax += $seqlen if ($mod_fmax_out_of_range);
	  my $label_position = $self->invert_transform($mod_label_position);
	  $label->{'pack-fmin'} = $pack_fmin;
	  $label->{'pack-fmax'} = $pack_fmax;
	  $label->{'position'} = $label_position;
      }

      # pack to determine vertical offsets and avoid overlaps (using pack-(fmin|fmax))
      my $tiers = undef;

      # TODO - allow $packer to specify any module in Circleator::Packer
      if ($packer eq 'none') {
	  # put everything in a single tier
	  $tiers = [$labels];
      }
      elsif ($packer eq 'LinePacker') {
	  my $lp = Circleator::Packer::LinePacker->new($self->logger(), $seqlen);
	  $tiers = $lp->pack($labels);
      }
      my $nt = scalar(@$tiers);
      
      if ($nt == 0) {
	  return (1, [[]]);
      }
      $self->logger()->debug(scalar(@$labels) . " label(s) packed into $nt tier(s) on track $tnum") if ($self->debug_opt('packing'));
      return($nt, $tiers);
  };
  
  # Some explanation is needed here.  How tightly one can pack
  # features and labels without inducing collisions is a function of
  # the vertical font size; the bigger the font, the further apart
  # features have to be.  So in order to know how many vertical
  # tiers are required to pack a given number of features, we must
  # first choosen a font size.  But the font size will depend on the
  # number of tiers chosen, as described below.  This creates some
  # circularity and makes it nontrivial to determine the optimal
  # font size and tier count.  As noted, the font size limited by
  # the total number of "tiers" (i.e., the concentric segments into
  # which the track has to to be broken in order to make everything
  # fit.)  For example, if there are 3 tiers (i.e., the track is
  # divided into 3 adjacent concentric circles with equal radial
  # height) then the font height cannot be greater than the total
  # tier height divided by 3.  To simplify things, let's define the
  # font size in terms of the font tier count (FTC), so that, for
  # example, an FTC of 4 implies a font that is at most 1/4 the
  # height of the entire track.  Note that while the tier count (TC,
  # i.e. the chosen number of tiers), can be greater or equal to the
  # font tier count (FTC), it cannot be less than the font tier
  # count without running the risk of the text overlapping in the
  # vertical/radial direction.
  # 
  # What this all means is that we are searching for a tier_count (TC)
  # and a font size tier count (FTC) that are not necessarily the same
  # but which satisfy the following two criteria:
  #
  #  1. TC <= FTC (so that adjacent tiers don't overlap, as noted)
  #  2. (FTC - TC) is minimized (so that as little space as possible is wasted)
  #
  # Furthermore note that an upper bound on the number of tiers can
  # be obtained by assuming the largest possible font size (FTC = 1).
  # The approach, then, is to start at the minimum TC value and try 
  # successively larger TC values until conditions 1 and 2 are both
  # met.  It isn't possible to do a standard binary search for the optimal value
  # because as TC is decreased the value of (FTC-TC) will first decrease
  # and then increase again.  However, it does mean that the search can
  # be halted once the value of (FTC-TC) starts increasing once again.

  # TODO - replace this simplistic approach with a faster minimization procedure
  # TODO - and note that this complexity is *only* needed in the circular case

  if (!defined($labels) || (scalar(@$labels) == 0)) {
      $self->logger()->warn("no labels to print on track $tnum");
  }

  # get upper bound on the number of tiers by assuming the largest possible font size:
  my($max_nt, $final_tiers) = &$do_pack(1);
  $self->logger()->debug("upper bound on num tiers = $max_nt") if ($self->debug_opt('packing'));
  my $final_nt = $max_nt;
  my $final_font_nt = $max_nt;
  my $min_diff = abs(1 - $final_nt);
  # track first derivative of $min_diff
  my $last_step = undef;
  my $last_md = $min_diff;
  my $pack_count = 1;
  
  # increase TC until we've minimized FTC-TC
  # going in steps of 0.5 to try to get as close as possible:
  for (my $try_nt = 1; $try_nt <= $max_nt; $try_nt += 0.5) {
      my($nt, $tiers) = &$do_pack($try_nt);
      my $md = abs($try_nt - $nt);
      my $new_step = $md - $last_md;
      ++$pack_count;
      
      $self->logger()->debug("try_nt=$try_nt actual nt=$nt md=$md new_step=$new_step final_nt=$final_nt min_diff=$min_diff") if ($self->debug_opt('packing'));
      
      # found a new minimum:
      if (($nt < $final_nt) && ($nt <= $try_nt) && ($md < $min_diff)) { 
	  $final_nt = $nt;
	  $final_tiers = $tiers;
	  $final_font_nt = $try_nt;
	  $min_diff = $md;
      }
      
      # This heuristic needs to be improved to allow for the possibility that 
      # the packer will do _worse_ with a slightly smaller font, causing the 
      # search to halt early.  It would probably be sufficient to let it run
      # for a few extra rounds and, if no improvement is observed, then halt.
      # Additionally, the early halt condition should be triggered _only_ if
      # we have attained a better-than-worst-case solution.
      
	# check whether the minimum value has been reached/passed
    #	if (defined($last_step) && ($last_step < 0) && ($new_step > 0)) {
    #	    last;
    #	}
      $last_step = $new_step;
      $last_md = $md;
  }
  $self->logger()->debug("packed " . scalar(@$labels) . " label(s) into $final_nt tier(s) with font_nt=$final_font_nt after $pack_count round(s) of packing") if ($self->debug_opt('packing'));
  my $tiers = $final_tiers;
  
  # TODO - recompute fhf on a per-tier basis and reassign every label a more accurate pack_fmin/pack_fmax
  # (e.g., for the benefit of the signpost label glyph, which relies on the pack_fmin/pack_fmax to determine
  # the extent of the label)
  
  # reverse tiers by default
  if ($reverse_pack_order || (defined($ltrack) && ($ltrack->{'tnum'} < $tnum))) {
      my @new_tiers = reverse @$tiers;
      $tiers = \@new_tiers;
  }
  
  my $radial_height = $ef - $sf;
  my $nt = scalar(@$tiers);
  my $tier_height = $radial_height / $final_nt;
  my($font_height_frac, $char_width_bp) = $self->get_tier_font_height_frac_and_char_width_bp($sf, $ef, $final_font_nt, $tier_gap_frac, $track_fhf, $track_fwf);
  $self->logger()->debug("radial_height=$radial_height final_nt=$final_nt track_fwf=$track_fwf");
  $self->logger()->debug("nt=$nt tier_height=$tier_height font_height_frac=$font_height_frac tier_gap_frac=$tier_gap_frac") if ($self->debug_opt('packing'));
  
  # assign font sizes and vertical offsets
  for (my $t = 0;$t < $nt; ++$t) {
      my $tier = $tiers->[$t];
      my $t_sf = $sf + ($tier_height * $t);
      my $t_ef = $t_sf + $tier_height - ($tier_height * $tier_gap_frac);
      my $m_tier_height = $t_ef - $t_sf;
      
      $self->logger()->debug("tiernum=$t t_sf=$t_sf t_ef=$t_ef") if ($self->debug_opt('packing'));
      
      # path for circular labels
      # circle starts at 9 o'clock and then goes for 450 degrees
      # this allows rendering labels that cross the origin.  90 degrees will be added to compensate
      my $circlePathId = "cp" . $self->new_svg_id();
      
      # approximate baseline radius
      my $br = ($t_ef - ($m_tier_height * $self->font_baseline_frac())) * $self->radius();
      my $ft_offset = pi2 * $br * (($self->origin_degrees() + $self->rotate_degrees())/360.0);
      
      # TODO - this is copied from draw_ruler_track and should be factored out
      my($bx,$by,$tx,$ty) = ($self->xoffset(),$self->yoffset()+$br,$self->xoffset(),$self->yoffset()-$br);
      my($lx,$ly,$rx,$ry) = ($self->xoffset()-$br,$self->yoffset(),$self->xoffset()+$br,$self->yoffset());
      my $xar = -$self->origin_degrees();
      my $cp = $group->path('id' => $circlePathId,
			    'd' =>
			    "M${lx},${ly} " .
			    "A$br,$br $xar,1,1 ${bx},${by} " .
			    "A$br,$br $xar,1,1 ${rx},${ry} ",
			    'fill' => "none",
			    'stroke' => "none");
      
      foreach my $lbl (@$tier) {
	  $lbl->{'font-height-frac'} = $font_height_frac;
	  $lbl->{'sf'} = $t_sf;
	  $lbl->{'ef'} = $t_ef;
	  $lbl->{'ft-offset'} = $ft_offset;
	  $lbl->{'path-id'} = $circlePathId;
	  $lbl->{'baseline-radius'} = $br;
      }
  }
  
  my ($sw1, $sw2, $sw3) = map { $self->get_scaled_stroke_width($radial_height, $nt, $_) } (5,10,100);
  
  # draw signpost connecting lines first
  foreach my $lbl (@$labels) {
      my($txt, $fhf, $fstyle, $fweight, $pos, $ta, $fto, $cpid, $br, $style, $lt, $dl, $lc, $lsf, $lef, $pfmin, $pfmax, $feat) =
	  map { $lbl->{$_}; } 
      ('text', 'font-height-frac', 'font-style', 'font-weight', 'position', 'text-anchor', 'ft-offset', 'path-id', 'baseline-radius', 'style', 'type', 'draw-link',
       'link-color', 'sf', 'ef', 'pack-fmin', 'pack-fmax', 'feat');
      
      my $fc = ((ref $fcolor) eq 'CODE') ? &$fcolor($feat) : $fcolor;
      my $sc = ((ref $scolor) eq 'CODE') ? &$scolor($feat) : $scolor;
      $pos = 0 if (!defined($pos));
      
      # optional line/signpost glyph connecting the label to the labeled feature
      if ($style eq 'signpost') {
	  
	  # draw line from the label to the label target
	  if (($dl) && defined($ltrack)) {
	      my($lx1, $ly1, $tx1, $ty1);
	      
	      # target track range
	      my $tt_sf = $ltrack->{'start-frac'};
	      my $tt_ef = $ltrack->{'end-frac'};
	      # target track is _outside_ this one
	      if (defined($ltrack) && ($ltrack->{'tnum'} > $tnum)) {
		  ($lx1, $ly1) = $self->bp_to_xy($pos, $lsf, $seqlen);
		  ($tx1, $ty1) = $self->bp_to_xy($pos, $tt_ef, $seqlen);
	      } 
	      # target track is _inside_ this one
	      else {
		  ($lx1, $ly1) = $self->bp_to_xy($pos, $lef, $seqlen);
		  ($tx1, $ty1) = $self->bp_to_xy($pos, $tt_sf, $seqlen);
	      }
	      $group->line('x1' => $lx1, 'y1' => $ly1, 'x2' => $tx1, 'y2' => $ty1, 'stroke' => $lc, 'stroke-width' => $stroke_width );
	  }
      }
  }
  
  # draw labels
  foreach my $lbl (@$labels) {
      my($txt, $fhf, $ffam, $fstyle, $fweight, $pos, $ta, $fto, $cpid, $br, $style, $lt, $dl, $lc, $lsf, $lef, $pfmin, $pfmax, $feat) =
	  map { $lbl->{$_}; } 
      ('text', 'font-height-frac', 'font-family', 'font-style', 'font-weight', 'position', 'text-anchor', 'ft-offset', 'path-id', 'baseline-radius', 'style', 'type', 'draw-link',
       'link-color', 'sf', 'ef', 'pack-fmin', 'pack-fmax', 'feat');
      
      my $fc = ((ref $fcolor) eq 'CODE') ? &$fcolor($feat) : $fcolor;
      my $sc = ((ref $scolor) eq 'CODE') ? &$scolor($feat) : $scolor;
      my $tc = ((ref $tcolor) eq 'CODE') ? &$tcolor($feat) : $tcolor;
      $tc = 'none' if (!defined($tc));
      $ffam = $track_ffam if (!defined($ffam));
      $fstyle = $track_fs if (!defined($fstyle));
      $fweight = $track_fw if (!defined($fweight));
      
      # defaults
      if (!defined($ta)) {
	  if ($lt eq 'spoke') {
	      $ta = 'start';
	  } else {
	      $ta = 'middle';
	  }
      }
      $pos = 0 if (!defined($pos));
      $fhf = $self->font_baseline_frac() if (!defined($fhf));
      $lt = $g_label_type if (!defined($lt));
      my $fh = $fhf * $self->radius();
      # TODO - factor these two lines out into coord_to_circumferential_coord (better name for this?)
      my $mod_pos = $self->transform($pos);
      my $ft = pi2 * $br * ($mod_pos/$seqlen) + $fto;
      
      if ($style eq 'signpost') {
	  # draw line from the label to the label target
	  if (($dl) && defined($ltrack)) {
	      my($lx1, $ly1, $tx1, $ty1);
	      # draw curved rectangle around the label
	      my $atts = { 'fill' => $fc, 'stroke' => $sc, 'stroke-width' => $sw2 };
	      $self->draw_rect($group, $pfmin, $pfmax, $lsf, $lef, $atts);
	  }
      }
      
      my $textArgs = {};
      $textArgs->{'font-size'} = $fh;
      $textArgs->{'fill'} = $tc;
      $textArgs->{'font-style'} = $fstyle if (defined($fstyle));
      $textArgs->{'font-family'} = $ffam if (defined($ffam));
      $textArgs->{'font-weight'} = $fweight if (defined($fweight));
      $textArgs->{'text-anchor'} = $ta;
      
      # draw the label text
      if ($lt eq 'curved') {
	  my $te = $group->text('x' => $ft, 'y' => 0, %$textArgs);
	  $te->textPath('xlink:href' => "#" . $cpid)->cdata($txt);
      } else {
	  my($tx1, $ty1) = $self->bp_to_xy($pos, $sf, $seqlen);
	  if ($lt eq 'horizontal') {
		my $te = $group->text('x' => $tx1, 'y' => $ty1, %$textArgs);
		$te->cdata($txt);
	  } elsif ($lt eq 'spoke') {
	      my $quad = $self->coord_to_quadrant($pos);
	      
	      # TODO - figure out adjustment to $pos to increase (right side of circle) or decrease (left side of circle) offset by half font height
	      my($fhf, $cwbp) = $self->get_tier_font_height_frac_and_char_width_bp($sf, $ef, $nt, $tier_gap_frac, $track_fhf, $track_fwf);
	      my $mod_pos = $self->transform($pos);
	      
	      # TODO - this is not correct
	      if ($quad =~ /r$/) {
		  $mod_pos += $cwbp/2;
	      } else {
		  $mod_pos -= $cwbp/2;
	      }
	      $mod_pos = $mod_pos % $seqlen if ($mod_pos > $seqlen);
	      
	      my $pos = $self->invert_transform($mod_pos);
	      my $mod_quad = $self->coord_to_quadrant($pos);
	      my $deg = $self->coord_to_degrees($pos);
	      my($tx1, $ty1) = $self->bp_to_xy($pos, $sf, $seqlen);
	      
	      # modify anchor based on quadrant if drawing spoke labels
	      if ($ta eq 'start') {
		  $textArgs->{'text-anchor'} = 'end' if ($mod_quad =~ /l$/);
	      } elsif ($ta eq 'end') {
		  $textArgs->{'text-anchor'} = 'start' if ($mod_quad =~ /l$/);
	      }

	      my $hfh = $fh/2.0;
	      my $tg = $group->group( 'transform' => "translate($tx1, $ty1)");
	      my $tr = $deg - 90;
	      $tr += 180 if ($mod_quad =~ /l$/);
	      my $te = $tg->text('x' => 0, 'y' => 0, 'transform' => "rotate($tr)", %$textArgs);
	      $te->cdata($txt);
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

sub get_tier_font_height_frac_and_char_width_bp {
  my($self, $sf, $ef, $ntiers, $tier_gap_frac, $font_height_frac, $font_baseline_frac) = @_;
  my $seqlen = $self->seqlen();
  $font_baseline_frac = $self->font_baseline_frac() if (!defined($font_baseline_frac));
  $font_height_frac = 1 if (!defined($font_height_frac));
  my $radial_height = $ef - $sf;
  my $tier_height = $radial_height / $ntiers;
  my $fhf = ($tier_height * (1 - ($tier_gap_frac * 1.5))) * $font_height_frac;
  # approximate average width of a single character at radius = $sf (assuming only 1 tier)
  my $char_width_px = $fhf * $self->radius() * $font_baseline_frac;
  # TODO - improve this estimate
  # Currently using average of inner and outer circles to estimate font size, which will 
  # underestimate label size for the inner tiers, where each pixel corresponds to more bp.
  my $circum_px = $self->circumference(($sf+$ef)/2);
  my $char_width_bp = ($char_width_px/$circum_px) * $seqlen;
  return($fhf, $char_width_bp);
}

1;
