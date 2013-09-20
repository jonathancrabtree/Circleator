#!/usr/bin/perl

package Circleator::SeqFunction::GCSkew;

use strict;
use Circleator::SeqFunction::SeqFunction;

our @ISA = qw(Circleator::SeqFunction::SeqFunction);

# ------------------------------------------------------------------
# Static (non-instance) methods
# ------------------------------------------------------------------
sub get_params {
    return [];
}

sub get_range {
    return (-1, 1);
}

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------
sub get_values {
    my($self, $seqref, $seqlen, $contig_info, $window_size, $window_offset) = @_;
    return $self->_get_seq_composition_function_values($seqref, $seqlen, $window_size, $window_offset, \&_gc_skew_fn);
}

sub _gc_skew_fn {
    my $base_counts = shift;
    my($total, $g, $c) = map {$base_counts->{$_}} ('total', 'Gg', 'Cc');
    return undef if (($g + $c) == 0);
    my $gc_skew = ($g - $c) / ($g + $c);
    return $gc_skew;
}

1;
