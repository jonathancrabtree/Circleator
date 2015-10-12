#!/usr/bin/perl

use strict;
use FileHandle;
use File::Spec;
use JSON;

# Quick hack to generate HTML documentation from the predefined track config file 
# (or any config file that adheres to the same conventions.)

# TODO - automatically replace detailed config track definitions with the new name for the purposes of the config file?

## globals
my $USAGE = "Usage: $0 config_file docs_dir circleator_dir default_data_file";
my $BATIK_JAR = '/usr/local/packages/apache-batik-1.7/batik-rasterizer.jar';
my $JAVA_HEAP_SIZE = '2400';
my $IMAGE_SUBDIR = 'predefined-tracks';
my $THUMBNAIL_PNG_WIDTH = 140;
my $FULLSIZE_PNG_WIDTH = 4000;
my $FULLSIZE_PDF_WIDTH = 2000;

# aspect ratio of zoomed-in views
my $ZOOM_WIDTH = 210;
my $ZOOM_HEIGHT = 140;
my $ZOOM_ASPECT = sprintf("%0.1f", $ZOOM_WIDTH / $ZOOM_HEIGHT);

# full image size 
my $FULL_IMAGE_AREA = [0,0,3200,3200];

# default region of interest to focus zoomed views on
# the most zoomed-in view will show exactly this region and then the next 2 zoom
# levels will be progressively larger views
my $DEFAULT_DETAIL_AREA = [1440,340,320,213];   # 10x
my $ZOOM_LEVELS = [5,2];

## input
my $config_file = shift || die $USAGE;
my $docs_dir = shift || die $USAGE;
my $circleator_dir = shift || die $USAGE;
my $sample_data_file = shift || die $USAGE;

my $circleator = File::Spec->catfile($circleator_dir, "bin", "circleator.pl");
die "can't find circleator.pl in $circleator_dir/bin)" unless (-e $circleator);;
my $circleator_lib_dir = File::Spec->catfile($circleator_dir, "lib");

## main program
my $tracks = &parse_config_file($config_file);
&print_page_html_header();

# make sure SVG/PNG directory exists
my $image_subdir = File::Spec->catfile($docs_dir, $IMAGE_SUBDIR);
&run_sys_command("mkdir -p $image_subdir");

# print description and sample image for each track
my $tc = 0;
my $figure_tracks = [];
my $json_list = [];
my $json_hash = {};

