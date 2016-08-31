#!/usr/bin/perl

package Circleator::CoordTransform::LinearScale;

use strict;
use Circleator::CoordTransform::CoordTransform;
our @ISA = qw(Circleator::CoordTransform::CoordTransform);

# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------

# $params must contain the following values:
#  seqlen - total sequence length
#  segments - listref of hashrefs with the following keys
#   fmin - segment start coordinate from 0 - seqlen
#   fmax - segment end coordinate from (fmin+1) - seqlen
#   scale - a number >= 0 by which the apparent length of the segment is to be multipled
#
# The segments must be nonoverlapping.  
#
sub new {
  my($invocant, $logger, $params, $debug) = @_;
  my $self = Circleator::CoordTransform::CoordTransform::new(@_);
  $self->{'seqlen'} = $params->{'seqlen'};
  $self->{'segments'} = $params->{'segments'};
  $self->{'debug'} = $params->{'debug'};
  my $class = ref($invocant) || $invocant;
  bless $self, $class;
  $self->_init();
  return $self;
}

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

sub transform {
  my($self, $coord) = @_;
  # allow negative coordinates for consistency with Identity.pm
  if ($coord < 0) {
      $coord = $coord % $self->{'seqlen'};
  }
  my $segment = $self->_lookup_segment($coord);
  # use linear interpolation along $segment
  my($fmin, $fmax, $sfmin, $sfmax, $unscaled_bp, $scaled_bp) =
    map {$segment->{$_}} ('fmin', 'fmax', 'scaled_fmin', 'scaled_fmax', 'unscaled_bp', 'scaled_bp');
  if ($unscaled_bp == 0){
    $self->_log_segments();
    $self->{'logger'}->logdie("found segment with unscaled bp = 0 [fmin=$fmin fmax=$fmax sfmin=$sfmin sfmax=$sfmax scaled_bp=$scaled_bp]");
  }
  my $frac = ($coord - $fmin) / $unscaled_bp;
  my $res = $sfmin + ($scaled_bp * $frac);
  $self->{'logger'}->debug("linear transform mapped $coord to $res using segment from $fmin-$fmax (unscaled_bp=$unscaled_bp, scaled_bp=$scaled_bp)") if ($self->{'debug'});
  return $res;
}

sub invert_transform {
  my($self, $coord) = @_;
  if ($coord < 0) {
    $coord = $coord % $self->{'seqlen'};
  }
  my $segment = $self->_lookup_segment($coord, 1);
  # use linear interpolation along $segment
  my($fmin, $fmax, $sfmin, $sfmax, $unscaled_bp, $scaled_bp) =
    map {$segment->{$_}} ('fmin', 'fmax', 'scaled_fmin', 'scaled_fmax', 'unscaled_bp', 'scaled_bp');
  if ($unscaled_bp == 0){
    $self->_log_segments();
    $self->{'logger'}->logdie("found segment with unscaled bp = 0 [fmin=$fmin fmax=$fmax sfmin=$sfmin sfmax=$sfmax scaled_bp=$scaled_bp]");
  }
  my $frac = ($coord - $sfmin) / $scaled_bp;
  my $res = $fmin + ($unscaled_bp * $frac);
  return $res;
}

# ------------------------------------------------------------------
# Private methods
# ------------------------------------------------------------------

