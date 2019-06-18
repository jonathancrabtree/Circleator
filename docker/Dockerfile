FROM ubuntu:18.04
MAINTAINER Jonathan Crabtree <jcrabtree@som.umaryland.edu>

RUN apt-get update && apt-get install -y curl

# Perl dependencies
RUN apt-get install -y libgd-svg-perl libjson-perl libtext-csv-perl liblog-log4perl-perl vcftools libbatik-java libmodule-build-perl make cpanminus bioperl fop
RUN cpanm Bio::FeatureIO::gff

# Install specific release of Circleator from source
RUN cd /opt && curl -LO https://github.com/jonathancrabtree/Circleator/archive/1.0.2.tar.gz && tar xzf 1.0.2.tar.gz
RUN cd /opt/Circleator-1.0.2 && perl Build.PL && ./Build && ./Build install
RUN cd /opt && ln -s Circleator-1.0.2 Circleator

# Install Circleator from GitHub master branch
#RUN head -c 5 /dev/random >random2.txt && cd /opt && curl -LO https://github.com/jonathancrabtree/Circleator/archive/master.zip && unzip master.zip
#RUN cd /opt/Circleator-master && perl Build.PL && ./Build && ./Build install
#RUN cd /opt && ln -s Circleator-master Circleator

# bam_get_coverage (optional Circleator extra)
# samtools 1.7 from source
RUN apt-get install -y libncurses5-dev zlib1g-dev libbz2-dev liblzma-dev gcc libglib2.0-dev
RUN cd /opt && curl -LO https://github.com/samtools/samtools/releases/download/1.7/samtools-1.7.tar.bz2 && tar xjf samtools-1.7.tar.bz2
RUN cd /opt/samtools-1.7 && ./configure && make
RUN cd /opt/Circleator/util/samtools && ./make.sh && cp bam_get_coverage *.pl ../*.pl /usr/local/bin/

# add non-root user
RUN useradd -ms /bin/bash circleator

# install tutorials in /home/circleator
RUN cd /opt && curl -LO https://github.com/jonathancrabtree/Circleator/archive/gh-pages.zip && unzip gh-pages.zip
RUN cp -r /opt/Circleator-gh-pages/tutorials /home/circleator/ && chown -R circleator:circleator /home/circleator/tutorials

# cleanup
RUN /bin/rm -rf /opt/Circleator-gh-pages /opt/*.gz /opt/*.zip /opt/*.bz2

# switch user
USER circleator
WORKDIR /home/circleator



