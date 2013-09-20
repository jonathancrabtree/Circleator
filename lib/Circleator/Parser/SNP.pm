#!/usr/bin/perl

package Circleator::Parser::SNP;

use strict;

# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------

sub new() {
  my($invocant) = @_;
  my $self = {};
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

# Prefix used when storing SNP-associated data in a BioPerl feature attribute
# (i.e. this prefix is prepended to the tag name)
#
sub tag_prefix() {
  my($self) = @_;
  return "SNP_";
}

# Prefix used when storing SNP-associated target genome base information in a 
# BioPerl feature attribute (i.e. this prefix is prepended to the tag name)
#
sub target_base_tag_prefix() {
  my($self) = @_;
  return "SNP_tb_";
}

# Process a set of newly-loaded SNP objects. This subroutine takes as input a listref of reference sequences
# with SNP features and adds the following attributes to each of the SNP features:
#
# num_targets - Total number of target genomes/sequences in the comparison.
# num_diffs - Number of target genomes/sequences that differ from the reference at a given position (for at least one allele.)
# num_no_hits - Number of target genomes/sequences with a "No Hit" result 
#               (i.e., the SNP position could not be located in that genome)
#
sub process_snps {
  my($self, $refseqs) = @_;
  my $tp = $self->tag_prefix();
  my $tbp = $self->target_base_tag_prefix();
  my $all_targets = {};
  my $all_snps = [];

  foreach my $refseq (@$refseqs) {
    # get all SNPs in $refseq
    my @ssf = $refseq->get_SeqFeatures();
    my $ns = 0;
    
    foreach my $snp (@ssf) {
      next unless ($snp->primary_tag() eq 'SNP');
      ++$ns;
      # number of target sequences/genomes with a difference wrt the reference
      my $num_diffs = 0;
      # number of target sequences/genomes with a "No Hit" result
      my $num_nh = 0;
      push(@$all_snps, $snp);

      # reference base
      my @rb = $snp->get_tag_values($tp . 'ref_base');
      $self->{'logger'}->logdie("invalid reference base") unless ((scalar(@rb) == 1) && ($rb[0] =~ /^[ACGTUMRWSYKVHDBN\.\-]+$/i));
      my @st = $snp->get_all_tags();

      # target bases
      foreach my $st (@st) {
        next if ($st =~ /\-no\-hit/);

        if ($st =~ /^$tbp/) {
          # see whether target base differs from reference
          my @tb = $snp->get_tag_values($st);
          my $target_differs = 0;
          my $no_hit = 0;

          foreach my $tb (@tb) {
            if ($tb =~ /^no hit$/i) {
              $no_hit = 1;
            } elsif ($tb =~ /^[ACGTUMRWSYKVHDBN\.\,\-]+$/i) {
              $target_differs = 1 if (uc($tb) ne uc($rb[0]));
            } else {
              $self->{'logger'}->logdie("invalid target base '$tb' for $st");
            }
          }
          # Shouldn't have multiple alleles if one of them is 'No Hit'!
          $self->{'logger'}->logdie("illegal SNP: $st has multiple alleles, one of which is 'No Hit'") if ($no_hit && (scalar(@tb) > 1));
          
          if ($no_hit) {
            ++$num_nh;
          } elsif ($target_differs) {
            ++$num_diffs;
          }
          # record target genome/sequence
          my $target = $st;
          $target =~ s/^$tbp//;
          $all_targets->{$target} = 1;
        }
      }
      # store num_diffs and num_no_hits
      $snp->add_tag_value($tp . 'num_diffs', $num_diffs);
      $snp->add_tag_value($tp . 'num_no_hits', $num_nh);
    }
  } # end foreach $refseq

  # store num_targets
  my $num_targets = scalar(keys %$all_targets);
  map { $_->add_tag_value($tp . 'num_targets', $num_targets); } @$all_snps;
}

1;
