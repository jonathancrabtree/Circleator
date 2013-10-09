#!/usr/bin/perl

# To run regression tests:
#  perl circleator.t
#
# To run regression tests and write .log and .svg for mismatching files into current directory:
#  perl circleator.t --working_dir=.
#
# To run regression tests and write .log, .svg, and .html for ALL files into the specified working directory:
#  perl circleator.t --working_dir=./1.0alpha3 --release=circleator-1.0alpha3
#
# Once the .svg and .log look OK, move the .svg into results/ and commit

use strict;

use FileHandle;
use File::Basename;
use File::Spec;
use File::Temp qw { tempdir };
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Test::More;

## ----------------------------------
## globals
## ----------------------------------
my $CONF_DIR = 't/conf';
my $DATA_DIR = 'data';
my $BIN_DIR = 'bin';
my $LIB_DIR = 'lib';

# prior output for regression tests
my $RESULTS_DIR = 't/results';

# test data
#
# CM000961 - Corynebacterium genitalium ATCC 33030 chromosome, whole genome shotgun sequence. - ~2.3Mb, inline gaps
# NC_011969 - Bacillus cereus Q1 chromosome, complete genome. - ~5.2 Mb
# CM000961-180bp - First 180bp of CM000961
# AE003852-AE003853.gbk - Chromosome I and II (concatenated) of Vibrio cholerae O1 biovar eltor str. N16961
#
my $TESTS = 
    [
     # rulers/coordinate labels
     {'data' => 'CM000961.gbk', 'conf' => 'rulers-1.cfg', 'descr' => "Sequence coordinate ruler tick-interval and label-type." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'rulers-1.cfg', 'descr' => "Sequence coordinate ruler tick-interval and label-type." },
     {'data' => 'NC_011969.gbk', 'conf' => 'rulers-1.cfg', 'descr' => "Sequence coordinate ruler tick-interval and label-type." },

     {'data' => 'CM000961.gbk', 'conf' => 'rulers-2.cfg', 'descr' => "Sequence coordinate ruler tick-interval, label-units, and label-precision." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'rulers-2.cfg', 'descr' => "Sequence coordinate ruler tick-interval, label-units, and label-precision." },
     {'data' => 'NC_011969.gbk', 'conf' => 'rulers-2.cfg', 'descr' => "Sequence coordinate ruler tick-interval, label-units, and label-precision." },

     {'data' => 'CM000961.gbk', 'conf' => 'rulers-3.cfg', 'descr' => "Sequence coordinate ruler label-units." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'rulers-3.cfg', 'descr' => "Sequence coordinate ruler label-units." },
     {'data' => 'NC_011969.gbk', 'conf' => 'rulers-3.cfg', 'descr' => "Sequence coordinate ruler label-units." },

     # track definitions from conf/predefined-tracks.cfg
     {'data' => 'CM000961.gbk', 'conf' => 'predef-tracks-1.cfg', 'descr' => "Predefined tracks #1: coordinates, contigs, genes, tRNAs, rRNAS." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'predef-tracks-1.cfg', 'descr' => "Predefined tracks #1: coordinates, contigs, genes, tRNAs, rRNAS." },
     {'data' => 'NC_011969.gbk', 'conf' => 'predef-tracks-1.cfg', 'descr' => "Predefined tracks #1: coordinates, contigs, genes, tRNAs, rRNAS." },

     {'data' => 'CM000961.gbk', 'conf' => 'predef-tracks-2.cfg', 'descr' => "Predefined tracks #2: coordinates, contigs, gaps, %GC, GC-skew." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'predef-tracks-2.cfg', 'descr' => "Predefined tracks #2: coordinates, contigs, gaps, %GC, GC-skew." },
     {'data' => 'NC_011969.gbk', 'conf' => 'predef-tracks-2.cfg', 'descr' => "Predefined tracks #2: coordinates, contigs, gaps, %GC, GC-skew." },

     {'data' => 'CM000961.gbk', 'conf' => 'predef-tracks-3.cfg', 'descr' => "Predefined tracks #3: coordinates, contigs, gaps, labels." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'predef-tracks-3.cfg', 'descr' => "Predefined tracks #3: coordinates, contigs, gaps, labels." },
     {'data' => 'NC_011969.gbk', 'conf' => 'predef-tracks-3.cfg', 'descr' => "Predefined tracks #3: coordinates, contigs, gaps, labels." },

     # track layout/placement
     {'data' => 'CM000961.gbk', 'conf' => 'tracks-1.cfg', 'descr' => "Relative and absolute track positioning, transparency, coordinate ruler fmin, fmax." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'tracks-1.cfg', 'descr' => "Relative and absolute track positioning, transparency, coordinate ruler fmin, fmax." },
     {'data' => 'NC_011969.gbk', 'conf' => 'tracks-1.cfg', 'descr' => "Relative and absolute track positioning, transparency, coordinate ruler fmin, fmax." },

     # scaling (scaled-segment-list)
     {'data' => 'CM000961.gbk', 'conf' => 'CM000961-scaling-1.cfg', 'descr' => "tracks-1.cfg with the first 100kb scaled to fill 25% of the circle." },
     {'data' => 'NC_011969.gbk', 'conf' => 'NC_011969-scaling-1.cfg', 'descr' => "tracks-1.cfg with the first 100kb scaled to fill 25% of the circle." },

     # check for off-by-one errors
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'CM000961-180bp-off-by-one-1.cfg', 'descr' => "Synthetic features to check for off-by-one errors in feature and sequence rendering." },

     {'data' => 'CM000961-180bp.gbk', 'conf' => 'CM000961-180bp-off-by-one-2.cfg', 'descr' => "CM000961-180bp-off-by-one-1.cfg with the interval [50,51] scaled by 10X." },

     # more advanced scaling test
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'CM000961-180bp-off-by-one-with-scaling-1.cfg',
      'args' => '--scaled_segment_list="179-180:5,0-1:10,1-2:5,49-50:5,50-51:10,51-52:5"',
      'descr' => "CM000961-180bp-off-by-one-1.cfg with the following scaling on the command line: 179-180:5,0-1:10,1-2:5,49-50:5,50-51:10,51-52:5" },
     
     # graphs
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'CM000961-180bp-graphs-1.cfg', 'descr' => "%GC graphs on a very short sequence with low window-size, plotted against the sequence." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'CM000961-180bp-graphs-2.cfg', 'descr' => "GC-skew graphs on a very short sequence with low window-size, plotted against the sequence." },
     # line graphs
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'CM000961-180bp-line-graphs-1.cfg', 'descr' => "Tests for graph-type=line." },
     # heat maps
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'CM000961-180bp-heat-maps-1.cfg', 'descr' => "Tests for graph-type=heat_map." },
     {'data' => 'CM000961.gbk', 'conf' => 'heat-maps-1.cfg', 'descr' => "Additional tests for graph-type=heat_map and heat_map_brewer_color_palette." },
     
     # labels
     {'data' => 'CM000961.gbk', 'conf' => 'labels-1.cfg', 'descr' => "Automatically-generated and packed labels for tRNA and rRNA features, plus manually-defined label(s)." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'labels-1.cfg', 'descr' =>  "Automatically-generated and packed labels for tRNA and rRNA features, plus manually-defined label(s)." },
     {'data' => 'NC_011969.gbk', 'conf' => 'labels-1.cfg', 'descr' =>  "Automatically-generated and packed labels for tRNA and rRNA features, plus manually-defined label(s)." },

     # multiple input contigs (in one file)
     {'data' => 'AE003852-AE003853.gbk', 'conf' => 'AE003852-AE003853-contigs-and-gaps-1.cfg', 'descr' => "Positioning of contigs and contig gaps." },

     # multiple input contigs (using --contig_list option)
     {'conf' => 'AE003852-AE003853-contigs-and-gaps-1.cfg', 'args' => "--contig_list=${CONF_DIR}/AE003852-AE003853-list-1.txt", 'descr' => "Multi-contig figure using --contig_list." },
     {'conf' => 'AE003852-AE003853-contigs-and-gaps-1.cfg', 'args' => "--contig_list=${CONF_DIR}/AE003852-AE003853-list-2.txt", 'descr' => "Multi-contig figure using --contig_list, including explicit 'genome' feature." },
     {'conf' => 'AE003852-AE003853-contigs-and-gaps-1.cfg', 'args' => "--contig_list=${CONF_DIR}/AE003852-AE003853-list-3.txt", 'descr' => "Multi-contig figure using --contig_list, manual gap specification." },
     {'conf' => 'AE003852-AE003853-contigs-and-gaps-2.cfg', 'args' => "--contig_list=${CONF_DIR}/AE003852-AE003853-list-4.txt", 'descr' => "Multi-contig figure using --contig_list, manual gap and genome specifications." },
     {'conf' => 'AE003852-AE003853-contigs-and-gaps-2.cfg', 'args' => "--contig_list=${CONF_DIR}/AE003852-AE003853-list-5.txt", 'descr' => "Multi-contig figure using --contig_list, manual gap and genome specifications II." },
     # 'revcomp' option to reverse-complement a contig
     {'conf' => 'AE003853-AE003853-contigs-and-gaps-1.cfg', 'args' => "--contig_list=${CONF_DIR}/AE003853-AE003853-list-1.txt", 'descr' => "Multi-contig figure using --contig_list and 'revcomp' option." },

     # GFF parsing
     {'data' => 'AE003852-AE003853.gbk', 'conf' => 'AE003852-AE003853-gff-1.cfg', 'descr' => "GFF file parsing." },

     # loops
     {'data' => 'AE003852-AE003853.gbk', 'conf' => 'AE003852-AE003853-loops-1.cfg', 'descr' => "Basic loops." },
     {'data' => 'AE003852-AE003853.gbk', 'conf' => 'AE003852-AE003853-loops-2.cfg', 'descr' => "Nested loops." },
     {'data' => 'AE003852-AE003853.gbk', 'conf' => 'AE003852-AE003853-loops-3.cfg', 'descr' => "Nested loops II." },

     # ----------------------------------------------------
     # images used in Circleator documentation/web site
     # ----------------------------------------------------

     # logos
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'logo-1.cfg', 'args' => "--rotate_degrees=10 ", 'descr' => "Simplified Circleator logo, rotated by 10 degrees." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'logo-2.cfg', 'args' => "--rotate_degrees=10 ", 'descr' => "Full Circleator logo, rotated by 10 degrees." },

     # navigation icons
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'nav-circle.cfg', 'args' => "--pad=0 ", 'descr' => "Navigation/page location icon for Circleator web site." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'nav-circle-sel-home.cfg', 'args' => "--pad=0 ", 'descr' => "Navigation/page location icon for Circleator web site, 'HOME' highlighted." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'nav-circle-sel-docs.cfg', 'args' => "--pad=0 ", 'descr' => "Navigation/page location icon for Circleator web site, 'DOCS' highlighted." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'nav-circle-sel-gallery.cfg', 'args' => "--pad=0 ", 'descr' => "Navigation/page location icon for Circleator web site, 'GALLERY' highlighted." },
     {'data' => 'CM000961-180bp.gbk', 'conf' => 'nav-circle-sel-software.cfg', 'args' => "--pad=0 ", 'descr' => "Navigation/page location icon for Circleator web site, 'SOFTWARE' highlighted." },

     # single sequence input modes
     #  only --data, no --seq
     #   ** already tested above in most of the previous examples **
     #  both --data and --seq
     {'data' => 'CM000961-no-seq.gbk', 'seq' => 'CM000961-seq.fsa', 'conf' => 'predef-tracks-2.cfg', 'descr' => "Predefined tracks #2, with annotation and sequence in separate files." },
     # only sequence passed to --data option
     {'data' => 'CM000961-180bp-seq.fsa', 'conf' => 'CM000961-180bp-off-by-one-1.cfg', 'descr' => "CM000961-180bp-off-by-one-1.cfg using only sequence, no annotation." },

     # ----------------------------------------------------
     # predefined config files
     # ----------------------------------------------------
     
     {'data' => 'CM000961.gbk', 'conf_dir' => 'conf', 'conf' => 'genes-percentGC-GCskew-1.cfg', 'args' => "--pad=100 ", 'descr' => "Predefined config. file genes-percentGC-GCskew-1.cfg" },

    ];

