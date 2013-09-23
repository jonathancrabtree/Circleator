### Overview

The Charm City Circleator--or Circleator for short--is a Perl-based
visualization tool for producing circular plots of genome-associated
data, like this one:

![Sample Circleator Image][sample image]

Common use-cases for the tool include:

* Displaying sequence properties and/or genes from a [GenBank][] flat file.
* Highlighting differences and/or similarities in gene content between related organisms.
* Showing differences in SNP/indel content and/or gene expression values.
* Visualizing coverage plots of RNA-Seq read alinments.

[sample image]: https://github.com/jonathancrabtree/Circleator/blob/gh-pages-dev/images/CP002104-1-600.png?raw=true "Sample Circleator Image"
[genbank]: http://www.ncbi.nlm.nih.gov/genbank/

### Key Features

* Implemented using [BioPerl][]
* Supports a variety of data types and input file formats
  * Including GenBank flat files, GFF, FASTA, BSR and TRF output, SAM/BAM, VCF-encoded SNPs, and various tab-delimited
* Produces publication-ready output in the [SVG][] (Scalable Vector Graphics) format
* Provides a unified configuration file format that aims to make the common case fast and the uncommon case possible
  * Predefined track types simplify the task of displaying commonly-used data types
  * Numerous track options allow the predefined track types to be customized or new ones defined
* Supports a number of advanced features that begin to blur the line between visualization and analysis
  * *Feature-based scaling* allows the figure scale to be selectively expanded around features of interest.
    * e.g., Use 100X scale for any nonsynonymous SNP position and display the affected bases.
  * *Configuration file loops* mean that 60-genome SNP panels can be displayed without cutting and pasting a SNP track 59 times.
  * *Symbolic track references* allow one track to reference another.
    * e.g., Label each tRNA displayed in the preceding track with its anticodon sequence.
  * *Computed features* can be added to supplement those features that explicitly appear in the input files.
    * e.g., Create and display a "SNP desert" feature in any location where there is at least 5kb of sequence that contains no SNPs.
    * e.g., Create and display a "low coverage" feature in any location where the valued plotted in the read coverage graph in track 2 falls below 5.
* Includes an extensive test suite
  * Using SVG as the primary output format allows standard text comparison tools to be used to check the results.
* An ExtJS web-based GUI ("Ringmaster") is under development and has been split into a separate GitHub project

[bioperl]: http://www.bioperl.org
[svg]: http://www.w3.org/Graphics/SVG/


### Getting Started

After installing Circleator (a Perl program) and its associated modules, getting started requires as little as

* A GenBank flat file for a genome of interest.
* A Circleator configuration file.

Here is a simple 9-line Circleator configuration file:

    coords
    small-cgap
    genes-fwd
    tiny-cgap
    genes-rev
    small-cgap
    %GCmin-max-dfa
    small-cgap
    GCskew-min-max-df0

### Requirements

* [Apache Batik][batik] package for converting SVG to PDF, JPEG, or PNG.
* 

[batik]: http://xmlgraphics.apache.org/batik/

### Acknowledgments

This product includes color specifications and designs developed by Cynthia Brewer <colorbrewer>.

[colorbrewer]: http://colorbrewer.org
