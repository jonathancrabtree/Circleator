#!/usr/bin/perl

package Circleator::Draw::Draw;

use Carp;
use Math::Trig ':pi';
use POSIX qw (floor);

# Base module from which all drawing modules should inherit.

my $DEFAULT_COORD_LABEL_TYPE = 'horizontal';
my $DEFAULT_RULER_FONT_SIZE = 50;
# approximate average font width as a fraction of font height
my $FONT_BASELINE_FRAC = 0.8;
# gap between label tiers as a fraction of a full tier
my $DEFAULT_TIER_GAP_FRAC = 0.2;
# target ratio of stroke width to effective tier height (in pixels)
my $TARGET_STROKE_WIDTH_RATIO = 1000;

# ------------------------------------------------------------------------------------
# Initialize
# ------------------------------------------------------------------------------------

sub init {
    my($self, $logger, $seqlen, $debug_opts, $options) = @_;
    $self->{'logger'} = $logger;
    $self->{'seqlen'} = $seqlen;
    $self->{'debug_opts'} = $debug_opts;
    $self->{'svg_id_counter'} = 0;
    $self->{'id_transform'} = Circleator::CoordTransform::Identity->new($logger, {});
    $self->{'transform_stack'} = [ $self->{'id_transform'} ];
    my $radius = $options->{'radius'};
    die "init() called with radius <= 0" if ($radius <= 0);
    map { $self->{$_} = $options->{$_} } ('pad_left', 'pad_right', 'pad_top', 'pad_bottom', 'rotate_degrees', 'radius');
}

# ------------------------------------------------------------------------------------
# Draw
# ------------------------------------------------------------------------------------

# accessors
sub logger { my($self) = @_; return $self->{'logger'}; }
sub seqlen { my($self) = @_; return $self->{'seqlen'}; }
sub radius { my($self) = @_; return $self->{'radius'}; }
sub debug_opts { my($self) = @_; return $self->{'debug_opts'}; }
sub debug_opt { my($self, $opt) = @_; return $self->{'debug_opts'}->{$opt}; }
sub rotate_degrees { my($self) = @_; return $self->{'rotate_degrees'}; }
sub pad_left { my($self) = @_; return $self->{'pad_left'}; }
sub pad_right { my($self) = @_; return $self->{'pad_right'}; }
sub pad_top { my($self) = @_; return $self->{'pad_top'}; }
sub pad_bottom { my($self) = @_; return $self->{'pad_bottom'}; }

# constants
sub default_coord_label_type { my($self) = @_; return $DEFAULT_COORD_LABEL_TYPE; }
sub default_ruler_font_size { my($self) = @_; return $DEFAULT_RULER_FONT_SIZE; }
sub default_tier_gap_frac { my($self) = @_; return $DEFAULT_TIER_GAP_FRAC; }
sub font_baseline_frac { my($self) = @_; return $FONT_BASELINE_FRAC; }
sub target_stroke_width_ratio { my($self) = @_; return $TARGET_STROKE_WIDTH_RATIO; }

sub circumference {
    my($self, $height_frac) = @_;
    $height_frac = 1 if (!defined($height_frac));
    return pi2 * $self->radius() * $height_frac;
}

sub new_svg_id {
    my($self) = @_;
    return ++$self->{'svg_id_counter'};
}

# set/get current coordinate system transformation
sub get_transform {
    my($self) = @_;
    return $self->{'transform_stack'}->[-1];
}

# push new transform onto the stack
sub push_transform {
    my($self, $transform) = @_;
    my $stack = $self->{'transform_stack'};
    push(@$stack, $transform);
}

# pop transform from the top of the stack
sub pop_transform {
    my($self, $transform) = @_;
    my $stack = $self->{'transform_stack'};
    my $nt = scalar(@$stack);
    my $top = $stack->[-1];
    pop(@$stack) if ($nt > 1);
    return $top;
}

# reset transform to identity transform
sub push_identity_transform {
    my($self) = @_;
    $self->push_transform($self->{'id_transform'});
}

# Change the scale/sequence transform and return a subroutine that will restore it to the original value.
sub set_scale {
  my($self, $scale) = @_;
  my $saved_transform = $self->get_transform();

  if (!defined($scale) || ($scale eq 'default')) {
      # no-op
  } elsif ($scale eq 'none') {
      $self->push_transform($self->{'id_transform'});
  } else {
      $self->logger()->logdie("unrecognized scale $scale");
  }

  return sub {
      $self->push_transform($saved_transform);
  };
}

# Apply the current coordinate system transformation to a sequence position.
sub transform {
    my($self, $coord) = @_;
    return $self->get_transform()->transform($coord);
}

# Inverse of transform()
sub invert_transform {
    my($self, $coord) = @_;
    return $self->get_transform()->invert_transform($coord);
}

