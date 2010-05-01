#!/usr/bin/perl -w

use strict;

use GraphViz;
use Spreadsheet::ParseExcel;

#source excel file
my $file = '/home/tibco/perl/merial/france/france.xls';

my $excel = Spreadsheet::ParseExcel::Workbook->Parse($file);


my $height = 0.2;
my $width = 2.5;

my %hash = ();

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
		print "team: $team s: $sourceName t: $destName int: $riceID \n";

		#set it to a dummy value of 1
		$hash{$team}{$sourceName}{$destName}{$riceID}=1;
	}
}

#my $graph = GraphViz->new(directed => 1, layout => 'dot', width => 8.5, height => 11, overlap => 'false', node => {shape => 'record'});
my $graph = GraphViz->new(directed => 1, layout => 'dot', overlap => 'false', node => {shape => 'record'});
$graph->add_node("Oracle", cluster=>"Oracle");
#create a new graph output file
open (OUTFILE, ">./france.gif");

foreach my $currentTeam (keys %hash) {
	foreach my $currentSource (keys %{$hash{$currentTeam}}) {
		foreach my $currentDest (keys %{$hash{$currentTeam}{$currentSource}}) {
			foreach my $edgeLabel (keys %{$hash{$currentTeam}{$currentSource}{$currentDest}}) {
				my $clusterName = $currentTeam;
				my $sourceNode = $graph->add_node($currentSource,  height => $height, width => $width, color=>'blue', cluster => $clusterName);
				my $targetNode = $graph->add_node($currentDest, height => $height, width => $width, color=>'blue', cluster=>$clusterName);
				#print "s: $currentSource t: $currentDest int: ". $edgeLabel. " \n";
				$graph->add_edge($sourceNode => $targetNode, color => 'blue');
			}
		}
	}
}

print OUTFILE $graph->as_gif;
close OUTFILE;
