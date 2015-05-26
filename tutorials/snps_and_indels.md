---
layout: default
title: Displaying SNPs and indels
---

# Displaying SNPs and indels

In this tutorial we'll cover using Circleator to display SNPs and indels
between closely-related strains. Before proceeding with the tutorial, 
please make sure that you have Circleator installed as described in the 
Circleator [Installation Guide][install].

[install]: {{site.baseurl}}/install.html

### Outline

* **[Example 1](#ex1): Reading variants from VCF files**

  1. [Download the input and configuration files](#ex1_download_files)
  2. [Run Circleator](#ex1_run_circleator)
  3. [Convert the figure from SVG to PNG](#ex1_convert_to_png)

***
<a name="ex1"></a>

## Reading variants from VCF files

<a name="ex1_download_files"></a>

### Download the input and configuration files

In this first example we'll look at displaying variants (SNPs, insertions,
and deletions) from VCF files. We're going to use the same reference 
genome, that of *Enterobacteria* phage lambda, as in Examples 1 and 2 from 
the [Coverage Plots tutorial][coverage_plots]. In that tutorial we used 
[Bowtie2][bt2] to align the synthetic read data provided with Bowtie against
the phage lambda genome, as described in [the Bowtie2 documentation][bt2_ex].
The Bowtie2 documentation also describes how to call variants and generate a
VCF file with the samtools package and one of the BAM alignment files. 
We'll use that VCF file for our first Circleator example. There's just one
small difference between the samtools command in the Bowtie documentation 
and the one that we're going to use, because we want to generate a ".vcf" 
file rather than a ".bcf" file (i.e., a plain VCF file rather than a 
binary-encoded VCF file.) So instead of the following command, from the 
Bowtie2 documentation:

    samtools mpileup -uf lambda_virus.fa eg2.sorted.bam | bcftools view -bvcg - > eg2.raw.bcf

We will instead use this command (with no -b flag and ".vcf" instead of ".bcf"):

    samtools mpileup -uf lambda_virus.fa eg2.sorted.bam | bcftools view -vcg - > eg2.raw.vcf

Here is the VCF file that this command should produce, assuming that it's 
run on the `eg2.sorted.bam` file from the Coverage Plots tutorial:

[eg2.raw.vcf][]

Here is the GenBank flat file for the phage lambda genome:

[NC_001416.1.gb][pl_gb]

And here is the Circleator configuration file for our first figure:

[variants-ex1.txt][]

[coverage_plots]: {{site.baseurl}}/tutorials/coverage_plots.html
[bt2]: http://bowtie-bio.sourceforge.net/bowtie2
[bt2_ex]: http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#getting-started-with-bowtie-2-lambda-phage-example
[eg2.raw.vcf]: {{site.baseurl}}/tutorials/snps_and_indels/eg2.raw.vcf
[pl_gb]: {{site.baseurl}}/tutorials/coverage_plots/NC_001416.1.gb

<a name="ex1_run_circleator"></a>

### Run Circleator

Once you've downloaded or generated the necessary files, you're ready to run Circleator, like so:

    $ circleator --contig_list=contig-list-ex1-gb.txt --config=variants-ex1.txt > variants-ex1.svg

<a name="ex1_convert_to_png"></a>

### Convert the figure from SVG to PNG

If everything looks good so far then use `rasterize-svg` to convert the SVG to a PNG file:

    rasterize-svg variants-ex1.svg png 3000 3000

Here's what the result should look like:

<div class='sample_image'>
<em>variants-ex1.png</em><br>
(data: <a href='snps_and_indels/lambda_virus.fa'>lambda_virus.fa</a> config: <a href='snps_and_indels/variants-ex1.txt'>variants-ex1.txt</a>, full size <a href='snps_and_indels/variants-ex1-3000.png'>PNG</a>&nbsp;|&nbsp;<a href='snps_and_indels/variants-ex1.svg'>SVG</a>)  
<img src='snps_and_indels/variants-ex1-400.png' class='sample_image'>
</div>

[variants-ex1.txt]: {{site.baseurl}}/tutorials/snps_and_indels/variants-ex1.txt


