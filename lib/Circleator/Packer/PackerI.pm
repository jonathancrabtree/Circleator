#!/usr/bin/perl

package Circleator::Packer::PackerI;

# An "interface" from which all packers should inherit.  A packer is
# a function/object that assigns each of a set of input features to
# a distinct vertical "tier" such that no two adjacent features will
# overlap when they are rendered.

# Subclasses should override the following method.
#
# $feat_list - listref of features to pack.  each feature should be 
#    a hashref with at least the following fields:
#      pack-fmin - start coordinate in 0-indexed interbase coordinates
#      pack-fmax - end coordinate in 0-indexed interbase coordinates
#
sub pack {
    my($self, $feat_list) = @_;

    # trivial default implementation: every feature is placed in the same tier
    my $tiers = [];
    push(@$tiers, @$feat_list);
    return $tiers;
}

1;
