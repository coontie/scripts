#!/usr/bin/perl -w

use strict;
use Net::SCP::Expect;

my $scpe = Net::SCP::Expect->new;

$scpe->login('a485029', 'Timwp08');

my $host = 'cib-calypsorate1.usa.wachovia.net';

$scpe->scp("$host:/etc/hosts","./");
