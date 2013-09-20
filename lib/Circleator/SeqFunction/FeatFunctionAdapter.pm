#!/usr/bin/perl

package Circleator::SeqFunction::FeatFunctionAdapter;

use strict;
use Circleator::SeqFunction::SeqFunction;

our @ISA = qw(Circleator::SeqFunction::SeqFunction);

# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------
sub new {
    my($invocant, $logger, $params) = @_;
    my $self = Circleator::SeqFunction::SeqFunction::new(@_);
    map { $self->{$_} = $params->{$_}; } ('feat-function', 'feats');
    my $class = ref($invocant) || $invocant;
    bless $self, $class;
    $logger->logdie("FeatFunctionAdapter parameter 'feat-function' is required") if (!defined($self->{'feat-function'}));
    $logger->logdie("FeatFunctionAdapter parameter 'feats' is required") if (!defined($self->{'feats'}));
    return $self;
}

# ------------------------------------------------------------------
# Static (non-instance) methods
# ------------------------------------------------------------------

sub get_params {
    return ['feat-function', 'feats'];
}

sub get_range {
    return (undef, undef);
}

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

sub get_values {
    my($self, $seqref, $seqlen, $contig_info, $window_size, $window_offset) = @_;
    my $ff = $self->{'feat-function'};
    my $feats = $self->{'feats'};
    my $values = [];
    
    # sort by ascending position
    my @sorted_feats = sort { ($a->start() <=> $b->start()) || ($a->end() <=> $b->end()) } @$feats;

    # not worrying about overlapping features
    # NOTE: no need to worry about adjust for contig position/orientation: these features are already in world coordinates
    foreach my $sf (@sorted_feats) {
      my $sval = &$ff($sf);
      push(@$values, [$sf->start()-1, $sf->end(), $sval]);
    }
    return $values;
}

1;
