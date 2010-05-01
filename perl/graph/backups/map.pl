#!/usr/bin/perl -w

use strict;
use XML::Parser;
use XML::SimpleObject;
use GraphViz;

my @configList = `ls configs/*`;
#my @configList = "./test.xml";

open (OUTFILE, ">./map.jpg");

my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $graph = GraphViz->new(directed => 1, concentrate => 1, layout => 'circo');

foreach my $configFile (@configList) {
	chomp($configFile);

	my $configXMLObject = XML::SimpleObject->new( $parser->parsefile($configFile) );

	foreach my $router ($configXMLObject->child('rendezvous')->child('configuration')->child('rvrd-parameters')->children("router")) {
		my $routerName = $router->attribute('name');

		$graph->add_node($routerName, color => "red", shape => "box");
		#print "I am $routerName and I have these neighbors: \n";
		foreach my $neighbor ($router->children("neighbor")) {
		#	print "\t" . $neighbor->attribute('neighbor-name') ."\n";
			my $neighborName = $neighbor->attribute('neighbor-name');
			my $localPort = ":".$neighbor->attribute('local-port');
			my $remotePort = ":".$neighbor->attribute('remote-port');
			my $pathCost = $neighbor->attribute('cost');
			$graph->add_edge($routerName => $neighborName, label => $pathCost, color => "blue");
		}
	}
#	print "________________________\n";
}

print OUTFILE $graph->as_jpeg;
close (OUTFILE);
