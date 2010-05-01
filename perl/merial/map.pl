#!/usr/bin/perl -w

use strict;
use XML::Parser;
use XML::SimpleObject;
use GraphViz;
#use Smart::Comments;

my $interfaceName = $ARGV[0];

print "my interface is $interfaceName \n";

my @interfaceList = `find /home/tibco/perl/merial/INTERFACES/$interfaceName -name "*.process" -print`;
#my @interfaceList = "./ifaces.xml";


my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
#my $graph = GraphViz->new(directed => 1, layout => 'circo', overlap => 'false');
my $graph = GraphViz->new(directed => 1, layout => 'dot', overlap => 'false');


my %nodeHash;


foreach my $interfaceFile (@interfaceList) { ### Processing [===|    ] % done

#	print "current file is $interfaceFile \n";

        chomp($interfaceFile);

	#chop the array up in pieces, separated by slashes
        my @processNameArray = split (/\//, $interfaceFile);

	#get the last element in array
        my $processName = $processNameArray[-1];

	#create a new graph output file
	open (OUTFILE, ">./output/$interfaceName.gif");

	#get rid of .process extension
        $processName =~ s/\.process//;

        print "process name is $processName \n";

        my $interfaceXMLObject = XML::SimpleObject->new( $parser->parsefile($interfaceFile) );

        foreach my $node ($interfaceXMLObject->child('pd:ProcessDefinition')->children('pd:transition')) {
                my $fromName = $node->child('pd:from')->value;
		$fromName = $processName if ($fromName eq 'Start');
                my $toName = $node->child('pd:to')->value;
		$toName = "End ".$processName if ($toName eq 'End');

		print "yay" if ($fromName eq 'End');

#		print "from $fromName, to $toName \n";

                my $conditionType = $node->child('pd:conditionType')->value;

                my $toNode = $graph->add_node($toName,  color => 'red');
                my $fromNode = $graph->add_node($fromName, color => 'red');
#		$nodeHash{$fromName}{$toName} = 0 unless (defined $nodeHash{$fromName}{$toName});
#                $graph->add_edge($fromNode => $toNode, label => $conditionType, color => 'blue') unless ($nodeHash{$fromName}{$toName} == 1);
                $graph->add_edge($fromNode => $toNode, label => $conditionType, color => 'blue');
#		$nodeHash{$fromName}{$toName} = 1;
        }
	print OUTFILE $graph->as_gif;
	close (OUTFILE);
}
print "________________________\n";


