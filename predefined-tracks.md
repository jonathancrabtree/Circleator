---
layout: default
title: Circleator - Predefined Tracks
---

# Circleator - Predefined Tracks

The Circleator provides a number of predefined circular tracks that
can be used to display various types of data with very little effort.
Simply find the appropriate predefined track type in the list below
(e.g., "genes" for a circular display of all annotated features of
type "gene") and place that keyword on a line by itself somewhere in
the Circleator configuration file.  The tracks will be drawn in the
order that they appear in the configuration file, starting with the
outside of the circle and moving inwards.  Most of the predefined track
types support one or more user-configurable options, many of which are also
described below.  Multiple options can be specified by separating them with
a comma (but no spaces), like so:

    genes color1=#ff0000,color2=#000000


The predefined tracks have been grouped into the following categories to make searching easier:

<ol>
<li><a href='#sequence_coordinates_and_contigs'>sequence coordinates and contigs</a>
<ul>
<li><a href='#coords'><span class='track'>coords</span></a></li>
<li><a href='#contigs'><span class='track'>contigs</span></a></li>
<li><a href='#contig-gaps'><span class='track'>contig-gaps</span></a></li></ul>

</li>
<li><a href='#sequence_features'>sequence features</a>
<ul>
<li><a href='#genes'><span class='track'>genes</span></a></li>
<li><a href='#genes-fwd'><span class='track'>genes-fwd</span></a></li>
<li><a href='#genes-rev'><span class='track'>genes-rev</span></a></li>
<li><a href='#tRNAs'><span class='track'>tRNAs</span></a></li>
<li><a href='#tRNAs-fwd'><span class='track'>tRNAs-fwd</span></a></li>
<li><a href='#tRNAs-rev'><span class='track'>tRNAs-rev</span></a></li>
<li><a href='#rRNAs'><span class='track'>rRNAs</span></a></li>
<li><a href='#rRNAs-fwd'><span class='track'>rRNAs-fwd</span></a></li>
<li><a href='#rRNAs-rev'><span class='track'>rRNAs-rev</span></a></li>
<li><a href='#gaps'><span class='track'>gaps</span></a></li></ul>

</li>
<li><a href='#track_layout'>track layout</a>
<ul>
<li><a href='#tiny-cgap'><span class='track'>tiny-cgap</span></a></li>
<li><a href='#small-cgap'><span class='track'>small-cgap</span></a></li>
<li><a href='#medium-cgap'><span class='track'>medium-cgap</span></a></li>
<li><a href='#large-cgap'><span class='track'>large-cgap</span></a></li></ul>

</li>
<li><a href='#graphs'>graphs</a>
<ul>
<li><a href='#%GC0-100'><span class='track'>%GC0-100</span></a></li>
<li><a href='#%GCmin-max'><span class='track'>%GCmin-max</span></a></li>
<li><a href='#%GCmin-max-dfa'><span class='track'>%GCmin-max-dfa</span></a></li>
<li><a href='#GCskew-1-df0'><span class='track'>GCskew-1-df0</span></a></li>
<li><a href='#GCskew-min-max-df0'><span class='track'>GCskew-min-max-df0</span></a></li></ul>

</li>
<li><a href='#labels'>labels</a>
<ul>
<li><a href='#small-label'><span class='track'>small-label</span></a></li>
<li><a href='#medium-label'><span class='track'>medium-label</span></a></li>
<li><a href='#large-label'><span class='track'>large-label</span></a></li></ul>
</li></ol>

<a name='sequence_coordinates_and_contigs'></a>
<h2>1. sequence coordinates and contigs</h2>

