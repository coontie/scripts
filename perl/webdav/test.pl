#!/usr/bin/perl -w
#
#

use strict;

use HTTP::DAV;

my $d = new HTTP::DAV;

my $url = "http://am-usa01-tst01.nam.merial.net:8000/BPT/TIBCO/PROJECTS/INTERFACES/"; 

$d->credentials( -user=>"kantori",-pass =>"merial1a", -url =>$url);

$d->open( -url=>$url ) or die("Couldn't open $url: " .$d->message . "\n");

$d->get("INT-014/",".");
