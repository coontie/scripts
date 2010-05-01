#!/usr/bin/perl -w

use strict;
use XML::Parser;
use XML::SimpleObject;
use GraphViz;

my @configList = `ls configs/*`;
#my @configList = "./test.xml";

open (OUTFILE, ">./rvrd_map.jpg");

my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $graph = GraphViz->new(directed => 1, layout => 'circo', overlap => 'false');

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
			my $pathCost = $neighbor->attribute('cost');
			$graph->add_edge($routerName => $neighborName, label => $pathCost, color => 'blue');
		}

	my %networkHash = ();
	my $portLabel = 'UDP Service:\n';
	my $networkNode = '';
	my $portNode = '';
	my $udpPortNumber = '';

        foreach my $local_network ($router->children("local-network")) {
            my $mcastAddress = $local_network->attribute("network");
            my $networkName = $local_network->attribute("name");
            $udpPortNumber = $local_network->attribute("service");
            $networkNode = "NETWORK:".$routerName.$mcastAddress;

	    #unique triplet to create a port node
            $portNode = $routerName.$mcastAddress.$udpPortNumber;
            #my $portNode = "PORT:".$routerName.$mcastAddress.":".$udpPortNumber;
		
            #this is done so that only 1 arrow is generated per network (following 3 lines)
		#set it to 0, meaning has not been created yet
		$networkHash{$networkNode} = 0 unless (defined ($networkHash{$networkNode}));   

		#add the node
		$graph->add_node($networkNode, label => $networkName.$mcastAddress, shape => 'box');
		#draw the edge
            	$graph->add_edge($networkNode => $routerName, color => 'red', dir => 'none') unless ($networkHash{$networkNode} == 1);
		#now set it to 1, created
		$networkHash{$networkNode} = 1;
		#______________________________________________________________________________
		
		#keep adding the port numbers into 1 bucket
		$portLabel = $portLabel." ".$udpPortNumber;
        }
	 	$graph->add_node($portNode, label => $portLabel, shape => 'plaintext');
            $graph->add_edge($portNode => $networkNode, color => 'green', dir => 'none');
	}
#	print "________________________\n";
}

print OUTFILE $graph->as_png;
close (OUTFILE);
