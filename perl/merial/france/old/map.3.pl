#!/usr/bin/perl -w

use strict;

use Tie::Handle::CSV;
use GraphViz;


my $fh = Tie::Handle::CSV->new('./france.csv', header => 1);
my $graph = GraphViz->new(directed => 1, layout => 'circo', overlap => 'false', node => {shape => 'record'});

my $height = 1;
my $width = 3;

my ($sourceName, $destName) = '';

#create a new graph output file
open (OUTFILE, ">./france.gif");

while (my $csv_line = <$fh>) {
	my $team = $csv_line->{'Team'};
	my $intName = $csv_line->{'RICE ID'};

	$sourceName = $csv_line->{'Source'}.':'.$team;
	$destName = $csv_line->{'Destination'}.':'.$team;
	my $source = $graph->add_node($sourceName,  height => $height, width => $width, color=>'blue');
	my $target = $graph->add_node($destName, height => $height, width => $width, color=>'blue');
	print "s: $sourceName t: $destName int: $intName \n";
	$graph->add_edge($source => $target, label => $intName, color => 'blue', cluster=>$team);
}

#$graph->add_node("Oracle", height => 4, width => 4, cluster => "Oracle");
print OUTFILE $graph->as_gif;
close OUTFILE;
close $fh;
