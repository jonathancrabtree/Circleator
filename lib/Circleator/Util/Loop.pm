package Circleator::Util::Loop;

# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------
sub new {
    my($invocant, $logger, $params) = @_;
    my $self = {};
    $self->{'logger'} = $logger;
    die "logger must be defined" unless $logger;
    my $class = ref($invocant) || $invocant;
    bless $self, $class;
    return $self;
}

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

sub unroll_loop {
  my($self, $tracks, $track, $config) = @_;
  my($tnum, $lvar, $lvalues, $ldepth) = map { $track->{$_} } ('tnum', 'loop-var', 'loop-values', 'loop-depth');
  $self->{'logger'}->logdie("loop-depth not defined in track $tnum") unless (defined($ldepth) && ($ldepth =~ /^\d+$/));

  # iterate over subsequent tracks looking for a matching loop-end (matching = has same loop var or no loop var specified)
  # index of the loop-start glyph
  my $loop_start_tnum = undef;
  # index of the loop-end glyph
  my $loop_end_tnum = undef;
  my $loop_tracks = [];
  my $new_tracks_pre = [];
  my $new_tracks_post = [];
  my $nt = scalar(@$tracks);

  for (my $t = 0;$t < $nt;++$t) {
    my $tr = $tracks->[$t];
    $self->{'logger'}->debug("loop unroll checking track $t with glyph=" . $tr->{'glyph'}) if ($config->{'debug_opts'}->{'loops'});

    # loop end already found
    if (defined($loop_end_tnum)) {
      push(@$new_tracks_post, $tr);
    }
    # loop start already found
    elsif (defined($loop_start_tnum)) {
      my($lv, $glyph, $ld) = map {$tr->{$_}} ('loop-var', 'glyph', 'loop-depth');
      # check for matching loop end and exit the loop when found
      if (($glyph eq 'loop-end') && ($ld == $ldepth)) {
	  $self->{'logger'}->debug("found loop-end glyph at track $t") if ($config->{'debug_opts'}->{'loops'});
        $loop_end_tnum = $t;
      } else {
        # loop end not yet found - add track to those in the loop
        push(@$loop_tracks, $tr);
      }
    } else {
      if ($tr eq $track) {
        $loop_start_tnum = $t;
        # sanity check
        $self->{'logger'}->logdie("actual loop-start track number ($loop_start_tnum) does not match tnum ($tnum)") unless ($loop_start_tnum == ($tnum-1));
      } else {
        push(@$new_tracks_pre, $tr);
      }
    }
  }
  my $nlt = scalar(@$loop_tracks);
  if ($config->{'debug_opts'}->{'loops'}) {
    $self->{'logger'}->debug("loop_unroll for $lvar found $nlt loop tracks at positions $loop_start_tnum - $loop_end_tnum");
    $self->{'logger'}->debug("loop_unroll: $nt track(s) before unroll");
  }
  # sanity check
  $self->{'logger'}->logdie("internal error: track count mismatch while processing loop") unless ($nt = (scalar(@$new_tracks_pre) + scalar(@$new_tracks_post) + 2 + $nlt));

  # make a copy of the loop tracks for each loop value, performing the substitution on each track
  my $all_loop_tracks = [];
  my $nlv = scalar(@$lvalues);

  for (my $lv = 0;$lv < $nlv;++$lv) {
    my $lvalue = $lvalues->[$lv];
    $self->{'logger'}->debug("loop_unroll processing iteration $lv: $lvar=$lvalue") if ($config->{'debug_opts'}->{'loops'});
    # substitutions to perform
    my $subs = 
      {
       $lvar => $lvalue,
       # odd/even flags are based on counting from 1, not 0:
       'LOOP_ODD' => 1 - ($lv % 2),
       'LOOP_EVEN' => ($lv % 2),
      };
    
    foreach my $lt (@$loop_tracks) {
      my $copy = $self->clone_track($lt, $subs);
      push(@$all_loop_tracks, $copy);
    }
  }

  if ($config->{'debug_opts'}->{'loops'}) {
    $self->{'logger'}->debug("loop_unroll: " . scalar(@$new_tracks_pre) . " new_tracks_pre");
    $self->{'logger'}->debug("loop_unroll: " . scalar(@$new_tracks_post) . " new_tracks_post");
    $self->{'logger'}->debug("loop_unroll: " . scalar(@$all_loop_tracks) . " all_loop_track");
  }

  # add the newly-created loop tracks, leaving the loop start/end tracks in place as markers
  my $new_tracks = $config->{'tracks'} = [];
  push(@$new_tracks, @$new_tracks_pre);
  push(@$new_tracks, $tracks->[$loop_start_tnum]); # loop start
  push(@$new_tracks, @$all_loop_tracks);
  push(@$new_tracks, $tracks->[$loop_end_tnum]); # loop end
  push(@$new_tracks, @$new_tracks_post);

  if ($config->{'debug_opts'}->{'loops'}) {
    $self->{'logger'}->debug("loop_unroll: " . scalar(@$new_tracks) . " track(s) after unroll");
    # reset and recompute start/end fracs (which may result in an overflow error)
    $self->{'logger'}->debug("loop_unroll restoring original start-frac, end-frac, height-frac");
  }
  foreach my $t (@{$config->{'tracks'}}) {
    map { $t->{$_} = $t->{'original_' . $_}; } ('start-frac', 'end-frac', 'height-frac');
  }
  $self->{'logger'}->debug("loop_unroll updating track start and end fracs for " . scalar(@{$config->{'tracks'}}) . " track(s)") if ($config->{'debug_opts'}->{'loops'});
  &Circleator::Config::Config::update_track_start_and_end_fracs($config->{'tracks'}, $self->{'logger'}, $config->{'debug_opts'}->{'tracks'});

  # reset and recompute track names and rebuild indexes
  map { $_->{'name'} = $_->{'original_name'} if (defined($_->{'original_name'})); } @{$config->{'tracks'}};
  $self->{'logger'}->debug("loop_unroll updating track names") if ($config->{'debug_opts'}->{'loops'});
  &Circleator::Config::Config::update_track_names($config->{'tracks'}, $self->{'logger'});

  # reset and recompute track functions
  foreach my $t (@{$config->{'tracks'}}) {
    foreach my $k (keys %$t) {
      if ($k =~ /^original\_fn\_(.*)$/) {
        my $v = $t->{$k};
        $t->{$1} = $v;
      }
    }
  }
  $self->{'logger'}->debug("loop_unroll updating track coderefs") if ($config->{'debug_opts'}->{'loops'});
  &Circleator::Config::Config::update_track_function_refs($config->{'tracks'}, $self->{'logger'}, $config->{'fn_factories'});

  # index tracks by name and unique name
  $self->{'logger'}->debug("loop_unroll updating track indexes") if ($config->{'debug_opts'}->{'loops'});
  $config->{'tracks_by_name'} = &Circleator::Config::Config::index_tracks($config->{'tracks'}, $self->{'logger'}, 'name');
  $config->{'tracks_by_original_name'} = &Circleator::Config::Config::index_tracks($config->{'tracks'}, $self->{'logger'}, 'original_name');

  # update tnums
  $self->{'logger'}->debug("loop_unroll updating track tnums") if ($config->{'debug_opts'}->{'loops'});
  my $tnum = 0;
  map { $_->{'tnum'} = ++$tnum; } @{$config->{'tracks'}};
}

