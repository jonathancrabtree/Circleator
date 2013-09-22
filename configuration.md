---
layout: default
pagetype: documentation
title: Configuration file reference
---

<h2>Introduction</h2>
The <span class='circleator'>Circleator</span> configuration file determines almost every aspect of how a 
<span class='circleator'>Circleator</span> figure will be drawn. When the <span class='circleator'>Circleator</span> 
is run <a href='command-line.html'>on the command line</a> the configuration file is specified by the 
<span class='cmdline_opt'>--config</span> option. When the <span class='circleator'>Circleator</span> is run 
via the <a href='web-application.html'><span class='ringmaster'>Ringmaster</span> web application</a> the configuration file is generated automatically
and cannot be edited directly. However, one can customize the track-level options through the web interface,
so much of what is discussed on this page is applicable regardless of how the tool is run:

<ul>
 <li><a href='#format'>File format</a></li>
 <li><a href='#predefined_tracks'>Predefined track types</a></li>
 <li><a href='#user_defined_tracks'>User-defined tracks</a></li>
 <li><a href='#track_position'>Track size and position</a></li>
 <li><a href='#feature_selection'>Feature selection</a></li>
 <li><a href='#colors'>Colors</a></li>
 <li><a href='#labels'>Labels</a></li>
 <li><a href='#opacity'>Opacity</a></li>
 <li><a href='#loops'>Loops</a></li>
 <li><a href='#z_index'>Z-index</a></li>

</ul>

<a name='format'>
<h2>File format</h2>
The standard <span class='circleator'>Circleator</span> configuration file is a tab-delimited plain text file
designed to be edited manually. Blank lines or lines beginning with the "#" character (i.e., as in Perl-style comments)
are ignored. Every other line contains one or more of the following tab-delimited fields:

<ol>
 <li><span class='config_field'>type</span> - either the name of a <a href='predefined-tracks.html'>predefined track type</a> OR the keyword "new"</li>
 <li><span class='config_field'>name</span> - a name by which the track may be referenced from elsewhere in the configuration file</li>
 <li><span class='config_field'>glyph</span> - the Circleator "glyph" used to render this track</li>
 <li><span class='config_field'>heightf</span> - height of the track as a fraction of the circle's radius (0-1)</li>
 <li><span class='config_field'>innerf</span> - position of the innermost part of the track as a fraction of the circle's radius (0-1)</li>
 <li><span class='config_field'>outerf</span> - position of the outermost part of the track as a fraction of the circle's radius (0-1)</li>
 <li><span class='config_field'>data</span> - path to a data file, if one is required by the chosen track <span class='config_field'>type</span> and/or <span class='config_field'>glyph</span></li>
 <li><span class='config_field'>feat_type</span> - display only features of the specified type (e.g., "gene", "tRNA")</li>
 <li><span class='config_field'>feat_strand</span> - display only features on the specified strand (e.g., "-", "+", "-1", "1")</li>
 <li><span class='config_field'>color1</span> - interpretation depends on the track type: usually the fill color</li>
 <li><span class='config_field'>color2</span> - interpretation depends on the track type: usually the stroke/outline color</li>
 <li><span class='config_field'>opacity</span> - opacity of the track between 0 and 1: 0 = invisible/completely transparent and 1=completely opaque</li>
 <li><span class='config_field'>zindex</span> - integer z-index of the track: tracks with higher z-indexes are drawn on top of those with lower z-indexes</li>
 <li><span class='config_field'>options</span> - a comma-delimited list of track options in the format "key=value"</li>
</ol>

<em>All</em> of these fields except for the very first one (<span class='config_field'>type</span>) are optional and may be omitted, meaning
that they can be left out completely, rather than having to enter blank values separated by tabs. Hence the simplest possible line/track 
in a <span class='circleator'>Circleator</span> configuration file is the name of a predefined track type and nothing else, like this:

<pre>
coords
</pre>

You can choose to include as many or as few of the field values as you like, provided that the type is always there. But note that once you
start skipping fields, you have to skip all the rest too. So, for example, you could specify fields  1-3 (<span class='config_field'>type</span>, 
<span class='config_field'>name</span>, <span class='config_field'>glyph</span>):

<pre>
new	r1	rectangle
</pre>

Or fields 1-6 (<span class='config_field'>type</span>, <span class='config_field'>name</span>, <span class='config_field'>glyph</span>, 
<span class='config_field'>heightf</span>, <span class='config_field'>innerf</span>, <span class='config_field'>outerf</span>):
<pre>
new	r1	rectangle	null	0.7	0.75
</pre>

But not fields 1-3 and 10 (<span class='config_field'>type</span>, <span class='config_field'>name</span>, <span class='config_field'>glyph</span>, 
<span class='config_field'>color1</span>):
<pre class='illegal'>
new	r1	rectangle	#ff0000
</pre>

