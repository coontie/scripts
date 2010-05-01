#!/usr/bin/perl -w

for (my $i=1; $i < 1000; $i++) {
	my $time = time();
	print $time .":". int(exp($i*.02));
	print "\n";
}