foreach my $track (@$tracks) {
  ++$tc;
  if (defined($track->{'html'})) {
    print $track->{'html'};
    if (defined($track->{'track_list'})) {
      print "<ul>\n" . join("\n", @{$track->{'track_list'}}) . "</ul>\n";
    }
    if (defined($track->{'docs'} && ($track->{'docs'} =~ /\S/))) {
      print $track->{'docs'} . "\n";
    }
    next;
  }

  my $detail_zoom = undef;
  my($config_path, $config_url, $config_changed) = (undef, undef, undef);
  my($svg_path, $svg_url, $svg_changed) = (undef, undef, undef);
  my($thumbnail_png, $fullsize_png, $fullsize_pdf, $zoom1_png, $zoom2_png, $zoom3_png) = (undef, undef, undef, undef, undef);
  my($thumbnail_png_url, $fullsize_png_url, $fullsize_pdf_url, $zoom1_png_url, $zoom2_png_url, $zoom3_png_url) = (undef, undef, undef, undef, undef);

  if ($track->{'reset'}) {
      $figure_tracks = [];
      next;
  }
  elsif ($track->{'show_figure'}) {
    if (scalar(@$figure_tracks) == 0) {
      print STDERR "WARNING - no tracks to generate figure at line $track->{'lnum'} of $config_file\n";
      next;
    }

    # write config file
    my $fig_name = $figure_tracks->[-1]->{'name'};
    $fig_name =~ s/\%/Percent/g;
    ($config_path, $config_url, $config_changed) = &make_track_config($docs_dir, $IMAGE_SUBDIR, $fig_name, $figure_tracks);
    $figure_tracks = [];

    # run circleator to generate SVG
    ($svg_path, $svg_url, $svg_changed) = &make_track_svg($docs_dir, $IMAGE_SUBDIR, $config_path, $fig_name, $circleator_lib_dir, $circleator, $sample_data_file, $config_changed);

    print STDERR "$fig_name: generating PNG images\n" if ($svg_changed);

    # thumbnail image
    ($thumbnail_png, $thumbnail_png_url) = &make_track_image($docs_dir, $IMAGE_SUBDIR, $svg_path, $svg_changed, $fig_name, $THUMBNAIL_PNG_WIDTH);

    # full-size image
    ($fullsize_png, $fullsize_png_url) = &make_track_image($docs_dir, $IMAGE_SUBDIR, $svg_path, $svg_changed, $fig_name, $FULLSIZE_PNG_WIDTH);
    ($fullsize_pdf, $fullsize_pdf_url) = &make_track_image($docs_dir, $IMAGE_SUBDIR, $svg_path, $svg_changed, $fig_name, $FULLSIZE_PDF_WIDTH, undef, undef, 'application/pdf');

    # cropped images
    my ($ix, $iy, $iw, $ih) = @$FULL_IMAGE_AREA;
    my $detail_area = $track->{'detail_area'};
    $detail_area = $DEFAULT_DETAIL_AREA if (!defined($detail_area));
    my ($dx, $dy, $dw, $dh) = @$detail_area;
    $detail_zoom = $iw/$dw;
    my $detail_aspect = sprintf("%0.1f", $dw / $dh);
    print STDERR "WARNING - aspect ratio of user-specified zoom area ($detail_aspect for $dw x $dh) != $ZOOM_ASPECT at line $track->{'lnum'}\n" if ($detail_aspect != $ZOOM_ASPECT);

    my $zoom_area2 = &calculate_zoom_area($detail_area, $ZOOM_LEVELS->[0], $detail_aspect);
    my $zoom_area1 = &calculate_zoom_area($detail_area, $ZOOM_LEVELS->[1], $detail_aspect);

    ($zoom1_png, $zoom1_png_url) = &make_track_image($docs_dir, $IMAGE_SUBDIR, $svg_path, $svg_changed, $fig_name, $ZOOM_WIDTH, $ZOOM_HEIGHT, '-z1', undef, join(',', @$zoom_area1));
    ($zoom2_png, $zoom2_png_url) = &make_track_image($docs_dir, $IMAGE_SUBDIR, $svg_path, $svg_changed, $fig_name, $ZOOM_WIDTH, $ZOOM_HEIGHT, '-z2', undef, join(',', @$zoom_area2));
    ($zoom3_png, $zoom3_png_url) = &make_track_image($docs_dir, $IMAGE_SUBDIR, $svg_path, $svg_changed, $fig_name, $ZOOM_WIDTH, $ZOOM_HEIGHT, '-z3', undef, join(',', @$detail_area));

  }
  elsif (!$track->{'noimage_mode'}) {
    push(@$figure_tracks, $track);
  }

  my $zoomed_images = 
    [
     {'url' => $zoom3_png_url, 'zoom_level' => $detail_zoom},
     {'url' => $zoom2_png_url, 'zoom_level' => $ZOOM_LEVELS->[0]}, 
     {'url' => $zoom1_png_url, 'zoom_level' => $ZOOM_LEVELS->[1]}, 
    ];

  map { $_->{'zoom_descr'} = sprintf("%0.1f", $_->{'zoom_level'}) . "x"; $_->{'width'} = $ZOOM_WIDTH; $_->{'height'} = $ZOOM_HEIGHT; } @$zoomed_images;
  &print_track_html($track, $config_url, $thumbnail_png_url, $fullsize_png_url, $svg_url, $fullsize_pdf_url, $zoomed_images);
  &add_track_json($json_list, $json_hash, $track, $config_url, $thumbnail_png_url, $fullsize_png_url, $svg_url, $fullsize_pdf_url, $zoomed_images);
}
&print_page_html_footer();

# write JSON file
my $json_file = "predefined-tracks.json";
my $json_path = File::Spec->catfile($docs_dir, $json_file);
my $jfh = FileHandle->new();
my $json = JSON->new();
$jfh->open(">$json_path") || die "unable to write to $json_path";
my $json_pp = $json->pretty->encode($json_list);
$jfh->print($json_pp);
$jfh->close();

exit(0);

