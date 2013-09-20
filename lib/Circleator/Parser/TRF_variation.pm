package Circleator::Parser::TRF_variation;

use strict;
use FileHandle;

# HACK - dataset-specific id mapping
my $ID_MAP = 
  {
   'K1' => 'FO082871',
   'K2' => 'FO082872',
   'K3' => 'FO082874'
};

# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------
sub new {
    my($invocant, $logger, $params) = @_;
    my $self = {};
    $self->{'logger'} = $logger;
    die "logger must be defined" unless $logger;
    $logger->logdie("reference sequence must be defined") unless (defined($params->{'bpseq'}));
    # set the reference
    map { $self->{$_} = $params->{$_} } ('seq', 'seqlen', 'bpseq', 'contig_location_info', 'strict_validation', 'config');
    my $class = ref($invocant) || $invocant;
    bless $self, $class;
    return $self;
}

# ------------------------------------------------------------------
# Static (non-instance) methods
# ------------------------------------------------------------------

# TBD

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

sub parse_file {
  my($self, $file) = @_;
  die "couldn't find TRF variation file $file" if ((!-e $file) || (!-r $file));
  $self->_index_TRF_feats() unless (defined($self->{'trf_index'}));
  my $num_cols = 0;
  my $col_names = undef;
  my $target_strains = undef;

  my $fh = FileHandle->new();
  $fh->open($file)|| die "unable to read from TRF variation file $file";
  my $lnum = 0;
  while (my $line = <$fh>) {
    chomp($line);
    ++$lnum;
    my @f = split(/\t/, $line);
    my $nf = scalar(@f);
    chomp($f[-1]);

    if (($lnum == 1) && ($line =~ /^\#Microsat/)) {
      $num_cols = $nf;
      $col_names = \@f;
      for (my $i = 3;$i < $nf-1;++$i) {
        push(@$target_strains, $f[$i]);
      }
      my $nt = scalar(@$target_strains);
      $self->{'logger'}->debug("found $nt target genome(s) in $file: " . join(',', @$target_strains)) if ($self->{'config'}->{'debug_opts'}->{'input'});
      next;
    } 
    elsif ($nf != $num_cols) {
      $self->{'logger'}->warn("line $lnum of $file had $nf column(s), but $num_cols were expected");
    }

    # lookup TRF microsatellite and store variation info.
    my ($name, $start, $period) = ($f[0], $f[1], $f[2]);
    my $region = $f[-1];
    my($trf_index, $c_info) = map {$self->{$_}} ('trf_index', 'contig_location_info');
    my $c_positions = $c_info->{'positions'};

    # HACK - dataset-specific regex to extract original reference sequence name and determine adjusted sequence offset
    my($chrom) = ($name =~ /\_(K[123])\-\d+/);
    $self->{'logger'}->logdie("unable to parse reference chromosome from microsat name '$name'") unless (defined($chrom));
    next if (!defined($c_positions->{$ID_MAP->{$chrom}}));
    my $adj_start = $c_positions->{$ID_MAP->{$chrom}} + $start;
    $self->{'logger'}->logdie("unable to determine sequence offset for reference chromosome $chrom") unless (defined($adj_start));
    my $key = join(':', $adj_start, $period);
    my $msf = $trf_index->{$key};
    $self->{'logger'}->logdie("unable to find TRF feature with key $key at adjusted reference location $adj_start (original start=$start, name=$name)") unless (defined($msf));
    my $prefix = 'TRF_variation_';
    my $var_prefix = 'TRF_variation_query_';

    # store variation info
    for (my $i = 3;$i < $nf-1;++$i) {
      my $target_strain = $target_strains->[$i-3];
      my $key = $var_prefix . $target_strain;
      $msf->add_tag_value($key, $f[$i]);
    }
    $msf->add_tag_value($prefix . 'Microsat.name', $f[0]);
    $msf->add_tag_value($prefix . 'Period.size', $f[2]);
    $msf->add_tag_value($prefix . 'Region', $region);
  }
  $fh->close();
  $self->{'logger'}->info("TRF variation file $file: $lnum line(s)");
}

sub _index_TRF_feats {
  my($self) = @_;
  my($bpseq) = $self->{'bpseq'};
  my $trf_hash = $self->{'trf_index'} = {};
  $self->{'logger'}->debug("indexing ref TRF features") if ($self->{'config'}->{'debug_opts'}->{'input'});
  my @sf = $bpseq->get_SeqFeatures();

  foreach my $sf (@sf) {
    my $pt = $sf->primary_tag();
    if ($pt eq 'TRF') {
      # index by sequence position and 
      my $start = $sf->start();
      
      if ($sf->has_tag('period')) {
        my @tv = $sf->get_tag_values('period');
        my $ps = $tv[0];
        my $key = join(':', $start, $ps);
        if (defined($trf_hash->{$key})) {
          $self->{'logger'}->warn("duplicate TRF feature with key $key at location $start in reference genome");
        } else {
          $trf_hash->{$key} = $sf;
        }
      } else {
        $self->{'logger'}->error("found TRF feature without 'period' attribute at location $start in reference genome");
      }
    }
  }
}

1;

