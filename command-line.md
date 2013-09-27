---
layout: default
pagetype: documentation
title: Running the Circleator on the command line
---

<h2>Overview</h2>
The <span class='circleator'>Circleator</span> may be run either directly using the command line interface
or indirectly via the <a href='web-application.html'><span class='ringmaster'>Ringmaster</span> web interface</a>.
This page covers using the command line interface.

<ul>
<li><a href='#quick_start'>Quick start guide</a></li>
<li><a href='#cmdline_opts'>Command line options</a></li>
<li><a href='#config_files'>Configuration files</a></li>
<li><a href='#input_data'>Input data (sequence and annotation)</a></li>
</ul>

<a name='quick_start'>
<h2>Quick start guide</h2>
</a>

This document provides a basic introduction to running the <span class='circleator'>Circleator</span> on the Linux command line.  To run the <span class='circleator'>Circleator</span> 
you will need at least the following two things:

<ol>
 <li>Sequence and/or sequence annotation in a BioPerl-supported format (e.g., a GenBank flat file.)</li>
 <li>A <span class='circleator'>Circleator</span> configuration file that specifies what to plot in the figure.</li>
</ol>

For example, the following command runs the <span class='circleator'>Circleator</span> (which we assume has been installed into 
/usr/local/packages/circleator/, as is the case at IGS) with the following input and configuration files, both 
of which are distributed with the <span class='circleator'>Circleator</span> source code:

<ol>
<li>CM000961.gbk, the GenBank WGS flat file for <a href='http://www.ncbi.nlm.nih.gov/nuccore/CM000961'><span style='font-style: italic;'>Corynebacterium genitalium ATCC 33030</span></a></li>
<li>genes-percentGC-GCskew-1.cfg, a predefined configuration file which plots annotated genes and a couple of graphs</li>
</ol>

Since the <span class='circleator'>Circleator</span> produces output in SVG format we will direct the output to a file called "fig1.svg":

<pre>
/usr/local/packages/circleator/bin/circleator --data=/usr/local/packages/circleator/data/CM000961.gbk \
 --config=/usr/local/packages/circleator/conf/genes-percentGC-GCskew-1.cfg >fig1.svg
</pre>

SVG (<a href='http://en.wikipedia.org/wiki/Scalable_Vector_Graphics'>Scalable
Vector Graphics</a>) is an XML-based vector graphics format that can
be viewed directly in many modern web browsers, or opened in programs
such as Adobe Illustrator, <a href='http://inkscape.org'>Inkscape</a>, and
<a href='http://www.gimp.org'>The GNU Image Manipulation Program
(GIMP)</a>.  However, different applications may vary in how well
and/or extensively they implement the SVG specification, so it is
often preferable to convert the SVG output into a different format,
such as PDF, PNG, or JPEG.  A script included in the <span class='circleator'>Circleator</span>
package uses the SVG rasterizer in the <a
href='http://xmlgraphics.apache.org/batik'>Apache Batik SVG
Toolkit</a> to do just this.  To run the conversion script, simply
specify the path to the input SVG file and the desired output format
(either 'pdf', 'png', or 'jpeg'):

<pre>
/usr/local/packages/circleator/bin/rasterize-svg fig1.svg pdf
/usr/local/packages/circleator/bin/rasterize-svg fig1.svg png
/usr/local/packages/circleator/bin/rasterize-svg fig1.svg jpeg
</pre>

<p>
This is what our fig1.svg looks like after converting it to PNG format:
</p>

&#x20;<a href='images/CM000961-genes-percentGC-GCskew-1-5000.png'><img src='images/CM000961-genes-percentGC-GCskew-1.png' class='index_example'></a><br clear='both'/>

The configuration file that we used in this example is composed entirely of 
<a href='predefined-tracks.html'>predefined tracks</a>.  By default the 
<span class='circleator'>Circleator</span> plots the first track in the configuration
file ("coords") around the outside of the circle and successive tracks inside the 
previous ones. Here is the entire configuration file, with comments (the lines 
that begin with "#") added for clarity. It should be straightforward to see the
correspondence between the lines in the configuration file and the circular "tracks"
in the sample image above:

