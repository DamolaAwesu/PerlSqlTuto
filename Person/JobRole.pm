package JobRole;

use strict;
use warnings;

#use Utilities::Enums qw(deptEnum);
use List::MoreUtils qw(any);
use Const::Fast;


const my %deptHash    => (SSW => "RD", HW => "RD", TFW => "RD", SAF => "RD", SEC => "RD",
                          PRD => "OP", PM => "OP", PU => "SP", FIN => "SP", HR => "SP",
                          QMS => "OP", IT => "SP", CxO => "MSSD", MKT => "MS", SALES => "MS"
                          );

sub new {
  #get params
  my ($class, %args) = @_;

  my $self = {};

  #arg checking
  $self->{title} = $args{title} if defined $args{title} and $args{title} ne "";
  $self->{dept} = $args{dept} if defined $args{dept} and $args{dept} ne "" and any {$args{dept}} keys %deptHash;
  $self->{process} = $deptHash{$args{dept}} if defined $args{dept} and $args{dept} ne "" and any {$args{dept}} keys %deptHash;
  #link the instance to the class so Perl knows its class
  bless $self, $class;
  #return object (which is basically a hash reference)
  return $self;
}

sub department {
  my ($self, $value) = @_;

  if(@_ == 2) {
    die qq{Invalid department supplied} if not any {$value} @{keys %deptHash};
    $self->{dept} = $value;
    $self->{process} = $deptHash{$value}
  }
  return $self->{dept} if defined $self->{dept};
}

sub title {
  my ($self, $value) = @_;

  if(@_ == 2) {
    die qq{Invalid title supplied} if $value eq "";
    $self->{title} = $value;
  }
  return $self->{title} if defined $self->{title};
}

sub process {
  my $self = shift;
  return $self->{process} if defined $self->{process};
}



1;