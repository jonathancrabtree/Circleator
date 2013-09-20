package Circleator::FeatFunction::Numeric::allelic_depth;

use Circleator::Parser::SNP;

my $SNP = Circleator::Parser::SNP->new();
my $SNP_TP = $SNP->tag_prefix();
my $SNP_TBTP = $SNP->target_base_tag_prefix();

sub get_function {
  my($track, $tname) = @_;
  my $query = $track->{'snp-query'};

  return sub {
    my $f = shift;
    my $ftype = $f->primary_tag();
    die "snp_type can only be used on SNPs, not features of type $ftype" unless ($ftype eq 'SNP');
    my $ad_key = $SNP_TBTP . $query . '_AD';
    if ($f->has_tag($ad_key)) {
      my @adepths = $f->get_tag_values($ad_key);
      return \@adepths;
    }
    return undef;
  };
}

1;