# Deep clone of track data structure, but copying any CODE refs and replacing any occurrences of
# "<$replace>" with $with in the scalars within the track.
#
# TODO - doing this substitution "right" (i.e., so that substitutions can be applied to function names) probably entails:
#  1. doing the substitution on the original _text_ of the line
#  2. handing that text back to Config::Standard (or whatever Config module was used) for reinterpretation
#
sub clone_track {
  my($self, $track, $subs) = @_;
  return undef if (!defined($track));
  my $rt = ref $track;

  # scalar or coderef
  if (($rt eq '') || ($rt eq 'CODE')) {
    my $copy = $track;
    foreach my $replace (keys %$subs) {
      my $with = $subs->{$replace};
      $copy =~ s/\<$replace\>/$with/g;
    }
    return $copy;
  }
  elsif ($rt eq 'HASH') {
    my $new_hr = {};
    # assuming that the hash keys are scalars
    foreach my $k (keys %$track) {
      my $v = $track->{$k};
      $new_hr->{$k} = &clone_track($self, $v, $subs);
    }
    return $new_hr;
  }
  elsif ($rt eq 'ARRAY') {
    my @new_array = map { &clone_track($self, $_, $subs) } @$track;
    return \@new_array;
  }
  else {
    # error
    $self->{'logger'}->logdie("don't know how to clone value of type $rt: $t");
  }
}

# ------------------------------------------------------------------
# Static methods
# ------------------------------------------------------------------

# Tag each loop-start and loop-end track with the depth of that loop. Top-level
# loops are assigned depth = 1. An error will be printed if the loops aren't 
# properly nested.
#
sub update_loop_track_depths {
  my($tracks, $logger) = @_;
  my $depth = 0;
  
  my $nt = scalar(@$tracks);
  for (my $t = 0;$t < $nt;++$t) {
    my $track = $tracks->[$t];
    my $glyph = $track->{'glyph'};

    if ($glyph eq 'loop-start') {
      $track->{'loop-depth'} = ++$depth;
    } elsif ($glyph eq 'loop-end') {
      if ($depth == 0) {
	my $lnum = $track->{'lnum'};
	$logger->warn("loop-end at line $lnum has no corresponding loop-start and will be ignored");
      }
      $track->{'loop-depth'} = $depth--;
    }
  }
}

1;
