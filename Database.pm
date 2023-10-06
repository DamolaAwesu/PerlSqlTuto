#!usr/bin/perl
package Database;

use strict;
use warnings;
use v5.10;

use DBI;
use Data::Dumper;

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA = qw(Exporter);

@EXPORT = qw(connect createTable addFKeyConstraint getFieldData getSingleRecord getAllRecords insertInTable updateRecord deleteRecord deleteTable disconnect);

=head1 NAME

Database - DB wrapper for SQLite3 in Perl

=head1 SYNOPSIS

$dbh    = connectDB($dataSource, $username, $passkey);

$retVal = createTable($dbh, $table, $tableSchema);

$retVal = insertInTable($dbh, $table, \%attr);
$retVal = getSingleRecord($dbh, $table, $field, $searchToken);
$retVal = getAllRecords($dbh, $table, $searchToken);
$retVal = updateRecord($dbh, $ttable, \%attr);
$retVal = deleteRecord($dbh, $table, $searchToken);

$retVal = disconnectDB($dbHandle);

I<This synopsis lists major methods and parameters.>

=cut


sub connect {
  my ($fileName, $user, $password) = @_;

  return if not -e $fileName;

  my $dsn      = "dbi:SQLite:dbname=$fileName";
  
  my $dbh = DBI->connect($dsn, $user, $password, {
    PrintError       => 0,
    RaiseError       => 1,
    AutoCommit       => 1,
    FetchHashKeyName => 'NAME_lc',
  });

  return $dbh;
}

sub createTable {
  my ($dbHandle, $tableName, $tableInfo) = @_;

  my $stmt = "CREATE TABLE IF NOT EXISTS $tableName ( "; #begin sql statement
  for my $entry (@{$tableInfo}) {
    my @arr = keys(%{$entry});
    $stmt .= $arr[0]; #write field name (key of hash)
    for my $entry2 (@{$entry->{$arr[0]}}) {
      $stmt .= " ".$entry2; #write all field constraints specified
    }
    $stmt .= ", ";
  }
  $stmt =~ s/, $//; #remove trailing comma and space characters
  $stmt .= ");"; #end sql statement

  my $sth = $dbHandle->prepare($stmt);
  #run command
  if ($sth->execute() == -1) {
    warn $sth->errstr;
  }

}

sub insertInTable {
  my $err = 0;
  my($dbHandle, $tableName, $employeeInfo) = @_;
  my $nbCols = 0;
  my @keys = keys(%{$employeeInfo});

  #TODO: check if record already exists using username

  my $stmt = "INSERT INTO $tableName (";
  for my $entry (@keys) {
    $stmt .= $entry.", ";
    $nbCols++;
  }
  $stmt =~ s/, $//; #remove trailing comma and space characters
  $stmt .= ") VALUES(";
  for my $entry2 (@keys) {
    $stmt .= "?, ";
  }
  $stmt =~ s/, $//; #remove trailing comma and space characters
  $stmt .= ");";    #end sql statement
  my $sth = $dbHandle->prepare($stmt);
  my @fields = ();
  for my $entry2 (@keys) {
    push(@fields,$employeeInfo->{$entry2});
  }
  #run command
  if($sth->execute(@fields) == -1) {
    $err++;
  }

  return $err;
}

#get field from record
sub getFieldData {
  my ($dbHandle, $tableName, $field, $searchKey) = @_;
  my $stmt = "SELECT $field FROM $tableName WHERE $field = ?;";
  my $sth = $dbHandle->prepare($stmt);
  $sth->execute($searchKey);
  while (my $row = $sth->fetchrow_hashref) {
    print "$field: $row->{$field}\n";
  }
  #return $sth->fetchrow_hashref;
}

#get single row from table
sub getSingleRecord {
  my ($dbHandle, $tableName, $field, $searchKey) = @_;
  my $err = 0;

  my $stmt = "SELECT * FROM $tableName WHERE $field = ?;";
  my $sth = $dbHandle->prepare($stmt);
  if( $sth->execute($searchKey) == -1){
    $err++;
  }
  return ($err,$sth->fetchrow_hashref);
}

#get all rows from table
sub getAllRecords {
  my ($dbHandle, $tableName) = @_;
  my $err = 0;

  my $stmt = "SELECT * FROM $tableName ";
  my $sth = $dbHandle->prepare($stmt);
  if( $sth->execute() == -1){
    $err++;
  }
  return ($err,$sth);
}

sub updateRecord {
  my ($dbHandle, $tableName, $uname, $recordInfo) = @_;
  my $err = 0;

  my @keys = keys(%{$recordInfo});

  my $stmt = "UPDATE $tableName SET ";
  # for my $entry (@keys) {
  #   $stmt .= $entry." = ".$recordInfo->{$entry}.", ";
  # }
  # $stmt =~ s/, $//; #remove trailing comma and space characters
  # $stmt .= " WHERE username = ".$uname.";";
  # print "$stmt\n";
  for my $entry (@keys) {
    $stmt .= "$entry=?, ";
  }
  $stmt =~ s/, $//;
  $stmt .= "WHERE username=?;";
  my $sth = $dbHandle->prepare($stmt);
  my @options = ();
  for my $entry (@keys) {
    push(@options, $recordInfo->{$entry});
  }

  if($sth->execute(@options,$uname) == -1) {
    $err++;
  }
  return $err;
}

#delete a row from the a table
sub deleteRecord {
  my ($dbHandle, $tableName, $field, $value) = @_;
  my $err = 0;

  my $stmt = "DELETE FROM $tableName WHERE $field = ?;";
  my $sth = $dbHandle->prepare($stmt);

  if($sth->execute($value) <= 0) {
    $err++;
  }

  return $err;
}

#delete a table from the database
sub deleteTable {
  my ($dbHandle, $tableName, $option) = @_;
  my $err = 0;

  my $stmt = "";
  if($option eq "D") {
    #drop table
    print "!!!Warning: Table will cease to exist. To add a new employee, Employee table must be created again!!!";
    $stmt = "DROP TABLE IF EXISTS $tableName;";
  }
  elsif($option eq "T") {
    #delete all records
    $stmt = "DELETE FROM $tableName;";

  }

  if($dbHandle->do($stmt) <= 0) {
    $err++;
  }

  return $err;
}


sub disconnect {
  my $dbh = shift;

  $dbh->disconnect or warn $dbh->errstr ;

}


=head1 DESCRIPTION

The Database package is a simple wrapper around the DBI module available on CPAN corresponding to needs in my OOP Perl project

=head2 Conventions

$dbh          Database handle object
$sth          Statement handle object
$retVal       General return value
$table        Database table name
\%attr        Reference to a hash of attribute values passed to methods
$searchToken  single attribute value

=head2 Usage

To use Database,
first you need to load the Database package:
  C<use Database>;
C<use strict;> is not required but is strongly recommended.
Then you need to L</connect> to your data source and get a I<handle> for the connection:
  $dbh = Database::connect($datasource, $username, $passkey);
Generally, you connect only once at program start and disconnect at the end
Once connected, the other methods provided by the Database package are ready to be used by the application

=head2 Methods

This section provides a description of all methods available for use

=head3 C<connect>

=head3 C<createTable>

=head3 C<deleteTable>

=head3 C<insertInTable>

=head3 C<getSingleRecord>

=head3 C<getAllRecords>

=cut

1;