#!/usr/bin/perl -w

use strict;

my $testVar = 1;
my $ptr = \$testVar;

if (my $pid = fork) {
	while (1) {
		print "from parent: $testVar \n";
		print "ptr from parent: $ptr \n";
		sleep 2;
	}
		waitpid($pid, 0);
} else {
	while (1) {
		print "from child: $testVar \n";
		print "ptr from client: $ptr \n";
		$$ptr++;
		sleep 2;
	}
	exit;
}
