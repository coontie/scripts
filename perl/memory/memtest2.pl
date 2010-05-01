#!/usr/bin/perl

use strict;

my @a;

open (INFILE, "<./zfile.txt") || die "no file";
print "starting!!! \n";

while (<INFILE>)
{
#	print ".\n";
	push @a, $_;
#	print $_;
	#push @a, ("Z") x 3;
#	print "new array is @a \n";
#	print "counter is $counter \n";
sleep .5;
}

close (INFILE);

print "done, sleeping. \n";
sleep 300;