## subroutines
sub parse_config_file {
  my($file) = @_;
  my $fh = FileHandle->new();
  $fh->open($file) || die "unable to read config file $file";
  my $lnum = 0;
  my $tracks = [];
  my $docs = undef;
  my $uncomment_mode = 0;
  my $nodoc_mode = 0;
  my $noimage_mode = 0;
  my $group_list = [];
  my $track_list = [];
  my $last_track_name = undef;
  my $groupnum = 1;
  my $track_name_indexes = {};
  
  while (my $line = <$fh>) {
    chomp($line);
    ++$lnum;

    # double hashtag means _uncomment_ the line for the purposes of documentation
    $line =~ s/^\#\#//;

    # special processing directives:

    # DOC/NODOC
    if ($line =~ /^\#\s*\<((NO)?DOC)\>/) {
      $nodoc_mode = ($1 eq 'DOC') ? 0 : 1;
      next;
    }

    # IMAGE/NOIMAGE
    if ($line =~ /^\#\s*\<((NO)?IMAGE)\>/) {
      $noimage_mode = ($1 eq 'IMAGE') ? 0 : 1;
      next;
    }

    if ($line =~ /^\#\s*\<FIGURE/) {
      my($zoom, $caption, $data, $reset) = (undef, undef, undef, 0);

      if ($line =~ /\s+RESET/) {
        $reset = 1;
      }
      if ($line =~ /\s+ZOOM\=(\d+)\,(\d+)\,(\d+)\,(\d+)/) {
        $zoom = [$1,$2,$3,$4];
      }
      if ($line =~ /\s+CAPTION\=\"([^\"]+)\"|\'([^\']+)\'/) {
        $caption = defined($1) ? $1 : $2;
      }
      if ($line =~ /\s+DATA\=\"([^\"]+)\"|\'([^\']+)\'/) {
        $data = defined($1) ? $1 : $2;
      }

      push(@$tracks, { 'show_figure' => 1, 'lnum' => $lnum, 'detail_area' => $zoom, 'caption' => $caption, 'data' => $data, 'reset' => $reset, 'name' => $last_track_name });
      next;
    }

    # blank line
    if ($line =~ /^\s*$/) {
      # TODO - do something with documentation not associated with a track?
      $docs = "";
      next;
    }
    # documentation line
    elsif ($line =~ /^\#(.*)$/) {
      if ($line =~ /\<GROUP\>\s*(.*)$/) {
        my $group = $1;
        my $gkey = $group;
        $gkey =~ s/\s/_/g;
        if (!$nodoc_mode) {
          $track_list = [];
          my $track = { 'html' => "<a name='$gkey'></a>\n<h2>${groupnum}. $group</h2>\n", 'lnum' => $lnum, 'track_list' => $track_list, 'docs' => $docs };
          push(@$tracks, $track);
          push(@$group_list, { 'key' => $gkey, 'name' => $group, 'track_list' => []});
          ++$groupnum;
        }
        $docs = "";
      } 
      elsif ($line =~ /\<TRACK\>\s*(.*)$/) {
        my $track_name = $1;
        my $tkey = $track_name;
        $tkey =~ s/\s/_/g;
        if (!$nodoc_mode) {
          my $track = { 'html' => "<h3><a name='$tkey'><span class='track_heading'>$track_name</span></h3>\n", 'lnum' => $lnum };
          push(@$tracks, $track);
          my $track_li = "<li><a href='#$tkey'><span class='track'>${track_name}</span></a></li>";
          push(@$track_list, $track_li);
          push(@{$group_list->[-1]->{'track_list'}}, $track_li);
          $last_track_name = $track_name;
        }
      }
      elsif ($line =~ /\<OPTION\>\s*(.*)$/) {
        my $option = $1;
        if (!$nodoc_mode) {
          my $track = { 'html' => "<h4><span class='track_heading'>$last_track_name</span> <span class='option_heading'>${option}</span>=</h4>\n", 'lnum' => $lnum };
          push(@$tracks, $track);
        }
      }
      else {
        $line =~ s/^\#//;
        $docs .= $line . "\n";
      }
    }
    # predefined track
    elsif ($line =~ /^(new|\S+)(?:\s+(\S+))?/) {
      my($alias, $name) = ($1, $2);
#      print STDERR "got alias='$alias' name='$name' at line $lnum\n";
      my $track = 
        { 
         'docs' => $docs, 
         'line' => $line, 
         'lnum' => $lnum,
         'alias_for' => ($alias eq 'new') ? undef : $alias,
         'name' => $name,
         'uncomment_mode' => $uncomment_mode,
         'noimage_mode' => $noimage_mode,
        };
      die "unnamed new track at line $lnum" if (($alias eq 'new') && ($track->{'name'} eq ''));
      $track->{'name'} = $alias if ($alias ne 'new');
      my $index = $track_name_indexes->{$track->{'name'}};
      $index = $track_name_indexes->{$track->{'name'}} = 0 if (!defined($index));
      ++$track_name_indexes->{$track->{'name'}};
      $track->{'name'} = $track->{'name'} . "." . ($index+1);
      push(@$tracks, $track) unless ($nodoc_mode);
      $docs = "";
#      print STDERR "created track with name='" .$track->{'name'}. "', alias_for='" .$track->{'alias_for'}.  "'\n";
    }
    else {
      print STDERR "unable to parse line $lnum of $file: $line\n";
    }
  }
  $fh->close();

  # add group index
  my $index_items = [];
  foreach my $group (@$group_list) {
    my($key, $name, $tl) = map {$group->{$_}} ('key', 'name', 'track_list');
    my $track_list = "<ul>\n" . join("\n", @$tl) . "</ul>\n";
    push(@$index_items, "<li><a href='#${key}'>$name</a>\n${track_list}\n</li>");
  }

  unshift(@$tracks, 
          { 
           'html' => "<ol>\n" . join("\n", @$index_items). "</ol>\n" 
          });
  return $tracks;
}