<ul>
<li><a href='#coords'><span class='track'>coords</span></a></li>
<li><a href='#contigs'><span class='track'>contigs</span></a></li>
<li><a href='#contig-gaps'><span class='track'>contig-gaps</span></a></li></ul>
<br>
<h3><a name='coords'><span class='track_heading'>coords</span></a></h3>
 The <span class='track'>coords</span> track draws an outer circle with small and large tick marks at intervals that can be specified 
 with the options <span class='option'>tick-interval</span> and <span class='option'>label-interval</span>.  Each large tick mark is labeled with the sequence
 coordinate at that position (e.g., 0.5Mb, 1.0Mb, 1.5Mb) using a label style specified by the <span class='option'>label-type</span> option.  Additional
 options can be used to control the label units (<span class='option'>label-units</span>, i.e., 'Mb', 'kb', 'bp'), precision 
 (the number of digits after the decimal point, <span class='option'>label-precision</span>), and 
 font size (<span class='option'>font-size</span>).  Note that if the Circleator is drawing
 a figure with multiple contigs then the coordinate labeling will include the lengths of any gaps between the contigs.
<br><br>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>coords</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/coords.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.2-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.2-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.2-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.2-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/coords.2.svg'>SVG</a>, <a href='images/predefined-tracks/coords.2-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/coords.2-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/coords.2.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>coords</span> <span class='option_heading'>label-type</span>=</h4>
 The <span class='option'>label-type</span> can be set to 'curved' (the default), 'spoke', or 'horizontal':
<br><br>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>coords</span> track with <span class='option'>label-type</span>=curved</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/coords.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.3-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.3-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.3-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.3-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/coords.3.svg'>SVG</a>, <a href='images/predefined-tracks/coords.3-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/coords.3-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/coords.3.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>coords</span> track with <span class='option'>label-type</span>=spoke</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/coords.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.4-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>8.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.4-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.4-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.4-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/coords.4.svg'>SVG</a>, <a href='images/predefined-tracks/coords.4-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/coords.4-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/coords.4.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>coords</span> track with <span class='option'>label-type</span>=horizontal</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/coords.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.5-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.5-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.5-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.5-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/coords.5.svg'>SVG</a>, <a href='images/predefined-tracks/coords.5-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/coords.5-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/coords.5.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>coords</span> <span class='option_heading'>tick-interval</span>=</h4>
 The tick-interval option controls how frequently (in base pairs) tick marks will be drawn around
 the outer circle of the <span class='track'>coords</span> track:

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>coords</span> track with <span class='option'>tick-interval</span>=100000 (default)</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/coords.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.6-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.6-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.6-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.6-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/coords.6.svg'>SVG</a>, <a href='images/predefined-tracks/coords.6-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/coords.6-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/coords.6.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>coords</span> track with <span class='option'>tick-interval</span>=50000</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/coords.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.7-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.7-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.7-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.7-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/coords.7.svg'>SVG</a>, <a href='images/predefined-tracks/coords.7-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/coords.7-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/coords.7.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>coords</span> <span class='option_heading'>label-interval</span>=</h4>
 The label-interval option controls how frequently (in base pairs) a larger labeled tick mark will
 be drawn around the outer circle of the 'coords' track.  Note that if more frequent labels are 
 specified it may also be necessary to increase the label-precision, and which
 determines how many digits will be shown after the decimal point in the coordinate labels (and
 which defaults to 1.)

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>coords</span> track with <span class='option'>label-interval</span>=500000 (default)</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/coords.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.8-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.8-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.8-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.8-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/coords.8.svg'>SVG</a>, <a href='images/predefined-tracks/coords.8-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/coords.8-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/coords.8.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>coords</span> <span class='option_heading'>label-precision</span>=</h4>
 In this example the <span class='option'>label-interval</span> is decreased to 200000 (200kb) and the <span class='option'>label-precision</span> is increased to 2:

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>coords</span> track with <span class='option'>label-interval</span>=200000,<span class='option'>label-precision</span>=2</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/coords.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.9-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.9-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.9-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.9-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/coords.9.svg'>SVG</a>, <a href='images/predefined-tracks/coords.9-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/coords.9-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/coords.9.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>coords</span> <span class='option_heading'>label-units</span>=</h4>
 The <span class='option'>label-units</span> option may be set to 'Mb' (the default), 'kb', or 'bp':

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>coords</span> track with <span class='option'>label-interval</span>=200000,<span class='option'>label-units</span>=Mb</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/coords.10-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.10-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.10-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.10-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.10-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.10-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.10-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.10-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/coords.10.svg'>SVG</a>, <a href='images/predefined-tracks/coords.10-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/coords.10-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/coords.10.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>coords</span> track with <span class='option'>label-interval</span>=200000,<span class='option'>label-units</span>=kb</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/coords.11-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.11-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.11-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.11-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.11-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.11-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.11-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.11-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/coords.11.svg'>SVG</a>, <a href='images/predefined-tracks/coords.11-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/coords.11-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/coords.11.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>coords</span> track with <span class='option'>label-interval</span>=200000,<span class='option'>label-units</span>=bp</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/coords.12-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.12-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.12-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.12-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.12-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.12-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/coords.12-4000x4000.png'><img class='zoom' src='images/predefined-tracks/coords.12-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/coords.12.svg'>SVG</a>, <a href='images/predefined-tracks/coords.12-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/coords.12-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/coords.12.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='contigs'><span class='track_heading'>contigs</span></a></h3>
 The <span class='track'>contigs</span> track draws a circle with a curved blue rectangle in the position of each contig/sequence
 in the input file.  It is most useful when the input contains multiple sequences:

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>contigs</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/contigs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contigs.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/contigs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contigs.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/contigs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contigs.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/contigs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contigs.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/contigs.1.svg'>SVG</a>, <a href='images/predefined-tracks/contigs.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/contigs.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/contigs.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='contig-gaps'><span class='track_heading'>contig-gaps</span></a></h3>
 The <span class='track'>contig-gaps</span> track draws a circle with a curved grey rectangle in the position of each contig gap (in multi-contig figures only)
 in the input file.
