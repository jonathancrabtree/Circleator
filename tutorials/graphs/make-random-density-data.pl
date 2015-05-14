#!/usr/bin/perl

use strict;

# H. influenzae Rd KW20
my $LOCUS = 'L42023';
my $SEQLEN_BP = 1830138;
my $WINDOW_SIZE_BP = 5000;
my $MAX_VALUE = 100;

for (my $i = 0;$i < $SEQLEN_BP;$i += $WINDOW_SIZE_BP) {
    my $value = int(rand($MAX_VALUE+1));
    my $end = $i + $WINDOW_SIZE_BP;
    $end = $SEQLEN_BP if ($end > $SEQLEN_BP);
    print join("\t", $LOCUS, $i, $i + $WINDOW_SIZE_BP, $value) . "\n";
}
