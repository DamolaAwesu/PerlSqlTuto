package Person;

use strict;
use warnings;

use Data::Dumper;
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
  $self->{phone} = $args{phone} if defined $args{phone} and $args{phone} =~ m/^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$/;
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

sub phone {
  my ($self, $value) = @_;

  if(@_ == 2) {
    die qq{Invalid phone number provided} if $value !~ m/^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$/;
    $self->{phone} = $value;
  }
  return $self->{phone} if defined $self->{phone};
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

sub department {
  my ($self, $value) = @_;

  if(@_ == 2) {
    $self->{position}->department($value);
  }
  return $self->{position}->department if defined $self->{position};
}

sub title {
  my ($self, $value) = @_;

  if(@_ == 2) {
    $self->{position}->title($value);
  }
  return $self->{position}->title if defined $self->{position}; 
}

##########################
# Helper functions
##########################
sub getNames {
  my ($self, $option) = @_;
  my @arr = split(/ /,$self->{name});
  my $first = ""; my $middle = ""; my $last = "";
  if(@arr == 2) {
    ($first, $last) = @arr;
  } else { 
    ($first, $middle, $last) = @arr;
  }
  return ($first,$middle,$last) if @_ == 2;
  return ($first, $last);
}

sub createEmail {
  my $self = shift;
  my ($first, $last) = $self->getNames;
  my $email = lc($first.".".$last."\@silicon-mobility.com");

  return $email;
}

sub generateUsername {
  my $self = shift;
  my ($first, $last) = $self->getNames;
  my $uname = lc(substr($first,0,1).$last);

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

sub update {
  my ($self, $updHash) = @_;
  return if @_ != 2 or not blessed $self;
  my @keys = keys(%{$updHash});

  for my $entry (@keys) {
    $self->{$entry} = $updHash->{$entry} if exists $self->{$entry};
  }
  #TODO: complete by adding link to Database::updateRecord function - maybe create a wrapper at app level that will call this function and the DB api also
  # Penser à faire le même chose pour les functions comme ça - new (addEmployee), deleteRecord (deleteEmployee), deleteTable (deleteOrg), createTable(createOrg) etc
}

sub toSchemaDB {
  my $self = shift;

  my $dbHash = {}; my ($first, $middle, $last) = $self->getNames("all");

  $dbHash->{username} = $self->username;
  $dbHash->{firstname} = $first;
  $dbHash->{middlename} = $middle if $middle ne ""; $dbHash->{lastname} = $last;
  $dbHash->{phoneNo} = $self->phone if defined $self->phone and $self->phone ne "";
  $dbHash->{position} = $self->title;
  $dbHash->{email} = $self->email;
  $dbHash->{department} = $self->department;
  $dbHash->{date} = $self->entryDate->dmy('/');

  return $dbHash;

}

1;