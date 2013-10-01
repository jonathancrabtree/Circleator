---
layout: default
title: Circleator - Installation Guide
---

## Installation Guide

Please note that the installation guide currently covers only
installation on Linux systems, although a similar approach should 
also work on Windows and MAC OS X systems:

1. [Install Prerequisites](#install_prerequisites)
    1. Install packages
    2. Install additional Perl modules
2. [Download Circleator](#download_circleator)
3. [Build and Install Circleator](#build_and_install_circleator)
4. [Test Circleator](#test_circleator)

### Install Prerequisites

#### Install packages

Install the following packages using the package manager, if you are
running a variant of Linux that supports this. On Ubuntu 13.04, for
example, the following packages may be installed using the Ubuntu
Software Center or by running `sudo apt-get install <packagename>` on
the command line:

* perl
* bioperl
* libbatik-java
* vcftools

#### Install additional Perl modules

Once Perl is installed the CPAN Shell can be used to install the
remaining Perl dependencies, like so:

    sudo cpan
    install CPAN
    reload cpan
    install JSON
    install Log::Log4perl
    install SVG
    install Text::CSV

Note that if you do not have superuser privileges for the machine in
question (i.e., to run `cpan` as root) then you will have to enlist
the help of a superuser or install Circleator and its dependencies in
your home directory or some other area to which you have write
privileges.

### Download Circleator

The most recent Circleator release can be downloaded from the
[Circleator releases page][releases] on GitHub.  Scroll past the
release notes for the version you want and click on one of the "Source
code" buttons to download a .zip or .tar.gz file.

[releases]: https://github.com/jonathancrabtree/Circleator/releases

### Build and Install Circleator

Unzip or untar the downloaded file with one of the following commands:

    unzip <release>.zip

or

    tar xzvf <release>.tar.gz

Move into the unpacked Circleator directory:

    cd <release>

To install Circleator system-wide (this requires superuser privileges):
   
    perl Build.PL
    ./Build
    ./Build test
    ./Build install

To install Circleator to a different location, do this instead:

    perl Build.PL --install_base=/install/path
    ./Build.PL
    ./Build test
    ./Build install

Note that the tests invoked by `./Build test` currently take several
minutes (~5-6 depending on the speed of the machine) to run.

### Test Circleator

After Circleator has been installed you can test that the *installed* copy is
set up correctly by using one of the configuration files and one of the data files
included in the distribution:

    /install/path/bin/circleator --config=conf/genes-percentGC-GCskew-1.cfg --data=data/NC_011969.gbk >fig1.svg
    /install/path/bin/rasterize-svg fig1.svg png

You may wish to create aliases for the `circleator` and `rasterize-svg` executables if 
they were not installed into a system-wide bin/ directory. Under the Bash shell, for
example, the following commands can be run on the command line or placed into a
~/.bashrc file:

    alias circleator="/install/path/bin/circleator"
    alias rasterize-svg="/install/path/bin/rasterize-svg"
