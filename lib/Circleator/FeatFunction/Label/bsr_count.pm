package Circleator::FeatFunction::Label::bsr_count;

use Circleator::Parser::BSR;

sub get_function {
  my($track, $tname) = @_;

  # get genome list
  my ($genomes, $threshold) = map { $track->{$_} } ('genomes', 'threshold');
  my @genome_list = split(/\s*\|\s*/, $genomes);
  $threshold = $Circleator::Parser::BSR::DEFAULT_BSR_THRESHOLD if (!defined($threshold));
  
  return sub {
    my $f = shift;
    my $count = 0;
    # TODO - factor this out - duplicates some code from 'bsr' track in circleator.pl
    foreach my $g (@genome_list) {
      my($rkey, $gkey, $nkey) = map { 'BSR_' . $g . '_' . $_ } ('ratio', 'gene', 'num');
      # get BSR value for $g, check whether it's above threshold
      if ($f->has_tag($rkey)) {
        my @trl = $f->get_tag_values($rkey);
        ++$count if ($trl[0] > $threshold);
      }
    }
    return $count;
  };
}

1;
