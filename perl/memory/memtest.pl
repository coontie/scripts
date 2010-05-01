#!/usr/bin/perl

use strict;

my @a;
my $counter = 0;

open (OUTFILE, ">zfile.txt");

while ($counter < 1000000)
{
#	push @a, ("Z") x 1000000;
	print OUTFILE "Z\n";
	#push @a, ("Z") x 3;
#	print "new array is @a \n";
#	print "counter is $counter \n";
	$counter++;
}

close (OUTFILE);
