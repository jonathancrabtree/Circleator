package Circleator::FeatFunction::Label::trf_microsat_var;

sub get_function {
  my($track, $tname) = @_;
  my $trf_query = $track->{'trf-query'};

  my $format_diff = sub {
    my $d = shift;
    $d =~ s/(\.0*)$//;
    return $d;
  };

  return sub {
    my $f = shift;
    my $ftype = $f->primary_tag();
    die "trf_microsat_var can only be used on TRF features, not features of type $ftype" unless ($ftype eq 'TRF');
        
    # check to make sure that variation data is present
    if (!$f->has_tag('TRF_variation_Period.size')) {
      print STDERR "WARNING - microsat at location " .$f->start() . "-" . $f->end() . " has no Period.size set\n";
      return undef;
    }

    my @tags = $f->get_all_tags();
    my $strain_diffs = {};
    my $diff_counts = {};
    my $num_ns = 0;
    my $n_strains = 0;

    foreach my $tag (@tags) {
      if ($tag =~ /^TRF_variation_query_(.*)$/) {
        my $strain = $1;
        ++$n_strains;
        my @tv = $f->get_tag_values($tag);
        my $diff = $tv[0];
        $strain_diffs->{$strain} = $diff;
        die "invalid TRF $strain query length diff $diff" if (!defined($diff) || ($diff !~ /^(\-?[\d\.]+|NS)$/));
        if ($diff ne 'NS') {
          ++$diff_counts->{$diff};
        } else {
          ++$num_ns;
        }
      }
    }

    my $nk = scalar(keys %$diff_counts);
    my $num_not_ns = $n_strains - $num_ns;
    my $summary_diff = undef;
    my $query_diff = (defined($trf_query) && ($trf_query =~ /\S/)) ? $strain_diffs->{$trf_query} : undef;
    $query_diff = undef if (($query_diff eq 'NS') || ($query_diff == 0));

    # all NS
    if ($num_ns != $n_strains) {
      # all the same as the reference
      if ($num_same == $num_not_ns) {
        $summary_color = $same_color;
        $summary_diff = 0;
      }
      # all query strains differ from the reference, and all by the same amount (excluding NS values)
      elsif ($nk == 1) {
        my @dk = keys %$diff_counts;
        $summary_diff = $dk[0];
      }
    }

    # return either per-strain or summary diff count
    if (defined($trf_query) && ($trf_query =~ /\S/)) {
      $query_diff = &$format_diff($query_diff);
      if (defined($summary_diff) && ($summary_diff == $query_diff)) {
        return undef;
      }
      return $query_diff;
    } else {
      $summary_diff = &$format_diff($summary_diff);
      return $summary_diff;
    }
  };
}

1;

