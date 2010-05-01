#!/usr/bin/perl -w

use strict;

use Tie::Handle::CSV;
use GraphViz;


my $fh = Tie::Handle::CSV->new('./france.csv', header => 1);

my $height = 1;
my $width = 3;

my %hash = '';

my ($sourceName, $destName) = '';


while (my $csv_line = <$fh>) {
	my $team = $csv_line->{'Team'};
	my $intName = $csv_line->{'RICE ID'};

	#$sourceName = $csv_line->{'Source'}.':'.$team;
	#$destName = $csv_line->{'Destination'}.':'.$team;
	$sourceName = $csv_line->{'Source'};
	$destName = $csv_line->{'Destination'};
	$hash{$team}{$sourceName}{$destName} = $intName;
}

foreach my $currentTeam (keys %hash) {
	my $graph = GraphViz->new(directed => 1, layout => 'dot', overlap => 'false', node => {shape => 'record'});
	#create a new graph output file
	open (OUTFILE, ">./$currentTeam.gif");
	print "New file: $currentTeam \n";
	foreach my $currentSource (keys %{$hash{$currentTeam}}) {
		foreach my $currentDest (keys %{$hash{$currentTeam}{$currentSource}}) {
			my $sourceNode = $graph->add_node($currentSource,  height => $height, width => $width, color=>'blue', cluster => $currentTeam);
			my $targetNode = $graph->add_node($currentDest, height => $height, width => $width, color=>'blue', cluster=>$currentTeam);
			my $edgeLabel = $hash{$currentTeam}{$currentSource}{$currentDest};
			print "s: $currentSource t: $currentDest int: ". $edgeLabel. " \n";
			$graph->add_edge($sourceNode => $targetNode, label => $edgeLabel, color => 'blue');
		}
	}
	print OUTFILE $graph->as_gif;
	close OUTFILE;
}
			
close $fh;