<pre>
# the outer circle with tick marks every 100kb and a coordinate label every 500kb:
coords
# a small gap between the previous track and the next:
small-cgap
# all forward-strand gene features (in CM000961.gbk) drawn as black curved rectangles
genes-fwd
# a very small gap between the previous track and the next:
tiny-cgap
# all reverse-strand gene features (in CM000961.gbk) drawn as black curved rectangles
genes-rev
small-cgap
# percent GC graph using nonoverlapping 5kb windows with range set to observed min &amp; max values.
# (dfa = display Difference From Average)
%GCmin-max-dfa
small-cgap
# GC-skew graph using nonoverlapping 5kb windows with range set to observed min &amp; max values.
# (df0 = display Difference From 0)
GCskew-min-max-df0
</pre>

<p>
We've now seen how to run the <span class='circleator'>Circleator</span> using a GenBank flat file to
specify the input sequence and sequence annotation and one of the <span class='circleator'>Circleator</span>'s
<a href='predefined-config-files.html'>predefined configuration files</a> to specify what type of figure
to plot. In the sections that follow we'll discuss:

<ul>
<li><a href='#cmdline_opts'>Command line options</a> supported by the <span class='circleator'>Circleator</span></li>
<li><a href='#config_files'>Configuration files</a>: different ways to create and/or customize them</li>
<li><a href='#input_data'>Input data files</a>: options for supplying the <span class='circleator'>Circleator</span> with sequence(s) and annotation</li>
</ul>
</p>

<a name='cmdline_opts'>
<h2>Other command line options</h2>
</a>

For a full list of the command line options that the <span class='circleator'>Circleator</span> 
supports, invoke the tool with the <span class='cmdline_opt'>--help</span> option:

<pre>
/usr/local/packages/circleator/bin/circleator --help
</pre>

Here are a few key options that may be useful in addition to those covered in the example above:

<ul>
<li>
<span class='cmdline_opt'>--rotate_degrees=180</span> <br clear='both'/>
    Optional.  Number of degrees (from 0 - 360) to rotate the circle in the clockwise direction.
    Default is 0, meaning that 0bp will appear at the top center of the circle.
</li>
<li>
<span class='cmdline_opt'>--pad=200</span><br clear='both'>
    Amount of padding/blank space to leave on each side of the figure. Default is 400. The main reason
    for increasing this value is to reserve additional space for long labels (e.g., gene product names)
    displayed around the outside of a figure with <span class='option'>label-type</span>=spoke
</li>
<li>
<span class='cmdline_opt'>--contig_list=contigs.txt</span><br clear='both'>
    Optional.  Path to a single tab-delimited file that lists one or more contigs that 
    should be joined into a single circular pseudomolecule by inserting gaps of size 
    <span class='cmdline_opt'>--contig_gap_size</span>.  Each line of the file must contain 5 or 6 tab-delimited fields, some
    of which may be left empty.  These fields are as follows
<ol>
      <li> contig id - the name/id of the sequence (optional)</li>
      <li> display name - a distinct display name to be used for the contig in figures (optional)</li>
      <li> seqlen - the length of the contig in base pairs (optional)</li>
      <li> data file - a contig annotation file in any format accepted by <span class='cmdline_opt'>--data</span></li>
      <li> sequence file - a contig sequence file in any format accepted by <span class='cmdline_opt'>--sequence</span></li>
      <li> revcomp - placing the keyword "revcomp" in the optional 6th field indicates that 
        the sequence/annotation should be reverse-complemented</li>
</ol>

    Note that if this option is provided then the <span class='cmdline_opt'>--data</span>, <span class='cmdline_opt'>--sequence</span>, 
    and <span class='cmdline_opt'>--seqlen</span> options will all be ignored.  The contig id may also be one of the following special 
    values:
  <ul>
      <li>genome - adds a 'genome' feature with name display name, covering all the 
        preceding contigs that are not already associated with a genome tag</li>
      <li> gap - inserts a gap of size seqlen between the previous contig and the next.
        If this keyword is used at any point in the file then --contig_gap_size will be
        ignored and Circleator will _not_ automatically generate any gaps.</li>
  </ul>
