### Overview

The Charm City Circleator--or Circleator for short--is a Perl-based
visualization tool for producing circular plots of genome-associated
data, like this one:

![Sample Circleator image][sample image]

Common uses of the tool include:

* Displaying the sequence and/or genes in a [GenBank][] flat file.
* Highlighting differences and/or similarities in gene content between related organisms.
* Showing differences in SNP/indel content and/or gene expression values in different strains or experimental timepoints.
* Visualizing coverage plots of RNA-Seq read alignments.

[sample image]: https://github.com/jonathancrabtree/Circleator/blob/gh-pages-dev/images/CP002104-1-600.png?raw=true "Sample Circleator Image"
[genbank]: http://www.ncbi.nlm.nih.gov/genbank/

### Key Features

* Builds on [BioPerl][] and the input file formats that it supports.
  * [GenBank][] flat files, GFF, FASTA
* Accepts commonly-used datatypes from several additional file formats:
  * [BSR][] and [TRF][] output, [SAM/BAM][samtools], [VCF][vcftools]-encoded SNPs, and various ad-hoc tab-delimited formats.
* Outputs publication-ready figures in [SVG][] (Scalable Vector Graphics) format.
* Requires a single configuration file whose lines correspond to the circular tracks in the figure, ordered from outermost to innermost.
* Supports a number of advanced features that begin to blur the line between visualization and analysis (see below for more detail).
* Includes an extensive set of regression tests.
* Offers a prototype ExtJS web-based GUI ("Ringmaster"), under development as a separate project.

[bioperl]: http://www.bioperl.org
[svg]: http://www.w3.org/Graphics/SVG/
[bsr]: http://bsr.igs.umaryland.edu
[trf]: http://tandem.bu.edu/trf/trf.html
[samtools]: http://samtools.sourceforge.net
[vcftools]: http://vcftools.sourceforge.net

### Advanced Configuration File Features

The Circleator unified configuration file format aims to make the common case fast
and the uncommon case possible. In other words, new users should be able to quickly 
produce a standard visualization of their data, provided it is in a commonly-used
format. Conversely, experienced users should be able to create intricately-customized 
figures by using the same configuration file syntax.

For new users:
  * **Walkthroughs and sample configuration files** provide HOW-TO guides for commonly-encountered datasets.
  * **Predefined track types** 

simplify the task of displaying commonly-encountered datasets.

    * e.g., the keyword `genes` by itself on a line in the configuration file will display a circular track in which each gene is a curved black rectangle.
  * **Configurable track options** allow the predefined track types to be customized.
    * e.g., the line `genes color1=red` will do the same, but replacing the default gene color (black) with red.

For experienced users:
  * **User-defined track types** can be created inline and then reused later in the configuration file.
  * **Feature-based scaling** allows the figure scale to be selectively expanded around features of interest.
    * e.g., Use 100X scale for any nonsynonymous SNP position and display the affected bases.
  * **Configuration file loops** mean that figures for 60-genome SNP panels can be configured and displayed without cutting and pasting the same SNP track 59 times.
  * **Symbolic track references** allow one track to reference another.
    * e.g., Label each tRNA displayed in the preceding track with its anticodon sequence and connect the label to the corresponding feature with a blue line.
  * **Computed features** can be added to supplement those features that appear directly in the input files.
    * e.g., Create and display a "SNP desert" feature in any location where there is at least 5kb of sequence that contains no SNPs.
    * e.g., Create and display a "low coverage" feature in any location where the valued plotted in the read coverage graph in track 2 falls below 5.

### Getting Started

After installing Circleator (a Perl program) and its dependencies, getting started requires as little as:

1. A GenBank flat file for a genome of interest.
2. A Circleator configuration file.

First, run the Circleator executable to generate an SVG-format figure, passing in the GenBank flat file and the Circleator configuration file:

       circleator --data=CM000961.gbk --config=genes-percent-GCskew-1.cfg > fig1.svg

Second (if needed), invoke the Apache Batik wrapper script to convert the SVG to PDF, PNG, or JPEG:

       rasterize-svg fig1.svg pdf
       rasterize-svg fig1.svg png
       rasterize-svg fig1.svg jpeg

See the [Documentation page][https://github.com/jonathancrabtree/Circleator/blob/gh-pages-dev/documentation.md] for the complete download and install instructions.

### Requirements

* Perl 5.6 or later.
* The [Apache Batik][batik] package to convert SVG to PDF, JPEG, or PNG.

[batik]: http://xmlgraphics.apache.org/batik/

### Acknowledgments

This product includes color specifications and designs developed by Cynthia Brewer (<http://colorbrewer.org>).
