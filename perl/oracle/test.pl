#!/usr/bin/perl -w

use strict;
use DBI;
my $dbh = DBI->connect( 'dbi:Oracle:host=bptdev1.merial.net;sid=BPTDEV1;port=1533',
                        'xxtibco',
                        'xxt1bco',
                      ) || die "Database connection not made: $DBI::errstr";
$dbh->disconnect;
