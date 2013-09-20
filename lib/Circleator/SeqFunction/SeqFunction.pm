#!/usr/bin/perl

package Circleator::SeqFunction::SeqFunction;

use strict;
use POSIX qw(ceil);

# Base class for sequence functions.

# TODO - add a trivial sequence function that plots values from a flat file

# ------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------
my $IUPAC_CODES = {
    'A' => 'A',
    'C' => 'C',
    'G' => 'G',
    'T' => 'T',
    'M' => 'AC',
    'R' => 'AG',
    'W' => 'AT',
    'S' => 'CG',
    'Y' => 'CT',
    'K' => 'GT',
    'V' => 'ACG',
    'H' => 'ACT',
    'D' => 'AGT',
    'B' => 'CGT',
    'N' => 'ACGT',
};

my $MIN_OFFSET_FOR_ALT_SEQ_COMPOSITION_METHOD = 200;

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

# List of parameters that can be passed to the function in the config. file.
# Defaults to empty if not overridden.  May be used to check the validity of
# the configuration file.
sub get_params {
    return [];
}

# theoretical minimum and maximum values: undef for no limit
sub get_range {
    die "subclasses must override get_range";
}

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

# Evaluate the function on the entire sequence and return an arrayref of arrayrefs of 
# the form [$fmin, $fmax, $value] where $fmin and $fmax are the 0-based interbase start 
# and end coordinates of a region over which the function was evaluated, and $value is
# the value over that region.
#
sub get_values {
    my($self, $seqref, $seqlen, $contig_info, $window_size, $window_offset) = @_;
    die "subclasses must override get_subseq_value";
}

# ------------------------------------------------------------------
# "Helper" methods for subclasses to use
# ------------------------------------------------------------------

# Implementation of get_values for any sequence function (supplied as a callback) that
# depends solely on the base composition of the sequence (e.g., %GC, GC-skew)
#
# $callback - coderef that accepts a hashref of base counts (indexed by IUPAC character)
#             and returns the corresponding function value.  The hashref will also contain
#             the special keys 'total' (for the total number of bases in the substring)
#             and 'not_actgn' for the count of bases that aren't a,c,t,g, or n.  Note that
#             the counts _are_ case sensitive, so to get case-insensitive counts use the
#             following keys: 'Aa', 'Cc', 'Tt', 'Gg', etc.
#
sub _get_seq_composition_function_values {
    my($self, $seqref, $seqlen, $window_size, $window_offset, $callback) = @_;
    if (!defined($seqref) || (length($$seqref) == 0)) {
      $self->{'logger'}->error("can't compute sequence function without sequence");
      return [];
    }

    my $windows_overlap = ($window_offset < $window_size);

    # alternate/string-based method is faster for 5kbp windows when offset >= ~150-200
    #
    # offset = 100 original: 46 secs alt: 65 seconds
    # offset = 200 original: 43 secs alt: 34 seconds
    # offset = 1000 original: 42 secs alt: 10 seconds
    # offset = 5000 original: 40 secs alt: 5 seconds
    # 
    if ($window_offset >= $MIN_OFFSET_FOR_ALT_SEQ_COMPOSITION_METHOD) {
	return _get_seq_composition_function_values_alt(@_);
    }

    my $base_counts = { 'total' => 0, 'not_actgn' => 0 };
    $self->{'logger'}->warn("window_offset ($window_offset) > window size ($window_size)") if ($window_offset > $window_size);

    # set initial counts to zero
    foreach my $bc (keys %$IUPAC_CODES) {
	$base_counts->{uc($bc)} = 0;
	$base_counts->{lc($bc)} = 0;
	$base_counts->{uc($bc) . lc($bc)} = 0;
    }

    my $values = [];
    
    # generate list of counts affected by a given base
    my $get_base_count_keys = sub {
	my $base = shift;
	my $keys = ['total'];
	# case-sensitive base count
	push(@$keys, $base);
	# case-insensitive base count
	my $ci_key = uc($base) . lc($base);
	push(@$keys, $ci_key);
	push(@$keys, 'not_actgn') if ($base !~ /actgn/i);;
	return $keys;
    };

    my $last_fmax = 0;
    my $num_windows = ceil($seqlen / $window_offset);
    my $end_char = $window_size + (($num_windows-1) * $window_offset);

    for (my $i = 0;$i < $end_char;++$i) {
	my $drop_char = 0;

	# don't wrap around if doing nonoverlapping windows
	if (($i >= $seqlen) && (!$windows_overlap)) {
	    $drop_char = 1;
	} 
	else {
	    # add the next base to the current counts
	    my $base = substr($$seqref, $i % $seqlen, 1);
	    my $bkeys = &$get_base_count_keys($base);
	    map { ++$base_counts->{$_} } @$bkeys;
	}

	# remove the oldest base from the counts, if current count is above window size
	if (($base_counts->{'total'} > $window_size) || $drop_char) {
	    my $oldBase = substr($$seqref, $i-$window_size, 1);
	    my $oldKeys = &$get_base_count_keys($oldBase);
	    map { --$base_counts->{$_} } @$oldKeys;
	}

	# report current value, if we're at an even multiple of window_offset or at the end 
	if (((($i+1) >= $window_size) && ((($i+1) % $window_offset) == 0))) {
	    my $value = &$callback($base_counts);
	    my $range_end = $i+1;
	    if ($range_end > $seqlen) {
		$range_end = $windows_overlap? ($range_end % $seqlen) : $seqlen;
	    }
	    push(@$values, [$last_fmax, $range_end, $value]);
	    $last_fmax += $window_offset;
	}
    }

    # DEBUG - compare values and alt_values
#    my $nv = scalar(@$values);
#    my $nav = scalar(@$alt_values);
#    die "nv=$nv nav=$nav" if ($nv != $nav);
#    for (my $i = 0;$i < $nv;++$i) {
#	my $v1 = $values->[$i];
#	my $v2 = $alt_values->[$i];
#	my($v1a,$v1b,$v1c) = @$v1;
#	my($v2a,$v2b,$v2c) = @$v2;
#	if (($v1a != $v2a) || ($v1b != $v2b) || ($v1c != $v2c)) {
#	    die "mismatch at $i: [$v1a,$v1b,$v1c] vs. [$v2a,$v2b,$v2c]";
#	}
#    }

    return $values;
}

