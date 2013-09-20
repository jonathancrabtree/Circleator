#!/usr/bin/perl

package Circleator::Parser::Gene_Cluster_Table;

use strict;

$Circleator::Parser::Gene_Cluster_Table::DEFAULT_CLUSTER_ANALYSIS = 'default';

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

# attach parsed cluster info. to all of these feature types:
my $FEAT_TYPES = ['gene', 'CDS'];

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

# Prefix used when storing cluster data in a BioPerl feature attribute
# (i.e. this prefix is prepended to the tag name)
#
sub tag_prefix {
  my($self) = @_;
  return "CLUSTER_";
}

sub parse_file {
  my($self, $file, $cluster_analysis) = @_;
  die "couldn't find tabular gene cluster file $file" if ((!-e $file) || (!-r $file));
  $cluster_analysis = $Circleator::Parser::Gene_Cluster_Table::DEFAULT_CLUSTER_ANALYSIS if (!defined($cluster_analysis));

  # index both genes and CDS features
  foreach my $ft (@$FEAT_TYPES) {
    if (!defined($self->{$ft . '_index'})) {
      $self->{$ft . '_index'} = $self->_index_feats($ft);
    }
  }

  my $tag_prefix = $self->tag_prefix();
  my $ns = undef;
  my $strain_names = undef;

  my $fh = FileHandle->new();
  $fh->open($file)|| die "unable to read from tabular gene cluster file $file";
  my $lnum = 0;
  while (my $line = <$fh>) {
    ++$lnum;
    my @f = split(/\t/, $line);
    my $nf = scalar(@f);
    chomp($f[-1]);

    if (($lnum == 1) && ($line =~ /^ref_gene/i)) {
      $ns = $nf - 1;
      shift @f;
      $strain_names = \@f;
      $self->{'logger'}->debug("Gene_Cluster_Table: found $ns strain(s) in $file: " . join(',', @$strain_names)) if ($self->{'config'}->{'debug_opts'}->{'input'});
      next;
    } 
    elsif ($nf != ($ns + 1)) {
      $self->{'logger'}->warn("line $lnum of $file had $nf column(s), but " . ($ns+1). " were expected");
    }

    # lookup features and store cluster info
    my $id = $f[0];
    my $feats = [];
    
    foreach my $ft (@$FEAT_TYPES) {
      my $fl = $self->{$ft . '_index'}->{$id};
      push(@$feats, @$fl) if (defined($fl));
    }
    my $nf = scalar(@$feats);
    $self->{'logger'}->warn("unable to find feature with id $id") unless ($nf > 0);

    # total number of genes including the reference
    my $total_genes = 0;
    my $cluster_prefix =  $tag_prefix . $cluster_analysis . "_";

    # store cluster info
    for (my $i = 0;$i < $ns;++$i) {
      my $strain = $strain_names->[$i];
      my $sgenes_str = $f[$i + 1];
      my @genes = split(/,/, $sgenes_str);
      my $ng = scalar(@genes);
      my $strain_prefix = $cluster_prefix . $strain;
      map {$_->add_tag_value($strain_prefix . "_gene_count", $ng);} @$feats;
      map {$_->add_tag_value($strain_prefix . "_genes", \@genes);} @$feats;
      $total_genes += $ng;
    }
    map {$_->add_tag_value($cluster_prefix . "_gene_count", $total_genes);} @$feats;
  }
  $fh->close();
  $self->{'logger'}->info("tabular gene cluster file $file: $lnum line(s)");
}

sub _index_feats {
  my($self, $feat_type) = @_;
  my($bpseq) = $self->{'bpseq'};
  my $feat_hash = {};
  $self->{'logger'}->debug("Gene_Cluster_Table: indexing ref $feat_type features") if ($self->{'config'}->{'debug_opts'}->{'input'});
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
          my $list = $feat_hash->{$key};
          $list = $feat_hash->{$key} = [] if (!defined($list));
          push(@$list, $sf);
        }
      }
      if ($ntags == 0) {
        $self->{'logger'}->warn("$feat_type feature with no " . join(" or " , @$tags) . " tags at location $start in reference genome");
      }
    }
  }
  return $feat_hash;
}

1;
