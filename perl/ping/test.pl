#!/usr/bin/perl -w
use Net::Ping;
use strict;

open (INFILE, "<./hostlist.txt") or die "host file list not found \n";

while (<INFILE>)
{
		chomp;
		my $host = $_;
		my $p = Net::Ping->new("icmp");
		print "$host is dead.\n" unless $p->ping($host);
		$p->close();
}

