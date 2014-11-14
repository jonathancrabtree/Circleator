---
layout: default
title: Downloading Genome Sequence Files From GenBank
---

# Downloading Genome Sequence Files From GenBank

This is a quick overview of one way to download a GenBank flat
file suitable for use in Circleator by using the [GenBank web site][genbank].

[genbank]: http://ncbi.nlm.nih.gov/genbank

1. Go to the following URL, replacing "L42023" with the accession
number of your sequence of interest:

    [http://www.ncbi.nlm.nih.gov/nuccore/L42023][gb_link]

2. Find the "Customize view" window in the top right corner of the page.
3. Select the "Show sequence" option under "Display options" and click on "Update View"
4. Wait for the sequence to be loaded (a notification bar should appear at the bottom of the page.) 
5. Click on "Send" at the top right of the page and then select "File" under "Choose Destination"
6. Choose "GenBank (full)" for the Format and click on "Create File"
7. The GenBank entry should download into a file named "sequence.gb" (NOTE: If you have previously downloaded sequences from GenBank and have never moved or renamed them, then your web browser may download the new sequence as "sequence.gb (1)" or "sequence.gb (2), to avoid overwriting the previously-downloaded files.)

8. Check the first and last few lines of the file to make sure that it looks OK:

        $ head -5 ~/Downloads/sequence.gb
	LOCUS       L42023               1830138 bp    DNA     circular BCT 31-JAN-2014
        DEFINITION  Haemophilus influenzae Rd KW20, complete genome.
        ACCESSION   L42023 U32686-U32848
        VERSION     L42023.1  GI:6626252
        DBLINK      BioProject: PRJNA219
        $ tail -5 ~/Downloads/sequence.gb 
          1830001 gatatagatc acaaaaaagt agtagggttt atagttttat aaaaatgctc gtgctatact
          1830061 ctgtgcgttg tcttactgag tgagcagtat tactcaaagc aaacagattt gtttaactta
          1830121 aataaaaggt gaaaatct
        //

9. Rename the downloaded file to make it easier to remember what is in it:

        mv ~/Downloads/sequence.gb ./L42023.1.gb

[gb_link]: http://www.ncbi.nlm.nih.gov/nuccore/L42023
