package Circleator::Util::SignatureFilter;

use strict;

# ------------------------------------------------------------------
# Static methods
# ------------------------------------------------------------------

# Construct feature filter from a list of key values and a corresponding signature
#
# $feat_type_regex - optional. a regular expression that must be matched by the feature primary_tag() for the filter to return 1
# $value_list_string - a list of possible values separated by "|"
# $signature - a string of "0", "1", and "." whose length must match the number of things in $value_list_string
# $min_matches - optional. specifies a minimum number of matches for the filter to return 1
# $max_matches - optional. specifies a maximum number of matches for the filter to return 1
# $list_name - a descriptive name for $value_list_string (e.g., "BSR genome list", "cluster genome list")
# $sig_name - a descriptive name for $signature (e.g., "BSR genome signature")
#
sub make_feature_filter {
  my($logger, $feat_type_regex, $value_list_string, $signature, $match_fn, $min_matches, $max_matches, $list_name, $sig_name) = @_;
  $list_name = "" if (!defined($list_name));
  $sig_name = "" if (!defined($sig_name));
  my @value_list = split(/\s*\|\s*/, $value_list_string);
  my $nv = scalar(@value_list);
  $logger->error("$list_name is empty") if ($nv == 0);

  # check that $value_list_string and $signature are compatible
  if (defined($signature)) {
    $logger->logdie("$sig_name must contain only the following characters: '0', '1', '.' (signature='$signature')") unless ($signature =~ /^[01\.]+$/);
    my $sl = length($signature);
    $logger->logdie("$sig_name has length $sl but $nv values were listed in $list_name") unless ($sl == $nv);
  }
  
  # feature filter: returns 0 for every feature that is NOT to be drawn
  my $filter = sub {
    my($feat) = @_;
    my $pt = $feat->primary_tag();
    # check feat_type_regex
    return 0 unless (!defined($feat_type_regex) || ($pt =~ /$feat_type_regex/));
    # compute signature and number of matches
    my $sig = '';
    my $num_matches = 0;
    foreach my $v (@value_list) {
      if (&$match_fn($feat, $v)) {
        $sig .= "1";
        ++$num_matches;
      } else {
        $sig .= "0";
      }
    }
    # check signature against regex
    my $matches_min = (!defined($min_matches)) || ($num_matches >= $min_matches);
    my $matches_max = (!defined($max_matches)) || ($num_matches <= $max_matches);
    my $matches_sig = (!defined($signature)) || ($sig =~ /^${signature}$/);
    # filter (return 0) anything not matching all the criteria
    return ($matches_min && $matches_max && $matches_sig) ? 1 : 0;
  };

  return $filter;
}

1;
