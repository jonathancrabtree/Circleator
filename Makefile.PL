use ExtUtils::MakeMaker;

# TODO - check for presence of Java and APACHE BATIK module, edit rasterize-svg accordingly
# TODO - check for samtools?

WriteMakefile(
    NAME             => "Circleator",
    ABSTRACT         => "A Perl-based visualization tool for producing circular plots of genome-associated data.",
    AUTHOR           => "Jonathan Crabtree <jonathancrabtree@gmail.com>",
    LICENSE          => "artistic_2",
    VERSION_FROM     => "bin/circleator",
    EXE_FILES        => ["bin/circleator", "bin/rasterize-svg"],
    BUILD_REQUIRES   => {
	# modules needed to build the module, but not run it
    },
    PREREQ_PM        => {
	# BioPerl
	'Bio::SeqFeature::Generic'    => '0',
	# other
	'Log::Log4perl'               => '1.42',
	'SVG'                         => '2.50',
	'Text::CSV'                   => '1.31',
    },
    clean            => { FILES => "" },
    );
