#!/usr/bin/perl -w

use strict;
use XML::XPath;
use Data::Dumper;
use XML::XPath::XMLParser;

my $xp = XML::XPath->new(filename => 'test.xml');

my $routerName = $xp->find('//router/@name');
my $neighborList = $xp->find('//neighbor/@remote-host');

foreach my $neighbor ($neighborList->get_nodelist) {
	print "got one:", XML::XPath::XMLParser::as_string($neighbor), "\n\n";
}

print "I am $routerName \n";
