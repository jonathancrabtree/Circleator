package Circleator::Util::GraphRegions;

# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------
sub new {
  my($invocant, $logger, $params) = @_;
  my $self = {};
  $self->{'logger'} = $logger;
  die "logger must be defined" unless $logger;
  $logger->logdie("reference sequence must be defined") unless (defined($params->{'bpseq'}));
  # set the reference
  map { $self->{$_} = $params->{$_} } ('seq', 'seqlen', 'bpseq', 'config');
  my $class = ref($invocant) || $invocant;
  bless $self, $class;
  return $self;
}

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

sub compute_regions {
  my($self, $values, $region_min_len, $region_max_len, $region_feat_type, $graph_minval, $graph_maxval, $is_circular) = @_;

  # defaults
  $region_min_len = 0 if (!defined($region_min_len));
  $region_feat_type = 'graph_region' if (!defined($region_feat_type));

  # find all values that meet the criteria
  my $qvalues = [];
  foreach my $v (@$values) {
	my($fmin, $fmax, $value, $conf_lo, $conf_hi) = @$v;
    if ((!defined($graph_minval) || ($value > $graph_minval)) && ((!defined($graph_maxval)) || ($value < $graph_maxval))) {
      push(@$qvalues, $v);
    }
  }

  # values should already be sorted so we just have to merge them
  # TODO - allow merges across the origin if this is a circular molecule
  my $regions = [];
  my $region = undef;

  foreach my $v (@$qvalues) {
	my($fmin, $fmax, $value, $conf_lo, $conf_hi) = @$v;

    # if fmin falls inside existing region then extend fmax of region to fmax
    if (defined($region) && ($fmin >= $region->[0]) && ($fmin <= $region->[1])) {
      $region->[1] = $fmax;
    }
    # otherwise a new region must be created
    else {
      $region = [$fmin, $fmax];
      push(@$regions, $region);
    }
  }

  # apply region filters to created regions
  foreach my $r (@$regions) {
    my($fmin, $fmax) = @$r;
    my $rlen = $fmax - $fmin;
    if ((!defined($region_min_len) || ($rlen > $region_min_len)) && (!defined($region_max_len) || ($rlen > $region_max_len))) {
      my $rs = $fmin+1;
      my $re = $fmax;
      $self->{'logger'}->debug("adding graph region feature of type '$region_feat_type' from $rs - $re") if ($self->{'config'}->{'debug_opts'}->{'coordinates'});
      my $rfeat = new Bio::SeqFeature::Generic(-start => $rs, -end => $re, -strand => 1,
                                               -primary => $region_feat_type, 
                                               -display_name => $region_feat_type . $rs);
      if (!$self->{'bpseq'}->add_SeqFeature($rfeat)) {
        $self->{'logger'}->logdie("failed to add desert feature of type '$desert_feat_type' to corresponding reference sequence");
      }
    }
  }
}

1;

