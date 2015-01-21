#!/bin/tcsh

# compilation command for Ubuntu Linux
setenv CFLAGS "-I/usr/include/glib-2.0 -I/usr/include/glib-2.0/glib -I/usr/lib/glib-2.0/include"
setenv SAMTOOLS_DIR samtools-0.1.19
gcc $CFLAGS -I${SAMTOOLS_DIR} -L${SAMTOOLS_DIR} -L${SAMTOOLS_DIR}/bcftools bam_hmp_util.c bam_get_coverage.c -o bam_get_coverage -lz -lbam -lgd -lgobject-2.0 -lgmodule-2.0

