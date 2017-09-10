#!/usr/bin/perl

package Circleator::Packer::LinePacker;

# A simple line-based packer that makes the simplifying assumption
# that all of the features to be packed can be placed in uniformly-
# sized vertical tiers (i.e., either all of the input features are the
# same height or they are close enough in height that the maximum
# height can be used to determine the tier height.)
#
# Adapted from Sybil::Graphics::Packer::LinePacker from sybil.sf.net

use strict;
use Circleator::Packer::PackerI;

our @ISA = ('Circleator::Packer::PackerI');

# ------------------------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------------------------

# $circular_seqlen - either undef or the sequence length if we're packing on a circular coordinate system
# 
sub new {
    my($invocant, $logger, $circular_seqlen) = @_;
    my $class = ref($invocant) || $invocant;
    my $self = {
        'logger' => $logger,
	'circular_seqlen' => $circular_seqlen,
    };
    return bless $self, $class;
}

# ------------------------------------------------------------------
# PackerI
# ------------------------------------------------------------------

# $feats - listref of features to pack.  May be presorted to indicate the preferred
#    order in which features are to be packed (earlier position in listref = greater
#    preference for low-numbered tiers.)
#
sub pack {
    my($self, $feats) = @_;
    my $circular_seqlen = $self->{'circular_seqlen'};
    my $num_feats = defined($feats) ? scalar(@$feats) : 0;
    return [] if ($num_feats == 0);

    # create sorted doubly-linked list of start and end coordinates
    my $coords_ll = [];

    for (my $f = 0;$f < $num_feats;++$f) {
	my $feat = $feats->[$f];
	my($min,$max) = map {$feat->{$_}} ('pack-fmin', 'pack-fmax');
	push(@$coords_ll, { 'type' => 'S', 'region' => $feat, 'coord' => $min, 'previous_E' => undef, 'next_S' => undef, 'linkers' => [] });
	push(@$coords_ll, { 'type' => 'E', 'region' => $feat, 'coord' => $max, 'previous_E' => undef, 'next_S' => undef, 'linkers' => [] });
    }

    # sort by increasing start
    my @sorted_coords = sort { $a->{'coord'} <=> $b->{'coord'} } @$coords_ll;
    my $n_coords = scalar(@sorted_coords);

    # perform forward traversal of the list to link each E to next S, each S to next S
    &_traverseList(\@sorted_coords, 'forward');
	
    # perform reverse traversal of the list to link each S to previous E, each E to previous E
    &_traverseList(\@sorted_coords, 'reverse');

    # link each feature to its own endpoints
    my $feat_coords = {};
    for (my $i = 0; $i < $n_coords;++$i) {
	my($type, $feat) = map { $sorted_coords[$i]->{$_} } ('type', 'region');
	$feat_coords->{$feat}->{$type} = $i;
    }

    # let the packing commence
    my $tiers = [];
    my $feat_index = 0;
    my $feats_used = {};

    while ($feat_index < $num_feats) {
	# find a starting region for this line; use the first available
	my $feat = $feats->[$feat_index++];
	next if ($feats_used->{$feat});
	
	# fill one line
	my $line = [$feat];

	&_removeRegion($feat_coords, \@sorted_coords, $feat);
	$feats_used->{$feat} = 1;
	
	# add regions to the left of $feat
	my $nfeat = $feat;
	my $last_added = $feat;

	while ($nfeat = &_getPreviousRegion($feat_coords, \@sorted_coords, $nfeat)) {
	    # make sure that this feature doesn't wrap around and overlap with the initial feature
	    if (defined($circular_seqlen) && &_featsOverlap($nfeat, $feat, $circular_seqlen)) {
		last;
	    }
	    push(@$line, $nfeat);
	    &_removeRegion($feat_coords, \@sorted_coords, $nfeat);
	    $feats_used->{$nfeat} = 1;
	    $last_added = $nfeat;
	}
	# add regions to the right of $feat
	$nfeat = $feat;
	while ($nfeat = &_getNextRegion($feat_coords, \@sorted_coords, $nfeat)) {
	    # make sure that this feature doesn't wrap around and overlap with the "most previous" or original feature
	    if (defined($circular_seqlen) && (&_featsOverlap($nfeat, $feat, $circular_seqlen) || &_featsOverlap($nfeat, $last_added, $circular_seqlen))) {
		last;
	    }
	    push(@$line, $nfeat);
	    &_removeRegion($feat_coords, \@sorted_coords, $nfeat);
	    $feats_used->{$nfeat} = 1;
	}
	
	# done filling this line; move on to the next
	push(@$tiers, $line);
    }
    
    return $tiers;
}

# ------------------------------------------------------------------
# LinePacker
# ------------------------------------------------------------------

# If a feature crosses the origin split it into two features. If not,
# return only the original feature.
sub _splitFeat {
    my($feat, $circular_seqlen) = @_;
    my $feat_list = [];
    my($fmin, $fmax) = map {$feat->{'pack-'. $_}} ('fmin', 'fmax');
    if ($fmax < $fmin) {
	push(@$feat_list, {'pack-fmin' => $fmin, 'pack-fmax' => $circular_seqlen});
	push(@$feat_list, {'pack-fmin' => 0, 'pack-fmax' => $fmax});
    } else {
	push(@$feat_list, $feat);
    }

    # TODO - check that all coordinates are within range after transformation
    return $feat_list;
}

