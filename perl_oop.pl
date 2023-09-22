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

my $dbfile = "simo.db";
 
# ...

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

my $db = Database::connectDB($dbfile, "", "");
Database::createTable($db, "Employees",\@employeeStruct);

Database::createTable($db, "SalaryInfo",\@salaryStruct);

#instantiate object
my $employee = Person->new(name => "Adedamola Adedeji Awesu", startDate => DateTime->new(year => 2021, month => 2, day => 8), position => JobRole->new(title => "SW Engineer", dept => "SSW"), phone => "0774222989");
my $employee2 = Person->new(name => "Ousseynou Adama Ndiaye", startDate => DateTime->new(year => 2021, month => 3, day => 2), position => JobRole->new(title => "SW Engineer", dept => "SSW"));
my $employee3 = Person->new(name => "Vinay Maruti Garade", startDate => DateTime->new(year => 2021, month => 2, day => 8), position => JobRole->new(title => "SW Engineer", dept => "SSW"));


Database::insertInTable($db, "Employees", $employee->toSchemaDB());
Database::insertInTable($db, "Employees", $employee2->toSchemaDB());
Database::insertInTable($db, "Employees", $employee3->toSchemaDB());

$employee->update({name => "Adedamola Adewale Awesu", phone => "+33774222989"});

Database::disconnectDB($db);