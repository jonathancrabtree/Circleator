#!/bin/bash

# compilation command for Ubuntu Linux
export CFLAGS=`pkg-config --cflags --libs glib-2.0`
export SAMTOOLS=../samtools-0.1.19
gcc bam_hmp_util.c bam_get_coverage.c  $CFLAGS -L$SAMTOOLS -I$SAMTOOLS -lbam -o bam_get_coverage -lz -lgobject-2.0 -lgmodule-2.0 -lpthread
