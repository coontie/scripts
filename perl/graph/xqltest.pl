#!/usr/bin/perl -w

use strict;
use XML::XQL;
use XML::XQL::DOM;
use Data::Dumper;

my $parser = new XML::DOM::Parser;
my $doc = $parser->parsefile ("./foom.xml");

my @routerList = $doc->xql ('//router/@name');
my @neighborList = $doc->xql ('//neighbor/@remote-host');

print @routerList ."\n";
print @neighborList . "\n";

#print @neighborList;
foreach my $router (@routerList) {
	print "router ". $router->getValue() ." has these neighbors: \n";
	foreach my $neighbor (@neighborList) {
		print "\t" . $neighbor->getValue() . "\n";
	}
}
