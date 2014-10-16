package Circleator::Parser::SNP_CLC_Find_Variations;

use strict;
use FileHandle;
use Circleator::Parser::SNP;
our @ISA = qw(Circleator::Parser::SNP);

# ------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------

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

# ------------------------------------------------------------------
# Instance methods
# ------------------------------------------------------------------

# Read a line from $fh, match it against the specified regex, and return the first
# match group.
sub read_line {
    my($self, $file, $fh, $lnum, $regex) = @_;
    my $match = undef;
    my $line = <$fh>;
    ++$$lnum;
    if ($line =~ /$regex/) {
	$match = $1;
    } else {
	$self->{'logger'}->logdie("line $lnum of $file was expected to match the regex '$regex' and it does not");
    }
    return $match;
}

sub parse_file {
  my($self, $file, $snp_ref) = @_;
  $self->{'logger'}->logdie("could find clc_find_variants file $file") if ((!-e $file) || (!-r $file));

  # DEBUG
  print STDERR "parsing clc_find_variants file $file\n";

  my $fh = FileHandle->new();
  $fh->open($file)|| $self->{'logger'}->logdie("unable to read from clc_find_variants file $file");
  my $lnum = 0;

  # blank line
  $self->read_line($file, $fh, \$lnum, '^\s*$');
  # defline of the reference sequence
  $self->read_line($file, $fh, \$lnum, '^\S+.*$');
  # blank line
  $self->read_line($file, $fh, \$lnum, '^\s*$');

  # all remaining lines should be variants
  while (my $line = <$fh>) {
      ++$lnum;
      last if ($line =~ /^\s*$/);
      
      # TODO - parse variant info.
      print STDERR "read line '$line'";
  }

  # allow blank lines at the end of the file
  while (my $line = <$fh>) {
      ++$lnum;
      if ($line !~ /^\s*$/) {
	  $self->{'logger'}->logdie("line $lnum of $file was expected to be blank and is not");
      }
  }

  $fh->close();

  # TODO
}

1;
