package JobRole;
$JobRole::VERSION = "1.0.0";

use strict;
use warnings;

use List::MoreUtils qw(any);
use Const::Fast;

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA = qw(Exporter);

@EXPORT = qw(printDepts);

=head1 NAME

JobRole - Class for specifying and handling job positions in SiliconMobility

=head1 SYNOPSIS

  $self                 = new(%attr);

  $retVal               = $self->department();
  $retVal               = $self->department($value);

  $retVal               = $self->title();
  $retVal               = $self->title($value);

  $retVal               = $self->process();

  printDepts();

I<This synopsis lists major methods and parameters.>

=cut

=head1 DESCRIPTION

The Database package is a simple wrapper around the DBI module available on CPAN corresponding to needs in my OOP Perl project

=head2 Conventions

  $self         JobRole object

  $retVal       General return value

  %attr         Hash containing attributes of the object

  $value        single attribute value

=head2 Usage

To use JobRole,

first you need to load the JobRole package:

  use Person::JobRole;

C<use strict;> is not required but is strongly recommended.

Then you need to create a L<new|/new> JobRole object:

  $self = JobRole->new(%attr);

=head2 Class Methods

This section provides a description of all methods available for use

=cut


const my %deptHash    => (SSW => "RD", HW => "RD", TFW => "RD", SAF => "RD", SEC => "RD",
                          PRD => "OP", PM => "OP", PU => "SP", FIN => "SP", HR => "SP",
                          QMS => "OP", IT => "SP", CxO => "MSSD", MKT => "MS", SALES => "MS"
                          );

=head3 new

  Parameters  : $class : JobRole class (passed in automatically by Perl)
                %attr  : hash containing job details

  Return      : $self   : JobRole object

  Description : JobRole class constructor - create new JobRole object

=cut

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


=head3 department

  Parameters  : $self   : JobRole object
                %value  : optional value to set

  Return      : $value  : department string

  Description : get/set department

=cut

sub department {
  my ($self, $value) = @_;

  if(@_ == 2) {
    die qq{Invalid department supplied} if not any {$value} @{keys %deptHash};
    $self->{dept} = $value;
    $self->{process} = $deptHash{$value}
  }
  return $self->{dept} if defined $self->{dept};
}

=head3 title

  Parameters  : $self   : JobRole object
                %value  : optional value to set

  Return      : $value  : job title string

  Description : get/set job title

=cut

sub title {
  my ($self, $value) = @_;

  if(@_ == 2) {
    die qq{Invalid title supplied} if $value eq "";
    $self->{title} = $value;
  }
  return $self->{title} if defined $self->{title};
}

=head3 process

  Parameters  : $self   : JobRole object

  Return      : $value  : process string

  Description : get process the position belongs to

=cut

sub process {
  my $self = shift;
  return $self->{process} if defined $self->{process};
}

=head2 Common Functions

=head3 printDepts

  Parameters  : None

  Return      : None

  Description : print all possible department options

=cut

sub printDepts {
  for my $entry (keys(%deptHash)) {
    print "$entry ";
  }
}

1;

__END__

=head1 SUPPORT

This module is managed in an open Github repository, L<github.com/DamolaAwesu/PerlSqlTuto|https://github.com/DamolaAwesu/PerlSqlTuto/blob/main/Person/JobRole.pm>.

=head1 COPYRIGHT

Copyright (c) 2023 Damola Awesu

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself

=head1 AUTHOR(S)

JobRole was created and is maintained by Damola Awesu, reachable at B<dammyawesu@gmail.com>

=cut