package Person;

use strict;
use warnings;

use Scalar::Util qw(blessed);

#create constructor
sub new {
  #new receives the string on the left side of the arrow operator in the call as the first parameter e.g Person->new becomes new("Person")
  my ($class, %args) = @_;
  #create anonymous hash reference to contain current object being instantiated
  my $self = {};
  #add parameter checking directly in constructor
  $self->{name} = $args{name} if defined $args{name} and $args{name} ne "";
  $self->{startDate} = $args{startDate} if defined $args{startDate} and blessed $args{startDate} and $args{startDate}->isa('DateTime');
  $self->{position} = $args{position} if defined $args{position} and blessed $args{position} and $args{position}->isa('JobRole');
  #link the instance to the class so Perl knows its class
  bless $self, $class;
  #hack to add email and username after blessing
  $self->{email} = createEmail($self);
  $self->{username} = generateUsername($self);
  #return object (which is basically a hash reference)
  return $self;
}

##########################
# Methods
##########################
sub name {
  #get params
  my ($self, $value) = @_;
  #if value is specified, act as setter
  if (@_ == 2) {
    $self->{name} = $value;
  }
  return $self->{name};
}

sub username {
  my $self = shift;

  return $self->{username} if defined $self->{username};
}

sub entryDate {
  #get params
  my ($self, $value) = @_;
  #if value is specified, act as setter
  if(@_ == 2) {
    die qq{Invalid start date supplied} if not blessed $value or not $value->isa('DateTime');
    $self->{startDate} = $value;
  }
  return $self->{startDate} if defined $self->{startDate};
}

sub email {
  my $self = shift;
  return $self->{email} if defined $self->{email};
}

sub department {
  my ($self, $value) = @_;

  if(@_ == 2) {
    $self->{position}->department($value);
  }
  return $self->{position}->department if defined $self->{position};
}

sub position {
  #get params
  my ($self, $value) = @_;
  #if value is specified, act as setter
  if(@_ == 2) {
    die qq{Invalid job position supplied} if not blessed $value or not $value->isa('JobRole');
    $self->{position} = $value;
  }
  elsif(@_ == 3) {
    die qq{Invalid job title supplied} if $_[1] eq "" or $_[2] eq "";
    $self->{position} = JobRole->new($_[1],$_[2]);
  }
  return $self->{position} if defined $self->{position};
}

##########################
# Helper functions
##########################
sub getNames {
  my $self = shift;
  my ($first, $middle, $last) = split(/ /,$self->{name});

  return ($first,$middle,$last);
}

sub createEmail {
  my $self = shift;
  my @arr = $self->getNames;
  my $email = lc($arr[0]).".".lc($arr[2])."\@silicon-mobility.com";

  return $email;
}

sub generateUsername {
  my $self = shift;
  my @arr = $self->getNames;
  my $uname = lc(substr($arr[0],0,1).$arr[2]);

  return $uname;
}

sub yearOfEntry {
  #get params
  my $self = shift;
  return $self->{startDate}->year if defined $self->{startDate};
}

sub info {
  my $self = shift;

  my $info = "Name: ".$self->name."\nUsername: ".$self->username."\nEmail: ".$self->email."\nEntry Date: ".$self->{startDate}->dmy('/')."\nPosition: ".$self->{position}->title."\n";

  return $info;
}

1;