#!/usr/bin/perl -w

use strict;

open (INFILE, "../../temp/rics.txt") or die "no file";

my ($fst, $snd, $third, @chopped);

while (<INFILE>)
{
	($fst, $snd, $third) = split (':', $_);
	@chopped = split ('', $snd);
	print $chopped[0],$chopped[1],":",$chopped[2],$chopped[3] . " " . $third;
#	print $snd . " " . $third;
}
