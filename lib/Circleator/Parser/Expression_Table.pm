#!/usr/bin/perl

package Circleator::Parser::Expression_Table;

use strict;

# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------

sub new {
  my($invocant, $logger, $params) = @_;
  my $self = {};
  $self->{'logger'} = $logger;
  map { $self->{$_} = $params->{$_} } ('seq', 'seqlen', 'bpseq', 'contig_location_info', 'strict_validation', 'config');
  my $class = ref($invocant) || $invocant;
  bless $self, $class;
  return $self;
}

# ------------------------------------------------------------------
# Static (non-instance) methods
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

# Prefix used when storing expression data in a BioPerl feature attribute
# (i.e. this prefix is prepended to the tag name)
#
sub tag_prefix {
  my($self) = @_;
  return "EXP_";
}

sub parse_file {
  my($self, $file) = @_;
  die "couldn't find tabular gene expression file $file" if ((!-e $file) || (!-r $file));
  $self->_index_feats('CDS') unless (defined($self->{'feat_index'}));
  my $tag_prefix = $self->tag_prefix();

  my $ns = undef;
  my $sample_names = undef;

  my $fh = FileHandle->new();
  $fh->open($file)|| die "unable to read from tabular gene expression file $file";
  my $lnum = 0;
  while (my $line = <$fh>) {
    chomp($line);
    ++$lnum;
    my @f = split(/\t/, $line);
    my $nf = scalar(@f);
    chomp($f[-1]);

    if (($lnum == 1) && ($line =~ /^Feature ID/i)) {
      $ns = $nf - 1;
      shift @f;
      $sample_names = \@f;
      $self->{'logger'}->debug("ExpressionTable: found $ns sample(s) in $file: " . join(',', @$sample_names)) if ($self->{'config'}->{'debug_opts'}->{'input'});
      next;
    } 
    elsif ($nf != ($ns + 1)) {
      $self->{'logger'}->warn("line $lnum of $file had $nf column(s), but " . ($ns+1). " were expected");
    }

    # lookup gene and store expression info.
    my $id = $f[0];
    my $feat_index = $self->{'feat_index'};
    my $gf = $feat_index->{$id};
    $self->{'logger'}->logdie("unable to find feature with id $id") unless (defined($gf));

    # store expression info
    for (my $i = 0;$i < $ns;++$i) {
      my $sample = $sample_names->[$i];
      my $exp_value = $f[$i + 1];
      my $key = $tag_prefix . $sample;
      $gf->add_tag_value($key, $exp_value);
    }
  }
  $fh->close();
  $self->{'logger'}->info("tabular gene expression file $file: $lnum line(s)");
}

sub _index_feats {
  my($self, $feat_type) = @_;
  my($bpseq) = $self->{'bpseq'};
  my $feat_hash = $self->{'feat_index'} = {};
  my $dup_hash = {};
  $self->{'logger'}->debug("Expression_Table: indexing ref $feat_type features") if ($self->{'config'}->{'debug_opts'}->{'input'});
  # index by feat name/symbol and locus_tag
  my $tags = ['gene', 'locus_tag'];
  my @sf = $bpseq->get_SeqFeatures();

  foreach my $sf (@sf) {
    my $pt = $sf->primary_tag();
    if ($pt eq $feat_type) {
      my $start = $sf->start();
      my $ntags = 0;
      foreach my $tag (@$tags) {
        if ($sf->has_tag($tag)) {
          ++$ntags;
          my @gv = $sf->get_tag_values($tag);
          my $key = $gv[0];
          if (defined($feat_hash->{$key})) {
            $self->{'logger'}->warn("duplicate $feat_type feature with $tag=$key at location $start in reference genome");
            $dup_hash->{$key} = 1;
          } else {
            $feat_hash->{$key} = $sf;
          }
        }
      }
      if ($ntags == 0) {
        $self->{'logger'}->warn("$feat_type feature with no " . join(" or " , @$tags) . " tags at location $start in reference genome");
      }
    }
  }
 
  # remove all ambiguous mappings
  foreach my $key (keys %$dup_hash) {
    delete $feat_hash->{$key};
  }
}

1;
