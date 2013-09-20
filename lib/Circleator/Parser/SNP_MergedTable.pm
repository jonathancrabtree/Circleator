package Circleator::Parser::SNP_MergedTable;

use strict;
use FileHandle;
use Circleator::Parser::SNP;
our @ISA = qw(Circleator::Parser::SNP);

# ------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------
my $COLUMNS = 
  [
   { 'name' => 'molecule' },
   { 'name' => 'refpos' },
   { 'name' => 'syn', 'regex' => '^syn\??$' },
   { 'name' => 'refbase' },

   # variable section 1:
   # one column for each genome/non-reference sequence
   { 'name' => undef, 'variable_section' => 1, 'is_target_base' => 1,
     'header_fn' => 
     sub {
       my($parser, $header, $vindex) = @_;
       # store names of non-reference genomes/sequences
       $parser->add_query_name($header);
     }},

   { 'name' => 'gene_name' },
   { 'name' => 'product' },
   { 'name' => 'gene_start' },
   { 'name' => 'gene_stop' },
   { 'name' => 'gene_length' },
   { 'name' => 'snps_per_gene' },
   { 'name' => 'pos_in_gene' },
   { 'name' => 'ref_codon' },
   { 'name' => 'ref_aa' },
   { 'name' => 'snp_codon', 'regex' => '^(snp|query)_codon$' },
   { 'name' => 'snp_aa', 'regex' => '^(snp|query)_aa$' },

   # variable section 2
   # one column for each genome/non-reference sequence
   { 'name' => undef, 'variable_section' => 1, 
     'header_fn' => 
     sub {
       my($parser, $header, $vindex) = @_;
       # check names against those in variable section #1
       my $qname = $parser->get_query_name($vindex);
       my $exph_re = "num_hits:" . '\s*' . $qname;
       $exph_re =~ s/([?])/\\$1/g;
       $parser->{'logger'}->logdie("unexpected header column: expected to see $exph_re but found $header instead") unless ($header =~ /$exph_re/);
     }},

   { 'name' => 'properties' },
#   { 'name' => 'other' },
   { 'name' => 'Num_No_Hit' },
   { 'name' => 'Homoplasy' },
  ];

my $NC = scalar(@$COLUMNS);

# ------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------
sub new {
    my($invocant, $logger, $params) = @_;
    my $self = {};
    $self->{'logger'} = $logger;
    $self->{'config'} = $params->{'config'};
    die "logger must be defined" unless $logger;
    my $class = ref($invocant) || $invocant;
    bless $self, $class;
    return $self;
}

# ------------------------------------------------------------------
# Static (non-instance) methods
# ------------------------------------------------------------------

# TBD

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

sub add_query_name {
  my($self, $qname) = @_;
  my $query_names = $self->{'query_names'};
  $query_names = $self->{'query_names'} = [] if (!defined($query_names));
  push(@$query_names, $qname);
  # check query names for uniqueness?
  my $qnh = $self->{'query_names_hash'};
  $qnh = $self->{'query_names_hash'} = {} if (!defined($qnh));
  $self->{'logger'}->logdie("duplicate query name '$qname'") if (defined($qnh->{$qname}));
}

sub get_query_name {
  my($self, $qindex) = @_;
  my $query_names = $self->{'query_names'};
  my $nqn = scalar(@$query_names);
  return ($qindex < $nqn) ? $query_names->[$qindex]: undef;
}

sub get_query_names {
  my($self) = @_;
  my $query_names = $self->{'query_names'};
  my @copy = @$query_names;
  return \@copy;
}

sub get_num_query_names {
  my($self) = @_;
  my $query_names = $self->{'query_names'};
  return scalar(@$query_names);
}

