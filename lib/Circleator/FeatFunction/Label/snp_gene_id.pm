package Circleator::FeatFunction::Label::snp_gene_id;

sub get_function {
  my($track, $tname) = @_;
  return sub {
    my $f = shift;
    my @gids = $f->get_tag_values('gene_id');
    return $gids[0];
  };       
}