## ----------------------------------
## input
## ----------------------------------
my $options = {};
&GetOptions($options,
            "working_dir|w=s",
            "release|r=s",
    );

my $working_dir = $options->{'working_dir'};
my $working_results_dir = undef;
if (defined($working_dir)) {
    die "unable to write to --working_dir=$working_dir" if (!-w $working_dir);
    $working_results_dir = File::Spec->catfile($working_dir, "results");
    mkdir $working_results_dir unless (-e $working_results_dir);
}
my $release = $options->{'release'};
my $hfh = undef;

## ----------------------------------
## main program
## ----------------------------------
my $n_tests = scalar(@$TESTS);
plan tests => $n_tests;

# generate HTML output
if (defined($release)) {
    die "--working_dir must be specified if --release flag is present" if (!defined($working_dir));
    $hfh = FileHandle->new();
    my $hfile = File::Spec->catfile($working_dir, "index.html");
    $hfh->open(">$hfile") || die "unable to write to $hfile";
    &print_html_header($hfh, $release, $n_tests);
}

# create tempdir for SVG output
my $tempdir = tempdir(CLEANUP => 1);
my $tnum = 0;
my $num_tests = 0;
my $num_passed = 0;

foreach my $test (@$TESTS) {
    my($data, $seq, $conf_dir, $conf, $descr, $args, $suffix) = map {$test->{$_};} ('data', 'seq', 'conf_dir', 'conf', 'descr', 'args', 'suffix');
    ++$tnum;
    $conf_dir = $CONF_DIR if (!defined($conf_dir));
    ++$num_tests;

    my $ok = 1;
    my $seq_id = undef;
    if (!defined($data) && ($args =~ /\-\-contig_list=(\S+)\.txt/)) {
	my $cl = $1;
	$seq_id = basename($cl);
    } else {
	($seq_id) = ($data =~ /([^\/]+)\.(gbk|fsa)/);
    }
    if (!defined($seq_id) || ($seq_id =~ /^\s*$/)) {
	$ok = 0; 
	diag("couldn't parse seq id from data filename '$data'");
    }
    my($conf_base) = ($conf =~ /([^\/]+)\.cfg/);
    if (!defined($conf_base)) {
	$ok = 0; 
	diag("couldn't parse config name from config filename '$conf'");
    }
    my $file_base = "${seq_id}-${conf_base}";
    $file_base .= "-${suffix}" if (defined($suffix) && ($suffix =~ /\S/));
    my $svg_file = $file_base . ".svg";
    my $log_file = $file_base . ".log";
    my $new_svg_path = File::Spec->catfile($tempdir, $svg_file);
    my $log_path = File::Spec->catfile($tempdir, $log_file);
    my $old_svg_path = File::Spec->catfile($RESULTS_DIR, $svg_file);
    my $data_path = (defined($data) && ($data =~ /\S/)) ? File::Spec->catfile($DATA_DIR, $data) : undef;
    my $seq_path = (defined($seq) && ($seq =~ /\S/)) ? File::Spec->catfile($DATA_DIR, $seq) : undef;
    my $conf_path = File::Spec->catfile($conf_dir, $conf) if (defined($conf));

    if (!-e $old_svg_path || !-r $old_svg_path) {
	$ok = 0;
	diag("missing file $old_svg_path");
    }

    # run Circleator
    my $cmd = "perl -I$LIB_DIR $BIN_DIR/circleator ";
    $cmd .= "--data=$data_path " if (defined($data_path));
    $cmd .= "--config=$conf_path " if (defined($conf));
    $cmd .= "--sequence=$seq_path " if (defined($seq_path));
    $cmd .= "--conf_dir=conf ";
    $cmd .= "--debug=all ";
    $cmd .= $args if (defined($args));
    $cmd .= "> $new_svg_path 2> $log_path";

    system($cmd);
    my $err = undef;

    # check exit status
    if ($? == -1) {
	$err = "circleator failed to execute: $!\n";
    }
    elsif ($? & 127) {
	$err = sprintf("circleator died with signal %d, %s coredump\n", ($? & 127), ($? & 128) ? 'with' : 'without');
    }
    else {
	my $exitval = $? >> 8;
	$err = "circleator exited with value $exitval" if ($exitval != 0);
    }
    
    if (defined($err)) {
	$ok = 0;
	diag($err);
    }
    # check output matches stored SVG 
    elsif (files_differ($old_svg_path, $new_svg_path)) {
	$ok = 0;
    }

    # copy SVG and error log output into --working_dir
    if (defined($working_dir) && ((!$ok) || (defined($release)))) {
	system("mv $new_svg_path ${working_dir}/");
	system("mv $log_path ${working_dir}/");
	
	if (defined($release)) {
	    my $ok_str = $ok ? 'ok' : 'not_ok';
	    system("cp $conf_path ${working_dir}/");
	    my $date = `date`;
	    chomp($date);
	    my $new_svg = $svg_file;
	    my $old_svg = "t/results/$svg_file";
	    my($new_png, $new_small_png) = map { my $copy = $new_svg; $copy =~ s/\.svg$/$_/; $copy; } ('-5000.png', '.png');
	    my($old_png, $old_small_png) = map { my $copy = $old_svg; $copy =~ s/\.svg$/$_/; $copy; } ('-5000.png', '.png');
	    
	    
	    $hfh->print("<h3 class='test'>$tnum/$n_tests $descr</h3>\n");
	    $hfh->print("<span class='test_${ok_str}'><span class='test_key'>result:</span> " . uc($ok_str) . "</span><br clear='both'>\n");
	    $hfh->print("<span class='test_key'>data file:</span> $data<br clear='both'>\n");
	    $hfh->print("<span class='test_key'>sequence file:</span> $seq<br clear='both'>\n");
	    $hfh->print("<span class='test_key'>run date:</span> $date<br clear='both'>\n");
	    $hfh->print("<span class='test_key'>command:</span> $cmd<br clear='both'>\n");

	    # display old and new side by side:
	    $hfh->print("<table class='test_${ok_str}'>\n<tbody>\n");

	    # test result + reference captions
	    $hfh->print("<tr><th class='test'>TEST RESULT</th><th class='test'>REFERENCE</th></tr>\n");

	    # small images
	    $hfh->print("<tr>\n");
	    # test result
	    $hfh->print("<td><img src='$new_small_png' class='test_result'></td>\n");
	    # reference
	    $hfh->print("<td><img src='$old_small_png' class='test_result'></td>");
	    $hfh->print("</tr><br clear='both'>\n");

	    # links to full-size images
	    $hfh->print("<tr>\n");
	    # test result
	    $hfh->print("<td class='test'><a href='$new_svg'>SVG</a>&nbsp;<a href='$new_png'>PNG</a>&nbsp;<a href='$conf'>config. file</a>&nbsp;<a href='$log_file'>log file</a></td>");
	    # reference
	    $hfh->print("<td class='test'><a href='$old_svg'>SVG</a>&nbsp;<a href='$old_png'>PNG</a></td>\n");
	    $hfh->print("</tr>\n");

	    $hfh->print("</tbody>\n</table>\n");

	    ++$num_passed if ($ok);
	    # copy results file too
	    system("cp $old_svg_path ${working_results_dir}");
	}
    }

    ok($ok, $descr);
}

