use Module::Build;

# TODO - copy conf/ files to central location in "make install"
# TODO - check for presence of Java and APACHE BATIK module, edit rasterize-svg accordingly
# TODO - check for samtools?

my $build = Module::Build->new
    ( dist_name            => 'Circleator',
      dist_version_from    => 'bin/circleator',
      license              => 'artistic_2',
      dist_author          => 'Jonathan Crabtree <jonathancrabtree@gmail.com>',
      cfg_files            =>  
      {
	  'conf/brewer.txt' => 'conf/brewer.txt',
	  'conf/predefined-tracks.cfg' => 'conf/predefined-tracks.cfg',
	  'conf/genes-percentGC-GCskew-1.cfg' => 'conf/genes-percentGC-GCskew-1.cfg',
      },
      install_path         => 
      {
	  conf => '/home/jcrabtree/circleator/conf'
      },
      configure_requires   => 
      { 
	  'Module::Build' => 0.38 
      },
      requires             => 
      {
	  'Module::Build' => 0.38,
	  # BioPerl
	  'Bio::SeqFeature::Generic'    => '0',
	  # other
	  'Log::Log4perl'               => '1.42',
	  'SVG'                         => '2.50',
	  'Text::CSV'                   => '1.31',
      },
      # check for presence of optional modules
#      auto_features   => {
#	  ssh_support => { 
#	      description => "Use remote mirrors via ssh",
#	      requires    => {Net::SSH => 0.08 }
#	  },
#     },
      # generate additional test files as needed
#      PL_files => { 
#	  't/002_config.t.PL' => ['t/testconfig','t/002_config.t','t/002_config'],
#      },
    );

$build->add_build_element('cfg');
$build->create_build_script;
