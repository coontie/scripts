#!/usr/bin/perl -w

use strict;

use Time::Interval;

my $newtime = "00:01:20";

my ($days,$hours,$minutes) = split(/:/,$newtime,3);

my $mins = convertInterval(
		days	=>0,
		hours	=>$hours,
		minutes	=>$minutes,
		ConvertTo	=>"minutes"
);

print "mins = $mins \n";
