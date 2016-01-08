use Module::Build;
use File::Spec;

# TODO - check for presence of Apache Batik rasterizer, update rasterize-svg if needed
# TODO - check for samtools?

# subclass Module::Build, overriding default install action
my $class = Module::Build->subclass(
    class => "Module::Build::Custom",
    code => <<'SUBCLASS' );

use File::Spec;

sub ACTION_install {
    my $self = shift;
    # edit the main circleator script before installing it in order to:
    #  1. set $DEFAULT_CONF_DIR to the location of the installed config files
    #  2. set $DEFAULT_LIB_DIR to the location of the installed lib files
    my $blib = $self->blib;
    my $script = File::Spec->catfile($blib, 'script', 'circleator');
    die "couldn't locate circleator script in ${blib}/script" if (!-e $script);
    my($conf_dir, $lib_dir) = map { $self->install_destination($_); } ('conf', 'lib');
    $lib_dir =~ s#/#\\\/#g;
    $conf_dir =~ s#/#\\\/#g;
    # TODO - use a more portable method for this
    my $replace_cmd = "perl -pi.bak -e 's/\\\$DEFAULT_CONF_DIR = \"[^\"]*\";/\\\$DEFAULT_CONF_DIR = \"$conf_dir\";/; s/\\\$DEFAULT_LIB_DIR = \"[^\"]*\";/\\\$DEFAULT_LIB_DIR = \"$lib_dir\";/;' $script";
    system($replace_cmd);
    die "failed to update \$DEFAULT_LIB_DIR, \$DEFAULT_CONF_DIR in $script" if ($?);
    unlink "${script}.bak";
    $self->SUPER::ACTION_install;
}
SUBCLASS

my $build = $class->new
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
	  # newdir() was added in 0.19:
	  'File::Temp'                  => '0.19', 
      },
    );

$build->install_path( conf => $build->install_base ? File::Spec->catfile($build->install_base, 'conf') : "/etc/circleator/conf" );
$build->add_build_element('cfg');
$build->create_build_script;
