#!/usr/bin/perl

# OOP Practice using Core Perl and Moose (later on)

use strict;
use warnings;
use v5.10;

use Person::Person;
use Person::JobRole;
use DateTime;
use Database;

my $dbfile = "simo.db";
 
# ...

my @employeeStruct = (
  { id          => ['NUMERIC','UNIQUE']},
  { username    => ['VARCHAR(25)', q(PRIMARY KEY)]},
  { firstname   => ['VARCHAR(100)', q(NOT NULL)]},
  { middlename  => ['VARCHAR(100)', q(NOT NULL)]},
  { lastname    => ['VARCHAR(100)', q(NOT NULL)]},
  { email       => ['VARCHAR(100)', 'UNIQUE', q(NOT NULL)]},
  { phoneNo     => ['VARCHAR(20)', 'UNIQUE']},
  { position    => ['VARCHAR(100)', q(NOT NULL)]},
  { department  => ['VARCHAR(25)', q(NOT NULL)]},
  { date        => ['VARCHAR(10)', q(NOT NULL)]}
);

my @salaryStruct = (
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
my $employee = Person->new(name => "Adedamola Adedeji Awesu", startDate => DateTime->new(year => 2021, month => 2, day => 8), position => JobRole->new(title => "SW Engineer", dept => "SSW"));
my $employee2 = Person->new(name => "Ousseynou Adama Ndiaye", startDate => DateTime->new(year => 2021, month => 3, day => 2), position => JobRole->new(title => "SW Engineer", dept => "SSW"));

say $employee->info;
say $employee2->info;

#my $idOld = 3; my $idNew = 2;

#$dbh->do('INSERT INTO people (name, position, date) VALUES (?, ?, ?)', undef, $employee->name, $employee->position->title, $employee->entryDate->dmy('/'));
#$dbh->do('INSERT INTO people (name, position, date) VALUES (?, ?, ?)', undef, $employee2->name, $employee2->position->title, $employee2->entryDate->dmy('/'));
#$dbh->do('UPDATE people SET id = ? WHERE id = ?', undef, $idNew, $idOld);

Database::disconnectDB($db);