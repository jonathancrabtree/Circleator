#!/bin/bash

# compilation command for Ubuntu 16.04LTS
export CFLAGS=`pkg-config --cflags --libs glib-2.0`
export SAMTOOLS=/opt/samtools-1.7
export HTSLIB=/opt/samtools-1.7/htslib-1.7
gcc bam_hmp_util.c bam_get_coverage.c  $CFLAGS -L$SAMTOOLS -L$HTSLIB -I$SAMTOOLS -I$HTSLIB -lst -lhts -lbam -o bam_get_coverage -llzma -lbz2 -lz -lgobject-2.0 -lgmodule-2.0 -lpthread
