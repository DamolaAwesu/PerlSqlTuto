package Person;
our $VERSION = 'v1.0.0';

use strict;
use warnings;

use Data::Dumper;
use Scalar::Util qw(blessed);

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA = qw(Exporter);

@EXPORT = qw(fromSchemaDB toSchemaDB);


=head1 NAME

Person - Class for specifying and creating employees

=head1 SYNOPSIS

  Constructor
    $self                 = new(%attr);

  Methods
    $name               = $self->name();
    $name               = $self->name($value);

    $username           = $self->username();

    $phone              = $self->phone();
    $phone              = $self->phone($value);

    $entryDate          = $self->entryDate();
    $entryDate          = $self->entryDate($value);

    $self->info();
        
  Common Functions
    $self               = fromSchemaDB($dbHash);
    $dbHash             = toSchemaDB($self);

I<This synopsis lists major methods and parameters.>

=cut

=head1 DESCRIPTION

The Person class is a simple class for describing employees in my OOP Perl project

=head2 Conventions

  $self         Person object

  $retVal       General return value

  %attr         Hash containing attributes of the object

  $value        single attribute value

=head2 Usage

To use Person,

first you need to load the Person package:

  C<use Person::Person>;

C<use strict;> is not required but is strongly recommended.

Then you need to create a L<new|/new> Person object:

  $self = Person->new(%attr);

=head2 Class Methods

This section provides a description of all methods available for use

=cut

=head3 new

  Parameters  : $class : Person class (passed in automatically by Perl)
                %attr  : hash containing person details

  Return      : $self   : new Person object

  Description : Person class constructor - create new Person object

=cut

sub new {
  #new receives the string on the left side of the arrow operator in the call as the first parameter e.g Person->new becomes new("Person")
  my ($class, %attr) = @_;
  #create anonymous hash reference to contain current object being instantiated
  my $self = {};
  #add parameter checking directly in constructor
  $self->{name} = $attr{name} if defined $attr{name} and $attr{name} ne "";
  $self->{email} = createEmail($attr{name}) if defined $attr{name} and $attr{name} ne "";
  $self->{username} = generateUsername($attr{name}) if defined $attr{name} and $attr{name} ne "";
  $self->{startDate} = $attr{startDate} if defined $attr{startDate} and blessed $attr{startDate} and $attr{startDate}->isa('DateTime');
  $self->{position} = $attr{position} if defined $attr{position} and blessed $attr{position} and $attr{position}->isa('JobRole');
  $self->{phone} = $attr{phone} if defined $attr{phone} and $attr{phone} =~ m/^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$/;
  $self->{salary} = $attr{salary} if defined $attr{salary};
  #link the instance to the class so Perl knows its class
  bless $self, $class;
  #hack to add email and username after blessing
  
  #return object (which is basically a hash reference)
  return $self;
}

=head3 name

  Parameters  : $self   : Person object
                $value  : [optional] name string

  Return      : $name   : person's name

  Description : get/set name of person

=cut

sub name {
  #get params
  my ($self, $value) = @_;
  #if value is specified, act as setter
  if (@_ == 2) {
    $self->{name} = $value;
    $self->{username} = generateUsername($self->name) if $self->username ne generateUsername($self->name) or $self->username eq "";
    $self->{email} = createEmail($self->name) if $self->email ne createEmail($self->name) or $self->email eq "";
  }
  return $self->{name};
}

=head3 username

  Parameters  : $self   : Person object

  Return      : $uname   : person's username

  Description : get username of person

=cut

sub username {
  my $self = shift;

  return $self->{username} if defined $self->{username};
}

=head3 entryDate

  Parameters  : $self   : Person object
                $value  : [optional] DateTime object

  Return      : $name   : person's start date

  Description : get/set start date of person

=cut

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

=head3 email

  Parameters  : $self   : Person object

  Return      : $email  : person's email address

  Description : get email address of person

=cut

sub email {
  my $self = shift;
  return $self->{email} if defined $self->{email};
}

=head3 phone

  Parameters  : $self   : Person object
                $value  : [optional] phone number

  Return      : $phone  : person's phone number

  Description : get/set phone number of person

=cut

sub phone {
  my ($self, $value) = @_;

  if(@_ == 2) {
    die qq{Invalid phone number provided} if $value !~ m/^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$/;
    $self->{phone} = $value;
  }
  return $self->{phone} if defined $self->{phone};
}

=head3 position

  Parameters  : $self       : Person object
                $value      : [optional] JobRole object

  Return      : $position   : JobRole object

  Description : get/set job role of person

=cut

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

=head3 department

  Parameters  : $self         : Person object
                $value        : [optional] department string

  Return      : $department   : person's department

  Description : get/set department of person

=cut

sub department {
  my ($self, $value) = @_;

  if(@_ == 2) {
    $self->{position}->department($value);
  }
  return $self->{position}->department if defined $self->{position};
}

