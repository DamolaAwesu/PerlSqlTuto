#!/usr/bin/perl

# OOP Practice using Core Perl and Moose (later on)

use strict;
use warnings;
use v5.10;

use Person::Person;
use Person::JobRole;
use DateTime;
use Database;
use Const::Fast;
use Pod::Usage;
use Getopt::Long;

my $db;
##################################
# Menu Functions
##################################

sub addEmployee {
  #my $dbHandle = shift;
  my $localHash = {}; my $input = "";

  #Get name
  print "Full Name: ";
  chomp($input=<STDIN>);
  until ($input ne "") {
	  print "Full Name: ";
	  chomp($input=<STDIN>);
  }
  $localHash->{name} = $input;
  #Get phone number
  print "Phone No: ";
  chomp($input=<STDIN>);
  until ($input =~ m/^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$/) {
	  print "Phone No: ";
	  chomp($input=<STDIN>);
  }
  $localHash->{phone} = $input;
  #Get position
  print "Position: ";
  chomp($input=<STDIN>);
  until ($input ne "") {
	  print "Position: ";
	  chomp($input=<STDIN>);
  }
  #Get department
  print "Choose a department from the list:\n";
  JobRole::printDepts();
  print "\nDepartment: ";
  chomp(my $input2=<STDIN>);
  until ($input2 ne "") {
	  print "Department: ";
	  chomp($input2=<STDIN>);
  }
  $localHash->{position} = JobRole->new(title => $input, dept => $input2);
  #Get start date
  #Get position
  print "Enter date: ";
	chomp($input=<STDIN>);
	until($input =~ /^(0[1-9]|[12][0-9]|30|31)\/(10|11|12|0[1-9])\/[0-9]{4}$/) {
		print "Date format seems to be incorrect! Enter date in DD/MM/YYYY format\n";
		print "Enter date: ";
		chomp($input=<STDIN>);
	}
  my @date = split(/\//,$input);
  $localHash->{startDate} = DateTime->new(year => $date[2], month => $date[1], day => $date[0]);

  #create new employee instance and add to database immediately
  my $employee = Person->new(name => $localHash->{name}, startDate => $localHash->{startDate}, position => $localHash->{position}, phone => $localHash->{phone});
  Database::insertInTable($db, "Employees", Person::toSchemaDB($employee));
}

sub getEmployeeInfo {
  my $retVal = 0; 
  my $refHash = {};
  my $searchToken = "";
  
  print "Username: ";
  chomp($searchToken=<STDIN>);
  until ($searchToken ne "") {
    print "Username: ";
    chomp($searchToken=<STDIN>);
  }

  #get record from database
  ($retVal, $refHash) = Database::getSingleRecord($db, "Employees", "username", $searchToken);
  #check record exists
  if ($retVal > 0) {
    print "No employee with username $searchToken found!\n";
  }
  else {
    #instantiate new employee object from $refHash using Person::fromSchemaDB and then use Person::info to display employee info
    my $employee = Person::fromSchemaDB($refHash);
    print $employee->info;
  }

}

sub listEmployees {
  my $retVal = 0;
  my $refHash = {};

  ($retVal,$refHash) = Database::getAllRecords($db, "Employees");
  if($retVal > 0) {
    print "No employee found!\n";
  }
  else {
    while (my $row = $refHash->fetchrow_hashref) {
      #get new employee object from $row using Person::fromSchemaDB and then use Person::info to display each employee info
      my $employee = Person::fromSchemaDB($row);
      print $employee->info;
    }
  }
}

sub deleteEmployee {
  my $retVal = 0;
  my $input = "";

  #Get name
  print "Username: ";
  chomp($input=<STDIN>);
  until ($input ne "") {
	  print "Username: ";
	  chomp($input=<STDIN>);
  }

  $retVal = Database::deleteRecord($db, "Employees", "username", $input);
  if($retVal > 0) {
    print "Error deleting employee record!\n";
  }
  else {
    print "Employee record successfully deleted\n";
  }

}

sub deleteAllEmployees {
  my $retVal = 0;
  
  $retVal = Database::deleteTable($db, "Employees","T");
  if($retVal > 0) {
    print "Error deleting all employee records!\n";
  }
  else {
    print "All employee records successfully deleted\n";
  }

}

sub updateEmployee {

}


sub printMenu {
  print "-" x20, "\n\tMenu\n", "-" x20;
	print "\n1. Add a new employee", "\n2. Remove existing employee", "\n3. Update employee info";
	print "\n4. Display employee info", "\n5. Display all employees", "\n6. Delete all employees' info";
	print "\n#. Exit program\n";
}


##########################################################
# Main Application
##########################################################

#get arguments passed from the command line
my %getopt_ph =
(
  'help|h'        => sub  {
                            pod2usage(1);
                            exit 0;
                          },
);
if (not Getopt::Long::GetOptions(%getopt_ph)){
  print "\nERROR: while parsing command line\n";
  pod2usage(1);
  exit -1;
}

# Database Initialization
my $dbfile = "simo.db";
const my @employeeStruct => (
  { username    => ['VARCHAR(25)', q(PRIMARY KEY)]},
  { firstname   => ['VARCHAR(100)', q(NOT NULL)]},
  { middlename  => ['VARCHAR(100)']},
  { lastname    => ['VARCHAR(100)', q(NOT NULL)]},
  { email       => ['VARCHAR(100)', 'UNIQUE', q(NOT NULL)]},
  { phoneNo     => ['VARCHAR(20)', 'UNIQUE']},
  { position    => ['VARCHAR(100)', q(NOT NULL)]},
  { department  => ['VARCHAR(25)', q(NOT NULL)]},
  { date        => ['VARCHAR(10)', q(NOT NULL)]}
);

const my @salaryStruct => (
  { username    => ['VARCHAR(25)', q(NOT NULL)]},
  { firstname   => ['VARCHAR(100)', q(NOT NULL)]},
  { lastname    => ['VARCHAR(100)', q(NOT NULL)]},
  { position    => ['VARCHAR(100)', q(NOT NULL)]},
  { salary      => ['REAL', q(NOT NULL)]},
  { acctNo      => ['VARCHAR(100)', q(UNIQUE)]}
);

$db = Database::connect($dbfile, "", "");
Database::createTable($db, "Employees",\@employeeStruct);
Database::createTable($db, "SalaryInfo",\@salaryStruct);

my $choice = "";
while($choice ne "#")
{
	#system "cls";
	printMenu();
	print "Please enter your menu option: ";
	chomp($choice=<STDIN>);
	given($choice) {
		when ("1") { &addEmployee; }
		when ("2") { &deleteEmployee; }
		when ("3") { &updateEmployee; }
		when ("4") { &getEmployeeInfo; }
		when ("5") { &listEmployees; }
    when ("6") { &deleteAllEmployees; }
		when ("#") { last; }
		default { print STDERR "Invalid choice\n"; }
	}
}

Database::disconnect($db);