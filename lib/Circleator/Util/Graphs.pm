package Circleator::Util::Graphs;

use strict;
use Circleator::Util::Colors;

$Circleator::Util::Graphs::DEFAULT_WINDOW_SIZE = 5000;

# ------------------------------------------------------------------
# Static methods
# ------------------------------------------------------------------

# Resolve graph function and parameters.
sub resolve_graph_class_and_params {
  my($logger, $track, $graph_fn_name, $tf_callback) = @_;

  # try to resolve Perl package that implements the requested graph function
  my $g_func_class = 'Circleator::SeqFunction::' . $graph_fn_name;
  eval "require $g_func_class";
  my $params = {};

  # if graph function can't be found in Circleator::SeqFunction then check Circleator::FeatFunction::Numeric
  if ($@ && $@ =~ /^can\'t locate/i) {
    $g_func_class = 'Circleator::SeqFunction::FeatFunctionAdapter';
    my $f_func_class = 'Circleator::FeatFunction::Numeric::' . $graph_fn_name;
    eval "require $f_func_class";
    $logger->logdie("failed to find/load graph function '$graph_fn_name' from either Circleator::SeqFunction or Circleator::FeatFunction::Numeric") if ($@);
    # pass the feature function to the adapter
    eval "\$params->{'feat-function'} = ${f_func_class}::get_function(\$track, \$track->{'name'});";
    $logger->logdie("failed to call get_function on $f_func_class: $@") if $@;
    # get set of features that the feat function will operate on
    my $tfs = &$tf_callback();
    $params->{'feats'} = $tfs->{'features'};
  }
  else {
    # collect required parameters
    my $needed_params;
    my $es = "\$needed_params = &${g_func_class}::get_params();";
    eval $es;
    map { $params->{$_} = $track->{$_}; } @$needed_params;
  }
  return ($g_func_class, $params);
}

sub get_graph_and_values {
  my($logger, $g_func_class, $params, $seq, $seqlen, $contig_location_info, $richseq, $track, $tracks, $config, $omit_short_last_window) = @_;
  my $contig_positions = $contig_location_info->{'positions'};
  my($window_size, $window_offset) = map {$track->{$_}} ('window-size', 'window-offset');
  $window_size = $Circleator::Util::Graphs::DEFAULT_WINDOW_SIZE if (!defined($window_size));
  # default = nonoverlapping windows
  $window_offset = $window_size if (!defined($window_offset));

  # TODO - print helpful error message (and list available packages?) if this fails
  use Data::Dumper;
  my $g_func_obj = $g_func_class->new($logger, $params);

  # use $g_func to compute values to plot
  my $values = $g_func_obj->get_values($seq, $seqlen, $contig_location_info, $window_size, $window_offset);

  # TODO - this doesn't work in the multiple sequence case
  if ($omit_short_last_window) {
    my $lwl = ($values->[-1]->[1] - $values->[-1]->[0]);
    if ($lwl < $window_size) {
      pop(@$values);
    }
  }
  return($g_func_obj, $values);
}