if (defined($hfh)) {
    my $num_failed = $num_tests - $num_passed;
    my $ok_str = ($num_failed == 0) ? 'ok' : 'not_ok';
    $hfh->print("<h3>SUMMARY</h3>\n");
    $hfh->print("$num_passed/$num_tests passed, <span class='test_${ok_str}'>$num_failed failed</a><br clear='both'>\n");
    &print_html_footer($hfh);
    $hfh->close();
}

exit(0);

## ----------------------------------
## subroutines
## ----------------------------------
sub files_differ {
    my($old_file, $new_file) = @_;

    my $old_fh = FileHandle->new();
    my $new_fh = FileHandle->new();
    if (!$old_fh->open($old_file)) {
	diag("unable to open saved SVG file $old_file");
	return 1;
    }

    if (!$new_fh->open($new_file)) {
	diag("unable to open new SVG file $new_file");
	$old_fh->close();
	return 1;
    }

    # line-by-line diff
    my $lnum = 0;
    my $first_diff_lnum = undef;

    while (my $old_line = <$old_fh>) {
	++$lnum;
	my $new_line = <$new_fh>;
	# stop if difference found
	if (!defined($new_line) || ($old_line ne $new_line)) {
	    $first_diff_lnum = $lnum;
	    diag("old ($old_file) and new ($new_file) SVG files first differ at line $lnum");
	    last;
	}
    }

    # TODO - check whether $new_fh still has data
    if (!defined($first_diff_lnum)) {
	my $line = <$new_fh>;
	if (defined($line)) {
	    diag("new SVG file is longer than original SVG file");
	    $first_diff_lnum = ++$lnum;
	}
    }

    $old_fh->close();
    $new_fh->close();
    return defined($first_diff_lnum) ? 1 : 0
}