The one exception to this rule is that you are allowed to include the final <span class='config_field'>options</span> field, even if you've
skipped some of the fields that precede it. For example, you can include fields 1-3 plus the <span class='config_field'>options</span> field (#14):

<pre>
new	r1	rectangle	stroke-width=3
</pre>

Another useful feature is that any of the positional fields listed above, with the exception of the first and last, can be
included in the final <span class='config_field'>options</span> field. So while you <em>can't</em> specify values for fields
1-3 and 10 like this (i.e., with only a single tab between "rectangle" and the color specifier "#ff0000"):

<pre class='illegal'>
new	r1	rectangle	#ff0000
</pre>

You <em>can</em> do it like this:

<pre>
new	r1	rectangle	color1=#ff0000
</pre>

Or, equivalently, like this (note the lack of spaces between the different options in the comma-separated option list: the configuration file parser
does not currently allow extra spaces):

<pre>
new	name=r1,glyph=rectangle,color1=#ff0000
</pre>

Note that in one of the preceding examples we used the word "null" to indicate a missing field value. Other ways to do this 
include:

<ul>
 <li>Leaving the field--and all those that follow it--out of the line and skipping directly to the <span class='config_field'>options</span> field.</li>
 <li>Using one of the following equivalent ways to indicate a null/undefined value:
   <ul>
     <li>null</li>
     <li>undef</li>
     <li>n/a</li>
     <li>na</li>
     <li>n</li>
     <li>.</li>
     <li>-</li>
   </ul>
 </li>
</ul>

<a name='predefined_tracks'>
<h2>Predefined track types (<span class='config_field'>type</span>)</h2>
If the value in the first column of a line in the configuration file is anything other than "new" then
it is the name of a predefined track type.  The entire set of <span class='circleator'>Circleator</span>-supported 
predefined track types is listed
on the <a href='predefined-tracks.html'>predefined tracks page</a>, along with information on the 
most commonly used configuration options for each track type. Additional examples of using predefined
track types in configuration files can also be found in both the 
<a href='predefined-config-files.html'>predefined configuration files</a> and also the test configuration
files found in the <a href='test-results/'>test-results</a> directory.

<a name='user_defined_tracks'>
<h2>User-defined tracks (<span class='config_field'>type</span>, <span class='config_field'>name</span>, <span class='config_field'>glyph</span>)</h3>
If the value in the first column of a line in the configuration file is "new" then the track is a user-defined
track and must include columns 2 (<span class='config_field'>name</span>) and 3 (<span class='config_field'>glyph</span>), 
either as positional fields or named values in the <span class='config_field'>options</span> field.  Here are the 
currently-supported <span class='circleator'>Circleator</span> glyphs:

<ul>
 <li>ruler</li>
 <li>rectangle</li>
 <li>label</li>
 <li>graph</li>
 <li>scaled-segment-list</li>
 <li>load</li>
 <li>load-bsr</li>
 <li>bsr</li>
 <li>load-trf-variation</li>
 <li>load-gene-expression-table</li>
 <li>load-gene-cluster-table</li>
 <li>compute-deserts</li>
 <li>compute-graph-regions</li>
 <li>cufflinks-transcript</li>
 <li>synteny-arrow</li>
 <li>loop-start</li>
 <li>loop-end</li>
</ul>

The prdefined track types are all defined in terms of these glyphs, so a predefined track type is really nothing
more than an alias for a user-defined track. The <span class='track'>coords</span> track, for example, is defined
like this in the system-wide predefined track configuration file:

<pre>
new coords ruler 0.02 tick-interval=100000,label-interval=500000,label-type=curved
</pre>

This means that placing either of the following two lines into a configuration file will have exactly the same
effect:

<pre>
# use predefined track type alias for the 'ruler' glyph:
coords
# create user-defined 'ruler' track with the exact same options:
new c1 ruler 0.02 tick-interval=100000,label-interval=500000,label-type=curved
</pre>

Something to note here is that the system-wide predefined track configuration file is not the only
place where new track types can be defined: every time you create a user-defined track and give it
a unique name (e.g., "c1" in the above example) that name can then be reused in the same configuration
file (strictly <em>after</em> the line on which it first appears) as though it were a predefined track
type. This can be useful in cases where you wish to define a number of very similar tracks but without
having to retype all the track options over and over again (or have to cut and paste them.) For example,
in this configuration file excerpt one of the user-defined tracks is given the name "lightblue_ring"
and then that name is used later in the same file to produce another copy of the same track:

<pre>
genes
small-cgap
new lightblue_ring rectangle feat-type=contig,color1=blue,opacity=0.2,heightf=0.05
small-cgap
# "lightblue_ring" is now an alias for the track defined above
lightblue_ring
</pre>

Currently the best way to begin learning about the glyphs is to examine the file that <em>defines</em> the 
predefined track types using the glyphs. This file, called predefined-tracks.cfg, is itself a 
<span class='circleator'>Circleator</span> configuration file, albeit with a significant amount of
documentation and special processing directives embedded in its comments. In the 
<span class='circleator'>Circleator</span> source code it can be found in conf/predefined-tracks.cfg
(e.g., if the software is installed in /usr/local/packages/circleator then this file will be 
/usr/local/packages/circleator/conf/predefined-tracks.cfg)


<a name="track_position">
<h2>Track size and position (<span class='config_field'>heightf</span>, <span class='config_field'>innerf</span>, <span class='config_field'>outerf</span>)</h3>

<p>
There are 3 configuration file options that control <em>where</em> a track will appear.  Each track
is defined as the area between two concentric circles, where the distance between those circles and
their individual radii are specified by <span class='config_field'>heightf</span>, <span class='config_field'>innerf</span>, and
 <span class='config_field'>outerf</span>, respectively. These three options are not independent: given
any two of them the third can be calculated (according to the simple equation <span class='config_field'>heightf</span> = <span class='config_field'>outerf</span> - <span class='config_field'>innerf</span>. In practical terms what this means is that if you 
specify all three of them in the configuration file then the <span class='circleator'>Circleator</span>
will ignore one of them. If you choose not to supply <em>any</em> of these options then the 
<span class='circleator'>Circleator</span> will assign a default <span class='config_field'>heightf</span> 
value to the track, which determines how thick the track will be, and it will set the <span class='config_field'>outerf</span> 
value so that the track appears just <em>inside</em> the track that preceded it in the configuration file.
So if the configuration file contains a number of tracks with no positioning or size information then by
default the first track in the file will appear at the very edge of the circle (<span class='config_field'>outerf</span> = 1.0)
and successive tracks will be nested inside those that came first. If too many tracks are placed using this 
method it is possible to run out of space in the circle, in which case the <span class='circleator'>Circleator</span> 
will report an error when it tries to draw the figure.
</p>

<p>
The following figure shows a number of tracks that are labeled with their 
<span class='config_field'>innerf</span> - <span class='config_field'>outerf</span> values. It 
also illustrates how one track can be drawn on top of another by using transparency and an
<span class='config_field'>innerf</span> - <span class='config_field'>outerf</span> range
that overlaps with one or more other tracks:
</p>

<img class='test_result' src='test-results/latest/results/CM000961-tracks-1-5000.png'>

<p>
Going roughly from outermost to innermost the tracks in this figure are:
<ul>
 <li>the 3 thin grey lines indicating gaps are all in a track from 0-1.1 i.e., <span class='config_field'>innerf</span>=0, <span class='config_field'>outerf</span>=1.1,  <span class='config_field'>heightf</span>=1.1: this track overlaps with all of the other tracks</li> 
 <li>outermost blue "contigs" track from 0.9-1.0 i.e., <span class='config_field'>innerf</span>=0.9, <span class='config_field'>outerf</span>=1.0,  <span class='config_field'>heightf</span>=0.1</li>
 <li>middle blue "contigs" track from 0.7-0.8 i.e., <span class='config_field'>innerf</span>=0.7, <span class='config_field'>outerf</span>=0.8,  <span class='config_field'>heightf</span>=0.1</li>
 <li>thin blue "contigs" track from 0.55-0.6 (i.e., <span class='config_field'>innerf</span>=0.55, <span class='config_field'>outerf</span>=0.6,  <span class='config_field'>heightf</span>=0.05</li>
 <li>thin grey track from 0.5-0.55 i.e., <span class='config_field'>innerf</span>=0.5, <span class='config_field'>outerf</span>=0.55,  <span class='config_field'>heightf</span>=0.05</li>
 <li>green transparent track from 0.5-1.0 i.e., <span class='config_field'>innerf</span>=0.5, <span class='config_field'>outerf</span>=1.0,  <span class='config_field'>heightf</span>=0.5: this track overlaps with all of the above tracks</li>
 <li>inner blue circle from 0-0.4 i.e., <span class='config_field'>innerf</span>=0, <span class='config_field'>outerf</span>=0.4,  <span class='config_field'>heightf</span>=0.4</li>
</ul>
</p>

<p>
In this example one of the tracks (the "gap" track) has an <span class='config_field'>outerf</span> value of 1.1. There's nothing wrong with using values greater than 1, but at some point these tracks will run off the edge of the figure. How soon that happens is a function of the <span class='cmdline_opt'>--pad</span> command-line argument, which determines how much blank space the <span class='circleator'>Circleator</span> will leave on each side of the circle. Note also that any of these three track configuration options (<span class='config_field'>innerf</span>, <span class='config_field'>outerf</span>, and <span class='config_field'>heightf</span>) can be set to the special value "same", which means that they will take on the same value as the track that immediately <em>preceded</em> the current track Setting both <span class='config_field'>innerf</span> and <span class='config_field'>heightf</span> to "same", for example, will create a track that <em>exactly</em> overlaps the one before it. One can also add or subtract a constant value from "same" to specify a value that is relative to the previous track. For example, setting "innerf=same+0.1" specifies an inner fraction that is 0.1 larger than the inner fraction of the previous track.
</p>

<a name='feature_selection'>
<h2>Feature selection (<span class='config_field'>feat_type</span>,<span class='config_field'>feat_strand</span>, and other options)</h2>

<p>
Many track and glyph types, for example the commonly-used rectangle glyph, operate on sets of features. For example, the <span class='track'>genes</span> track is defined thusly:
</p>

<pre>
new genes rectangle 0.07 . . . gene . #000000
</pre>

<p>
Note the value of "gene" in the <span class='config_field'>feat_type</span> field and "." in the <span class='config_field'>feat_strand</span> field; 
this indicates that a black ("#000000") curved rectangle (the "rectangle" glyph) should be drawn for every input feature with type "gene", regardless
of strand.  The definition for the <span class='track'>genes-fwd</span> track is the same but with <span class='config_field'>feat_strand</span> set 
to "1" to draw only forward-strand genes:
</p>

<pre>
new genes-fwd rectangle 0.07 . . . gene 1 #000000
</pre>

As usual, the <span class='config_field'>feat_type</span> and <span class='config_field'>feat_strand</span> may be included in the final 
<span class='config_field'>options</span> field rather than using the equivalent positional options. Note that either dashes or underscores
may be used in the final options field: "feat-type" and "feat_type" are treated the same:

<pre>
new genes-fwd-too rectangle 0.07 feat-type=gene,feat-strand=1,color1=#000000
</pre>

<h3>Feature filter track options</h3>

<span class='config_field'>feat_type</span> and <span class='config_field'>feat_strand</span> are both examples of feature "filters". That
is, they filter or restrict the set of features on which the track will operate. The following list enumerates the other feature filters that
<span class='circleator'>Circleator</span> supports:

<ul>
 <li><span class='option'>refseq-name</span> - Filters all features that are NOT from the specified sequence/contig
<pre>
# draw only genes on contig239
new genes rectangle heightf=0.05,feat-type=gene,refseq-name=contig239
</pre>
</li>
 <li><span class='option'>clip-fmin, clip-fmax</span> - Filters all features that are outside the specified sequence coordinate range
<pre>
# label all genes in the region between 265kb and 275kb with their locus_ids:
small-label label-type=spoke,innerf=1.04,feat-type=gene,label-function=locus,clip-fmin=265000,clip-fmax=275000
</pre>
</li>
 <li><span class='option'>feat-type</span> - Filters all features that are NOT of the specified type (e.g., exon, CDS, gene, rRNA, tRNA)
<pre>
# color all tRNAs red
new genes rectangle heightf=0.05,color1=red,feat-type=tRNA
</pre>
</li>
 <li><span class='option'>feat-type-regex</span> - Filters all features whose type is NOT matched by the specified Perl regular expression
<pre>
# color all tRNAs AND all rRNAs red
new genes rectangle heightf=0.05,color1=red,feat-type-regex=[tr]RNA
</pre>
</li>
 <li><span class='option'>feat-strand</span> - Filters all features that are NOT on the specified strand
<pre>
# color all forward-strand tRNAs red
new genes rectangle heightf=0.05,color1=red,feat-type=tRNA,feat-strand=1
</pre>
</li>
 <li><span class='option'>feat-min-length</span>,<span class='option'>feat-max-length</span>  - Filters all features whose length (i.e., max genomic coord - min genomic coord) is less than (or more than) the specified value
<pre>
# label all genes that are more than 20kb long:
small-label label-type=spoke,innerf=1.04,feat-type=gene,label-function=locus,feat-min-length=20000
</pre>
</li>
 <li><span class='option'>overlapping-feat-type</span> - Filters all feature that do NOT overlap with another feature of the specified type
<pre>
# label all CDS features that contain at least one SNP
new GL label feat-type=CDS,innerf=1.32,heightf=0.02,label-function=product,label-type=spoke,packer=none,overlapping-feat-type=SNP
</pre>
</li>
 <li><span class='option'>feat-tag</span> - Used in conjunction with the remaining filters to select features based on their attributes. If none of the other feat-tag filters are given then it will filter all features that do NOT have the specified attribute.</li>
 <li><span class='option'>feat-tag-value</span> - Filter all features whose <span class='option'>feat-tag</span> attribute does NOT have the specified value
<pre>
# draw only SNPs with SNP_num_diffs=7 (i.e., SNPs at which 7 of the query genomes differ from the reference)
new SNP rectangle 0.03 feat-type=SNP,stroke-width=1,color1=#000000,feat-tag=SNP_num_diffs,feat-tag-value=7
</pre>
</li>
 <li><span class='option'>feat-tag-min-value</span>,<span class='option'>feat-tag-max-value</span> - Filter all features whose <span class='option'>feat-tag</span> attribute is less than (or more than) the specified value
<pre>
# highlight genes whose expression value in the lung-derived sample is greater than 2
new H1 rectangle innerf=0.32,outerf=1.13,opacity=0.5,color1=#d0d0d0,color2=#000000,feat-type=CDS,feat-tag=EXP_Lung,feat-tag-min-value=2
</pre>
</li>
 <li><span class='option'>feat-tag-regex</span> - Filter all features whose <span class='option'>feat-tag</span> attribute does NOT match the specified Perl regular expression
<pre>
# highlight genes whose gene product matches either "hypothetical protein" or "hypotheticalprotein"
new HCH rectangle feat-type=CDS,feat-tag=product,feat-tag-regex=hypothetical\sprotein,innerf=same,outerf=same,opacity=0.8,color1=#00ff00
</pre>
</li>
</ul>

<h3>Feature source</h3>

In all of the preceding examples we are implicitly considering <em>all</em> of the genomic sequence features that appear in the original input files
(i.e., the file(s) passed to the <span class='cmdline_opt'>--data</span> and/or <span class='cmdline_opt'>--contig_list</span> command line options)
and selecting a subset of those features based on feature type, feature strand, feature attribute values, etc. If the original input file is a GenBank flat file, for 
example, then features of the following types are common (this is not meant to be an exhaustive list): source, gap, gene, CDS, tRNA, rRNA, ncRNA,
tmRNA, misc_feature, misc_binding. In addition to features that appear explicitly in the input file(s), Circleator also adds some features
to represent the genomic sequences/contigs and the spaces between them:

<ul>
 <li><span class='feature_type'>reference_sequence</span>: Circleator will always create a single feature of type 'reference_sequence' that spans the <span style='font-style: italic'>entire</span> reference coordinate system, including gaps if there are multiple sequences.</li>
 <li><span class='feature_type'>contig</span>: Circleator will create a feature of type 'contig' for each input sequence specified by the <span class='cmdline_opt'>--data</span>, <span class='cmdline_opt'>--sequence</span>, or <span class='cmdline_opt'>--contig_list</span> options.</li>
 <li><span class='feature_type'>contig_gap</span>: If the input contains multiple contigs then Circleator will create a feature of type 'contig_gap' between each pair of adjacent contigs (even if <span class='cmdline_opt'>--contig_gap_size</span> is set to 0). If using the <span class='cmdline_opt'>--contig_list</span> option then the location and size of individual gaps can be specified explicitly in the contig list file.</li>
 <li><span class='feature_type'>genome</span>: Circleator will add a feature of type 'genome' for each 'genome' line in the contig list file specified by <span class='cmdline_opt'>--contig_list</span>. See the <a href='http://jcrabtreevm-lx.igs.umaryland.edu/circleator-src/html/docs/command-line.html#cmdline_opts'>command-line option documentation</a> for more information on the use of this option.</li>
</ul>

With this in mind, here are the possible feature sources for any given track:

<ol>
<li><em>The combination of all the features from all of the input files plus the special features mentioned above.</em> (This is the default feature source.)</li>

<li><em>The set of features that are used by another track in the figure.</em><br> This feature source can be selected with the 
 <span class='option'>feat-track</span> option, which specifies the <span class='option'>name</span> of the track whose feature list should be 
     used. A common use of this option is to define a track that prints a label for every feature that was drawn in a previous track. Using the
     <span class='option'>feat-track</span> option is essentially a shortcut to avoid having to repeat all of the same feature filters in 
     multiple tracks.  Here is a simple example:
<pre>
# we use the predefined track type 'contigs' to show all features of type contig 
# (i.e., feat-type=contig) and name it "c1"
contigs c1
# label only the features that were selected by track c1:
medium-label feat-track=c1,label-function=primary_id,packer=none,innerf=same+0.01,outerf=same,text-color=#ffffff
</pre>
</li>

<li><em>The set of features loaded from a (new) external file.</em><br> The <span class='option'>feat-file</span> and <span class='option'>feat-file-type</span> 
options allow one to load features from files that were not included in the <span class='cmdline_opt'>--data</span>, <span class='cmdline_opt'>--sequence</span>, or <span class='cmdline_opt'>--contig_list</span> command-line options that were given when <span class='circleator'>Circleator</span> was run.
The <span class='option'>feat-file</span> option specifies the full path to the file to be loaded and the <span class='option'>feat-file-type</span> 
option specifies what type the file is. If the file is a format accepted by BioPerl (e.g. GenBank flat file, multi-FASTA) then 
<span class='option'>feat-file-type</span> may be omitted. Otherwise it must be one of the following (case-insensitive) options:
<ul>
 <li>ucsc_refGene</li>
 <li>ucsc_refGene_exons</li>
 <li>ucsc_knownGene</li>
 <li>ucsc_knownGene_exons</li>
 <li>ucsc_rmsk</li>
 <li>cufflinks_gtf</li>
 <li>skirret-snp</li>
 <li>merged-table-snp</li>
 <li>snp-table</li>
 <li>VCF</li>
 <li>csv-snp</li>
 <li>tabbed-snp</li>
 <li>trf</li>
 <li>gff</li>
</ul>
<pre>
# Load SNPs for ATCC_30222 from VCF:
new r1 rectangle 0.06 feat-file=data/ATCC_30222.extra-filtered.vcf,feat-file-type=VCF,feat-type=SNP,color1=snp_type,color2=snp_type,snp-query=ATCC_30222
</pre>
</li>

<li><em>A single user-defined feature.</em><br> It is also possible to define a single simple feature directly in the configuration file by using
the following track options:
<ul>
 <li><span class='option'>user-feat-fmin</span>,<span class='option'>user-feat-fmax</span> - coordinates of the feature in chado-style 0-indexed interbase coordinates</li>
 <li><span class='option'>user-feat-start</span>,<span class='option'>user-feat-end</span> - coordinates of the feature in BioPerl-style 1-indexed base-based coordinates</li>
 <li><span class='option'>user-feat-strand</span> - strand of the user-defined feature, either 0,1, or -1</li>
 <li><span class='option'>user-feat-type</span> - type of the user-defined feature (e.g., "gene", "new_feat_type_x"</li>
 <li><span class='option'>user-feat-seq</span> - reference sequence/contig on which the feature is localized</li>
 <li><span class='option'>user-feat-id</span> - unique id for the user-defined feature</li>
</ul>
This can be useful for defining regions of interest directly in the configuration file.  For example, the following configuration
file excerpt highlights the user-defined sequence region from 0-5kb:
<pre>
new SD5000 rectangle innerf=0,outerf=1.2,opacity=0.15,color1=#ff00ff,user-feat-fmin=0,user-feat-fmax=5000
</pre>
One could also define several user-defined features (at most one per line) with the same <span class='option'>user-feat-type</span>
and then refer to all of those features in a subsequent track using <span class='option'>feat-type</span>. For example, here we 
create several ROI (region of interest) features and then highlight them. Note the use of the <span class='track'>load</span>
glyph/track type, which does not draw anything, but only loads and/or creates new features:
<pre>
new uf1a load user-feat-fmin=3898103,user-feat-fmax=3898620,user-feat-type=roi
new uf2a load user-feat-fmin=844688,user-feat-fmax=845220,user-feat-type=roi
new highlight_rois rectangle feat-type=roi,innerf=0,outerf=1.1,opacity=0.4,color1=red,color2=black
</pre>
</li>
</ol>

<em>NOTE:</em> Certain track types can be thought of as having both "input" and "output" features. That is, they 
select a subset of the available features by using 
feature filters (the input) and then they produce a new set of features (the output) using the input features. For example, the
<span class='track'>compute-deserts</span> track type takes a set of input features and then creates a new "desert" feature wherever
it finds a large region that is empty of the input features. It could be used to create a feature of type "SNP_desert" wherever 
there is 15kb or more of sequence that does not contain any SNPs: the SNPs are the input features and the SNP_deserts are the output
features. Currently the <span class='option'>feat-track</span> option always refers to the input features for a track, never the
output features. In the preceding example one could instead refer to the output desert features by using the feature filter 
<span class='option'>feat-type</span>=SNP_desert. Also in some cases the <span class='option'>feat-type</span> option is used to specify the
type of features that a track should create, rather than filtering the input features.

<a name='colors'>
<h2>Colors (e.g., <span class='option'>color1</span>, <span class='option'>color2</span>, <span class='option'>text-color</span>)</h2>
Wherever it expects a color specification (e.g., in the <span class='option'>color1</span>, <span class='option'>color2</span>, and <span class='option'>text-color</span> options) <span class='circleator'>Circleator</span> should accept any of the following:

<ol>
<li>Any valid <a href='http://www.w3.org/TR/SVG/types.html#ColorKeywords'>SVG 1.1 color specifier</a>.<br>
 For example, all of the following are valid ways to set <span class='option'>color1</span> to red:
<pre>
new cr1a rectangle feat-type=gene,color1=rgb(255,0,0)
new cr1b rectangle feat-type=gene,color1=red
new cr1c rectangle feat-type=gene,color1=#ff0000
</pre>
</li>

<li>Any color function defined in the <span class='circleator'>Circleator's</span> Circleator::FeatFunction::Color package:<br>
<ul>
<li><span class='option'>expression_level</span> - Assigns color based on expression level. Uses the following additional options:
<ul>
 <li><span class='option'>sample</span> - the sample whose expression level should be used to determine the color.</li>
 <li><span class='option'>exp-default-color</span> - a default color to use if one is not specified by the following options.</li>
 <li><span class='option'>exp-thresholds</span> - a "|"-delimited list of one or more threshold values
 <li><span class='option'>exp-colors</span> - a "|"-delimited list of colors, one for each value in <span class='option'>exp-thresholds</span>.</li>
</ul>
<pre>
# Genes whose expression value is between 0 and 2 in the lung sample are colored green, those with value >2 are red:
new genes rectangle 0.08 feat-type=CDS,color1=expression_level,color2=expression_level,sample=Lung,exp-default-color=black,exp-thresholds=0|2,exp-colors=green|red
</pre>
</li>

<li><Span class='option'>regex_list</span> - Assigns color based on matching a feature's attribute to one or more regular expressions. Uses the following additional optiosn:
<ul>
 <li><span class='option'>color[12]-regexes</span> - a "|"-delimited list of Perl regular expressions against which to match the named feature attribute.</li>
 <li><span class='option'>color[12]-colors</span> - a "|"-delimited list of color specifies, one for each of the Perl regular expressions.</li>
 <li><span class='option'>color[12]-min-lengths</span> -  a "|"-delimited list of minimum feature length values, one for each of the Perl regular expressions.</li>
 <li><span class='option'>color[12]-max-lengths</span> -  a "|"-delimited list of maximum feature length values, one for each of the Perl regular expressions.</li>
 <li><span class='option'>color[12]-attribute</span> - the feature attribute to match against the regexes: currently "display_name" and "product" are the only options</li>
 <li><span class='option'>color[12]-default</span> - the color to use for any feature whose display_name or product matches none of the regular expressions</li>
</ul>
<pre>
# Attempt to color-code hypothetical genes based on their length (0-499,500-999,1000-1999,2000+):
new genes rectangle 0.08 feat-type=CDS,color1=regex_list,color1-regexes=hypothetical|hypothetical|hypothetical|hypothetical,color1-colors=#375817|#ef3c17|#ef16b7|#162bef,color1-attribute=product,color1-default=none,color1-min-lengths=0|500|1000|2000
</pre>
</li>

<li><span class='option'>snp_text</span> - Assigns color based on whether a SNP/small sequence variant affects a single base or multiple bases. Uses the following additional options:
<ul>
<li><span class='option'>snp-query</span> - the name of the query (i.e., non-reference) genome or strain in question</li>
</ul>
<pre>
# Display the variant allele/genomic sequence bases from sequence AE015925.1, using text-color=snp_text to draw single base alleles white and multibase alleles gray
new SNPL1 label 0.02 innerf=same,label-track-num=-1,label-function=snp_base,text-color=snp_text,snp-query=gi|29835126|gb|AE015925.1|,packer=none
</pre>
</li>

<li><span class='option'>snp_type</span> - Assigns color based on the type of a SNP/indel. Uses the following additional options (all of which except <span class='option'>snp-query</span> are optional and have predefined defaults):
<ul>
<li><span class='option'>snp-query</span> - the name of the query (i.e., non-reference) genome or strain in question</li>
<li><span class='option'>snp-no-hit-color</span> - color to use for SNPs/indels where the variant position could not be identified in the snp-query strain</li>
<li><span class='option'>snp-same-as-ref-color</span> - color to use for SNPs where the query sequence is the same as the reference sequence</li>
<li><span class='option'>snp-unknown-color</span> - color to use for SNPs that haven't been classified as synonymous/nonsynonymous/intergenic</li>
<li><span class='option'>snp-intergenic-color</span> - color to use for intergenic SNPs (wrt to some reference annotation)</li>
<li><span class='option'>snp-syn-color</span> - color to use for synonymous SNPs</li>
<li><span class='option'>snp-nsyn-color</span> - color to use for nonsynonymous SNPs</li>
<li><span class='option'>snp-multiple-color</span> - color to use for SNPs that may be both synonymous and nonsynonymous, depending on context</li>
<li><span class='option'>snp-ins-color</span> - color to use for insertions in the query relative to the reference</li>
<li><span class='option'>snp-del-color</span> - color to use for deletions in the query relative to the reference</li>
<li><span class='option'>snp-intronic-color</span> - color to use for intronic SNPs</li>
<li><span class='option'>snp-readthrough-color</span> - color to use for readthrough SNPs</li>
<li><span class='option'>snp-other-color</span> - color to use for any SNP not covered by any of the other cases</li>
</ul>
<pre>
# set snp-nsyn-color to 'none', which in this case has the effect of showing only the SYNonymous SNPs
new snp2 rectangle heightf=0.07,feat-track=snp1,color1=snp_type_no_indel,color2=snp_type_no_indel,snp-query=PCTRA_SC110_consensus_hhcedit,snp-nsyn-color=none,snp-intergenic-color=none
</pre>
</li>

<li><span class='option'>snp_type_no_indel</span> - Assigns color base don the type of a SNP/indel. Accepts the same options as <span class='option'>snp_type</span>, minus <span class='option'>snp-ins-color</span> and <span class='option'>snp-del-color</span></li>

</ul>

</li>
</ol>

<a name='labels'>
<h2>Labels (<span class='option'>label-text</span>, <span class='option'>label-function</span>)</h2>
The <span class=''>label</span> track type in <span class='circleator'>Circleator</span> allows labels (i.e., short text strings) to be drawn next to tracks and/or specific features. For example, one might label an entire track "%GC-Content" or one might label a highlighted region of interest "highly variable region 1" or one might label all tRNAs with their anticodon. There are two ways to specify what label should be drawn:

<ol>
<li>The <span class='option'>label-text</span> option specifies a literal string that the label should display. It is important to note that the current configuration file format does NOT allow for spaces in option values, although it is possible to use an underscore character or the string "&nbsp;" (i.e., the HTML character entity reference for a non-breaking space) instead.  So the following is NOT legal:
<pre>
large-label label-text=C. albicans
</pre>
But both of these are legal:
<pre>
large-label label-text=C._albicans
large-label label-text=C.&amp;nbsp;albicans
</pre>
</li>

<li>The <span class='option'>label-function</span> option can be used to specify any of the label functions defined in the <span class='circleator'>Circleator</span>'s Circleator::FeatFunction::Label package. These label functions assign labels to individual features using a variety of methods. Some are specific to particular feature types whereas others should work regardless of type:</li>

<ul>
<li><span class='option'>tag</span> - this function can be used to extract any BioPerl-defined tag/attribute value from a feature. For example, it could be applied to extract the ID field from features read from a GFF3 file. The function supports the following options:
<ul>
 <li><span class='option'>tag-name</span> - the name of the tag/attribute whose value is to be used for the label</li>
 <li><span class='option'>tag-value-separator</span> - a string that should be used to join together multiple tag values in the case where a feature has more than one.</li>
 <li><span class='option'>tag-ignore-multiple-values</span> - set this to 1 to ignore multiple values and use only the first.</li>
</ul>
<pre>
new pl label innerf=same+0.02,outerf=same-0.025,label-function=tag,tag-name=ID,feat-type=p_arm,text-color=white,packer=none,label-type=spoke
new ql label innerf=same,outerf=same,label-function=tag,tag-name=ID,feat-type=q_arm,text-color=white,packer=none,label-type=spoke
</pre>
</li>

<li><span class='option'>accession</span> - labels features with their accession number, if any.</li>
<li><span class='option'>display_name</span> - labels features with their BioPerl display_name(), if any.</li>
<li><span class='option'>id</span> - labels features with their BioPerl id(), if any.</li>
<li><span class='option'>primary_id</span> - labels features with ther BioPerl primary_id, if any.</li>

<li><span class='option'>locus</span> - labels features with their BioPerl locus id, if any. Note that the following two lines are equivalent:
<pre>
small-label label-type=spoke,innerf=1.12,feat-type=gene,label-function=locus
small-label label-type=spoke,innerf=1.12,feat-type=gene,label-function=tag,tag-name=locus,tag-ignore-multiple-values=1
</pre>
</li>

<li><span class='option'>product</span> - labels features with their BioPerl product, if any. Note that the following two lines are equivalent:
<pre>
small-label label-type=spoke,innerf=1.12,feat-type=CDS,label-function=product
small-label label-type=spoke,innerf=1.12,feat-type=CDS,label-function=tag,tag-name=product,tag-ignore-multiple-values=1
</pre>
</li>

<li><span class='option'>bsr_count</span> - labels a BSR feature with the number of genomes in which the corresponding gene is conserved according to the BLAST Score Ratio threshold. Supports the following options:
<ul>
 <li><span class='option'>genomes</span> - a "|"-delimited list of BSR query genomes to consider when counting the number of genomes in which each gene is conserved.</li>
 <li><span class='option'>threshold</span> - a BSR threshold value above which genes are considered to be conserved. Default is 0.4</li>
</ul>
<pre>
new glc1 label 0.02 outerf=same,feat-track=bsr_track_e,label-function=bsr_count,text-anchor=middle,packer=none,label-type=curved,genomes=gcp8455|gcpCP3|gcpGR9|gcpM56|gcpMN|gcpNJ1|gcpVS225|gcpWC|gcpWSRTE30
</pre>
</li>

<li><span class='option'>genomic_seq</span> - labels a feature with its literal genomic sequence. Typically used for individual base features that have been expanded to the point where there's room to display the corresponding A,C,G, or T within.</li>

<li><span class='option'>length_bp</span> - labels features with their length in base pairs.</li>
<li><span class='option'>length_kb</span> - labels features with their length in kilobases.</li>
<li><span class='option'>position</span> - labels features with their genomic sequence position.</li>

<li><span class='option'>rRNA_product</span> - labels rRNA features with their type (e.g., 16S, 23S).</li>

<li><span class='option'>snp_base</span> - labels SNP/indel features with their DNA sequence in a specified strain/genome. Supports the following options:
<ul>
<li><span class='option'>snp-query</span> - the name of the query (i.e., non-reference) genome or strain in question</li>
 <li><span class='option'>snp-no-hit-label</span> - a specific label/string to use when the SNP position could not be identified in the specified query strain.</li>
 <li><span class='option'>snp-same-as-ref-label</span> - a specific label/string to use when the DNA sequence in the specified query strain is the same as the sequence in the reference strain. Setting this to &amp;nbsp;, for example, will print the DNA sequence only for those loci that differ from the reference.</li>
</ul>
<pre>
small-label label-function=snp_base,label-track-num=-2,text-color=#a0a0a0,style=default,snp-query=CP1041
</pre>
</li>

<li><span class='option'>snp_ref_base</span> - similar to <span class='option'>snp_base</span>, but it displays the reference DNA sequence at a given SNP position.</li>
<li><span class='option'>snp_gene_id</span> - displays the gene_id (if any) associated with a SNP feature.  Note that the following two lines are equivalent:
<pre>
new SNPP label innerf=1.20,heightf=0.35,label-track-num=-2,label-function=snp_gene_id,label-type=spoke,text-anchor=start
new SNPP label innerf=1.20,heightf=0.35,label-track-num=-2,label-function=tag,tag-name=gene_id,tag-ignore-multiple-values=1,label-type=spoke,text-anchor=start
</pre>
</li>

<li><span class='option'>snp_product</span> -  displays the gene product (if any) associated with a SNP feature.  Note that the following two lines are equivalent:
<pre>
new SNPP label innerf=1.20,heightf=0.35,label-track-num=-2,label-function=snp_product,label-type=spoke,text-anchor=start
new SNPP label innerf=1.20,heightf=0.35,label-track-num=-2,label-function=tag,tag-name=SNP_product,tag-ignore-multiple-values=1,label-type=spoke,text-anchor=start
</pre></li>
</ul>
</ol>

<a name='opacity'>
<h2>Opacity (<span class='option'>opacity</span>)</h2>

The opacity/transparency of any track can be set with the <span class='opacity'>opacity</span> option, which takes as its value a number between 0 and 1, with 0 meaning 0% opacity (i.e., the track is completely invisible) and 1 meaning 100% opacity (i.e., it completely obscures anything directly behind it). Values between 0 and 1 can be used to make tracks semi-transparent. For example, one might highlight a region of interest by overlaying a shaded area with opacity set to 0.3 or 0.4, like so:
<pre>
new highlight1 rectangle user-feat-fmin=50000,user-feat-fmax=100000,color1=red,color2=none,opacity=0.3,innerf=0,outerf=1.1
</pre>

<a name='loops'>
<h2>Loops (<span class='track'>loop-start</span>, <span class='track'>loop-end</span>)</h2>

<span class='circleator'>Circleator</span> supports the use of loops to simplify the construction of configuration files when the same track or set of tracks must be repeated many times for a different subset of the data (e.g., as when showing SNPs, gene clusters, or BSR data for a number of genomes or strains in a large multi-strain comparison.) Loops may be added to a configuration file using two special track types, <span class='track'>loop-start</span> and <span class='track'>loop-end</span> . At present a loop may specify only a single loop variable (i.e., a special keyword that will be replaced by each of a list of values), like so:

<pre>
# highlight a set of genes:
new ls1 loop-start loop-var=GENE,loop-values=VC_0788|VC_A0970|VC_0915|VC_A1016|VC_A0790
# the contents of the loop, starting here, are repeated for each of the loop-values above:
# with each loop iteration the keyword &lt;GENE&gt; is replaced by each of the values in turn
new gi rectangle feat-type=gene,feat-tag=locus_tag,feat-tag-value=&lt;GENE&gt;,innerf=0,outerf=1.1,color1=red,color2=grey,opacity=0.2,stroke-width=1.5
medium-label innerf=1.12,feat-track=-1,label-function=locus,label-type=spoke
new le1 loop-end
</pre>

<a name='z_index'>
<h2>Z-index</h2>

The Z-index of a track determines its relative stacking position (i.e., top to bottom) in the figure. Currently the Z-index of each track is determined by its position in the configuration file, with the first track in the file appearing on the bottom of the stack and the last track in the file appearing on the top of the stack.
