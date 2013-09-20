package Circleator::Util::Tracks;

# ------------------------------------------------------------------
# Static methods
# ------------------------------------------------------------------

sub resolve_track_reference {
  my($logger, $all_tracks, $config, $tnum, $feat_track_name) = @_;
  my $num_tracks = scalar(@$all_tracks);
  my $referenced_track = undef;
  
  if (defined($feat_track_name) && ($feat_track_name =~ /\S/)) {  
    my $orig_feat_track_name = $feat_track_name;

    # first check track name against unique track names and then against original track names
    my $t = $config->{'tracks_by_name'}->{$feat_track_name};
    my $ot = $config->{'tracks_by_original_name'}->{$feat_track_name};

    # unique track name match
    if (defined($t) && (scalar(@$t) == 1)) {
      $feat_track_name = $t->[0]->{'tnum'};
    }
    # original track name match
    elsif (defined($ot) && (scalar(@$ot) == 1)) {
      $feat_track_name = $ot->[0]->{'tnum'};
    }

    # now see whether it can be interpreted as an absolute or relative track index
    # relative track index, special cases
    if ($feat_track_name =~ /^next$/) {
      $feat_track_name = '+1';
    } elsif ($feat_track_name =~ /^prev|previous$/) {
      $feat_track_name = '-1';
    }
    # relative track indexes: integer preceded by + or -
    if ($feat_track_name =~ /^\+(\d+)$/) {
      $feat_track_name = $tnum + $1;
    } elsif ($feat_track_name =~ /^\-(\d+)$/) {
      $feat_track_name = $tnum - $1;
    }

    # at this point we should have a numeric track index in the $range [1, $num_tracks]
    if ($feat_track_name !~ /^\d+$/) {
      $logger->error("feat-track '$orig_feat_track_name' cannot be resolved to a valid track index");
    } elsif (($feat_track_name < 1) || ($feat_track_name > $num_tracks)) {
      $logger->error("feat-track '$orig_feat_track_namep' resolves to an out-of-range track index ($feat_track_name)");
    } else {
      $referenced_track = $all_tracks->[$feat_track_name - 1];
    }
  }
  return $referenced_track;
}

1;

