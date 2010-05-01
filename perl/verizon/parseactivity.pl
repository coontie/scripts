#!/usr/bin/perl -w

use strict;

use XML::XPath;
use XML::XPath::XMLParser;

my @emxFileList = `ls ~/documents/workspace/Verizon/*.emx`;

foreach my $modelFile (@emxFileList) {
	chomp $modelFile;
	die "No file specified!" unless ($modelFile);

	my $parser = XML::XPath->new(filename => $modelFile);

	#get the model name, should only return one element - 0th element
	my @modelNameArray = $parser->find('//uml:Model')->get_nodelist;
	my $modelName = $modelNameArray[0]->getAttribute('name');
	#____________________________


	my @activityDiagrams = $parser->find('//packagedElement[@xmi:type="uml:Activity"]')->get_nodelist;
	#print "activities has ". scalar @activities ." elements \n";
	foreach my $activityDiagram (@activityDiagrams) {

		#get the name
		my $activityDiagramName = $activityDiagram->getAttribute('name');
		print "Processing $activityDiagramName \n";
		#append .doc extension for MS WORD
		my $fileName = $modelName."-".$activityDiagramName.".doc";
		#open file for writing
		open (OUTFILE, ">./output/$fileName");
		print OUTFILE "Title: ".$activityDiagram->getAttribute('name') . "\n";
		#actors live in ActivityPartitions
		print OUTFILE "Actors:\n";
		foreach my $actor ($parser->find('./group[@xmi:type="uml:ActivityPartition"]',$activityDiagram)->get_nodelist) {
			my $actorName = $actor->getAttribute('name');
			print OUTFILE "\t".$actorName."\n";
		}
		print OUTFILE "Activities:\n";
		my $i=1;
		foreach my $node ($parser->find('./node',$activityDiagram)->get_nodelist) {
			my $nodeName = $node->getAttribute('name');
			print OUTFILE "\tActivity \#$i $nodeName \n";
			$i++;
		}
		$i=0;
		
		print OUTFILE "Preconditions:\n";
		print OUTFILE "Postconditions:\n";
		print OUTFILE "Assumptions: \n";
		print OUTFILE "Notes: \n";
		close OUTFILE;
	}


}
