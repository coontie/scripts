#!/usr/bin/perl -w
use IO::Socket::Multicast;
use Data::Dumper;
use Tk;
use RMDS;

use strict;

my $host = RMDS->new();

$host->setName('p2ps1');

my $name = $host->getName();
print "host name is $name \n";
