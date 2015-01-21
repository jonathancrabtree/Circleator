#!/usr/bin/perl

use strict;
use FileHandle;
use File::Spec;

# Wrapper for samtools mpileup command 

## globals
my $USAGE = "Usage: $0 bam_file window_size seqid fmin fmax skip_anomalous_reads log_transform";
my $SAMTOOLS_DIR = "/usr/local/packages/samtools";

## input
my $bam_file = shift || die $USAGE;
my $window_size = shift || die $USAGE;
my $seqid = shift || die $USAGE;
my $fmin = shift;
my $fmax = shift || die $USAGE;
my $skip_anomalous_reads = shift;
my $log_transform = shift;

## main program
my $samtools = File::Spec->catfile($SAMTOOLS_DIR, 'samtools');
die "samtools executable $samtools not found or not executable" if ((!-e $samtools) || (!-x $samtools));

# expand pileup region to end on a window boundary
my $fmin_window_num = int($fmin / $window_size);
my $fmax_window_num = int($fmax / $window_size);

my $mod_fmin = $fmin_window_num * $window_size;
my $mod_fmax = ($fmax_window_num + 1) * $window_size;
$mod_fmin = 0 if ($mod_fmin < 0);

print STDERR "fmin=$fmin fmax=$fmax window_size=$window_size fmin_window_num=$fmin_window_num fmax_window_num=$fmax_window_num mod_fmin=$mod_fmin mod_fmax=$mod_fmax\n";

# default is to _include_ anomalous reads, for consistency with IGV and samtools view
my $a_opt = $skip_anomalous_reads ? "" : "-A";

# -d10000000 increases max_depth from default of 8000 to ensure we don't miss anything:
my $depth_cmd = "$samtools depth $a_opt -r '${seqid}:${mod_fmin}-${mod_fmax}' $bam_file";

print STDERR "running $depth_cmd\n";
my $fh = FileHandle->new();
$fh->open("$depth_cmd |") || die "error running $depth_cmd";
my $lnum = 0;

# summarized coverage stats for the current window
my $cwin = {
            'seqid' => $seqid,
            # window position in chado coordinates.
            'fmin' => $mod_fmin,
            # TODO - currently fmax may be > seqlen
            'fmax' => $mod_fmin + $window_size,
            # sum of read depths, either including or not including mismatches/insertions
            'sum' => 0,
           };

# parse the output
while (my $line = <$fh>) {
  chomp($line);
  ++$lnum;
  if ($line =~ /^(\S+)\t(\d+)\t(\d+)$/) {
    my($chr, $posn, $depth) = ($1, $2, $3);
    die "sequence id mismatch" if ($chr ne $seqid);

    # convert position to 0-based half open coords
    my $pfmin = $posn - 1;
    my $pfmax = $posn;
    die "illegal position posn=$posn" if ($pfmin < 0);

    # if current position is to the right of the current window then one or more windows need to be output
    &output_windows_before($cwin, $pfmin, $pfmax);
    $cwin->{'sum'} += $depth;
 } 
  else {
    die "couldn't parse depth output line $lnum: $line";
  }
}
$fh->close();

# output the last window, if there is one
&output_windows_before($cwin, $mod_fmax + 1);
exit(0);

## subroutines

sub output_window {
  my($win) = @_;
  my $value = $win->{'sum'} / $window_size;
  if ($log_transform) {
    $value = ($value <= 1) ? 0 : log($value)/log(10);
  }
  print join("\t", $win->{'seqid'}, $win->{'fmin'}, $win->{'fmax'}, $value) . "\n";
}

sub output_windows_before {
  my($win, $fmin, $fmax) = @_;
  while ($fmin >= $win->{'fmax'}) {
    &output_window($win);
    $win->{'fmin'} += $window_size;
    $win->{'fmax'} += $window_size;
    $win->{'sum'} = 0;
  }
}
