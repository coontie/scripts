#!/usr/bin/perl -w

use strict;

use GraphViz;
use Spreadsheet::ParseExcel;

#source excel file
my $file = '/home/tibco/perl/merial/france/business/france.xls';

my $excel = Spreadsheet::ParseExcel::Workbook->Parse($file);


my $height = 1.2;
my $width = 2;

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
	my $logicalGroup = $sheet->{Cells}[$row][17]->{Val};
	my $businessObject =  $sheet->{Cells}[$row][18]->{Val};
	my $transaction =  $sheet->{Cells}[$row][19]->{Val};


	if ($riceType eq 'Interface') {
		print "team: $team s: $sourceName t: $destName int: $riceID \n";

		#set it to a dummy value of 1
#		$hash{$team}{$sourceName}{$destName}{$riceID}=1;
		$hash{$businessObject}{$logicalGroup}{$riceID}=$transaction;
	}
}

#my $graph = GraphViz->new(directed => 1, rankdir=>'LR', layout => 'dot', overlap => 'false', node => {shape => 'record'});
my $graph = GraphViz->new(directed => 1, layout => 'dot', overlap => 'false', node => {shape => 'record'});
open (OUTFILE, ">./business_map.gif");

foreach my $currentBusinessObject (keys %hash) {
	print "currBO: $currentBusinessObject \n";
	foreach my $currentLogicalGroup (keys %{$hash{$currentBusinessObject}}) {
		print "\t currLG: $currentLogicalGroup \n";
		foreach my $currentRICEID (keys %{$hash{$currentBusinessObject}{$currentLogicalGroup}}) {
			my $currentTransaction =  $hash{$currentBusinessObject}{$currentLogicalGroup}{$currentRICEID};
			print "\t\t currriceID: $currentRICEID trans: $currentTransaction \n";
#			foreach my $edgeLabel (keys %{$hash{$currentBusinessObject}{$currentLogicalGroup}{$currentRICEID}}) {
				my $sourceNode = $graph->add_node($currentBusinessObject, width => $width, color=>'blue');
				my $targetNode = $graph->add_node($currentTransaction, width => $width, color=>'blue');
				#my $sourceNode = $graph->add_node($currentLogicalGroup,  height => $height, width => $width, color=>'blue', cluster => $currentBusinessObject);
				#my $targetNode = $graph->add_node($currentRICEID, height => $height, width => $width, color=>'blue', cluster=>$currentBusinessObject);
				#print "s: $currentLogicalGroup t: $currentRICEID int: ". $edgeLabel. " \n";
				$graph->add_edge($sourceNode => $targetNode, label => $currentRICEID, color => 'blue') unless (($currentBusinessObject eq '') || ($currentTransaction eq ''));
#			}
		}
	}
}

print OUTFILE $graph->as_gif;
close OUTFILE;
