package Circleator::Config::Standard;

use Circleator::Config::Config;
use Circleator::Parser::SNP;
use FileHandle;

use strict;

## globals
my $DEFAULT_TRACK_HEIGHT = 0.1;

my $SNP = Circleator::Parser::SNP->new();
my $SNP_TP = $SNP->tag_prefix();
my $SNP_TBTP = $SNP->target_base_tag_prefix();

my $HAS_NO_SPACES_FN = sub { my $val = shift; return ($val =~ /^\S+$/); };

# type must be either a reference to a known type or 'new' for a new user-defined type (the default)
my $IS_TYPE_FN = sub { my $val = shift; return (($val =~ /^\S+$/) || ($val eq 'new')); };

my $IS_FRAC_FN = sub { my $val = shift; return ($val =~ /^([\d\.]+|same)$/i); };

my $IS_GLYPH_FN = sub {
  my $val = shift;
  # TODO - this will eventually be based on a dynamic lookup for a matching glyph package
  return ($val =~ /^none|label|graph|ruler||rectangle|cufflinks-transcript|synteny-arrow$/);
};

my $IS_DATA_FN = sub {
  # check that this is a valid file
  my $val = shift;
  return (-e $val);
};

my $IS_FEAT_TYPE_FN = sub {
  return 1;
};

my $IS_FEAT_STRAND_FN = sub {
  my $val = shift;
  return ($val =~ /^|\-|\+|1|\-1$/i);
};