<br><br>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>contig-gaps</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/contig-gaps.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contig-gaps.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/contig-gaps.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contig-gaps.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/contig-gaps.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contig-gaps.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/contig-gaps.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contig-gaps.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/contig-gaps.1.svg'>SVG</a>, <a href='images/predefined-tracks/contig-gaps.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/contig-gaps.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/contig-gaps.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>contig-gaps</span> <span class='option_heading'>color1</span>=</h4>
 The color of most tracks can be changed by using the <span class='option'>color1</span> and <span class='option'>color2</span> 
 options.  <span class='option'>color1</span> typically sets the fill color whereas <span class='option'>color2</span> sets the
 color used for the outline of the feature.  Currently only HTML-style hexadecimal colors of the form "#ff0000" are supported by
 these two options
<br><br>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>contigs</span> track with <span class='option'>color1</span>=#ff0000</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/contigs.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contigs.2-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/contigs.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contigs.2-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/contigs.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contigs.2-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/contigs.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/contigs.2-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/contigs.2.svg'>SVG</a>, <a href='images/predefined-tracks/contigs.2-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/contigs.2-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/contigs.2.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<a name='sequence_features'></a>
<h2>2. sequence features</h2>
<ul>
<li><a href='#genes'><span class='track'>genes</span></a></li>
<li><a href='#genes-fwd'><span class='track'>genes-fwd</span></a></li>
<li><a href='#genes-rev'><span class='track'>genes-rev</span></a></li>
<li><a href='#tRNAs'><span class='track'>tRNAs</span></a></li>
<li><a href='#tRNAs-fwd'><span class='track'>tRNAs-fwd</span></a></li>
<li><a href='#tRNAs-rev'><span class='track'>tRNAs-rev</span></a></li>
<li><a href='#rRNAs'><span class='track'>rRNAs</span></a></li>
<li><a href='#rRNAs-fwd'><span class='track'>rRNAs-fwd</span></a></li>
<li><a href='#rRNAs-rev'><span class='track'>rRNAs-rev</span></a></li>
<li><a href='#gaps'><span class='track'>gaps</span></a></li></ul>
 Several track types are provided to plot common sequence features like genes, tRNAs, and rRNAs.  Many of these track types
 come in 3 different variants, to plot either:
 <ol>
  <li>all features of that type, regardless of strand (e.g., <span class='track'>genes</span>)</li>
  <li>only features of that type on the forward strand (e.g., <span class='track'>genes-fwd</span>)</li>
  <li>only features of that type on the reverse strand (e.g., <span class='track'>genes-rev</span>)</li>
 </ol>
 
 In the examples below, all 3 track types are shown for the <span class='track'>genes</span> track, but only the
 first is shown for the other feature types:

