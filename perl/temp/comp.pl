#!/usr/bin/perl -w
use strict;

my $found = 0;

open (HOSTFILE, "hostlist.txt") or die "no hostlist file";

while (<HOSTFILE>) {
	chomp;
	my $currentHost = $_;
	#print "gas is $currentHost \n";
	open (MNGDFILE, "<managelist.txt") or die "no managed hosts file";
	while (<MNGDFILE>) {
	#	print "hem is $_ \n";
	chomp;
		if ($currentHost eq $_) {
			#print "$_";
			$found = 1;
		}
	}
	close (MNGDFILE);

	print "$currentHost not found \n " unless $found;
	$found = 0;
}

close (HOSTFILE);
close (MNGDFILE);
