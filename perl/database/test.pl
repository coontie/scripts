#!/usr/bin/perl -w

use strict;

use DBI;

my $dbh = DBI->connect( 'dbi:Sybase:ITSTEST',
                        'emsdbo',
                        'emsdbo1',
                      ) || die "Database connection not made: $DBI::errstr";
    
$dbh->disconnect();
