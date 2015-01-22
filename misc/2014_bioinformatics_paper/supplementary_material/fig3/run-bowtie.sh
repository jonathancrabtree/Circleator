#!/bin/tcsh
setenv FASTQ_DIR /path/to/hmp/fastq/files
setenv WDIR /usr/local/scratch
setenv SAMTOOLS /usr/local/samtools-0.1.19/samtools

cd $WDIR
wget http://downloads.hmpdacc.org/data/Illumina/posterior_fornix/SRS011111.tar.bz2 $WDIR
wget http://downloads.hmpdacc.org/data/Illumina/posterior_fornix/SRS017497.tar.bz2 $WDIR
wget http://downloads.hmpdacc.org/data/Illumina/posterior_fornix/SRS024068.tar.bz2 $WDIR
wget http://downloads.hmpdacc.org/data/Illumina/posterior_fornix/SRS013542.tar.bz2 $WDIR
wget http://downloads.hmpdacc.org/data/Illumina/posterior_fornix/SRS023468.tar.bz2 $WDIR

tar xjvf SRS011111.tar.bz2
tar xjvf SRS017497.tar.bz2
tar xjvf SRS024068.tar.bz2
tar xjvf SRS013542.tar.bz2
tar xjvf SRS023468.tar.bz2

# for some reason SRS023468 and SRS011111 files aren't in a directory
mkdir SRS023468
mv SRS023468.denovo* SRS023468/
mkdir SRS011111
mv SRS011111.denovo* SRS011111/

# create Bowtie index for target genome(s)
bowtie-build CP002725.1.fsa CP002725.1 > bowtie-build.log
cp CP002725.1.*.ebwt $WDIR/
mv CP002725.1.fsa data/

# check base ranges
# SRS024068 is the smallest
cd $FASTQ_DIR
./autodetectFastqRange.pl $WDIR/SRS024068/SRS024068.denovo_duplicates_marked.trimmed.1.fastq > ranges.txt
./autodetectFastqRange.pl $WDIR/SRS024068/SRS024068.denovo_duplicates_marked.trimmed.2.fastq >> ranges.txt
./autodetectFastqRange.pl $WDIR/SRS024068/SRS024068.denovo_duplicates_marked.trimmed.singleton.fastq >> ranges.txt

./autodetectFastqRange.pl $WDIR/SRS011111/SRS011111.denovo_duplicates_marked.trimmed.1.fastq >> ranges.txt
./autodetectFastqRange.pl $WDIR/SRS011111/SRS011111.denovo_duplicates_marked.trimmed.2.fastq >> ranges.txt
./autodetectFastqRange.pl $WDIR/SRS011111/SRS011111.denovo_duplicates_marked.trimmed.singleton.fastq >> ranges.txt

./autodetectFastqRange.pl $WDIR/SRS017497/SRS017497.denovo_duplicates_marked.trimmed.1.fastq >> ranges.txt
./autodetectFastqRange.pl $WDIR/SRS017497/SRS017497.denovo_duplicates_marked.trimmed.2.fastq >> ranges.txt
./autodetectFastqRange.pl $WDIR/SRS017497/SRS017497.denovo_duplicates_marked.trimmed.singleton.fastq >> ranges.txt

./autodetectFastqRange.pl $WDIR/SRS023468/SRS023468.denovo_duplicates_marked.trimmed.1.fastq >> ranges.txt
./autodetectFastqRange.pl $WDIR/SRS023468/SRS023468.denovo_duplicates_marked.trimmed.2.fastq >> ranges.txt
./autodetectFastqRange.pl $WDIR/SRS023468/SRS023468.denovo_duplicates_marked.trimmed.singleton.fastq >> ranges.txt

./autodetectFastqRange.pl $WDIR/SRS013542/SRS013542.denovo_duplicates_marked.trimmed.1.fastq >> ranges.txt
./autodetectFastqRange.pl $WDIR/SRS013542/SRS013542.denovo_duplicates_marked.trimmed.2.fastq >> ranges.txt
./autodetectFastqRange.pl $WDIR/SRS013542/SRS013542.denovo_duplicates_marked.trimmed.singleton.fastq >> ranges.txt

mv *-ranges.txt $WDIR/
# all are phred33, no need for special processing

# run Bowtie alignment(s) w/ 0.12.9
cd $WDIR

# SRS024068
# align paired reads together
bowtie --chunkmbs 512 -q --phred33-quals -l 21 -n 2 -a --best --strata -m 10 -t --sam \
  --max SRS024068_too_many_hits-p.fastq CP002725.1 \
  -1 SRS024068/SRS024068.denovo_duplicates_marked.trimmed.1.fastq \
  -2 SRS024068/SRS024068.denovo_duplicates_marked.trimmed.2.fastq \
  SRS024068-p.sam
# singletons
bowtie --chunkmbs 512 -q --phred33-quals -l 21 -n 2 -a --best --strata -m 10 -t --sam \
  --max SRS024068_too_many_hits-s.fastq CP002725.1 SRS024068/SRS024068.denovo_duplicates_marked.trimmed.singleton.fastq SRS024068-s.sam