=head3 title

  Parameters  : $self   : Person object
                $value  : [optional] job title string

  Return      : $title  : person's job title

  Description : get/set title of person

=cut

sub title {
  my ($self, $value) = @_;

  if(@_ == 2) {
    $self->{position}->title($value);
  }
  return $self->{position}->title if defined $self->{position}; 
}

=head3 update

  Parameters  : $self     : Person object
                $updHash  : reference to hash containing attributes to update

  Return      : None

  Description : update attributes of person (might be deprecated later)

=cut

sub update {
  my ($self, $updHash) = @_;
  return if @_ != 2 or not blessed $self;
  my @keys = keys(%{$updHash});

  for my $entry (@keys) {
    $self->{$entry} = $updHash->{$entry} if exists $self->{$entry};
  }
}

=head3 yearOfEntry

  Parameters  : $self   : Person object

  Return      : $year   : year string

  Description : get start year of person

=cut

sub yearOfEntry {
  #get params
  my $self = shift;
  return $self->{startDate}->year if defined $self->{startDate};
}

=head3 info

  Parameters  : $self   : Person object

  Return      : $info   : contact detail string

  Description : get person basic info

=cut

sub info {
  my $self = shift;

  my $info = "Name: ".$self->name."\nUsername: ".$self->username."\nEmail: ".$self->email."\nEntry Date: ".$self->entryDate->dmy('/')."\nPosition: ".$self->position->title."\n";

  return $info;
}

=head2 Internal Functions

These functions are used to process data and generate some attributes of the Person object that are not directly settable

=cut

=head3 getNames

  Parameters  : $name     : name string
                $option   : [optional] option to choose if middle name is returned also

  Return      : $first    : person's first name
                $last     : person's last name
                $middle   : [optional] person's middle name

  Description : split name of person into first, middle and last

=cut

sub getNames {
  my ($name, $option) = @_;
  my @arr = split(/ /,$name);
  my $first = ""; my $middle = ""; my $last = "";
  if(@arr == 2) {
    ($first, $last) = @arr;
  } else { 
    ($first, $middle, $last) = @arr;
  }
  return ($first,$middle,$last) if @_ == 2;
  return ($first, $last);
}

=head3 createEmail

  Parameters  : $fullName   : Person object

  Return      : $email      : generated email address

  Description : create email for person

=cut

sub createEmail {
  my $fullName = shift;
  my ($first, $last) = getNames($fullName);
  my $email = lc($first.".".$last."\@silicon-mobility.com");

  return $email;
}

=head3 generateUsername

  Parameters  : $fullName   : Person object

  Return      : $uname      : generated username

  Description : create email for person

=cut

sub generateUsername {
  my $fullName = shift;
  my ($first, $last) = getNames($fullName);
  my $uname = lc(substr($first,0,1).$last);

  return $uname;
}

=head2 Common Functions

These functions are used to interact with the database package

=cut

=head3 fromSchemaDB

  Parameters  : $dbHash     : reference to a hash containing data from database

  Return      : $employee   : new Person object

  Description : convert database record into Person object

=cut

sub fromSchemaDB($) {
  my $dbHash = shift;
  my $employee = Person->new;

  $employee->{username} = $dbHash->{username};
  #get full name
  $employee->{name} = $dbHash->{firstname}." " if defined $dbHash->{firstname};
  $employee->{name} .= $dbHash->{middlename}." " if defined $dbHash->{middlename}; 
  $employee->{name} .= $dbHash->{lastname} if defined $dbHash->{lastname};
  #get phone, position, email
  $employee->{phone} = $dbHash->{phoneNo} if defined $dbHash->{phoneNo};
  $employee->{position} = JobRole->new(title => $dbHash->{position}, dept => $dbHash->{department}) if defined $dbHash->{position} and defined $dbHash->{department};
  $employee->{email} = $dbHash->{email};
  #get date
  my @date = split(/\//,$dbHash->{date}) if defined $dbHash->{date};
  $employee->{startDate} = DateTime->new(year => $date[2], month => $date[1], day => $date[0]);

  return $employee;
}

=head3 toSchemaDB

  Parameters  : $employee : Person object

  Return      : $dbHash   : reference to hash containg data to be inserted into database

  Description : convert Person object into database record

=cut

sub toSchemaDB {
  my $self = shift;

  my $dbHash = {}; my ($first, $middle, $last) = getNames($self->name, "all");

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

__END__

=head1 SUPPORT

This module is managed in an open Github repository, L<github.com/DamolaAwesu/PerlSqlTuto|https://github.com/DamolaAwesu/PerlSqlTuto/blob/main/Person/Person.pm>.

=head1 COPYRIGHT

Copyright (c) 2023 Damola Awesu

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself

=head1 AUTHOR(S)

Person was created and is maintained by Damola Awesu, reachable at B<dammyawesu@gmail.com>

=cut