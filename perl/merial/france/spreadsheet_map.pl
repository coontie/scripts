#!/usr/bin/perl -w

use strict;

use GraphViz;
use Spreadsheet::ParseExcel;

#source excel file
my $file = './france.xls';

my $excel = Spreadsheet::ParseExcel::Workbook->Parse($file);


my $height = 1.2;
my $width = 2;

my %hash = ();

my $edgeFontSize = 8;
my $nodeFontSize = 8;

#use FR Rice List sheet only!
my $sheet = ${$excel->{Worksheet}}[0];

printf("Sheet: %s\n", $sheet->{Name});
$sheet->{MaxRow} ||= $sheet->{MinRow};

foreach my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
        my $team = $sheet->{Cells}[$row][0]->{Val};
	my $riceType = $sheet->{Cells}[$row][1]->{Val};
        my $riceID = $sheet->{Cells}[$row][2]->{Val};
        my $sourceName = $sheet->{Cells}[$row][14]->{Val};
        my $destName = $sheet->{Cells}[$row][15]->{Val};

	if ($riceType eq 'Interface') {
#		print "team: $team s: $sourceName t: $destName int: $riceID \n";

		#set it to a dummy value of 1
		$hash{$team}{$sourceName}{$destName}{$riceID}=1;
	}
}

foreach my $currentTeam (keys %hash) {
	my $graph = GraphViz->new(directed => 1, rankdir=>'LR', layout => 'dot', overlap => 'false', node => {shape => 'record'});
	$graph->add_node($currentTeam, shape => 'plaintext', color=>'red');
	#create a new graph output file
	open (OUTFILE, ">./interfaces/$currentTeam.gif");
	print "New file: $currentTeam \n";
	foreach my $currentSource (keys %{$hash{$currentTeam}}) {
		foreach my $currentDest (keys %{$hash{$currentTeam}{$currentSource}}) {
			foreach my $edgeLabel (keys %{$hash{$currentTeam}{$currentSource}{$currentDest}}) {
				my $sourceNode = $graph->add_node($currentSource, width => $width, color=>'blue', fontsize => $nodeFontSize);
				my $targetNode = $graph->add_node($currentDest, width => $width, color=>'blue', fontsize => $nodeFontSize);
				#my $sourceNode = $graph->add_node($currentSource,  height => $height, width => $width, color=>'blue', cluster => $currentTeam);
				#my $targetNode = $graph->add_node($currentDest, height => $height, width => $width, color=>'blue', cluster=>$currentTeam);
				print "s: $currentSource t: $currentDest int: ". $edgeLabel. " \n";
				$graph->add_edge($sourceNode => $targetNode, label => $edgeLabel, color => 'blue', fontsize => $edgeFontSize);
				#print $sourceNode."->".$targetNode.":".$edgeLabel . "\n";
				#print "______\n";
			}
		}
	}
	print OUTFILE $graph->as_gif;
	close OUTFILE;
}
