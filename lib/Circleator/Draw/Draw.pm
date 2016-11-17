#!/usr/bin/perl

package Circleator::Draw::Draw;

use Carp;
use Math::Trig ':pi';
use POSIX qw (floor);

# Base module from which all drawing modules should inherit.

my $DEFAULT_COORD_LABEL_TYPE = 'horizontal';
my $DEFAULT_RULER_FONT_SIZE = 50;
my $FONT_BASELINE_FRAC = 0.8;
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

# Get/check track arguments for draw_coordinate_labels()
sub _draw_coordinate_labels_track_args {
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

sub draw_coordinate_labels {
  my($self, $group, $seq, $contig_positions, $track, $all_tracks, $config) = @_;
    # no default implementation
    die "subclass method draw_coordinate_labels not implemented";
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

1;