sub make_track_config {
  my($docs_dir, $conf_subdir, $fig_name, $tracks) = @_;
  my $c_file = $fig_name . ".cfg";
  my $c_url = $conf_subdir . "/" . $c_file;
  my $c_path = File::Spec->catfile($docs_dir, $conf_subdir, $c_file);
  my $new_config = join("\n", map {$_->{'line'}} @$tracks) . "\n";
  my $config_changed = 1;

  if (-e $c_path) {
    my $current_config = `cat $c_path`;
    if ($new_config eq $current_config) {
      $config_changed = 0;
    }
  }

  # write/overwrite config file
  if ($config_changed) {
    print STDERR "$fig_name: updating/writing config file\n";
    my $cfh = FileHandle->new();
    $cfh->open(">$c_path");
    $cfh->print($new_config);
    $cfh->close();
  } else {
    print STDERR "$fig_name: no change\n";
  }

  return ($c_path, $c_url, $config_changed);
}

sub make_track_svg {
  my($docs_dir, $image_subdir, $conf_path, $fig_name, $cdir, $circleator, $data, $config_changed) = @_;
  my $svg_file = $fig_name . ".svg";
  my $svg_url = $image_subdir . "/" . $svg_file;
  my $svg_path = File::Spec->catfile($docs_dir, $image_subdir, $svg_file);
  my $svg_changed = 0;
  # only overwrite existing SVG if config has changed
  if (!(-e $svg_path) || $config_changed) {
    my $ccmd = "perl -I${cdir}/lib $circleator --data=${data} --config=${conf_path} >${svg_path}";
    print STDERR "$fig_name: updating/generating SVG file\n";
    &run_sys_command($ccmd);
    $svg_changed = 1;
  }
  return ($svg_path, $svg_url, $svg_changed);
}

sub make_track_image {
  my($docs_dir, $image_subdir, $svg_path, $svg_changed, $fig_name, $width, $height, $suffix, $type, $area) = @_;
  $height = $width if (!defined($height));
  $suffix = "-" . $width . "x" . $height if (!defined($suffix));
  $type = 'image/png' if (!defined($type));
  my($file_ext) = ($type =~ /\/(png|pdf|jpeg)/);
  $file_ext =~ s/jpeg/jpg/;

  my $img_path = $svg_path;
  $img_path =~ s/\.svg$/.$file_ext/;

  # run rasterizer to make PNG
  my $area_str = defined($area) ? "-a '$area'": "";
  my $rcmd = "java -mx${JAVA_HEAP_SIZE}M -jar $BATIK_JAR -w $width -h $height -m ${type} ${area_str} $svg_path > /dev/null";
  &run_sys_command($rcmd) if ($svg_changed);

  # rename image
  my $new_img_file = $fig_name . $suffix . "." . $file_ext;
  my $new_img_url = $image_subdir . "/" . $new_img_file;
  my $new_img_path = File::Spec->catfile($docs_dir, $image_subdir, $new_img_file);
  &run_sys_command("mv $img_path $new_img_path") if ($svg_changed);
  
  return ($new_img_path, $new_img_url);
}