# Get start and end multiples of an interval within a coordinate range.
sub _get_interval_multiples_in_range {
    my($self, $fmin, $fmax, $interval) = @_;
    my $start_ind = floor($fmin / $interval);
    my $start_posn = $start_ind * $interval;
    ++$start_ind if ($start_posn < $fmin);
    my $end_ind = floor($fmax / $interval);
    $self->logger()->debug("converted fmin=$fmin, fmax=$fmax, interval=$interval to start_ind=$start_ind, end_ind=$end_ind") if ($self->debug_opt('coordinates'));
    return ($start_ind, $end_ind);
}

sub _format_coordinate {
    my($self, $pos, $labelUnits, $labelPrecision) = @_;
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
    return $coordLabel;
}

# Get/check track arguments for draw_ruler_track()
sub _draw_ruler_track_args {
    my($self, $track) = @_;
    my $seqlen = $self->seqlen();
    my $args = {};

    map { $args->{$_} = $track->{$_}; } 
    ('start-frac', 'end-frac', 'tick-interval', 'label-interval', 'label-type', 'label-units', 'label-precision', 'font-size', 'no-circle', 'fmin', 'fmax');

    $args->{'label-type'} = $self->default_coord_label_type() if (!defined($args->{'label-type'}));
    if ($args->{'label-type'} !~ /^horizontal|spoke|curved$/) {
	$self->logger()->logdie("unsupported label_type $args->{'label-type'} requested: only horizontal, spoke, and curved are supported");
    }
    $args->{'label-units'} = "Mb" if (!defined($args->{'label-units'}));
    $args->{'label-precision'} = "1" if (!defined($args->{'label-precision'}));
    $args->{'fmin'} = 0 if (!defined($args->{'fmin'}) || ($args->{'fmin'} < 0));
    $args->{'fmax'} = $seqlen if (!defined($args->{'fmax'}) || ($args->{'fmax'} > $seqlen));
    $args->{'font-size'} = $self->default_ruler_font_size() if (!defined($args->{'font-size'}));
    
    return $args;
}

# Get/check track arguments for draw_label_track()
sub _draw_label_track_args {
    my($self, $track) = @_;
    my $seqlen = $self->seqlen();
    my $args = {};

    map { $args->{$_}  = $track->{$_}} 
    ('tnum', 'packer', 'reverse-pack-order', 'feat-type', 'glyph', 'start-frac', 'end-frac', 'opacity', 
     'z-index', 'stroke-color', 'fill-color', 'text-color', 'stroke-width',
     'style', 'text-anchor', 'draw-link', 'link-color', 'label-type', 
     'labels', 'label-function', 'tier-gap-frac', 'font-height-frac', 'font-family', 'font-style', 'font-weight', 'font-width-frac'
    );

    # defaults
    $args->{'stroke-width'} = 1 if (!defined($args->{'stroke-width'}));
    $args->{'stroke-color'} = 'none' if (!defined($args->{'stroke-color'}));
    $args->{'fill-color'} = 'none' if (!defined($args->{'fill-color'}));
    $args->{'text-color'} = 'black' if (!defined($args->{'text-color'}));
    $args->{'packer'} = 'LinePacker' if (!defined($args->{'packer'}));
    $args->{'label-function'} = sub { my $f = shift; return $f->display_name(); } if (!defined($args->{'label-function'}));
    $args->{'tier-gap-frac'} = $self->default_tier_gap_frac() if (!defined($args->{'tier-gap-frac'}));
    $args->{'font-height-frac'} = 1 if (!defined($args->{'font-height-frac'}));
    $args->{'style'} = 'default' if (!defined($args->{'style'}));
    $args->{'draw-link'} = 0 if (!defined($args->{'draw-link'}));
    $args->{'link-color'} = 'black' if (!defined($args->{'link-color'}));
    $args->{'label-type'} = 'curved' if (!defined($args->{'label-type'}));

    return $args;
}