# $update_value_fn - replaces symbolic values such as "data_min" with their actual values for the current data set
#
sub get_heat_map_color_function {
  my($logger, $conf_dir, $track, $tracks, $config, $update_value_fn) = @_;
  my($hm_min, $hm_max, $hmv, $hmc, $hmlb, $hmorc, $hmbp) = 
    map {$track->{$_}} 
      ('heat-map-min-value', 'heat-map-max-value', 'heat-map-values', 'heat-map-colors', 'heat-map-log-base', 
       'heat-map-out-of-range-color', 'heat-map-brewer-palette');
  
  # TODO - add some heat_map_interpolation options
  # TODO - add way to automate matching a divergent palette's critical point with data_avg (or some predefined set point)

  # defaults
  $hmorc = 'none' if (!defined($hmorc));

  # if no colors or color palette defined then the
  # default is a sequential 9 color white - red Brewer color palette from data_min to data_max
  if ((!defined($hmc) && (!defined($hmbp)))) {
    $hmbp = 'ylorrd-seq-9';
  }

  $hm_min = 'data_min' if (!defined($hm_min) && !defined($hmv));
  $hm_max = 'data_max' if (!defined($hm_max) && !defined($hmv));

  # the list of colors from heat-map-brewer-palette overrides heat-map-colors if present
  if (defined($hmbp)) {
    my $bp = &Circleator::Util::Colors::get_brewer_palette($logger, $conf_dir, $hmbp);
    if (defined($bp)) {
      $hmc = join("|", @{$bp->{'colors'}});
    }
  }

  # undo/reverse log-scaling before computing color
  my $log_base_fn = sub {
    my $v = shift;
    if (defined($hmlb)) {
      my $newval = $hmlb ** $v;
      $v = $newval;
    }
    return $v;
  };

  # convert all colors to [$r,$g,$b]
  my $color_fn = sub {
    my $c = shift;
    my $rgb = &Circleator::Util::Colors::string_to_rgb($logger, $conf_dir, $c);
    if (!defined($rgb)) {
      $logger->error("unrecognized color specifier '$c' in heat_map_colors list");
      return [0,0,0];
    }
    return $rgb;
  };

  # parse lists and replace symbolic values (e.g., data_min, data_avg) with the actual numbers
  $hm_min = &$update_value_fn($hm_min) if (defined($hm_min));
  $hm_max = &$update_value_fn($hm_max) if (defined($hm_max));

  # $hmv doesn't have to be defined
  my @hm_vals = undef;
  @hm_vals = map { &$log_base_fn(&$update_value_fn($_)) } split(/\s*\|\s*/, $hmv) if (defined($hmv));

  # hmc _does_ have to be defined
  my @hm_colors = map {&$color_fn($_)} split(/\s*\|\s*/, $hmc);
  my $num_colors = scalar(@hm_colors);
  my $num_vals = scalar(@hm_vals);
  
  # ignore the extra colors and/or values if there are too many
  if (defined($hmv) && ($num_colors != $num_vals)) {
    my $ne = undef;
    if ($num_vals < $num_colors) {
      $num_colors = $num_vals;
      my $diff = $num_colors - $num_vals;
      $ne = "$diff color(s)";
    } else {
      my $diff = $num_vals - $num_colors;
      $ne = "$diff value(s)";
    }
    $logger->warn("$num_vals heat-map-values and $num_colors heat-map-colors were specified, ignoring the extra $ne");
  }

  # check that hm_vals are in order 
  my $map_intervals = undef;
  if ($num_vals > 0) {
    $map_intervals = [];
    my $last_value = undef;
    for (my $c = 0;$c < $num_colors;++$c) {
      push(@$map_intervals, {'value' => $hm_vals[$c], 'color' => $hm_colors[$c]});
      # print warning about out-of-order values
      if (defined($last_value) && ($hm_vals[$c] <= $last_value)) {
        $logger->warn("heat-map-values is not in strictly ascending order: value $hm_vals[$c] is out of order");
      }
      $last_value = $hm_vals[$c];
    }
    my @sorted_map_intervals = sort { $a->{'value'} <=> $b->{'value'} } @$map_intervals;
    $map_intervals = \@sorted_map_intervals;
  }

  return sub {
    my($value) = @_;
    $value = &$log_base_fn($value);

    # option 1: use heat-map-values with linear interpolation between the colors listed in heat-map-colors
    if (defined($hmv)) {
      # given a value determine which 2 colors it's between and then linearly interpolate
      # linear search should be OK here: color array shouldn't be big
      my $from = undef;
      my $to = undef;
      
      for (my $c = 0;$c < $num_colors-1;++$c) {
        my $iv1 = $map_intervals->[$c]->{'value'};
        my $iv2 = $map_intervals->[$c+1]->{'value'};
        if (($value >= $iv1) && ($value <= $iv2)) {
          $from = $c;
          $to = $c+1;
        }
      }
      
      # print a warning if $value is out of range and return no color
      if (!defined($from) || !defined($to)) {
        $logger->warn("heat map value $value is out of range of specified heat-map-values");
        return $hmorc;
      }
      
      # otherwise return interpolated color
      my $from_i = $map_intervals->[$from];
      my $to_i = $map_intervals->[$to];
      my $frac = ($value - $from_i->{'value'}) / ($to_i->{'value'} - $from_i->{'value'});
      my($from_c, $to_c) = map {$_->{'color'}} ($from_i, $to_i);
      # interpolate
      my($nr, $ng, $nb) = map { int(($frac * ($to_c->[$_] - $from_c->[$_])) + $from_c->[$_]) } (0,1,2);
      return "rgb(" . join(',', ($nr, $ng, $nb)) . ")";
    }
    # option 2: use linear interpolation to pick one of the exact colors from hm_colors
    else {
      # print a warning if $value is out of range and return no color
      if (($value < $hm_min) || ($value > $hm_max)) {
        $logger->warn("heat map value $value is out of range of specified hm_min ($hm_min) and hm_max ($hm_max)");
        return $hmorc;
      }
      my $frac = ($value - $hm_min) / ($hm_max - $hm_min);
      # pick the _closest_ of the colors
      # divide range evenly amongst the colors
      my $n = int($frac * $num_colors);
      $n = 0 if ($n < 0);
      $n = $num_colors - 1 if ($n >= $num_colors);
      return "rgb(" . join(',', @{$hm_colors[$n]}) . ")";
    }
  };
}

1;
