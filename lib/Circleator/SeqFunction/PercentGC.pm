#!/usr/bin/perl

package Circleator::SeqFunction::PercentGC;

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
    return (0,100);
}

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------
sub get_values {
    my($self, $seqref, $seqlen, $contig_info, $window_size, $window_offset) = @_;
    return $self->_get_seq_composition_function_values($seqref, $seqlen, $window_size, $window_offset, \&_gc_fn);
}

sub _gc_fn {
    my $base_counts = shift;
    # TODO - handle ambiguity chars?
    # TODO - subtract Ns from seqlen?
    my($total, $g, $c) = map {$base_counts->{$_}} ('total', 'Gg', 'Cc');
    my $percent_gc = (($g + $c)/$total) * 100.0;
    return $percent_gc;
}

1;