<br>
<h3><a name='genes'><span class='track_heading'>genes</span></a></h3>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>genes</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/genes.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/genes.1.svg'>SVG</a>, <a href='images/predefined-tracks/genes.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/genes.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/genes.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='genes-fwd'><span class='track_heading'>genes-fwd</span></a></h3>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>genes-fwd</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/genes-fwd.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-fwd.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/genes-fwd.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-fwd.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/genes-fwd.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-fwd.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/genes-fwd.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-fwd.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/genes-fwd.1.svg'>SVG</a>, <a href='images/predefined-tracks/genes-fwd.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/genes-fwd.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/genes-fwd.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='genes-rev'><span class='track_heading'>genes-rev</span></a></h3>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>genes-rev</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/genes-rev.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-rev.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/genes-rev.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-rev.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/genes-rev.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-rev.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/genes-rev.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-rev.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/genes-rev.1.svg'>SVG</a>, <a href='images/predefined-tracks/genes-rev.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/genes-rev.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/genes-rev.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>genes-fwd</span> and <span class='track'>genes-rev</span> tracks together</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/genes-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-rev.2-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/genes-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-rev.2-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/genes-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-rev.2-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/genes-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes-rev.2-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/genes-rev.2.svg'>SVG</a>, <a href='images/predefined-tracks/genes-rev.2-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/genes-rev.2-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/genes-rev.2.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='tRNAs'><span class='track_heading'>tRNAs</span></a></h3>
 Displays all tRNAs, regardless of strand.

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>tRNAs</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/tRNAs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/tRNAs.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/tRNAs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/tRNAs.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/tRNAs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/tRNAs.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/tRNAs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/tRNAs.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/tRNAs.1.svg'>SVG</a>, <a href='images/predefined-tracks/tRNAs.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/tRNAs.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/tRNAs.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='tRNAs-fwd'><span class='track_heading'>tRNAs-fwd</span></a></h3>
 Displays only forward-strand tRNAs.
<br><br>
<h3><a name='tRNAs-rev'><span class='track_heading'>tRNAs-rev</span></a></h3>
 Displays only reverse-strand tRNAs.

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>tRNAs-fwd</span> and <span class='track'>tRNAs-rev</span> tracks together</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/tRNAs-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/tRNAs-rev.2-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/tRNAs-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/tRNAs-rev.2-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/tRNAs-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/tRNAs-rev.2-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/tRNAs-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/tRNAs-rev.2-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/tRNAs-rev.2.svg'>SVG</a>, <a href='images/predefined-tracks/tRNAs-rev.2-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/tRNAs-rev.2-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/tRNAs-rev.2.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='rRNAs'><span class='track_heading'>rRNAs</span></a></h3>
 Displays all rRNAs, regardless of strand.

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>rRNAs</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/rRNAs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/rRNAs.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/rRNAs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/rRNAs.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/rRNAs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/rRNAs.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/rRNAs.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/rRNAs.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/rRNAs.1.svg'>SVG</a>, <a href='images/predefined-tracks/rRNAs.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/rRNAs.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/rRNAs.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='rRNAs-fwd'><span class='track_heading'>rRNAs-fwd</span></a></h3>
 Displays only forward-strand tRNAs.