# SRS011111
# align paired reads together
bowtie --chunkmbs 512 -q --phred33-quals -l 21 -n 2 -a --best --strata -m 10 -t --sam \
  --max SRS011111_too_many_hits-p.fastq CP002725.1 \
  -1 SRS011111/SRS011111.denovo_duplicates_marked.trimmed.1.fastq \
  -2 SRS011111/SRS011111.denovo_duplicates_marked.trimmed.2.fastq \
  SRS011111-p.sam
# singletons
bowtie --chunkmbs 512 -q --phred33-quals -l 21 -n 2 -a --best --strata -m 10 -t --sam \
  --max SRS011111_too_many_hits-s.fastq CP002725.1 SRS011111/SRS011111.denovo_duplicates_marked.trimmed.singleton.fastq SRS011111-s.sam

# SRS017497
# align paired reads together
bowtie --chunkmbs 512 -q --phred33-quals -l 21 -n 2 -a --best --strata -m 10 -t --sam \
  --max SRS017497_too_many_hits-p.fastq CP002725.1 \
  -1 SRS017497/SRS017497.denovo_duplicates_marked.trimmed.1.fastq \
  -2 SRS017497/SRS017497.denovo_duplicates_marked.trimmed.2.fastq \
  SRS017497-p.sam
# singletons
bowtie --chunkmbs 512 -q --phred33-quals -l 21 -n 2 -a --best --strata -m 10 -t --sam \
  --max SRS017497_too_many_hits-s.fastq CP002725.1 SRS017497/SRS017497.denovo_duplicates_marked.trimmed.singleton.fastq SRS017497-s.sam

# SRS023468
# align paired reads together
bowtie --chunkmbs 512 -q --phred33-quals -l 21 -n 2 -a --best --strata -m 10 -t --sam \
  --max SRS023468_too_many_hits-p.fastq CP002725.1 \
  -1 SRS023468/SRS023468.denovo_duplicates_marked.trimmed.1.fastq \
  -2 SRS023468/SRS023468.denovo_duplicates_marked.trimmed.2.fastq \
  SRS023468-p.sam
# singletons
bowtie --chunkmbs 512 -q --phred33-quals -l 21 -n 2 -a --best --strata -m 10 -t --sam \
  --max SRS023468_too_many_hits-s.fastq CP002725.1 SRS023468/SRS023468.denovo_duplicates_marked.trimmed.singleton.fastq SRS023468-s.sam

# SRS013542
# align paired reads together
bowtie --chunkmbs 512 -q --phred33-quals -l 21 -n 2 -a --best --strata -m 10 -t --sam \
  --max SRS013542_too_many_hits-p.fastq CP002725.1 \
  -1 SRS013542/SRS013542.denovo_duplicates_marked.trimmed.1.fastq \
  -2 SRS013542/SRS013542.denovo_duplicates_marked.trimmed.2.fastq \
  SRS013542-p.sam
# singletons
bowtie --chunkmbs 512 -q --phred33-quals -l 21 -n 2 -a --best --strata -m 10 -t --sam \
  --max SRS013542_too_many_hits-s.fastq CP002725.1 SRS013542/SRS013542.denovo_duplicates_marked.trimmed.singleton.fastq SRS013542-s.sam

# rewrite seq ids in sam files
perl -pi.bak -e 's/SN:gi\|\d+\|gb\|CP002725\.1\|/SN:CP002725/;' *.sam
rm *.bak

# convert sam to bam
$SAMTOOLS view -S -b -o SRS024068-p.bam SRS024068-p.sam
$SAMTOOLS view -S -b -o SRS024068-s.bam SRS024068-s.sam
$SAMTOOLS sort SRS024068-p.bam SRS024068-p-sorted
$SAMTOOLS sort SRS024068-s.bam SRS024068-s-sorted

$SAMTOOLS view -S -b -o SRS011111-p.bam SRS011111-p.sam
$SAMTOOLS view -S -b -o SRS011111-s.bam SRS011111-s.sam
$SAMTOOLS sort SRS011111-p.bam SRS011111-p-sorted
$SAMTOOLS sort SRS011111-s.bam SRS011111-s-sorted

$SAMTOOLS view -S -b -o SRS017497-p.bam SRS017497-p.sam
$SAMTOOLS view -S -b -o SRS017497-s.bam SRS017497-s.sam
$SAMTOOLS sort SRS017497-p.bam SRS017497-p-sorted
$SAMTOOLS sort SRS017497-s.bam SRS017497-s-sorted

$SAMTOOLS view -S -b -o SRS023468-p.bam SRS023468-p.sam
$SAMTOOLS view -S -b -o SRS023468-s.bam SRS023468-s.sam
$SAMTOOLS sort SRS023468-p.bam SRS023468-p-sorted
$SAMTOOLS sort SRS023468-s.bam SRS023468-s-sorted

$SAMTOOLS view -S -b -o SRS013542-p.bam SRS013542-p.sam
$SAMTOOLS view -S -b -o SRS013542-s.bam SRS013542-s.sam
$SAMTOOLS sort SRS013542-p.bam SRS013542-p-sorted
$SAMTOOLS sort SRS013542-s.bam SRS013542-s-sorted