</li>
<li>
<span class='cmdline_opt'>--contig_gap_size=2000</span><br clear='both'>
    Optional.  Size of the gap, in base pairs, to place between each pair of contigs listed
    in <span class='cmdline_opt'>--contig_list</span>.
</li>
<li>
<span class='cmdline_opt'>--no_seq</span><br clear='both'>
    Optional.  Set this if no sequence is available for the contigs in <span class='cmdline_opt'>--contig_list</span>, 
    or if sequence is available but the sequences are too large to concatenate into a single pseudomolecule in BioPerl.
</li>
<li>
<span class='cmdline_opt'>--log=logfile.txt</span><br clear='both'>
    Redirects the log/debug output to a file.
</li>
</ul>

<a name='config_files'>
<h2>Configuration files</h2>
</a>

A <span class='circleator'>Circleator</span> figure is composed of several concentric rings, each of which
depicts a specific subset or aspect of the data plotted against a circular reference coordinate system. The rings in
the figure are called "tracks", a term adopted from linear genome visualization tools. The 
<span class='circleator'>Circleator</span> configuration file, specified by the <span class='cmdline_opt'>--config</span> 
command line option, is a plain text file in which each line corresponds to a single track in the resulting figure.
By default as the <span class='circleator'>Circleator</span> reads through the configuration file it places the first 
track on the very outside of the circle, with successive tracks occupying smaller and smaller inner rings until the 
available space is exhausted. There are a number of ways to obtain a <span class='circleator'>Circleator</span>
configuration file, one of which is to simply use one of the predefined configuration files distributed with the 
software, as in our example above. Here is a more complete list of options to consider:

<ul>
 <li>Use one of the <a href='predefined-config-files.html'>predefined configuration files</a> without making any changes.</li>
 <li>Make a copy of a predefined configuration file and modify it as needed.</li>
 <li>Use the <span class='ringmaster'>Ringmaster</span> web interface to create a configuration file as a starting point.</li>
 <li>Create a new configuration file from scratch.</li>
</ul>

In terms of defining tracks within the configuration file there are also several available options:

<ul>
 <li>Choose tracks from the library of customizable <a href='predefined-tracks.html'>predefined track types</a>.</li>
 <li>Create user-defined track types based on the <span class='circleator'>Circleator</span>'s built-in graphical drawing primitives (glyphs).</li>
 <li>Use the <span class='circleator'>Circleator</span>'s Perl API to define entirely new glyphs.</li>
</ul>

For more information on writing and editing configuration files please see the detailed <a href='configuration.html'>configuration file documentation</a>.

<a name='input_data'>
<h2>Input data (sequence and annotation)</h2>
</a>

The <span class='circleator'>Circleator</span> is designed to address a variety of use cases, from displaying
single circular microbial genomes to making figures for large multichromosomal eukaryotic genomes. There are 
several different ways to provide it with the sequence and/or annotation that will appear in the figure, but 
the basic choice is whether the reference coordinate system for the figure will be based on a single contiguous
genome sequence (possibly containing some internal gaps of known lengths) or based on multiple contiguous genome
sequences, separated by artificial gaps of arbitrary size:

<ul>
 <li><a href='#single_input_seq'>Single input sequence</a></li>
 <li><a href='#multiple_input_seqs'>Multiple input sequences/contigs/chromosomes/genomes</a></li>
</ul>

<a name='single_input_seq'>
<h3>Using a single input sequence</h3>
</a>

