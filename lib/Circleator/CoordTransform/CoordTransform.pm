#!/usr/bin/perl

package Circleator::CoordTransform::CoordTransform;

use strict;

# ------------------------------------------------------------------
# Static (non-instance) methods
# ------------------------------------------------------------------

# Constructor
sub new {
    my($invocant, $logger, $params) = @_;
    my $class = ref($invocant) || $invocant;
    my $self = {
        'logger' => $logger,
    };
    return bless $self, $class;
}

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

sub transform {
  my($self, $coord) = @_;
  die "subclasses must override transform";
}

sub invert_transform {
  my($self, $coord) = @_;
  die "subclasses must override invert_transform";
}

1;