sub _draw_label_track_get_labels {
    my($self, $group, $seq, $contig_positions, $richseq, $track, $all_tracks, $config, $args) = @_;
    my($labels, $label_fn, $g_style, $g_anchor, $g_label_type) = map {$args->{$_}} ('labels', 'label-function', 'style', 'text-anchor', 'label-type');

    # explicitly-defined labels
    if (defined($labels)) {
	my $new_labels = [];
	foreach my $lbl (@$labels) {
	    # case 1: single user-defined label repeated multiple times
	    if (defined($lbl->{'repeat'})) {
		my $lp = $lbl->{'position'};
		$lp = 0 if (!defined($lp));
		for (my $lpos = $lp; $lpos < $seqlen; $lpos += $lbl->{'repeat'}) {
		    my %copy = %$lbl;
		    $copy{'position'} = $lpos;
		    $copy{'fmin'} = $lpos if (!defined($copy{'fmin'}));
		    $copy{'fmax'} = $lpos if (!defined($copy{'fmax'}));
		    push(@$new_labels, \%copy);
		}
	    } 
	    # case 2: a single user-defined label
	    else {
		$lbl->{'fmin'} = $lbl->{'position'} if (!defined($lbl->{'fmin'}));
		$lbl->{'fmax'} = $lbl->{'position'} if (!defined($lbl->{'fmax'}));
		push(@$new_labels, $lbl);
	    }
	}
	$labels = $new_labels;
    }
    # implicitly-defined labels - one for each feature in the track
    else {
	my $tfs = &main::get_track_features($group, $seq, $seqlen, $contig_positions, $richseq, $track, $all_tracks, $config);
	($ltrack, $lfeat_list) = map {$tfs->{$_}} ('track', 'features');
	
	foreach my $feat (@$lfeat_list) {
	    my $f_type = $feat->primary_tag();
	    my $f_start = $feat->start();
	    my $f_end = $feat->end();
	    my $f_strand = $feat->strand();
	    my($fmin, $fmax, $strand) = &main::bioperl_coords_to_chado($f_start, $f_end, $f_strand);
	    my $label_text = &$label_fn($feat);
	    if (!defined($label_text)) {
		next;
	    }
	    
	    my $glt = ((ref $g_label_type) eq 'CODE') ? &$g_label_type($feat) : $g_label_type;
	    my $ga = (defined($g_anchor) && ((ref $g_anchor) eq 'CODE')) ? &$g_anchor($feat) : $g_anchor;
	    $ga = ($glt eq 'spoke') ? 'start' : 'middle' if (!defined($ga));
	    my $gsty = ((ref $g_style) eq 'CODE') ? &$g_style($feat) : $g_style;
	    
	    push(@$labels, {
		# label fields
		'position' => ($fmin + $fmax) / 2.0,
		'text' => $label_text,
		'text-anchor' => $ga,
		'style' => $gsty,
		'draw-link' => $g_draw_link,
		'link-color' => $g_link_color,
		'type' => $glt,
		# non-label fields
		'fmin' => $fmin,
		'fmax' => $fmax,
		'strand' => $strand,
		'feat' => $feat
		 });
	}
    }
    return $labels;
}

# ------------------------------------------------------------------------------------
# Subclass methods - should be overridden
# ------------------------------------------------------------------------------------

sub xoffset { 
    my($self) = @_; 
    die "subclass method xoffset not implemented";
}

sub yoffset { 
    my($self) = @_; 
    die "subclass method yoffset not implemented";
}

sub svg_width {
    my($self) = @_;
    die "subclass method svg_width not implemented";
}

sub svg_height {
    my($self) = @_;
    die "subclass method svg_height not implemented";
}

# Convert sequence coordinate in base pairs and radius fraction to x,y position.
#
sub bp_to_xy {
    my($self, $bp, $frac) = @_;
    # no default implementation
    die "subclass method bp_to_xy not implemented";
}

# Draw a curved rectangle
#
sub draw_rect {
    my($self, $svg, $fmin, $fmax, $sf, $ef, $pathAtts, $innerScale, $outerScale) = @_;
    # no default implementation
    die "subclass method draw_rect not implemented";
}

# Supports the following label-specific $track options.  Generally one will specify either
# 'labels', to display a preset set of labels,  or 'feat-track' and 'label-function'
# to label the features in a (typically) adjoining track.
#
# labels
#  An explicit list of literal labels to display.
#  Must be an arrayref of hashrefs with the following keys:
#    text - text of the label
#    font-height-frac - font height as a fraction of the track, or 'auto' to set it based on the available space (default = 1)
#    position - sequence position with which to align the label
#    text-anchor - start, middle, or end
#    style - 
#      default - plain vanilla label
#      signpost - surrounded by a rectangle and with a line pointing to the labeled feature (if applicable)
#
# label-function
#  Function that computes the label to display (if any) for each feature
#
sub draw_label_track {
  my($group, $seq, $contig_positions, $track, $all_tracks, $config) = @_;
  # no default implementation
  die "subclass method draw_label_track not implemented";
}

sub draw_ruler_track {
  my($self, $group, $seq, $contig_positions, $track, $all_tracks, $config) = @_;
  # no default implementation
  die "subclass method draw_ruler_track not implemented";
}

# TODO - move this into DrawCircular only
sub origin_degrees { 
    my($self) = @_; 
    return 0;
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

# Divide a track into $ntiers tiers, returning the corresponding tier font height fraction
# and average character width in base pairs.
#
# $sf - start fraction for the track 
# $ef - end fraction for the track 
# $ntiers - number of tiers to divide the track into
# $tier_gap_frac - fraction of each tier that should be empty
# $font_height_frac - unmodified font height as a fraction of *the track's* height
# $font_baseline_frac - approximate font width as a fraction of font height
#
sub get_tier_font_height_frac_and_char_width_bp {
  my($self, $sf, $ef, $ntiers, $tier_gap_frac, $font_height_frac, $font_baseline_frac) = @_;
  # no default implementation
  die "subclass method get_font_height_frac_and_char_width_bp";
}

1;