sub parse_file {
  my($self, $file) = @_;
  die "couldn't find merged table SNP file $file" if ((!-e $file) || (!-r $file));
  my $entries = [];
  # TODO - standardize on how this is done; does the parser add the features to the original seq (as in BSR.pm) or does the main program do that (as for the existing SNP parsers)?
  my $ref_seqs = {};
  my $snps = {};

  my $fh = FileHandle->new();
  $fh->open($file)|| die "unable to read from merged table SNP file $file";
  my $lnum = 0;

  # parse header line
  my $header_line = <$fh>;
  ++$lnum;
  chomp($header_line);
  my @hf = split(/\t/, $header_line);
  my $n_cols = scalar(@hf);
  $self->{'logger'}->debug("header line of $file has $n_cols columns") if ($self->{'config'}->{'debug_opts'}->{'input'});

  # match columns in the file with the template defined in $COLUMNS
  my $file_cols = [];

  # index into the actual header column values (NOT $COLUMNS, which specifies how to parse the actual values)
  my $cnum = 0;

  for (my $c = 0;$c < $NC;++$c) {
    my $col_spec = $COLUMNS->[$c];
    my($name, $col_re, $vs, $header_fn, $is_target_base) = map {$col_spec->{$_}} ('name', 'regex', 'variable_section', 'header_fn', 'is_target_base');
    $col_re = '^' . $name . '$' if (!defined($col_re));
    # the column specifier after the variable section is used to determine when the variable section ends
    if ($vs) {
      my($next_name, $next_vs) = (undef, undef);
      if ($c < ($NC - 1)) {
        my $next_col_spec = $COLUMNS->[$c+1];
        ($next_name, $next_vs) = map {$next_col_spec->{$_}} ('name', 'variable_section');
        if (!defined($next_name) || $next_vs) {
          $self->{'logger'}->logdie("variable section at index $c must be followed by a named/non-variable column");
        }
      }
      my $vindex = 0;
      # process all variable columns in this block
      while(($cnum < $n_cols) && (!defined($next_name) || ($next_name ne $hf[$cnum]))) {
        # process $hf[$cnum] using function associated with colspec?
        push(@$file_cols, { 'name' => $hf[$cnum], 'is_target_base' => $is_target_base });
        &$header_fn($self, $hf[$cnum], $vindex++) if (defined($header_fn));
        ++$cnum;
      }
      next;
    } 

    # not in variable section -process $hf[$cnum++]
    my $col_name = $hf[$cnum];
    # check that col_name is as expected
    $self->{'logger'}->logdie("name of column $cnum ($col_name) does not match expected regex ($col_re)") unless ($col_name =~ /$col_re/);
    push(@$file_cols, { 'name' => $name, 'is_target_base' => $is_target_base });
    &$header_fn($self, $hf[$cnum]) if (defined($header_fn));
    ++$cnum;
 }

  # check that all of the input has been consumed
  my $nfc = scalar(@$file_cols);
  $self->{'logger'}->logdie("failed to parse all columns from header line of $file: parsed $cnum of $n_cols") unless ($cnum == $n_cols); 
  $self->{'logger'}->logdie("internal error: parsed $nfc column(s), should have $n_cols") unless ($nfc == $n_cols); 
  my $nq = $self->get_num_query_names();

  if ($self->{'config'}->{'debug_opts'}->{'input'}) {
    $self->{'logger'}->debug("read $nq query name(s) from $file:");
    my $qnames = $self->get_query_names();
    map { $self->{'logger'}->debug("  " . $_); } @$qnames;
  }

  # parse the actual SNP data
  my $entries = [];
  my $ref_seqs = {};
  # SNPs indexed by reference position: used to check for duplicates
  my $snps = {};
  # prefixes used to define unique BioPerl attribute tags for SNP-related attributes
  my $tp = $self->tag_prefix();
  my $tbtp = $self->target_base_tag_prefix();

  while (my $line = <$fh>) {
    chomp($line);
    ++$lnum;
    my @f = split(/\t/, $line);
    my $nf = scalar(@f);
    $self->{'logger'}->logdie("wrong number of columns at line $lnum of $file: expected $n_cols but found $nf") if ($nf != $n_cols);
    # store SNP-associated data (molecule, refpos, syn, etc.)
    my $snp_data = {};
    for (my $c = 0;$c < $n_cols;++$c) {
      my $fc = $file_cols->[$c];
      my($name, $is_target_base) = map {$fc->{$_}} ('name', 'is_target_base');
      if ($is_target_base) {
        my $tbv = $f[$c];
        my @tba = split(/\s*[\/\,]\s*/, $tbv);
        $snp_data->{$tbtp . $name} = \@tba;
      } else {
        $snp_data->{$tp . $name} = $f[$c];
      }
    }

    # standardize SNP encoding 
    $snp_data->{$tp . 'syn_nonsyn'} = $snp_data->{$tp . 'syn'};
    $snp_data->{$tp . 'ref_base'} = $snp_data->{$tp . 'refbase'};
    
    # get or create ref seq
    my $ref_seq = $ref_seqs->{$snp_data->{$tp . 'molecule'}};
    if (!defined($ref_seq)) {
      $ref_seq = $ref_seqs->{$snp_data->{$tp . 'molecule'}} = Bio::Seq::RichSeq->new(-seq => '', -id => $snp_data->{$tp . 'molecule'}, -alphabet => 'dna');
      push(@$entries, [$ref_seq, undef, undef]);
    }
    my $start = $snp_data->{$tp . 'refpos'};
    my $end = $start + length($snp_data->{$tp . 'refbase'}) - 1;

    # should be at most one line per reference position
    my $snp_key = join(':', $snp_data->{$tp .'molecule'}, $snp_data->{$tp . 'refpos'});
    my $esnp = $snps->{$snp_key};
    $self->{'logger'}->logdie("duplicate reference location ($snp_key) at line $lnum of $file") if (defined($esnp));

    # new SNP feature
    my $snp_feat = new Bio::SeqFeature::Generic(-start => $start, -end => $end, -strand => 1, -primary => 'SNP', -display_name => 'SNP.' . $start, -tag => $snp_data);
    if (!$ref_seq->add_SeqFeature($snp_feat)) {
      $self->{'logger'}->logdie("failed to add SNP feature to corresponding reference sequence for $snp_data->{'molecule'}");
    }
    $snps->{$snp_key} = $snp_feat;
  }

  my @refseqs = map {$_->[0]} @$entries;
  $self->process_snps(\@refseqs);
  return $entries;
}

1;
