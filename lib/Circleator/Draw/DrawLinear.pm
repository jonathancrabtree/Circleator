#!/usr/bin/perl

package Circleator::Draw::DrawLinear;

# Linear drawing routines

use strict;
use Circleator::Draw::Draw;

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

sub draw_rect {
  my($self, $svg, $fmin, $fmax, $sf, $ef, $pathAtts, $innerScale, $outerScale) = @_;
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

1;

