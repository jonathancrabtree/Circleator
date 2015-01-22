#!/bin/tcsh

setenv GLIB_DIR /usr/include/glib-2.0
setenv LD_LIBRARY_PATH ${GLIB_DIR}:${LD_LIBRARY_PATH}

setenv BAMD circleator/util/samtools
setenv WDIR /usr/local/scratch

# index .bam files
cd $WDIR
samtools index SRS024068-p-sorted.bam
samtools index SRS024068-s-sorted.bam
samtools index SRS011111-p-sorted.bam
samtools index SRS011111-s-sorted.bam
samtools index SRS013542-p-sorted.bam
samtools index SRS013542-s-sorted.bam
samtools index SRS017497-p-sorted.bam
samtools index SRS017497-s-sorted.bam
samtools index SRS023468-p-sorted.bam
samtools index SRS023468-s-sorted.bam

# extract coverage info.
$BAMD/bam_get_coverage $WDIR/SRS024068-p-sorted.bam 2000 SRS024068-p-cov.txt
$BAMD/bam_get_coverage $WDIR/SRS024068-s-sorted.bam 2000 SRS024068-s-cov.txt
$BAMD/bam_get_coverage $WDIR/SRS011111-p-sorted.bam 2000 SRS011111-p-cov.txt
$BAMD/bam_get_coverage $WDIR/SRS011111-s-sorted.bam 2000 SRS011111-s-cov.txt
$BAMD/bam_get_coverage $WDIR/SRS013542-p-sorted.bam 2000 SRS013542-p-cov.txt
$BAMD/bam_get_coverage $WDIR/SRS013542-s-sorted.bam 2000 SRS013542-s-cov.txt
$BAMD/bam_get_coverage $WDIR/SRS017497-p-sorted.bam 2000 SRS017497-p-cov.txt
$BAMD/bam_get_coverage $WDIR/SRS017497-s-sorted.bam 2000 SRS017497-s-cov.txt
$BAMD/bam_get_coverage $WDIR/SRS023468-p-sorted.bam 2000 SRS023468-p-cov.txt
$BAMD/bam_get_coverage $WDIR/SRS023468-s-sorted.bam 2000 SRS023468-s-cov.txt
