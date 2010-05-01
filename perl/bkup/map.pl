#!/usr/bin/perl -w

use strict;
use XML::Parser;
use XML::SimpleObject;
use GraphViz;

my @interfaceList = `find /home/tibco/perl/merial/interfaces/INTERFACES/ -name "*.process" -print`;
#my @interfaceList = "./ifaces.xml";


my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
#my $graph = GraphViz->new(directed => 1, layout => 'circo', overlap => 'false');
my $graph = GraphViz->new(directed => 1, layout => 'circo', overlap => 'false');


foreach my $interfaceFile (@interfaceList) {
        chomp($interfaceFile);

	#chop the array up in pieces, separated by slashes
        my @processNameArray = split (/\//, $interfaceFile);

	#get the last element in array
        my $processName = $processNameArray[-1];

	#get the interface name
	my $interfaceName = $processNameArray[7];
	#print "iface name is $interfaceName \n";
	open (OUTFILE, ">./output/$interfaceName.gif");

	#get rid of .process extension
        $processName =~ s/\.process//;

        print "process name is $processName \n";

        my $interfaceXMLObject = XML::SimpleObject->new( $parser->parsefile($interfaceFile) );

        foreach my $node ($interfaceXMLObject->child('pd:ProcessDefinition')->children('pd:transition')) {
                my $fromName = $node->child('pd:from')->value;
                my $toName = $node->child('pd:to')->value;

                if ($fromName eq "Start") {
                        $fromName = $fromName.".".$processName;
                }

                if ($toName eq "End") {
                        $toName = $toName.".".$processName;
                }

                my $conditionType = $node->child('pd:conditionType')->value;

#               my $fromNode = $graph->add_node(label => $fromName, color => 'red');
#               my $toNode = $graph->add_node(label => $toName, color => 'red');
                $graph->add_node($toName, color => 'red');
                $graph->add_node($fromName, color => 'red');
                $graph->add_edge($fromName => $toName, label => $conditionType, color => 'blue');
        }
	print OUTFILE $graph->as_gif;
	close (OUTFILE);
}
print "________________________\n";