The simple example shown above uses the <span class='cmdline_opt'>--data</span> command line option to generate a figure for a single sequence entry.
This handles the case where both the sequence and its associated annotation (assuming there is any) are both in the same file.  Not all file formats
support combining sequence and annotation in a single file, however.  If the sequence and annotation are in separate files then they can be passed
to the <span class='circleator'>Circleator</span> separately, using the <span class='cmdline_opt'>--data</span> and <span class='cmdline_opt'>--sequence</span> options.  It is also
possible to run the <span class='circleator'>Circleator</span> by giving it only an annotation input file and no sequence input file.  In this case one restriction is that if the
annotation file does not specify the length of the underlying sequence then it must be passed to <span class='circleator'>Circleator</span> explicitly with the <span class='cmdline_opt'>--seqlen</span>
option.

<a name='multiple_input_seqs'>
<h3>Using multiple input sequences/contigs</h3>
</a>

There are two ways to handle multiple input sequences: they can either be placed into a single BioPerl-supported sequence or 
annotation file or they can be kept in separate files.  In the former case they are passed to the <span class='circleator'>Circleator</span>
using the <span class='cmdline_opt'>--data</span> and/or <span class='cmdline_opt'>--sequence</span> options, just as in the
single input sequence case. In the latter case the paths to the various input files must be placed into a tab-delimited flat
file that is then passed to the <span class='circleator'>Circleator</span>'s <span class='cmdline_opt'>--contig_list</span> 
option:

<ul>
 <li><a href='#multiple_seqs_one_file'>Multiple sequences in one input file</a></li>
 <li><a href='#multiple_seqs_multiple_files'>Multiple sequences in several input files</a></li>
</ul>

<a name='multiple_seqs_one_file'>
<h4>Multiple sequences in one input file</h4>
</a>
The simplest way to display multiple contigs with the <span class='circleator'>Circleator</span> is to use an input file (e.g., a GenBank flat file) that contains 
multiple sequence entries.  The file is still passed to the <span class='circleator'>Circleator</span> with the <span class='cmdline_opt'>--data</span> option, but the <span class='circleator'>Circleator</span> will automatically concatenate
all the sequences in the input file into a single pseudomolecule, placing a gap of size 20000 bp between each adjacent pair of sequences.  The inserted
gap size can be modified by using the <span class='cmdline_opt'>--contig_gap_size</span> option.


<a name='multiple_seqs_multiple_files'>
<h4>Multiple sequences in several input files</h4>
</a>
If, on the other hand, you have multiple sequences split into several files then you can use the <span class='cmdline_opt'>--contig_list</span> option in place of the
<span class='cmdline_opt'>--data</span> option.  The <span class='cmdline_opt'>--contig_list</span> option expects to be given the path to a single tab-delimited file that lists
one or more contig annotation and/or sequence files that should be joined into a single circular pseudomolecule.  Each line of the
tab-delimited file must contain the following 5 or 6 columns, some of which may be left empty:
    <ol>
      <li> contig id - the name/id of the sequence (optional)</li>
      <li> display name - a distinct display name to be used for the contig in figures (optional)</li>
      <li> seqlen - the length of the contig in base pairs (optional)</li>
      <li> data file - a contig annotation file in any format accepted by <span class='cmdline_opt'>--data</span></li>
      <li> sequence file - a contig sequence file in any format accepted by <span class='cmdline_opt'>--sequence</span></li>
      <li> revcomp - placing the keyword "revcomp" in the optional 6th field indicates that the sequence/annotation should be reverse-complemented</li>
    </ol>

Note that if the <span class='cmdline_opt'>--contig_list</span> option is provided then the <span class='cmdline_opt'>--data</span>, <span class='cmdline_opt'>--sequence</span>, and <span class='cmdline_opt'>--seqlen</span> options
will all be ignored.

<h2>More information</h2>

See the list of <a href='predefined-config-files.html'>predefined configuration files</a> for examples of complete configuration 
files that can be used as-is or customized to make your own <span class='circleator'>Circleator</span> configuration file.  Also 
see the list of <a href='predefined-tracks.html'>predefined track types</a> that are available for use in the configuration file.
The predefined tracks can also be used as-is or customized to serve a specific purpose.
