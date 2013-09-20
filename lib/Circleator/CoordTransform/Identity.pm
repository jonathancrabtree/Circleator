#!/usr/bin/perl

package Circleator::CoordTransform::Identity;

use strict;
use Circleator::CoordTransform::CoordTransform;
our @ISA = qw(Circleator::CoordTransform::CoordTransform);

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

sub transform {
  my($self, $coord) = @_;
  return $coord;
}

sub invert_transform {
  my($self, $coord) = @_;
  return $coord;
}

1;