sub print_track_html {
  my($track, $conf_url, $thumb_url, $fullsize_png_url, $svg_url, $pdf_url, $zoomed_images) = @_;
  print $track->{'docs'} . "\n" if (defined($track->{'docs'}) && ($track->{'docs'} =~ /\S/));

  if ($track->{'show_figure'} && !$track->{'noimage_mode'}) {
    my $zoom_div = sub {
      my($descr) = @_;
      return "<div style='position: absolute; margin: 1em 0em 0em 0.5em;'><span class='zoom'>$descr</span></div>";
    };
    
    my $ncols = scalar(@$zoomed_images) + 1;
    print "<table class='figure'>\n";
    print "<tbody>\n";
    print "<tr>\n";
    print "<th class='figure_caption' colspan='$ncols'><span class='figure_caption'>" . $track->{'caption'} . "</span></th>\n" if (defined($track->{'caption'}));
    print "</tr>\n";
    print "<tr>\n";

    foreach my $z (@$zoomed_images) {
      my($url, $zdescr, $width, $height) = map {$z->{$_}} ('url', 'zoom_descr', 'width', 'height');
      print "<td>";
      print "<a href='$fullsize_png_url'><img class='zoom' src='$url' style='width: ${width}px; height: ${height}px;'></a>";
      print &$zoom_div($zdescr);
      print "</td>\n";
    }

    my $tpw = $THUMBNAIL_PNG_WIDTH;
    print "<td><a href='$fullsize_png_url'><img class='zoom' src='$thumb_url' style='float: left; width: ${tpw}px; height: ${tpw}px;'></a>" . &$zoom_div("1.0x") . "</td>\n";
    print "</tr>\n";
    print "<tr>\n";
    print "<td colspan='$ncols'><span class='downloads'>view/download <a href='$svg_url'>SVG</a>, <a href='$fullsize_png_url'>large PNG image</a>, <a href='$pdf_url'>PDF</a> or circleator <a href='$conf_url'>config file</a></span></td>\n";
    print "</tr>\n";
    print "</tbody>\n";
    print "</table>\n";
    print "\n";
  }
}

sub add_track_json {
  my($jlist, $jhash, $track, $conf_url, $thumb_url, $fullsize_png_url, $svg_url, $pdf_url, $zoomed_images) = @_;
  my $docs = (defined($track->{'docs'}) && ($track->{'docs'} =~ /\S/)) ? $track->{'docs'} : '';
  my $tname  = $track->{'name'};
  if ($track->{'show_figure'} && !$track->{'noimage_mode'} && (!defined($jhash->{$tname}))) {
    my $zi = $zoomed_images->[0];
    my($url, $zdescr, $width, $height) = map {$zi->{$_}} ('url', 'zoom_descr', 'width', 'height');
    push(@$jlist, 
         { 
          'name' => $tname,
          'caption' => $track->{'caption'},
          'icon_url' => $url,
          'descr' => $zdescr,
          'width' => $width,
          'height' => $height,
         });
    # include only the first example for each track type
    $jhash->{$tname} = 1;
  }
}

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

# returns the coordinates (x,y,w,h) of a region centered around $detail_area and magnified by a factor 
# of $zoom_level from the full-size image
sub calculate_zoom_area {
  my($detail_area, $zoom_level, $aspect_ratio) = @_;
  my ($ix, $iy, $iw, $ih) = @$FULL_IMAGE_AREA;
  my ($dx, $dy, $dw, $dh) = @$detail_area;
  my $aw = $iw / $zoom_level;
  my $ah = $aw * (1/$aspect_ratio);
  my $xdiff = $aw - $dw;
  my $ydiff = $ah - $dh;
  my $ax = $dx - ($xdiff/2);
  my $ay = $dy - ($ydiff/2);;
  return [$ax, $ay, $aw, $ah];
}

sub print_page_html_header {
  my $title = "Circleator : documentation : predefined tracks";
  print <<HEADER;
<html>
<head>
<title>Circleator : documentation : predefined tracks</title>
<link href="css/circleator.css" rel="stylesheet" type="text/css" />
</head>
<body>
<table class='header'>
<tbody>
<tr>
 <td class='header' rowspan='2'><img src='images/logo-2.png' class='header_logo'></td>
 <td><h1>Predefined tracks</h1></td>
 <td class='header' rowspan='2'><img src='images/nav-circle-sel-docs.png' class='nav_circle'></td>
</tr>
<tr>
 <td>&nbsp;<a href='index.html'>home</a>&nbsp;|&nbsp;<a href='documentation.html'>documentation</a>&nbsp;|&nbsp;<a href='gallery.html'>gallery</a>&nbsp;|&nbsp;<a href='software.html'>software</a></td>
</tr>
</tbody>
</table>
<div class='main'>

<p>
The Circleator provides a number of predefined circular tracks that
can be used to display various types of data with very little effort.
Simply find the appropriate predefined track type in the list below
(e.g., "genes" for a circular display of all annotated features of
type "gene") and place that keyword on a line by itself somewhere in
the Circleator configuration file.  The tracks will be drawn in the
order that they appear in the configuration file, starting with the
outside of the circle and moving inwards.  Most of the predefined track
types support one or more user-configurable options, many of which are also
described below.  Multiple options can be specified by separating them with
a comma (but no spaces), like so:
<pre>
genes color1=#ff0000,color2=#000000
</pre>
</p>

<p>
The predefined tracks have been grouped into the following categories to make searching easier:
</p>
HEADER
}

sub print_page_html_footer {
  print <<FOOTER;
</div>
<div class='footer'>
</div>
</body>
</html>
FOOTER
}
