#!/usr/bin/env perl

# Update an old MergedTable SNP file by adding the 3 columns (using dummy values) 
# that the parser now requires.

use strict;

my $COLS = ['properties', 'Num_No_Hit', 'Homoplasy'];
my $VALS = ['', '0', '.'];

my $lnum = 0;

while (my $line = <>) {
    chomp($line);
    ++$lnum;
    if ($lnum == 1) {
	$line .= join("\t", @$COLS);
	$line =~ s/gene_end/gene_stop/;
    } else {
	$line .= join("\t", @$VALS);
    }
    print $line . "\n";
}