sub print_html_header {
    my($hfh, $release, $n_tests) = @_;
    print $hfh <<HTML_HEADER;
<html>
<head>
<title>Circleator : documentation : $release test results</title>
<link href="../../css/circleator.css" rel="stylesheet" type="text/css" />
</head>
<body>
<table class='header'>
<tbody>
<tr>
 <td class='header' rowspan='2'><img src='../../images/logo-2.png' class='header_logo'></td>
 <td><h1>Circleator</h1></td>
 <td class='header' rowspan='2'><img src='../../images/nav-circle-sel-docs.png' class='nav_circle'></td>
</tr>

<tr>
 <td>&nbsp;<a href='../../index.html'>home</a>&nbsp;|&nbsp;<a href='../../documentation.html'>documentation</a>&nbsp;|&nbsp;<a href='../../gallery.html'>gallery</a>&nbsp;|&nbsp;<a href='../../software.html'>software</a></td>
</tr>
</tbody>
</table>
<div class='main'>
<h2>$release test results</h2>
<p>
These are the results of running the $n_tests test(s) using the $release release of the software. A pair
of images is displayed for each test: the image on the left was created by running the specified version
of the <span class='circleator'>Circleator</span> against the indicated input files and the image on the
right is a reference image that was created using an earlier version of the software and then validated 
manually to ensure that it correctly represents the input data and configuration files. If the SVG documents
from which these images were created differ in any way then that is considered a test failure and the test
and images in question will be highlighted in red. At the end of this page we list the number of failed
tests (which should be zero for any public stable release of the code!)  It is possible that the SVG 
generated by the <span class='circleator'>Circleator</span> might change <em>without</em> affecting the resulting
image (e.g., if the whitespace is changed, or the precision of some of the coordinates is altered slightly)
but in such cases the reference test results should have been updated accordingly prior to finalizing the
release of the software.
</p>
HTML_HEADER
}

sub print_html_footer {
    my($hfh) = @_;
    print $hfh <<HTML_FOOTER;
</div>

<div class='footer'>
</div>
</body>
</html>
HTML_FOOTER
}
