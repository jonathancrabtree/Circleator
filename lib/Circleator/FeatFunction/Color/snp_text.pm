package Circleator::FeatFunction::Color::snp_text;

use Circleator::Parser::SNP;

my $SNP = Circleator::Parser::SNP->new();
my $SNP_TP = $SNP->tag_prefix();
my $SNP_TBTP = $SNP->target_base_tag_prefix();

# White for single-base labels, black for multibase
sub get_function {
  my($track, $tname) = @_;
  my $query = $track->{'snp-query'};
  return sub {
    my $f = shift;
    my @q_bases = $f->get_tag_values($SNP_TBTP . $query);
    my $qb = $q_bases[0];
    return (length($qb) > 1) ? '#808080' : '#ffffff';
  };
} 

1;

