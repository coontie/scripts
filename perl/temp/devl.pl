#!/usr/bin/perl -w

use strict;

open (INFILE, "<./devl.txt") || die "couldn't open";

while (<INFILE>)
{
	chomp;
	my @currentLine = split ('/', $_);
	my $gzip = $currentLine[4];
	my $file = $currentLine[7];
	print "gunzip -c /backup1/backup1/$gzip/$gzip.tar.gz | tar xvf - $gzip/oradata/DEVL/$file &\n" ;
	print "gunzip -c /backup1/backup2/$gzip/$gzip.tar.gz | tar xvf - $gzip/oradata/DEVL/$file\n";
}