sub _init() {
    my($self) = @_;
    my($seqlen, $segments, $logger) = map { $self->{$_} } ('seqlen', 'segments', 'logger');
    my @sorted_segments = sort { $a->{'fmin'} <=> $b->{'fmin'} } @$segments;
    
    # check that scaling is feasible, print a warning and reduce it if not
    my $compute_bp_sums = sub {
      my $unscaled_bp_sum = 0;
      my $scaled_bp_sum = 0;
      my $last_fmax = undef;
      foreach my $seg (@sorted_segments) {
        my($fmin, $fmax, $scale) = map {$seg->{$_}} ('fmin', 'fmax', 'scale');
        my $unscaled_bp = $seg->{'unscaled_bp'} = $fmax - $fmin;
        my $scaled_bp = $seg->{'scaled_bp'} = $unscaled_bp * $scale;
        # fmin must be < fmax
        $logger->logdie("illegal segment has fmax ($fmax) < fmin ($fmin)") if ($fmax < $fmin);
        # segments cannot overlap
        $logger->logdie("overlapping segments not allowed (last_fmax=$last_fmax, fmin=$fmin)") if (defined($last_fmax) && ($fmin < $last_fmax));
        $logger->logdie("illegal segment with fmin=$fmin") if ($fmin < 0);
        $logger->logdie("illegal segment with fmax=$fmax") if ($fmax > $seqlen);
        $last_fmax = $fmax;
        $unscaled_bp_sum += $unscaled_bp;
        $scaled_bp_sum += $scaled_bp;
      }
      return($unscaled_bp_sum, $scaled_bp_sum);
    };

    my($unscaled_bp_sum, $scaled_bp_sum) = &$compute_bp_sums();

    # reduce scaled segments to take up only 75% of the available space
    if ($scaled_bp_sum >= $seqlen) {
      my $target_unscaled_bp_sum = int(0.75 * $seqlen);
      my $rfact = $target_unscaled_bp_sum / $scaled_bp_sum;
      $logger->warn("invalid scaled_segment_list: there is insufficient space for the unscaled sequence at the specified 'scale' factor.");
      $logger->warn("automatically reducing the scaling by a factor of $rfact. To remove this warning please decrease the 'scale' amount and rerun.");
      map { $_->{'scale'} *= $rfact; } @sorted_segments;
      ($unscaled_bp_sum, $scaled_bp_sum) = &$compute_bp_sums();
    }

    my $leftover_scaled_bp = $seqlen - $scaled_bp_sum;
    my $leftover_unscaled_bp = $seqlen - $unscaled_bp_sum;
    # compute scale factor for the rest of the sequence not covered by the segment list
    my $leftover_seq_scale = $leftover_scaled_bp / $leftover_unscaled_bp;
    $self->{'logger'}->debug("scaled_bp_sum=$scaled_bp_sum, leftover_seq_scale=$leftover_seq_scale");

    # create new segment list with explicit segment for every region of the sequence
    my $new_segments = [];
    my $last_fmax = 0;
    my $scaled_fmin = 0;
    foreach my $seg (@sorted_segments) {
        my($fmin, $fmax, $scale) = map {$seg->{$_}} ('fmin', 'fmax', 'scale');
        # add missing segment _before_ this one, if necessary
        if ($fmin > $last_fmax) {
          my $scaled_bp = ($fmin - $last_fmax) * $leftover_seq_scale;
          my $scaled_fmax = $scaled_fmin + $scaled_bp;
          my $new_seg = {'fmin' => $last_fmax, 'fmax' => $fmin, 'unscaled_bp' => ($fmin - $last_fmax),
                         'scaled_fmin' => $scaled_fmin, 'scaled_fmax' => $scaled_fmax, 'scaled_bp' => $scaled_bp,
                         'scale' => $leftover_seq_scale};
          push(@$new_segments, $new_seg);
          $scaled_fmin = $scaled_fmax;
        }
        $seg->{'scaled_fmin'} = $scaled_fmin;
        $seg->{'scaled_fmax'} = $scaled_fmin + $seg->{'scaled_bp'};
        push(@$new_segments, $seg);
        $scaled_fmin = $seg->{'scaled_fmax'};
        $last_fmax = $fmax;
    }
    # add final missing segment, if necessary
    if ($last_fmax < $seqlen) {
        my $scaled_bp = $seqlen - $scaled_fmin;
        push(@$new_segments, {'fmin' => $last_fmax, 'fmax' => $seqlen, 'unscaled_bp' => ($seqlen - $last_fmax),
                              'scaled_fmin' => $scaled_fmin, 'scaled_fmax' => $seqlen, 'scaled_bp' => $scaled_bp,
                              'scale' => $leftover_seq_scale});
    }
    $self->{'segments'} = $new_segments;
    $self->_log_segments();
}

sub _lookup_segment {
    my($self, $coord, $invert_transform) = @_;
    my($seqlen, $segments, $logger) = map { $self->{$_} } ('seqlen', 'segments', 'logger');
    my($fmin_att, $fmax_att) = $invert_transform ? ('scaled_fmin', 'scaled_fmax') : ('fmin', 'fmax');
    if (($coord < 0) || ($coord > $seqlen)) {
      $logger->logdie("out-of-range coordinate ($coord) passed to _lookup_segment for sequence of length $seqlen");
    }
    my $segment = undef;
    # TODO - use something faster than a linear search
    foreach my $seg (@$segments) {
      # multiple matches can be found if the requested coordinate is on the boundary but the
      # result should be the same
      if (($seg->{$fmin_att} <= $coord) && ($seg->{$fmax_att} >= $coord)) {
        $segment = $seg;
      }
    }
    $logger->logdie("no segment found for coord=$coord") if (!defined($segment));
    return $segment;
}

sub _log_segments {
  my($self) = @_;
  if ($self->{'debug'}) {
      my($logger, $segments) = map {$self->{$_}} ('logger', 'segments');
      $logger->debug("LinearScale has " . scalar(@$segments) . " scaled segment(s):");
      foreach my $ns (@$segments) {
	  $logger->debug(join(" ", map {$_ . "=>" . $ns->{$_}} ('fmin', 'fmax', 'unscaled_bp', 'scaled_fmin', 'scaled_fmax', 'scaled_bp', 'scale')));
      }
  }
}

1;