my $IS_COLOR_FN = sub {
  my $val = shift;
  # TODO - allow color names too
  # HTML-style hexadecimal color specs for now
  return ($val =~ /^\#[a-f0-9]{6}$/i);
};

my $IS_ZERO_TO_ONE_FN = sub {
  my $val = shift;
  return ($val =~ /^[\d\.]+$/) && ($val >=0) && ($val <= 1);
};

my $IS_INT_FN = sub {
  my $val = shift;
  return ($val =~ /\d+/);
};

my $IS_OPTIONS_FN = sub {
  # TODO - add some checking/parsing
  return 1;
};

my $FIELDS = 
  [ 
   { 'name' => 'type', 'track_name' => 'type', 'validator' => $HAS_NO_SPACES_FN, 'default' => 'new' },
   { 'name' => 'name', 'track_name' => 'name', 'validator' => $HAS_NO_SPACES_FN },
   { 'name' => 'glyph', 'track_name' => 'glyph', 'validator' => $IS_GLYPH_FN },
   { 'name' => 'heightf', 'track_name' => 'height-frac', 'validator' => $IS_FRAC_FN },
   { 'name' => 'innerf', 'track_name' => 'start-frac', 'validator' => $IS_FRAC_FN },
   { 'name' => 'outerf', 'track_name' => 'end-frac', 'validator' => $IS_FRAC_FN },
   { 'name' => 'data', 'validator' => $IS_DATA_FN },
   { 'name' => 'feat_type', 'track_name' => 'feat-type', 'validator' => $IS_FEAT_TYPE_FN },
   { 'name' => 'feat_strand', 'track_name' => 'feat-strand', 'validator' => $IS_FEAT_STRAND_FN },
   { 'name' => 'color1', 'track_name' => 'fill-color', 'validator' => $IS_COLOR_FN },
   { 'name' => 'color2', 'track_name' => 'stroke-color', 'validator' => $IS_COLOR_FN },
   { 'name' => 'opacity', 'track_name' => 'opacity', 'validator' => $IS_ZERO_TO_ONE_FN },
   { 'name' => 'zindex', 'track_name' => 'z-index', 'validator' => $IS_INT_FN },
   { 'name' => 'options', 'validator' => $IS_OPTIONS_FN }
  ];

# options allowed in any track
my $GLOBAL_OPTS = 
  [
   'feat-file', 'feat-file-type',
   # SNPs
   'snp-ref', 'snp-query', 'snp-min-diffs', 'snp-max-diffs', 'snp-no-hit-color', 'snp-same-as-ref-color', 'snp-unknown-color', 'snp-syn-color', 
   'snp-nsyn-color', 'snp-multiple-color', 'snp-ins-color', 'snp-del-color', 'snp-intergenic-color',
   'snp-other-color', 'snp-intronic-color', 'snp-readthrough-color',
   'snp-same-as-ref-label', 'snp-no-hit-label', 'snp-utr-color',
   # tag labels
   'tag-name', 'tag-value-separator', 'tag-ignore-multiple-values',
   # TRF
   'trf-query',
   # gene expression
   'sample', 'exp-default-color', 'exp-thresholds', 'exp-colors',
   # color configuration (TODO - get these from the functions)
   'fill-color', 'stroke-color', 'fill-colors', 'stroke-colors',
   'color1-regexes', 'color1-colors', 'color1-default', 'color1-attribute', 'color1-min-lengths', 'color1-max-lengths',
   'color2-regexes', 'color2-colors', 'color2-default', 'color2-attribute', 'color2-min-lengths', 'color2-max-lengths',
   # other SVG options
   'stroke-width',
   # track from which to obtain features
   'feat-track',
   # whether to skip drawing this track (e.g., it could be set to LOOP_EVEN in a loop)
   'skip-track',
   'z-index',
   # filters
   'feat-type', 'feat-type-regex', 'feat-strand', 'feat-tag', 'feat-tag-value', 'feat-tag-min-value', 'feat-tag-max-value', 'feat-tag-regex',
   'feat-tag-lt', 'feat-tag-lte', 'feat-tag-gt', 'feat-tag-gte', 
   'feat-min-length', 'feat-max-length', 'clip-fmin', 'clip-fmax', 'overlapping-feat-type', 'overlapping-feat-track',
   # filter by gene cluster
   'gene-cluster-genomes', 'gene-cluster-signature', 'gene-cluster-analysis', 'gene-cluster-min-genomes', 'gene-cluster-max-genomes',
   # font width - modifies constant assumption about ratio of font width to height
   'font-width-frac'
  ];

# TODO - move this info into the individual Glyph packages
my $GLYPH_OPTS = 
  {
   'graph' => ['window-size', 'window-offset', 'graph-function', 'graph-type', 'graph-direction', 'graph-baseline', 
               'graph-min', 'graph-max', 'no-labels', 'no-circles', 'fmin', 'fmax', 'omit-short-last-window', 'file',
               'heat-map-min-value', 'heat-map-max-value', 'heat-map-values', 'heat-map-colors', 'heat-map-log-base', 
               'heat-map-out-of-range-color', 'heat-map-brewer-palette' ],
   'ruler' => ['tick-interval', 'label-interval', 'label-type', 'label-units', 'label-precision', 'font-size', 'no-circle', 'fmin', 'fmax'],
   'rectangle' => ['inner-scale', 'outer-scale', 'stroke-width', 'stroke-dasharray'],
   'circle' => ['stroke-width', 'stroke-dasharray'],
   'variant-base-histogram' => ['inner-scale', 'outer-scale', 'stroke-width', 'stroke-dasharray', 'min-allele-pct', 'label-bases', 'font-height-frac'],
   'scaled-segment-list' => ['scale', 'target-bp'],
   'loop-start' => ['loop-var'],
   'loop-end' => [],
   'compute-deserts' => ['desert-feat-type', 'desert-min-length'],
   'compute-graph-regions' => ['region-feat-type', 'region-min-length', 'region-max-length', 'graph-min-value', 'graph-max-value', 'graph-track'],
   'load-bsr' => ['bsr-file', 'genome1', 'genome2'],
   'bsr' => ['inner-scale', 'outer-scale', 'stroke-width', 'stroke-dasharray', 'threshold', 'genomes', 'signature', 'min-genomes', 'max-genomes'],
   'load-trf-variation' => ['trf-variation-file'],
   'load-gene-expression-table' => ['gene-expression-file'],
   'load-gene-cluster-table' => ['gene-cluster-file'],
   # TODO - these need work
   'cufflinks-transcript' => ['gene-id-mapping-file'],
   'synteny-arrow' => ['gene-pairs', 'inner-scale', 'outer-scale', 'stroke-width', 'max-insertion-gene-count'],
   'label' => ['text-anchor', 'label-function', 'packer', 'reverse-pack-order', 'text-color', 'style', 'link-color', 
               'label-type', 'draw-link', 'stroke-width', 'font-height-frac', 'font-family', 'font-style', 'font-weight', 'text',
               # used by bsr_count
               'genomes', 'threshold'],
  };

## subroutines
sub new {
  my($invocant, $logger, $params) = @_;
  my $class = ref($invocant) || $invocant;
  my $pdtf = $params->{'predefined_track_file'};

  my $atts = 
    {
     'logger' => $logger,
     'predefined_track_file' => $pdtf,
     'predefined_tracks' => {},
    };
  my $self = bless $atts, $class;

  if (defined($pdtf)) {
    my $pconfig = $self->read_config_file($pdtf);
    my $ptracks = $pconfig->{'tracks'};
    # index tracks by name
    map { $self->{'predefined_tracks'}->{$_->{'name'}} = $_; } @$ptracks;
  }

  return $self;
}

sub read_config_file {
  my($self, $file) = @_;
  my $logger = $self->{'logger'};
  my $predef_tracks = $self->{'predefined_tracks'};

  my $lines = [];
  my $num_lines_with_errors = 0;

  my $fh = FileHandle->new();
  $fh->open($file) || $logger->logdie("unable to read from config file $file");
  my $lnum = 0;
  while (my $line = <$fh>) {
    chomp($line);
    ++$lnum;
    # allow Perl-style comments
    next if ($line =~ /^(\s*|\#.*)$/);

    my $fields = [];
    while($line =~ /(\"[^\"]*\"|[^\"\s]\S*)/g) {
      my $fv = $1;
      if ($fv =~ /^\"([^\"]*)\"$/) {
        $fv = $1;
      }
#      print STDERR "$lnum: got field '$1'\n";
      push(@$fields, $fv);
    }

    my $line_h = { 'lnum' => $lnum, 'line' => $line };

    # replace NULL value proxies with explicit undefs
    my @new_fields = map { ($_ =~ /^([\.\-]|null|undef|n\/a|na|n)$/i) ? undef : $_; } @$fields;
    my $num_errors = 0;
    $fields = \@new_fields;
    my $nf = scalar(@$fields);

    # pop off final field if it looks like an options list
    # track type must be specified, everything else is optional
    if (($nf > 1) && ($fields->[-1] =~ /\=/)) {
      $line_h->{'options'} = pop @$fields;
      --$nf;
    }

    for (my $f = 0;$f < $nf;++$f) {
      my $field = $FIELDS->[$f];
      my($name, $validator, $default) = map {$field->{$_}} ('name', 'validator', 'default');
      my $field_val = ($name eq 'options') ? $line_h->{'options'} : $fields->[$f];
      if (!defined($field_val)) {
        $line_h->{$name} = defined($default) ? $default : undef;
      }
      elsif (&$validator($field_val)) {
        $line_h->{$name} = $field_val;
#        print STDERR "line $lnum field $f: $field_val ($name)\n";
      } else {
        $logger->error("invalid field " . ($f+1) . " at line $lnum: '" . $field_val . "'");
        ++$num_errors
      }
    }
    push(@$lines, $line_h);
    ++$num_lines_with_errors if ($num_errors > 0);
  }
  $fh->close();
  $logger->logdie("$num_lines_with_errors line(s) in $file had errors; please correct them and rerun") if ($num_lines_with_errors > 0);

  # populate $tracks based on contents of $lines
  my $tracks = [];
  # tracks indexed by name
  my $tracks_h = {};

  foreach my $line (@$lines) {
    # check whether this line uses a previously-defined track
    my $type = $line->{'type'};
    my $track = undef;

    if ($type ne 'new') {
      # check global predefined tracks first
      my $ptrack = $predef_tracks->{$type};
#      print STDERR "checked $type against globals, got $ptrack\n";
      if (defined($ptrack)) {
        my %copy =%$ptrack;
        $track = \%copy;
      }
      # then all tracks defined before this one in the current config file
      else {
        my $plist = $tracks_h->{$type};
#        print STDERR "checked $type against locals, got $plist\n";
        my $pll = defined($plist) ? scalar(@$plist) : 0;
        if ($pll == 1) {
          my %copy =%{$plist->[0]};
          $track = \%copy;
        } elsif ($pll > 1) {
          $logger->error("reference to ambiguous track type '$type' at line " . $line->{'lnum'});
        } else {
          $logger->logdie("reference to unknown track type '$type' at line " . $line->{'lnum'});
        }
      }
    }
    $track = {} if (!defined($track));

    # set/override positional configuration options
    my $set_track_att = sub {
      my($tname, $lname) = @_;
      $lname = $tname if (!defined($lname));
      $track->{$tname} = $line->{$lname} if (defined($line->{$lname}));
    };
    foreach my $field (@$FIELDS) {
      my($name, $tname) = map {$field->{$_}} ('name', 'track_name');
      if (defined($tname)) {
        &$set_track_att($tname, $name);
      }
    }

    # set/override explicitly-named configuration options from the last field
    my $options_str = $line->{'options'};
    my @options = split(/\s*\,\s*/, $options_str);
    my $options_kv = {};
    my $opts_unused = {};

    foreach my $option (@options) {
      my($k,$v) = split(/\=/, $option);
      $logger->warn("couldn't parse option value '$option' at line $line->{'lnum'}: $line->{'line'}") if (!defined($k) || !defined($v));
      $options_kv->{$k} = $v;
      $opts_unused->{$k} = $v;
    }

    # allow positional options to be specified as named options too
    foreach my $field (@$FIELDS) {
      my($name, $tname) = map {$field->{$_}} ('name', 'track_name');
      if (defined($options_kv->{$name})) {
        $track->{$tname} = $options_kv->{$name};
        delete $opts_unused->{$name};
      }
    }

    # extract glyph-specific options, ignore everything else
    my $glyph = $track->{'glyph'};
    my $glyph_opts = $GLYPH_OPTS->{$glyph};

    foreach my $opt (@$glyph_opts, @$GLOBAL_OPTS) {

      # allow use of "_" instead of "-" in option names
      my $alt_opt = $opt;
      $alt_opt =~ s/\-/\_/g;

      if (defined($options_kv->{$alt_opt}) && !defined($options_kv->{$opt})) {
        $options_kv->{$opt} = $options_kv->{$alt_opt};
        $opts_unused->{$opt} = $options_kv->{$alt_opt};
        delete $options_kv->{$alt_opt};
        delete $opts_unused->{$alt_opt};
      }

      if (defined($options_kv->{$opt})) {
        $track->{$opt} = $options_kv->{$opt};
        # special case for snp-query: add feature filter to get only SNPs with the named query seq
        if ($opt eq 'snp-query') {
          my $ff = $track->{'feat-filters'};
          $ff = $track->{'feat-filters'} = [] if (!defined($ff));
          push(@$ff, { 'tag' => $SNP_TBTP . $options_kv->{$opt} });
        }
        # special cases for filters on the SNP num_diffs attribute
        elsif ($opt eq 'snp-min-diffs') {
          my $ff = $track->{'feat-filters'};
          $ff = $track->{'feat-filters'} = [] if (!defined($ff));
          my $mv = $options_kv->{$opt};
          push(@$ff, { 'fn' => sub {
                         my($feat) = @_;
                         return 0 unless ($feat->primary_tag() eq 'SNP');
                         my @nd = $feat->get_tag_values($SNP_TP . 'num_diffs');
                         return ((scalar(@nd) == 1) && ($nd[0] >= $mv)) ? 1 : 0;
                       }});
        }
        elsif ($opt eq 'snp-max-diffs') {
          my $ff = $track->{'feat-filters'};
          $ff = $track->{'feat-filters'} = [] if (!defined($ff));
          my $mv = $options_kv->{$opt};
          push(@$ff, { 'fn' => sub {
                         my($feat) = @_;
                         return 0 unless ($feat->primary_tag() eq 'SNP');
                         my @nd = $feat->get_tag_values($SNP_TP . 'num_diffs');
                         return ((scalar(@nd) == 1) && ($nd[0] <= $mv)) ? 1 : 0;
                       }});
        }
      }
      delete $opts_unused->{$opt};
    }

    # TODO - move these special-case options (e.g., label-text for labels, plus the color functions
    # out of config and into the main Circleator and/or track code.  There's no reason it shouldn't
    # be possible to use these shortcuts from one of the other config file formats.

    # user-defined label
    if (defined($opts_unused->{'label-text'})) {
      # create label list with a single element
      my $label = {};
      foreach my $lbl_att ('text', 'position', 'text-anchor', 'font-style', 'font-family', 'repeat') {
        my $key = 'label-' . $lbl_att;
        my $val = $opts_unused->{$key};
        if (defined($val)) {
          # HACK
          if ($lbl_att eq 'text') {
            $val =~ s/\&nbsp\;/ /g;
            $val =~ s/\&equals\;/=/g;
            $val =~ s/\&comma\;/,/g;
          }
          $label->{$lbl_att} = $val;
          delete $opts_unused->{$key};
        }
      }
      $track->{'labels'} = [ $label ];
    }

    # user-defined feature (only one for now)
    if (defined($opts_unused->{'user-feat-fmin'}) || defined($opts_unused->{'user-feat-start'})) {
      # create feature list with a single element
      my $feat = {};
      foreach my $feat_att ('id', 'seq', 'start', 'end', 'fmin', 'fmax', 'strand', 'type') {
        my $key = 'user-feat-' . $feat_att;
        my $val = $opts_unused->{$key};
        if (defined($val)) {
          $feat->{$feat_att} = $val;
          delete $opts_unused->{$key};
        }
      }
      my $tfeats = $track->{'features'} = [];

      # user-feat-width creates _multiple_ features from fmin - fmax
      if (defined($opts_unused->{'user-feat-width'})) {
	  my $ufw = $opts_unused->{'user-feat-width'};
	  delete $opts_unused->{'user-feat-width'};
	  for (my $ffmin = $feat->{'fmin'}; $ffmin <= $feat->{'fmax'} - $ufw; $ffmin += $ufw) {
	      my %copy = %$feat;
	      $copy{'fmin'} = $ffmin;
	      my $ffmax = $ffmin + $ufw;
	      $ffmax = $feat->{'fmax'} if ($ffmax > $feat->{'fmax'});

	      $copy{'fmax'} = $ffmax;
	      push(@$tfeats, \%copy);
	  }
      } else {
	  push(@$tfeats, $feat);
      }
    }
    
    # Circleator::SeqFunction::BAMCoverage: populate bam-files array
    if (defined($opts_unused->{'bam-file'})) {
      my $bam_file = {};
      foreach my $bam_att ('file', 'seqid', 'seqregex') {
        my $key = 'bam-' . $bam_att;
        my $val = $opts_unused->{$key};
        if (defined($val)) {
          $bam_file->{$bam_att} = $val;
          delete $opts_unused->{$key};
        }
      }
      $track->{'bam-files'} = [$bam_file];
    }

    if (defined($opts_unused->{'loop-values'})) {
      my $lv = $opts_unused->{'loop-values'};
      my @lvs = split(/\|/, $lv);
      $track->{'loop-values'} = \@lvs;
      delete $opts_unused->{"loop-values"};
    }

    if (defined($opts_unused->{'circle-values'})) {
      my $cv = $opts_unused->{'circle-values'};
      my $cl = $opts_unused->{'circle-labels'};
      my $ca = $opts_unused->{'circle-aligns'};
      my @cval = split(/\|/, $cv);
      my @clbl = defined($cl) ? split(/\|/, $cl) : undef;
      my @caln = defined($ca) ? split(/\|/, $ca) : undef;
      my $ncv = scalar(@cval);
      my $circles = [];
      for (my $c = 0;$c < $ncv;++$c) {
        my $cv = $cval[$c];
        my $cl = $clbl[$c];
        my $ca = $caln[$c];
        push(@$circles, {'value' => $cv, 'label' => $cl, 'align' => $ca});
      }
      $track->{'circles'} = $circles;
      map { delete $opts_unused->{"circle-" . $_} } ('values', 'labels', 'aligns');
    }

    # TODO - allow specification of feature label and position for label tracks 
    # TODO - plotting user-defined features, should support same mechanism at least for single feature
    
    # print warning for any ignored fields
    foreach my $opt (keys %$opts_unused) {
      $logger->warn("option '$opt' at line $line->{'lnum'} is not supported by glyphs of type '$glyph' and has been ignored");
    }

    $track->{'lnum'} = $line->{'lnum'};
    push(@$tracks, $track);

    if ($type eq 'new') {
	my $list = $tracks_h->{$track->{'name'}};
	$list = $tracks_h->{$track->{'name'}} = [] if (!defined($list));
	push(@$list, $track);
    }
  }

  return {'tracks' => $tracks};
}

1;