# Determine whether two features overlap, taking circular coordinates into account.
sub _featsOverlap {
    my($feat1, $feat2, $circular_seqlen) = @_;
    my($feats1, $feats2) = map { &_splitFeat($_, $circular_seqlen); } ($feat1, $feat2);

    # do exhaustive check for overlaps between feats1 and feats2
    # (this should entail at most 4 checks)
    foreach my $f1 (@$feats1) {
	foreach my $f2 (@$feats2) {
	    if (($f1->{'pack-fmax'} > $f2->{'pack-fmin'}) && ($f1->{'pack-fmin'} < $f2->{'pack-fmax'})) {
		return 1;
	    }
	}
    }
    return 0;
}

# Traverse doubly-linked list of coordinates in either the forward or reverse
# direction; used to initialize the data structures used in packing.
#	
sub _traverseList {
    my($sortedCoords, $direction) = @_;
    my($startIndex, $endIndex, $step, $linkToKey, $linkFrom);
    my $nCoords = scalar(@$sortedCoords);
    
    if ($direction eq 'forward') {
	$startIndex = 0;
	$endIndex = $nCoords-1;
	$step = 1;
	$linkToKey = 'next_S'; # target of the links
	$linkFrom = 'E';
    } else {
	$startIndex = $nCoords-1;
	$endIndex = 0;
	$step = -1;
	$linkToKey = 'previous_E';
	$linkFrom = 'S';
    }
    
    my $last_FROM_list = [];
    my $last_TO = undef;
    
    for (my $i = $startIndex;$i != $endIndex; $i += $step) {
	my $coord = $sortedCoords->[$i]->{'coord'};
	my $type = $sortedCoords->[$i]->{'type'};
	
	# =a coordinate of type $linkFrom
	if ($type eq $linkFrom) {
	    push(@$last_FROM_list, $i);
	} 
	# =a coordinate of type $linkTo
	else {
	    # create link from $last_TO to here and reset $last_TO
	    if (defined($last_TO)) {
		$sortedCoords->[$last_TO]->{$linkToKey} = $i;
		push(@{$sortedCoords->[$i]->{'linkers'}}, $last_TO);
	    }
	    $last_TO = $i;
	    
	    # create link from each strictly smaller or larger coordinate in $last_FROM_list to here
	    my $new_last_FROM_list = [];
	    foreach my $lastFROM (@$last_FROM_list) {
		my $lastFROMCoord = $sortedCoords->[$lastFROM]->{'coord'};
		if ($lastFROMCoord != $coord) {
		    $sortedCoords->[$lastFROM]->{$linkToKey} = $i;
		    push(@{$sortedCoords->[$i]->{'linkers'}}, $lastFROM);
		} else {
		    push(@$new_last_FROM_list, $lastFROM);
		}
	    }
	    $last_FROM_list = $new_last_FROM_list;
	}
    }
}
	
# subroutine to remove a single coordinate from the list
sub _removeCoordinate {
    my($sortedCoords, $index) = @_;
    my $entry = $sortedCoords->[$index];
    my $type = $entry->{'type'};
    my $keyName = ($type eq 'S') ? "next_S" : "previous_E";
    
    # update coordinates that are pointing to us
    my $linkers = $entry->{'linkers'};
    foreach my $linker (@$linkers) {
	$sortedCoords->[$linker]->{$keyName} = $entry->{$keyName};
	if (defined($entry->{$keyName})) {
	    push(@{$sortedCoords->[$entry->{$keyName}]->{'linkers'}}, $linker);
	}
    }
    $entry->{'linkers'} = [];
}
	
# get the next region to the left of $rnum
sub _getPreviousRegion {
    my($regionCoords, $sortedCoords, $rnum) = @_;
    my $startCoord = $regionCoords->{$rnum}->{'S'};
    my $previousEnd = $sortedCoords->[$startCoord]->{'previous_E'};
    if (!defined($previousEnd)) {
	return undef;
    } else {
	return $sortedCoords->[$previousEnd]->{'region'};
    }
}
	
# get the next region to the right of $rnum
sub _getNextRegion {
    my($regionCoords, $sortedCoords, $rnum) = @_;
    my $endCoord = $regionCoords->{$rnum}->{'E'};
    my $nextStart = $sortedCoords->[$endCoord]->{'next_S'};
    if (!defined($nextStart)) {
	return undef;
    } else {
	return $sortedCoords->[$nextStart]->{'region'};
    }
}

sub _removeRegion {
    my($regionCoords, $sortedCoords, $rnum) = @_;
    &_removeCoordinate($sortedCoords, $regionCoords->{$rnum}->{'S'});
    &_removeCoordinate($sortedCoords, $regionCoords->{$rnum}->{'E'});
}

sub _printLinkedListToStderr {
    my($sortedCoords) = @_;
    my $nCoords = scalar(@$sortedCoords);
    for (my $i = 0; $i < $nCoords;++$i) {
	my $type = $sortedCoords->[$i]->{'type'};
	my $region = $sortedCoords->[$i]->{'region'};
	my $coord = $sortedCoords->[$i]->{'coord'};
	my $prevE = $sortedCoords->[$i]->{'previous_E'} ||  '';
	my $nextS = $sortedCoords->[$i]->{'next_S'} || '';
	my $linkers = $sortedCoords->[$i]->{'linkers'};
    }
}

1;
