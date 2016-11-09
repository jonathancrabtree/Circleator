#!/usr/bin/perl

package Circleator::Draw::Draw;

use Math::Trig ':pi';

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
    my($self, $logger, $seqlen, $radius, $debug_opts, $options) = @_;
    $self->{'logger'} = $logger;
    $self->{'seqlen'} = $seqlen;
    $self->{'radius'} = $radius;
    $self->{'debug_opts'} = $debug_opts;
    $self->{'svg_id_counter'} = 0;
    $self->{'id_transform'} = Circleator::CoordTransform::Identity->new($logger, {});
    $self->{'transform_stack'} = [ $self->{'id_transform'} ];
    map { $self->{$_} = $options->{$_} } ('pad_left', 'pad_right', 'pad_top', 'pad_bottom', 'rotate_degrees');
    die "init() called with radius <= 0" if ($radius <= 0);
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

# ------------------------------------------------------------------------------------
# Subclass methods - should be overridden
# ------------------------------------------------------------------------------------

# Draw a curved rectangle
#
sub draw_rect {
    my($self, $svg, $fmin, $fmax, $sf, $ef, $pathAtts, $innerScale, $outerScale) = @_;
    # no default implementation
}

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
    # default = no scaling
    return $stroke_width;
}

1;
