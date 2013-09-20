package Circleator::FeatFunction::Color::trf_microsat_var;

# Assign color based on TRF microsatellite variability, either:
#  1. in a single target strain (if trf-query is set)
#  2. across all available target strains
#
sub get_function {
  my($track, $tname) = @_;
  my $trf_query = $track->{'trf-query'};
  my $ns_color = $track->{'trf-ns-color'} || '#ffb841';
  my $same_color = $track->{'trf-same-color'} || 'black';
  my $longer_color = $track->{'trf-longer-color'} || 'red';
  my $shorter_color = $track->{'trf-shorter-color'} || 'blue';
  my $queries_differ_alike_color = $track->{'trf-queries-differ-alike-color'} || '#cd1a37';
  my $queries_differ_color = $track->{'trf-queries-differ-color'} || '#53d72f';

  return sub {
    my $f = shift;
    my $ftype = $f->primary_tag();
    die "trf_microsat_var can only be used on TRF features, not features of type $ftype" unless ($ftype eq 'TRF');
    
    # check to make sure that variation data is present, return $ns_color if not
    if (!$f->has_tag('TRF_variation_Period.size')) {
      print STDERR "WARNING - microsat at location " .$f->start() . "-" . $f->end() . " has no Period.size set\n";
      return $ns_color;
    }
    
    # color based on single query strain
    my $strain_color = undef;
    if (defined($trf_query) && ($trf_query =~ /\S/)) {
      # length difference of microsatellite in specified query compared to the reference
      my $tag = 'TRF_variation_query_' . $trf_query;
      my @tv = $f->get_tag_values($tag);
      my $diff = $tv[0];
      die "invalid TRF $trf_query query length diff $diff" if (!defined($diff) || ($diff !~ /^(\-?[\d\.]+|NS)$/));
      
      if ($diff eq 'NS') {
        $strain_color = $ns_color;
      } 
      elsif ($diff == 0) {
        $strain_color = $same_color;
      }
      elsif ($diff > 0) {
        $strain_color = $longer_color;
      } 
      else {
        $strain_color = $shorter_color;
      } 
    }

    # color based on multiple query strains
    my $summary_color = undef;
    my @tags = $f->get_all_tags();
    my $num_ns = 0;
    my $num_same = 0;
    my $num_longer = 0;
    my $num_shorter = 0;
    my $diff_counts = {};
    my $n_strains = 0;
    
    foreach my $tag (@tags) {
      if ($tag =~ /^TRF_variation_query_(.*)$/) {
        my $strain = $1;
        ++$n_strains;
        my @tv = $f->get_tag_values($tag);
        my $diff = $tv[0];
        die "invalid TRF $strain query length diff $diff" if (!defined($diff) || ($diff !~ /^(\-?[\d\.]+|NS)$/));
        ++$diff_counts->{$diff} if ($diff ne 'NS');
        
        if ($diff eq 'NS') {
          ++$num_ns;
        } 
        elsif ($diff == 0) {
          ++$num_same;
        }
        elsif ($diff > 0) {
          ++$num_longer;
        } 
        else {
          ++$num_shorter;
        } 
      }
    }

#    print STDERR "TRF " . $f->start() . "-" . $f->end() . " num_ns=$num_ns num_same=$num_same n_strains=$n_strains num_longer=$num_longer num_shorter=$num_shorter\n";
    # return color
    my $nk = scalar(keys %$diff_counts);
    my $num_not_ns = $n_strains - $num_ns;
    
    # all NS
    if ($num_ns == $n_strains) {
      $summary_color = $ns_color;
    } 
    # all the same as the reference
    elsif ($num_same == $num_not_ns) {
      $summary_color = $same_color;
    }
    # all query strains differ from the reference, and all by the same amount (excluding NS values)
    elsif ($nk == 1) {
      $summary_color = $queries_differ_alike_color;
    }
    else {
      $summary_color = $queries_differ_color;
    }

    if (defined($strain_color)) {
      # don't return black (same)/yellow (NS) if the summary color is the same
      if ((($summary_color eq $ns_color) || ($summary_color eq $same_color)) && ($summary_color eq $strain_color)) {
        return 'none';
      } else {
        return $strain_color;
      }
    } else {
      return $summary_color;
    }
  };
}

1;