<h3><a name='rRNAs-rev'><span class='track_heading'>rRNAs-rev</span></a></h3>
 Displays only reverse-strand tRNAs.

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>rRNAs-fwd</span> and <span class='track'>rRNAs-rev</span> tracks together</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/rRNAs-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/rRNAs-rev.2-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/rRNAs-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/rRNAs-rev.2-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/rRNAs-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/rRNAs-rev.2-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/rRNAs-rev.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/rRNAs-rev.2-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/rRNAs-rev.2.svg'>SVG</a>, <a href='images/predefined-tracks/rRNAs-rev.2-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/rRNAs-rev.2-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/rRNAs-rev.2.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='gaps'><span class='track_heading'>gaps</span></a></h3>
 Displays all gaps, regardless of strand.  Note that these are gaps in the genomic sequence that have been 
 explicitly annotated in the input, and are distinct from the gaps that can be placed between adjacent 
 annotation tracks in Circleator figures (these are supported by the "cgap" tracks and are described in the 
<a href='#track_layout'>track layout</a> section.

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>gap</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/gaps.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/gaps.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/gaps.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/gaps.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/gaps.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/gaps.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/gaps.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/gaps.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/gaps.1.svg'>SVG</a>, <a href='images/predefined-tracks/gaps.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/gaps.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/gaps.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<a name='track_layout'></a>
<h2>3. track layout</h2>
<ul>
<li><a href='#tiny-cgap'><span class='track'>tiny-cgap</span></a></li>
<li><a href='#small-cgap'><span class='track'>small-cgap</span></a></li>
<li><a href='#medium-cgap'><span class='track'>medium-cgap</span></a></li>
<li><a href='#large-cgap'><span class='track'>large-cgap</span></a></li></ul>
<br>
<h3><a name='tiny-cgap'><span class='track_heading'>tiny-cgap</span></a></h3>
 By default the Circleator will not leave any space between adjacent tracks, making it difficult in some cases to clearly see
 the features being plotted.  To create a space between two adjacent tracks in the Circleator configuration file, simply add 
 one of the following 'gap' track types on a new line between the two adjacent tracks.  The only difference between the following
 gap types is the amount of space that each one inserts:

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>tiny-cgap</span> track</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/genes.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.2-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.2-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.2-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.2-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/genes.2.svg'>SVG</a>, <a href='images/predefined-tracks/genes.2-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/genes.2-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/genes.2.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='small-cgap'><span class='track_heading'>small-cgap</span></a></h3>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track' ZOOM='1440,390,320,213'>small-cgap</span> track</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/genes.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.3-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.3-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.3-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.3-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/genes.3.svg'>SVG</a>, <a href='images/predefined-tracks/genes.3-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/genes.3-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/genes.3.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='medium-cgap'><span class='track_heading'>medium-cgap</span></a></h3>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track' ZOOM='1440,420,320,213'>medium-cgap</span> track</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/genes.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.4-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.4-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.4-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.4-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/genes.4.svg'>SVG</a>, <a href='images/predefined-tracks/genes.4-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/genes.4-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/genes.4.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='large-cgap'><span class='track_heading'>large-cgap</span></a></h3>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track' ZOOM='1440,440,320,213'>large-cgap</span> track</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/genes.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.5-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.5-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.5-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/genes.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/genes.5-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/genes.5.svg'>SVG</a>, <a href='images/predefined-tracks/genes.5-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/genes.5-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/genes.5.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<a name='graphs'></a>
<h2>4. graphs</h2>
<ul>
<li><a href='#%GC0-100'><span class='track'>%GC0-100</span></a></li>
<li><a href='#%GCmin-max'><span class='track'>%GCmin-max</span></a></li>
<li><a href='#%GCmin-max-dfa'><span class='track'>%GCmin-max-dfa</span></a></li>
<li><a href='#GCskew-1-df0'><span class='track'>GCskew-1-df0</span></a></li>
<li><a href='#GCskew-min-max-df0'><span class='track'>GCskew-min-max-df0</span></a></li></ul>
 A number of predefined graph track types are available, and graph tracks are highly customizable.  The Circleator 
 currently supports graphing the following basic data types:
 <ul>
  <li><span class='graph'>%GC</span>: plots percent GC composition computed from the input sequence(s)</li>
  <li><span class='graph'>GC-skew</span>: plots GC skew (G-C/G+C) computed from the input sequence(s)</li>
  <li><span class='graph'>User-defined</span>: plots user-supplied data (TODO - not yet supported)</li>
  <li><span class='graph'>BAM coverage</span>: plots read coverage histograms based on the contents of a SAM or BAM alignment file (TODO - not yet supported)</li>
 </ul>
<br>
<h3><a name='%GC0-100'><span class='track_heading'>%GC0-100</span></a></h3>
 A graph of percent GC sequence composition, ranging from a minimum value of 0% to a maximum value of 100%.  The
 GC percentage is computed using nonoverlapping windows of length 5kb and is plotted using a circular bar graph:

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GC0-100</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGC0-100.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGC0-100.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGC0-100.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGC0-100.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGC0-100.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGC0-100.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGC0-100.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGC0-100.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGC0-100.1.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGC0-100.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGC0-100.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGC0-100.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='%GCmin-max'><span class='track_heading'>%GCmin-max</span></a></h3>
 The same as %GC0-100, but using the observed minimum and maximum percent GC values for the lower and upper bounds of
 the graph.  Note that the minimum, maximum, and average values are indicated directly in the figure (at the top) by default.

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.1.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='%GCmin-max-dfa'><span class='track_heading'>%GCmin-max-dfa</span></a></h3>
 A variant of %GCmin-max in which the baseline for the graph is the observed average value (dfa = Deviation From Average)
 instead of the observed minimum value, as was the case for %GCmin-max:

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max-dfa</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max-dfa.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max-dfa.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max-dfa.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max-dfa.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max-dfa.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max-dfa.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max-dfa.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max-dfa.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max-dfa.1.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max-dfa.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max-dfa.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max-dfa.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='GCskew-1-df0'><span class='track_heading'>GCskew-1-df0</span></a></h3>
 A GC-skew graph with a minimum value of -1 and a maximum value of 1.  Values are plotted against a baseline value of 0

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCskew-1-df0</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/GCskew-1-df0.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/GCskew-1-df0.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/GCskew-1-df0.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/GCskew-1-df0.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/GCskew-1-df0.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/GCskew-1-df0.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/GCskew-1-df0.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/GCskew-1-df0.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/GCskew-1-df0.1.svg'>SVG</a>, <a href='images/predefined-tracks/GCskew-1-df0.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/GCskew-1-df0.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/GCskew-1-df0.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='GCskew-min-max-df0'><span class='track_heading'>GCskew-min-max-df0</span></a></h3>
 A GC-skew graph with minimum and maximum values based on the observed minimum and maximum and plotted using a baseline value of 0.

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCskew-min-max-df0</span> track with default options</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/GCskew-min-max-df0.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/GCskew-min-max-df0.1-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/GCskew-min-max-df0.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/GCskew-min-max-df0.1-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/GCskew-min-max-df0.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/GCskew-min-max-df0.1-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/GCskew-min-max-df0.1-4000x4000.png'><img class='zoom' src='images/predefined-tracks/GCskew-min-max-df0.1-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/GCskew-min-max-df0.1.svg'>SVG</a>, <a href='images/predefined-tracks/GCskew-min-max-df0.1-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/GCskew-min-max-df0.1-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/GCskew-min-max-df0.1.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>GCskew-min-max-df0</span> <span class='option_heading'>graph-direction</span>=</h4>
 The following options can be used with any Circleator graph track:
 The <span class='option'>graph-direction</span> can be set to 'out' (the default) or 'in'.  A graph direction of 'out' places lower
 values on the y-axis closer to the center of the circle and higher values on the y-axis closer to the outside of the circle.  
 A graph direction of 'in' does the opposite.

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with <span class='option'>graph-direction</span>=out</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.2-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.2-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.2-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.2-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.2.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.2-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.2-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.2.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with <span class='option'>graph-direction</span>=in</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.3-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.3-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.3-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.3-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.3.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.3-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.3-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.3.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>GCskew-min-max-df0</span> <span class='option_heading'>graph-type</span>=</h4>
 The <span class='option'>graph-type</span> can be set to 'bar' (the default) or 'line'.  The former plots a bar graph whereas the latter
 plots a line graph:

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with <span class='option'>graph-type</span>=bar</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.4-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.4-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.4-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.4-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.4.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.4-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.4-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.4.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with <span class='option'>graph-type</span>=line</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.5-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.5-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.5-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.5-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.5.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.5-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.5-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.5.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>GCskew-min-max-df0</span> <span class='option_heading'>window-size</span>=</h4>
 The <span class='option'>window-size</span> option determines the size of the window (in base pairs) over which the sequence-based 
 functions are computed.  It is set to 5000 bp by default but can be customized as needed:

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with <span class='option'>window-size</span>=5000</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.6-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.6-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.6-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.6-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.6.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.6-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.6-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.6.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with <span class='option'>window-size</span>=15000</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.7-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.7-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.7-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.7-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.7.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.7-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.7-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.7.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>GCskew-min-max-df0</span> <span class='option_heading'>graph-min</span>=</h4>
<h4><span class='track_heading'>GCskew-min-max-df0</span> <span class='option_heading'>graph-max</span>=</h4>
 The <span class='option'>graph-min</span> and <span class='option'>graph-max</span> options specify the minimum value to be 
plotted on the graph's y-axis.  Each can be set to either a number (e.g., to 0 for the <span class='track'>%GC0-100</span> graph), or to 
the special value 'data_min' to use the minimum value observed in the current sequence data, 'data_max' to use the maximum value observed
in the current sequence data, or 'data_avg' to use the average value:

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with <span class='option'>graph-min</span>=0,<span class='option'>graph-max</span>=100</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.8-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.8-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.8-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.8-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.8.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.8-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.8-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.8.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with <span class='option'>graph-min</span>=50</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.9-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.9-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.9-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.9-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.9.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.9-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.9-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.9.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with <span class='option'>graph-min</span>=data_min</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.10-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.10-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.10-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.10-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.10-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.10-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.10-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.10-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.10.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.10-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.10-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.10.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>GCskew-min-max-df0</span> <span class='option_heading'>graph-baseline</span>=</h4>
 The <span class='option'>graph-baseline</span> option is only relevant for bar graphs and it specifies the baseline of the graph, meaning the point from 
 which the rectangles making up the graph will be drawn.  Setting the graph-baseline to the same value as graph-min (the default) will display a
 traditional bar graph, and setting the graph-baseline to some other value between the min and the max can be used to illustrate the deviation from 
 that value--either above or below it--at any given point in the sequence:

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with <span class='option'>graph-baseline</span>=0</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.11-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.11-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.11-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.11-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.11-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.11-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.11-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.11-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.11.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.11-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.11-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.11.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>%GCmin-max</span> track with <span class='option'>graph-baseline</span>=60</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/PercentGCmin-max.12-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.12-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>20.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.12-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.12-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.12-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.12-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/PercentGCmin-max.12-4000x4000.png'><img class='zoom' src='images/predefined-tracks/PercentGCmin-max.12-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/PercentGCmin-max.12.svg'>SVG</a>, <a href='images/predefined-tracks/PercentGCmin-max.12-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/PercentGCmin-max.12-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/PercentGCmin-max.12.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<a name='labels'></a>
<h2>5. labels</h2>
<ul>
<li><a href='#small-label'><span class='track'>small-label</span></a></li>
<li><a href='#medium-label'><span class='track'>medium-label</span></a></li>
<li><a href='#large-label'><span class='track'>large-label</span></a></li></ul>
 Circleator figures can also include text, by way of label tracks.  The following basic label track types allow text of 
 varying sizes to be placed in the figure.  The text to include is specified by the <span class='option'>label-text</span>
 option and the text will appear centered around the 0 bp position by default.  To move the text to a different location
 around the circle, use the <span class='option'>position</span> option.  The type of label to use is specified by the
 <span class='option'>label-type</span> option.
<br>
<h3><a name='small-label'><span class='track_heading'>small-label</span></a></h3>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>small-label</span> track with <span class='option'>label-text</span>=Label1</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/small-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/small-label.2-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/small-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/small-label.2-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/small-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/small-label.2-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/small-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/small-label.2-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/small-label.2.svg'>SVG</a>, <a href='images/predefined-tracks/small-label.2-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/small-label.2-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/small-label.2.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='medium-label'><span class='track_heading'>medium-label</span></a></h3>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>medium-label</span> track with <span class='option'>label-text</span>=Label1</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/medium-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.2-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.2-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.2-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.2-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/medium-label.2.svg'>SVG</a>, <a href='images/predefined-tracks/medium-label.2-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/medium-label.2-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/medium-label.2.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h3><a name='large-label'><span class='track_heading'>large-label</span></a></h3>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>large-label</span> track with <span class='option'>label-text</span>=Label1</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/large-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/large-label.2-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/large-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/large-label.2-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/large-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/large-label.2-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/large-label.2-4000x4000.png'><img class='zoom' src='images/predefined-tracks/large-label.2-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/large-label.2.svg'>SVG</a>, <a href='images/predefined-tracks/large-label.2-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/large-label.2-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/large-label.2.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>large-label</span> <span class='option_heading'>label-type</span>=</h4>
 The <span class='option'>label-type</span> can be set to 'curved' (the default), 'spoke', or 'horizontal':

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>large-label</span> track with <span class='option'>label-type</span>=curved</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/medium-label.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.3-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.3-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.3-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.3-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.3-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/medium-label.3.svg'>SVG</a>, <a href='images/predefined-tracks/medium-label.3-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/medium-label.3-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/medium-label.3.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>large-label</span> track with <span class='option'>label-type</span>=spoke</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/medium-label.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.4-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.4-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.4-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.4-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.4-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/medium-label.4.svg'>SVG</a>, <a href='images/predefined-tracks/medium-label.4-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/medium-label.4-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/medium-label.4.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>large-label</span> track with <span class='option'>label-type</span>=horizontal</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/medium-label.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.5-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.5-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.5-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.5-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.5-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/medium-label.5.svg'>SVG</a>, <a href='images/predefined-tracks/medium-label.5-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/medium-label.5-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/medium-label.5.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>large-label</span> <span class='option_heading'>label-position</span>=</h4>
<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>large-label</span> track with <span class='option'>label-text</span>=Label1, <span class='option'>label-position</span>=100000</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/medium-label.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.6-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.6-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.6-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.6-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.6-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/medium-label.6.svg'>SVG</a>, <a href='images/predefined-tracks/medium-label.6-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/medium-label.6-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/medium-label.6.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<h4><span class='track_heading'>large-label</span> <span class='option_heading'>label-text-anchor</span>=</h4>
 The <span class='option'>label-text-anchor</span> option specifies where the label should be positioned relative to its 
 sequence location (i.e., the value passed to the <span class='option'>position</span> option.  It can be set to 
 'center' (the default), 'start', or 'end'.

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>medium-label</span> track with <span class='option'>label-text-anchor</span>=middle</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/medium-label.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.7-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.7-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.7-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.7-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.7-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/medium-label.7.svg'>SVG</a>, <a href='images/predefined-tracks/medium-label.7-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/medium-label.7-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/medium-label.7.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>medium-label</span> track with <span class='option'>label-text-anchor</span>=start</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/medium-label.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.8-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.8-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.8-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.8-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.8-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/medium-label.8.svg'>SVG</a>, <a href='images/predefined-tracks/medium-label.8-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/medium-label.8-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/medium-label.8.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>

<table class='figure'>
<tbody>
<tr>
<th class='figure_caption' colspan='4'><span class='figure_caption'><span class='track'>medium-label</span> track with <span class='option'>label-text-anchor</span>=end</span></th>
</tr>
<tr>
<td><a href='images/predefined-tracks/medium-label.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.9-z3.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>10.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.9-z2.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>5.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.9-z1.png' style='width: 210px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>2.0x</span></div></td>
<td><a href='images/predefined-tracks/medium-label.9-4000x4000.png'><img class='zoom' src='images/predefined-tracks/medium-label.9-140x140.png' style='float: left; width: 140px; height: 140px;'></a><div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>1.0x</span></div></td>
</tr>
<tr>
<td colspan='4'><span class='downloads'>view/download <a href='images/predefined-tracks/medium-label.9.svg'>SVG</a>, <a href='images/predefined-tracks/medium-label.9-4000x4000.png'>large PNG image</a>, <a href='images/predefined-tracks/medium-label.9-2000x2000.pdf'>PDF</a> or circleator <a href='images/predefined-tracks/medium-label.9.cfg'>config file</a></span></td>
</tr>
</tbody>
</table>
