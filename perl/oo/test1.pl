#!/usr/bin/perl -w

use strict;

sub test
{
	my $param = $_[0];
	my $ptr = sub {$param++; $_[0] = $param;};
	return $ptr;
}

my $closure = test 3;

while ($closure->(my $foo))
{
	print $foo . "\n";
	sleep 1;
}
