package Circleator::Config::Config;

my $DEFAULT_MAX_END_FRAC = 1;

# TODO - add method and/or option to rescale track starts and/or ends into a specified range (e.g., 0-1)

# ensure each track has a unique name
sub update_track_names {
  my($tracks, $logger) = @_;
  my $tracks_by_name = {};

  my $nt = scalar(@$tracks);
  for (my $t = 0;$t < $nt;++$t) {
    my $track = $tracks->[$t];
    my $tname = $track->{'name'};
    # record original, possibly non-unique name
    $track->{'original_name'} = $tname;
    # assign nameless tracks a number
    if (!defined($tname) || ($tname =~ /^\s*$/)) {
      $track->{'name'} = $t+1;
    }
    else {
      my $list = $tracks_by_name->{$name};
      $list = $tracks_by_name->{$name} = [] if (!defined($list));
      push(@$list, $track);
    }
  }  

  # append a .1, .2., .3 to any duplicates
  foreach my $name (keys %$tracks_by_name) {
    my $list = $tracks_by_name->{$name};
    my $ll = scalar(@$list);
    if ($ll > 1) {
      my $suffix = 1;
      map { $_->{'name'} .= "." . $suffix++; } @$list;
    }
  }
}

# compute explicit start and end fraction values for each track
sub update_track_start_and_end_fracs {
  my($tracks, $logger, $debug) = @_;

  # compute start-frac and end-frac for those not explicitly specified
  my $nt = scalar(@$tracks);
  my $last_start_frac = $DEFAULT_MAX_END_FRAC;
  my $last_end_frac = $DEFAULT_MAX_END_FRAC;

  for (my $t = 0;$t < $nt;++$t) {
    my $track = $tracks->[$t];
    my $tname = $track->{'name'};
    my $tglyph = $track->{'glyph'};
    # save original values in case positions have to be recomputed (e.g., for loop unrolling - see Circleator::Util::Loop)
    my($sf, $ef, $hf) = map { $track->{'original_' . $_} = $track->{$_}; } ('start-frac', 'end-frac', 'height-frac');
    my($sfs,$efs,$hfs) = map { defined($_) ? $_ : "" } ($sf, $ef, $hf);
    $logger->logdie("height-frac cannot be negative (set to $hfs for track ${tname})") if (defined($hf) && ($hf < 0));
    $logger->debug("track $tname before update: sf=$sfs ef=$efs hf=$hfs glyph=$tglyph") if ($debug);

    # TODO - turn this back into a warning _except_ for predefined tracks?
    if (defined($sf) && defined($ef) && defined($hf)) {
      $logger->debug("innerf ($sf), outerf ($ef), and heightf ($hf) are all specified for track ${tname}, ignoring height-frac") if ($debug);
      $hf = undef;
    }

    # if either sf or ef is 'same' it gets set to the same value as the previous track
    # sf or ef can also be set to some offset from the previous track's value e.g., "same+0.2" or "same-0.1"
    my $eval_frac = sub {
      my($frac, $last_frac) = @_;
      if ($frac eq 'same') {
        return $last_frac;
      } elsif ($frac =~ /^same\s*([+\-])\s*([\d\.]+)\s*$/) {
        my($op, $num) = ($1, $2);
        return ($op eq '+') ? $last_frac + $num : $last_frac - $num;
      } else {
        return $frac;
      }
    };

    if (defined($sf) && ($sf =~ /^same/)) {
      $sf = $track->{'start-frac'} = &$eval_frac($sf, $last_start_frac);
    }
    if (defined($ef) && ($ef =~ /^same/)) {
      $ef = $track->{'end-frac'} = &$eval_frac($ef, $last_end_frac);
    }

    # if $ef and $sf are omitted but $hf is not then $ef is set to the last start_frac
    if ((!defined($ef)) && (!defined($sf))) {
	# default height of 0 for tracks that don't actually display anything
	if (!defined($hf) && ($tglyph =~ /^(loop-|compute|load|scaled-segment-list)/)) {
	    $hf = 0;
	}
	if (defined($hf)) {
	    $ef = $track->{'end-frac'} = $last_start_frac;
	}
    }

    # if $hf is set it can be used in place of one of the endpoints
    if (defined($hf)) {
      if (!defined($sf)) {
        $sf = $track->{'start-frac'} = $ef - $hf;
      } elsif (!defined($ef)) {
        $ef = $track->{'end-frac'} = $sf + $hf;
      }
    }

    $logger->logdie("either heightf or innerf and/or outerf must be defined for track ${tname} with glyph=$tglyph") if (!defined($sf) || !defined($ef));
    $logger->logdie("innerf ($sf) > outerf ($ef) for track ${tname}") if ($sf > $ef);
    $logger->logdie("innerf ($sf) < 0 for track ${tname}") if ($sf < 0);
    # TODO - glyphs should be full-fledged objects, one of whose properties indicates whether they're typically 0-height
    $logger->warn("innerf ($sf) = outerf ($ef) for track ${tname} with glyph=$tglyph") if (($sf == $ef) && ($tglyph !~ /^(loop-|compute|load|scaled-segment-list|none)/));
    $logger->debug("Config track $t/$tname sf=$sf ef=$ef") if ($debug);

    $last_start_frac = $sf;
    $last_end_frac = $ef;
  }
}

sub index_tracks {
  my($tracks, $logger, $key) = @_;
  my $index = {};
  my $nt = scalar(@$tracks);
  for (my $t = 0;$t < $nt;++$t) {
    my $track = $tracks->[$t];
    my $tname = $track->{$key};
    my $list = $index->{$tname};
    $list = $index->{$tname} = [] if (!defined($list));
    push(@$list, $track);
  }
  return $index;
}

# $fn_factories - hashref mapping track attribute prefix (e.g., "color", "label-function") to a 
# coderef that takes as input a function name and returns a factory coderef that maps from 
# ($track, $att_name) to the function/coderef of the appropriate type.
#
sub update_track_function_refs {
  my($tracks, $logger, $fn_factories) = @_;

  # replace function keywords with actual (parameterized) functions
  foreach my $track (@$tracks) {
    foreach my $att (keys %$track) {
      my $tval = $track->{$att};
      foreach my $ff_re (keys %$fn_factories) {
        if ($att =~ /$ff_re/) {
          my $ff_fn = $fn_factories->{$ff_re};
          my $ff = &$ff_fn($tval);
	  # avoid double-replacements (Issue #25)
          if (defined($ff) && ($att !~ /original_fn/)) {
            # replace function name with the actual function
            $track->{'original_fn_' . $att} = $tval;
            $track->{$att} = &$ff($track, $att);
            last;
          }
        }
      }
    }
  }
}

1;
