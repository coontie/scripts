#!/usr/bin/perl -wT

use strict;
use HTML::Table;

my $mainTable = new HTML::Table(-style=>'color: blue', -border=>1);

print "Content-type: text/html \n\n";
print "Last 40 executions of the deploy.pl command: \n\n";
print "<p>";
#$mainTable->addRow('ID','Project Name','XML MD5 hash', 'EAR MD5 hash', 'Date', 'Env', 'Result');
$mainTable->addRow('ID','Project Name', 'Date', 'Env', 'Result');

#my $dbLocation = '/var/www/cgi-bin/dev/deploy.db';
my $dbLocation = '/var/www/cgi-bin/deploy.db';

use DBI;
my $dbh = DBI->connect( "dbi:SQLite:$dbLocation" ) || die "Cannot connect: $DBI::errstr";

my $select_statement = qq(select id, project, time, env, result from checksums order by id desc limit 40);

#create the handle
my $sth = $dbh->prepare ($select_statement);

#make the execution plan for the statement
$sth->execute() or die "Cannot execute" . $sth->errstr;
while (my @row_array = $sth->fetchrow_array()) {
	$mainTable->addRow(@row_array);
}

$mainTable->print;
