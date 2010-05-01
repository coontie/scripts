#!/usr/bin/perl -w

use Time::Piece;

use strict;

my $t1 = localtime();

print $t1->hms;

print "\n";

sleep 1;

my $t2 = localtime();
print $t2->hms;

my $diff = $t2->epoch - $t1->epoch;

print "difference is $diff \n";

my $foo = test();

{print "TRUE \n"} if (test()) else {print "false \n"};

sub test
{
	return 0;
}

