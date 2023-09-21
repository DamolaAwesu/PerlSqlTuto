#!/usr/bin/perl

use strict;
use warnings;
use v5.10;

use DateTime;
use Test::More tests => 11;
use Test::Exception;

use Person::Person;
use Person::JobRole;

#Test 1: check that object is an instance of the Person class
my $p = Person->new;
isa_ok($p, 'Person');

#Test 2-3: Check getter and setter behavior;
is($p->name('Damola Awesu'), 'Damola Awesu', 'setter');
is($p->name, 'Damola Awesu', 'getter');

#Test 4: check entryDate is set with DateTime object
isa_ok($p->entryDate(DateTime->new(year => 2021, month => 2, day => 8)), 'DateTime');

#Test 5-6: Check that entryDate is a DateTime object
my $d = $p->entryDate;
isa_ok($d, 'DateTime');
is($d->year,'2021','Year is correct');

#Test 7: check position is set with a JobRole object
isa_ok($p->position(JobRole->new(title => "SW Engr", dept => "SSW")), 'JobRole');

#Test 8 - 11: check that position is a JobRole object
my $pos = $p->position;
isa_ok($pos, 'JobRole');
is($pos->title, 'SW Engr', 'Title is correct');
is($pos->department, 'SSW', 'Department is correct');
is($pos->process, 'RD', 'Process is correct');