#!/usr/bin/perl

use strict;
use FileHandle;
use File::Spec;
use File::Temp qw { tempdir };

# Generate icons/images for web site.

## globals
my $DOCS_TEST_DIR = '../html/docs/test-results';
my $BATIK_JAR = '/usr/local/packages/apache-batik-1.7/batik-rasterizer.jar';
my $MIME_TYPES = {
    'png' => 'image/png',
    'jpg' => 'image/jpeg',
    'pdf' => 'application/pdf',
};

# places where files requiring conversion are to be found
my $DIRS = 
    [
     # saved regression test results under test/results
     { 
	 'svg_dir' => '../test/results', 
	 'image_dir' => '../html/docs/images',
	 'rast_param_fn' => sub {
	     my($f) = @_;

	     # Circleator logos
	     if ($f =~ /\-logo\-/) {
		 return [
		     {'a' => '440,400,1440,2438', 'w' => 80, 'h' => 115, 'type' => 'png', 'suffix' => '' },
		     {'a' => '440,400,1440,2438', 'w' => 400, 'h' => 575, 'type' => 'png', 'suffix' => '-400' },
		     {'a' => '440,400,1440,2438', 'w' => 3478, 'h' => 5000, 'type' => 'png', 'suffix' => '-5000' },
		     {'a' => '440,400,1440,2438', 'w' => 800, 'h' => 1150, 'type' => 'pdf', 'suffix' => '' },
		     {'a' => '440,400,1440,2438', 'w' => 800, 'h' => 1150, 'type' => 'svg', 'suffix' => '' }
		     ];
	     }
	     # navigation icons
	     elsif ($f =~ /\-nav\-circle/) {
		 return [{'a' => '0,0,2400,2400', 'w' => 115, 'h' => 115, 'type' => 'png', 'suffix' => '' }];
	     } 
	     # sample images for docs/command-line.html
	     elsif ($f =~ /CM000961-genes-percentGC-GCskew-1\.svg/) {
		 return [
		     {'a' => '0,0,2600,2600', 'w' => 400, 'h' => 400, 'type' => 'png', 'suffix' => '' },
		     {'a' => '0,0,2600,2600', 'w' => 5000, 'h' => 5000, 'type' => 'png', 'suffix' => '-5000' }
		     ];
	     }
	     return undef;
	 },
	 'rewrite_fn' => sub {
	     my($path) = @_;
	     # HACK
	     my $copy = $path;
	     $copy =~ s/CM000961-180bp-//;
	     return $copy;
	 },
     }
    ];

# regression test results under html/docs
opendir(RTD, $DOCS_TEST_DIR);
foreach my $td (readdir(RTD)) {
    next if ($td =~ /^\./);
    my $svg_dir1 = File::Spec->catfile($DOCS_TEST_DIR, $td);
    my $svg_dir2 = File::Spec->catfile($DOCS_TEST_DIR, $td, 'results');

    foreach my $svg_dir ($svg_dir1, $svg_dir2) {
	push(@$DIRS, 
	     {
		 'svg_dir' => $svg_dir, 'image_dir' => $svg_dir, 
		 'rast_param_fn' => sub {
		     my($f) = @_;
		     return [
			 {'a' => undef, 'w' => 600, 'h' => 600, 'type' => 'png', 'suffix' => '' },
			 {'a' => undef, 'w' => 5000, 'h' => 5000, 'type' => 'png', 'suffix' => '-5000' }
			 ];
		 },
		 'rewrite_fn' => sub { my($path) = shift; return $path; } ,
	     });
    }
}
closedir(RTD);

## main program

# create tempdir for SVG output
my $tempdir = tempdir(CLEANUP => 1);

foreach my $dir (@$DIRS) {
    my($svg_dir, $image_dir, $rast_param_fn, $rewrite_fn) = map {$dir->{$_}} ('svg_dir', 'image_dir', 'rast_param_fn', 'rewrite_fn');

    opendir(SD, $svg_dir);
    my @svg_files = grep(/\.svg$/i, readdir(SD));
    closedir(SD);

    foreach my $f (@svg_files) {
	my $rast_params = &$rast_param_fn($f);
	next if (!defined($rast_params));
	my $f_path = File::Spec->catfile($svg_dir, $f);
	my $t_f_path = File::Spec->catfile($tempdir, $f);
	$t_f_path = &$rewrite_fn($t_f_path);
	&run_sys_command("cp $f_path $t_f_path");
	
	foreach my $rp (@$rast_params) {
	    my($a,$w,$h,$type,$suffix) = map {$rp->{$_}} ('a', 'w', 'h', 'type', 'suffix');

	    # parse SVG to determine coordinate bounds
	    if (!defined($a)) {
		my($width, $height) = &get_svg_dimensions($t_f_path);
		$a = "0,0,$width,$height";
	    }

	    my $img_path = $t_f_path;
	    $img_path =~ s/\.svg$/\.${type}/;
	    
	    my $final_img_file = $f;
	    $final_img_file =~ s/\.svg$/${suffix}\.${type}/;
	    $final_img_file = &$rewrite_fn($final_img_file);

	    my $final_img_path = File::Spec->catfile($image_dir, $final_img_file);

	    if (-e $final_img_path) {
		print STDERR "$final_img_path already exists: skipping it\n";
		next;
	    }
	    
	    if ($type ne 'svg') {
		my $mime_type = $MIME_TYPES->{$type};
		my $cmd = "java -jar $BATIK_JAR " . 
		    (($f =~ /nav/) ? "" : "-bg 255.255.255.255 ") .
		    "-a '$a' " .
		    "-w $w " .
		    "-h $h " .
		    "-m $mime_type " .
		    $t_f_path . " 2> /dev/null";
		
		print STDERR "converting $t_f_path to $mime_type\n";
		&run_sys_command($cmd);
	    }

	    die "target file $img_path does not exist" if (!-e $img_path);
	    print STDERR "copying $img_path to $final_img_path\n";
	    &run_sys_command("cp $img_path $final_img_path");
	}
    }
}

exit(0);

## subroutines

sub run_sys_command {
  my($cmd) = @_;
print STDERR "cmd=$cmd\n";
  system($cmd);

  # check for errors, halt if any are found
  my $err = undef;
  if ($? == -1) {
    $err = "failed to execute: $!";
  }
  elsif ($? & 127) {
    $err = sprintf("child died with signal %d, %s coredump\n", ($? & 127), ($? & 128) ? 'with' : 'without');
  }
  else {
    my $exit_val = $? >> 8;
    $err = sprintf("child exited with value %d\n", $exit_val) if ($exit_val != 0);
  }
  die $err if (defined($err));
}

sub get_svg_dimensions {
    my($file) = @_;
    my $width = undef;
    my $height = undef;
    my $fh = FileHandle->new();
    $fh->open($file) || die "unable to read from $file";
    while (my $line = <$fh>) {
	chomp($line);
	# assumes opening <svg> declaration is on a single line
	if ($line =~ /^\<svg/) {
	    ($width) = ($line =~ /width=\"(\d+)\"/);
	    ($height) = ($line =~ /height=\"(\d+)\"/);
	    last;
	}
    }
    $fh->close();
    die "couldn't parse SVG width and height from $file" unless (defined($width) && defined($height));
    return ($width, $height);
}
