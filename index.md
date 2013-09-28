---
layout: default
pagetype: home
title: Circleator
---

### Overview

The <span class='circleator'>Charm City Circleator</span>--or <span class='circleator'>Circleator</span> 
for short--is a visualization tool developed at the <a href='http://www.igs.umaryland.edu'>Institute for Genome
Sciences</a> in the University of Maryland's School of Medicine. The <span class='circleator'>Circleator</span>'s 
goal is provide a user-friendly way to quickly produce circular plots of genome sequence and genome-sequence-associated
data, like these:<br clear='both'>

<div style='padding: 1em'>
<a href='images/CP002104-1-5000.png'><img src='images/CP002104-1-400.png' class='index_example' alt='Gardnerella vaginalis ATCC 14019, complete genome'></a> 
<a href='images/Hs-fig-1-mi-diff-5000.png'><img src='images/Hs-fig-1-mi-diff-400.png' class='index_example' alt='Human genome with RNA-Seq'></a>
</div>

More <span class='circleator'>Circleator</span>-generated figures can be found in the <a href='gallery.html'>gallery</a>.

### Key Circleator features

* Implemented using [BioPerl][]
* Supports a variety of data types and common input file formats:
  * GenBank flat file, GFF, FASTA, and any other sequence or annotation file format supported by [BioPerl][]
  * Output from the [BLAST Score Ratio][bsr] (BSR) tool of [Rasko <span style='font-style: italic'>et al.</span>][rasko_etal]
  * SAM (Sequence Alignment/Map) and BAM format alignments, via the [SAMtools][] package.
  * [VCF][]-encoded SNP data, via the [VCFtools][] package
  * Tab-delimited quantitative data (e.g., sequence read coverage, aligned RNA-seq read counts)
  * Output from the [Tandem Repeats Finder][trf] of [Benson][]
  * GTF-encoded [Cufflinks][] transcripts of [Trapnell <span style='font-style: italic'>et al.</span>][trapnell_etal]
  * The refGene, knownGene, and rmsk [UCSC genome browser][ucsc_browser] tables
  * Various ad-hoc tab and comma-delimited formats for SNP, gene expression, and gene cluster data
* Produces publication-ready output in the [Scalable Vector Graphics][svg] (SVG) format
  * Using SVG as the primary output format makes it easier to write regression tests.
  * The <span class='circleator'>Circleator</span> does NOT use the GD::SVG package, which limits one to the subset of SVG that corresponds to the GD API.
  * The <span class='circleator'>Circleator</span> leverages the [Apache Batik][batik] project to convert SVG to PDF, JPEG, or PNG.
* Offers the choice of a <a href='command-line.html'>command-line</a> or <a href='web-application.html'>web-based</a> interface:
  * The command-line interface gives finer-grained control and can be incorporated into scripts or other programs.
  * A prototype [ExtJS][] web interface automatically generates a configuration file, runs the <span class='circleator'>Circleator</span>, and displays the results.
* Provides a range of configuration options:
  * Choose from a library of customizable <a href='predefined-config-files.html'>predefined configuration files</a>, each of which generates a particular type of figure using your data.
  * Customize or create a configuration file by choosing individual tracks from a library of customizable <a href='predefined-tracks.html'>predefined track types</a>.
  * Create user-defined track types based on the <span class='circleator'>Circleator</span>'s built-in graphical drawing primitives (glyphs).
  * Use the <span class='circleator'>Circleator</span>'s Perl API to define entirely new glyphs.
* Extensive test suite
  * Regression tests have been written for most of the major features of the tool, helping to ensure that when we fix bugs they stay fixed :)

[batik]: http://xmlgraphics.apache.org/batik/
[benson]: http://www.ncbi.nlm.nih.gov/pubmed/9862982
[bioperl]: http://www.bioperl.org
[bsr]: http://bsr.igs.umaryland.edu
[cufflinks]: http://cufflinks.cbcb.umd.edu/
[extjs]: http://www.sencha.com/products/extjs/
[rasko_etal]: http://www.ncbi.nlm.nih.gov/pmc/articles/PMC545078/
[samtools]: http://samtools.sourceforge.net
[svg]: http://www.w3.org/Graphics/SVG/
[trapnell_etal]: http://www.nature.com/nprot/journal/v7/n3/full/nprot.2012.016.html
[trf]: http://tandem.bu.edu/trf/trf.html
[ucsc_browser]: http://genome.ucsc.edu/
[vcftools]: http://vcftools.sourceforge.net
[vcf]: http://www.1000genomes.org/node/101

### Getting started

The <a href='documentation.html'>documentation section</a> of the web
site contains easy-to-follow tutorials that describe how to run the
<span class='circleator'>Circleator</span> using either the command-line interface or the prototype
ExtJS-based web interface.

### Acknowledgments

* This product includes color specifications and designs developed by Cynthia Brewer (<http://colorbrewer.org>).
