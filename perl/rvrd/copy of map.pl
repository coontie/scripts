#!/usr/bin/perl -w

use strict;
use XML::Parser;
use XML::SimpleObject;
use GraphViz;

my @configList = `ls configs/*`;
#my @configList = "./test.xml";

open (OUTFILE, ">./rvrd_map.jpg");

my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $graph = GraphViz->new(directed => 1, layout => 'circo', overlap => 'true');

foreach my $configFile (@configList) {
#	print "Processing $configFile";

	chomp($configFile);

	my $configXMLObject = XML::SimpleObject->new( $parser->parsefile($configFile) );

	foreach my $router ($configXMLObject->child('rendezvous')->child('configuration')->child('rvrd-parameters')->children("router")) {
		my $routerName = $router->attribute('name');

		$graph->add_node($routerName, color => 'red');
		#print "I am $routerName and I have these neighbors: \n";
		foreach my $neighbor ($router->children("neighbor")) {
		#	print "\t" . $neighbor->attribute('neighbor-name') ."\n";
			my $neighborName =  $neighbor->attribute('neighbor-name');
			my $pathCost = "Cost:".$neighbor->attribute('cost');
			$graph->add_edge($routerName => $neighborName, label => $pathCost, color => 'blue');
		}
        foreach my $local_network ($router->children("local-network")) {
            my $mcastAddress = $local_network->attribute("network");
            my $udpPortNumber = $local_network->attribute("service");
            my $networkLeaf = "NETWORK:".$routerName.$mcastAddress;
            my $portLeaf = "PORT:".$routerName.$mcastAddress.":".$udpPortNumber;
            $graph->add_edge($networkLeaf => $routerName, color => 'green');
            $graph->add_edge($portLeaf => $networkLeaf, color => 'green');
        }
	}
#	print "________________________\n";
}

print OUTFILE $graph->as_png;
close (OUTFILE);
