#!usr/bin/perl
package Database;
our $VERSION = 'v1.0.0';

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

  $dbh                 = connectDB($dataSource, $username, $password);

  $retVal              = createTable($dbh, $table, $tableSchema);
  $retVal              = insertInTable($dbh, $table, \%attr);
  ($retVal, $attrHash) = getSingleRecord($dbh, $table, $field, $searchToken);
  ($retVal, $sth)      = getAllRecords($dbh, $table, $searchToken);
  $retVal              = updateRecord($dbh, $table, $uname, \%attr);
  $retVal              = deleteRecord($dbh, $table, $uname, $searchToken);

  $retVal              = disconnectDB($dbHandle);

I<This synopsis lists major methods and parameters.>

=cut

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

Then you need to L<connect|/connect> to your data source and get a I<handle> for the connection:

  $dbh = Database::connect($datasource, $username, $password);

Generally, you connect only once at program start and L<disconnect|/disconnect> at the end

Once connected, the other methods provided by the Database package are ready to be used by the application

=head2 Methods

This section provides a description of all methods available for use

=cut

=head3 C<connect>

  Parameters  : $datasource : path to database
                $user       : username
                $password   : user credential

  Return      : $dbh        : database handle

  Description : connect to database

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

=head3 C<createTable>

  Parameters  : $dbh          : database handle
                $tableName    : name of table
                $tableSchema  : schema of table to be created

  Returns     : $retVal       : query status

  Description : creates a new table in the database, if it does not already exist, based on the provided schema

=cut

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

=head3 C<insertInTable>

  Parameters      : $dbh        : database handle
                    $tableName  : name of table to insert into
                    \%attr      : hash containing data to be inserted

  Returns         : $err        : status of query

  Description     : insert record into table

=cut

#insert a new row into the specified table
sub insertInTable {
  my $err = 0;
  my($dbHandle, $tableName, $recordInfo) = @_;
  my $nbCols = 0;
  my @keys = keys(%{$recordInfo});

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
    push(@fields,$recordInfo->{$entry2});
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

=head3 C<getSingleRecord>

  Parameters     :  $dbh          : database handle
                    $tableName    : name of table to read from
                    $field        : column to filter data
                    $searchToken  : value to match in filter

  Returns        :  $err          : status of query
                    $attrHash     : hash containing data in the filtered row

  Description    :  get all data in a single row from the specified table based on the provided filter

=cut

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

=head3 C<getAllRecords>

  Parameters     :  $dbh          : database handle
                    $tableName    : name of table to read from

  Returns        :  $err          : status of query
                    $attrHash     : hash containing all data in the specified table

  Description    :  get all data present in the specified table

=cut

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

=head3 C<updateRecord>

  Parameters     :  $dbh          : database handle
                    $tableName    : name of table to read from
                    $uname        : column to filter data
                    $recordInfo   : values to update

  Returns        :  $err          : status of query

  Description    :  update select data in a record in specified table based on filter provided

=cut

#update a row in the database
sub updateRecord {
  my ($dbHandle, $tableName, $pKey, $pKeyVal, $recordInfo) = @_;
  my $err = 0;

  my @keys = keys(%{$recordInfo});

  my $stmt = "UPDATE $tableName SET ";

  for my $entry (@keys) {
    $stmt .= "$entry=?, ";
  }
  $stmt =~ s/, $//;
  $stmt .= "WHERE $pKey=?;";
  my $sth = $dbHandle->prepare($stmt);
  my @options = ();
  for my $entry (@keys) {
    push(@options, $recordInfo->{$entry});
  }

  if($sth->execute(@options,$pKeyVal) == -1) {
    $err++;
  }
  return $err;
}

=head3 C<deleteRecord>

  Parameters     :  $dbh          : database handle
                    $tableName    : name of table to read from
                    $field        : column to filter data
                    $value        : value to match in filter

  Returns        :  $err          : status of query

  Description    :  delete a single row from the specified table based on the provided filter

=cut

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

=head3 C<deleteRecord>

  Parameters     :  $dbh          : database handle
                    $tableName    : name of table to read from
                    $option       : "D" to delete entire table + schema, "T" to only delete records in the table

  Returns        :  $err          : status of query

  Description    :  delete a single row from the specified table based on the provided filter

=cut

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

=head3 C<disconnect>

  Parameters     :  $dbh  : database handle

  Returns        :  None

  Description    :  disconnect from database

=cut

#disconnect from database
sub disconnect {
  my $dbh = shift;

  $dbh->disconnect or warn $dbh->errstr ;

}

1;

__END__

=head1 SUPPORT

This module is managed in an open Github repository, L<github.com/DamolaAwesu/PerlSqlTuto|https://github.com/DamolaAwesu/PerlSqlTuto/blob/main/Database.pm>.

=head1 COPYRIGHT

Copyright (c) 2023 Damola Awesu

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself

=head1 AUTHOR(S)

Database was created and is maintained by Damola Awesu, reachable at B<dammyawesu@gmail.com>

=cut
