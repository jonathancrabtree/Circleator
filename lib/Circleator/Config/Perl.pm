package Circleator::Config::Perl;

use Circleator::Config::Config;

sub new {
  my($invocant, $logger, $params) = @_;
  my $class = ref($invocant) || $invocant;
  my $self = 
    {
     'logger' => $logger,
    };
  return bless $self, $class;
}

sub read_config_file {
  my($self, $file) = @_;
  my $logger = $self->{'logger'};

  # EXTREMELY UNSAFE HACK:
  my $fc = `cat $file`;
  my $tracks = eval($fc);
  warn $@ if $@;

  return {'tracks' => $tracks};
}

1;
