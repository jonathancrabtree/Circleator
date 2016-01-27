package Circleator::FeatFunction::Color::expression_level;

use Circleator::Parser::Expression_Table;

my $EXP = Circleator::Parser::Expression_Table->new();
my $EXP_TP = $EXP->tag_prefix();

# Assign color based on expression level.  Requires sample name.
sub get_function {
  my($track, $tname) = @_;
  my $sample = $track->{'sample'};
  my $default_color = $track->{'exp-default-color'} || 'none';
  my $thresholds = $track->{'exp-thresholds'} || 'none';
  my $colors = $track->{'exp-colors'} || 'none';
  die "exp-thresholds not defined" if (!defined($thresholds) || ($thresholds =~ /^\s*$/));
  die "exp-colors not defined" if (!defined($colors) || ($colors =~ /^\s*$/));

  my @threshold_array = split(/\s*\|\s*/, $thresholds);
  my @color_array = split(/\s*\|\s*/, $colors);

  # sort thresholds in ascending order
  my $tc = [];
  my $nt = scalar(@threshold_array);
  for (my $i = 0;$i < $nt;++$i) {
    my $t = $threshold_array[$i];
    my $c = $color_array[$i];
    push(@$tc, [$t, $c]);
  }

  my @sorted_tc = sort { $a->[0] <=> $b->[0] } @$tc;

  return sub {
    my $f = shift;
    my $ftype = $f->primary_tag();
    my $color = $default_color;
    my $tag = $EXP_TP . $sample;

    if ($f->has_tag($tag)) {
      my @tv = $f->get_tag_values($tag);
      my $v = $tv[0];

      # check $v against sorted thresholds
      for (my $i = 0;$i < $nt;++$i) {
        my $th = $sorted_tc[$i];
        if (defined($th->[0]) && ($v >= $th->[0]) && (defined($th->[1]))) {
          $color = $th->[1];
        }
      }
    }
    return $color;
  };
}

1;

