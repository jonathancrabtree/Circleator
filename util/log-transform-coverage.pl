#!/usr/bin/perl

use strict;
use FileHandle;

## globals
my $USAGE = "Usage: $0 coverage-file.txt";

## main program
my $min_cov = undef;
my $cov_sum = 0;
my $max_cov = undef;
my $max_log_cov = 0;
my $num_lines = 0;

# rewrite the file and track the max values
while (my $cov_file = shift) {
  my $norm_cov_file = $cov_file;
  $norm_cov_file =~ s/\.txt/-log10.txt/;

  my $lnum = 0;
  my $fh = FileHandle->new();
  my $ofh = FileHandle->new();
  $fh->open($cov_file) || die "unable to read from $cov_file";
  $ofh->open(">$norm_cov_file") || die "unable to write to $norm_cov_file";
  print STDERR "writing $norm_cov_file\n";

  while (my $line = <$fh>) {
    chomp($line);
    ++$lnum;
    if ($line =~ /^([^\t]+\t\d+\t\d+\t)([\-\d\.]+(?:e-\d+)?)(?:\t([\-\d\.]+(?:e-\d+)?)\t([\-\d\.]+(?:e-\d+)?))?$/) {
      my ($prefix, $cov, $conf_lo, $conf_hi) = ($1, $2, $3, $4);
      print STDERR "ERROR - coverage at line $lnum of $cov_file = $cov\n" if ($cov < 0);
      my $log_cov = ($cov <= 1) ? 0 : log($cov)/log(10);
      if (!defined($max_cov) || ($cov > $max_cov)) {
        $max_cov = $cov;
        $max_log_cov = $log_cov;
      }
      $min_cov = $cov if (!defined($min_cov) || ($cov < $min_cov));
      $cov_sum += $cov;

      my $conf_str = "";
      if (defined($conf_lo) && defined($conf_hi)) {
        my $log_conf_lo = ($conf_lo <= 1) ? 0 : log($conf_lo)/log(10);
        my $log_conf_hi = ($conf_hi <= 1) ? 0 : log($conf_hi)/log(10);
        $conf_str = join("\t", ('', $log_conf_lo, $log_conf_hi));
      }

      $ofh->print($prefix . $log_cov. $conf_str . "\n");
    } else {
      die "unable to parse line $lnum of $cov_file: $line";
    }
    ++$num_lines;
  }
  $ofh->close();
  $fh->close();
}

print STDERR "cov_sum=$cov_sum, num_lines=$num_lines\n";
my $avg_cov = sprintf("%.2f", $cov_sum/$num_lines);
print STDERR "min_cov=$min_cov max_cov=$max_cov avg_cov=$avg_cov max_log_cov=$max_log_cov\n";

exit(0);

