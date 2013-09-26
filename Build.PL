use Module::Build;

# TODO - check for presence of Apache Batik rasterizer, update rasterize-svg if needed
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
    );

$build->add_build_element('cfg');
$build->create_build_script;
