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

@EXPORT = qw(connectDB createTable addFKeyConstraint insertInTable deleteTable disconnectDB);


sub connectDB {
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

  my $stmt = "CREATE TABLE IF NOT EXISTS $tableName ( ";
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

  #run command
  $dbHandle->do($stmt)==0 or warn $dbHandle->errstr;
  
}

sub insertInTable {
  my($dbHandle, $tableName, )
}

sub disconnectDB {
  my $dbh = shift;

  $dbh->disconnect or warn $dbh->errstr ;

}

1;