# alternate implementation of _get_seq_composition_function_values that evaluates each window as an independent string,
# rather than doing base-by-base counting.
#
sub _get_seq_composition_function_values_alt {
    my($self, $seqref, $seqlen, $window_size, $window_offset, $callback) = @_;
    if (!defined($seqref) || (length($$seqref) == 0)) {
      $self->{'logger'}->error("can't compute sequence function without sequence");
      return [];
    }
    my $windows_overlap = ($window_offset > $window_size);
    $self->{'logger'}->warn("window_offset ($window_offset) > window size ($window_size)") if ($window_offset > $window_size);
    my $values = [];

    for (my $start = 0; $start < $seqlen; $start += $window_offset) {
	my $end = $start + $window_size;
	if ($windows_overlap) {
	    # TODO - handle wrapping around the origin correctly if doing overlapping windows
	    die "wrapping overlapping windows not yet supported";
	} 
	# otherwise last window may be a different size in nonoverlapping window mode
	else {
	    $end = $seqlen if ($end > $seqlen);
	}
	my $actual_window_size = $end - $start;

	# get sequence substring
	my $ss = substr($$seqref, $start, $actual_window_size);
	die "internal error" if (length($ss) != $actual_window_size);
	
	my $base_counts = { 'total' => $actual_window_size };
	# compute base counts
	foreach my $ic (keys %$IUPAC_CODES) {
	    my $ucb = uc($ic);
	    my $lcb = lc($ic);
	    my $uc_count = $ss =~ s/${ucb}//g;
	    my $lc_count = $ss =~ s/${lcb}//g;
	    $uc_count = 0 if (!defined($uc_count));
	    $lc_count = 0 if (!defined($lc_count));
	    $base_counts->{$ucb} = $uc_count;
	    $base_counts->{$lcb} = $lc_count;
	    $base_counts->{$ucb . $lcb} = $uc_count + $lc_count;
	}
	
	# not_actgn is everything that's left
	my $actgn = ($base_counts->{'Aa'} + $base_counts->{'Cc'} + $base_counts->{'Tt'} + $base_counts->{'Gg'} + $base_counts->{'Nn'});
	$base_counts->{'not_actgn'} = $base_counts->{'total'} - $actgn;
	my $value = &$callback($base_counts);
	push(@$values, [$start, $end, $value]);
    }
    
    return $values;
}

1;
