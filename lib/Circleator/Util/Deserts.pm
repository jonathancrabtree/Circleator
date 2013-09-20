package Circleator::Util::Deserts;

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

sub compute_deserts {
  my($self, $feats, $desert_min_len, $desert_feat_type, $is_circular) = @_;
  # defaults
  $desert_min_len = 0 if (!defined($desert_min_len));
  $desert_feat_type = 'desert' if (!defined($desert_feat_type));

  # find all deserts of size $desert_min_len or greater in $feats
  my @sorted_feats = sort { ($a->start() <=> $b->start()) || ($a->end() <=> $b->end()) } @$feats;
  $self->{'logger'}->debug("compute_deserts: is_circular=$is_circular seqlen=" . $self->{'seqlen'}) if ($self->{'config'}->{'debug_opts'}->{'coordinates'});
  
  my $nf = scalar(@sorted_feats);
  for (my $f = 0;$f < $nf;++$f) {
    my $end = $sorted_feats[$f]->end();
    my $next_start = undef;
    my $dist = 0;
    
    # compare last feature with the first if this is a circular molecule
    if ($is_circular && ($f == ($nf - 1))) {
      $next_start = $sorted_feats[0]->start();
      $dist = ($self->{'seqlen'} - $end) + $next_start - 1;
    } else {
      if ($f == ($nf - 1)) {
        $next_start = $self->{'seqlen'};
      } else {
        $next_start = $sorted_feats[$f+1]->start();
      }
      $dist = ($next_start - $end) - 1;
    }

    $self->{'logger'}->debug("end=$end next_start=$next_start dist=$dist") if ($self->{'config'}->{'debug_opts'}->{'coordinates'});
    
    # create new feature if desert is greater than the specified length
    if ($dist > $desert_min_len) {
      my $ds = $end + 1;
      $ds = $self->{'seqlen'} if ($ds > $self->{'seqlen'});
      my $de = $next_start - 1;
      $de = $self->{'seqlen'} if ($de == 0);
      $self->{'logger'}->debug("adding desert feature of type '$desert_feat_type' from $ds - $de") if ($self->{'config'}->{'debug_opts'}->{'coordinates'});
      my $dfeat = new Bio::SeqFeature::Generic(-start => $ds, -end => $de, -strand => 1, 
                                               -primary => $desert_feat_type, 
                                               -display_name => $desert_feat_type . $ds);
      if (!$self->{'bpseq'}->add_SeqFeature($dfeat)) {
        $self->{'logger'}->logdie("failed to add desert feature of type '$desert_feat_type' to corresponding reference sequence");
      }
    }
  }
}

1;

