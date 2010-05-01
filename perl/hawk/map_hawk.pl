#!/usr/bin/perl -w

use strict;
use XML::Parser;
use XML::SimpleObject;
use GraphViz;

#my @configList = `ls configs_md/*`;
#my @configList = "./test.xml";

#open (OUTFILE, ">./hawk_map.jpg");

my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $graph = GraphViz->new(overlap => 'orthoyx', directed => 1, concentrate => 1, layout => 'circo');

my $configFile = "./rbmap.hrm";

my $configXMLObject = XML::SimpleObject->new( $parser->parsefile($configFile) );

foreach my $host ($configXMLObject->child('RuleBaseMap')->child('Hosts')->children("Host")) {
    my $hostName = $host->attribute('Name');
    print "HOST: $hostName \n";
#    $graph->add_node($hostName, color => "red");
    foreach my $ruleBase ($host->children("RuleBase")) {
        my $ruleBaseName=$ruleBase->attribute("Name");
#        print "ruleBase name is $ruleBaseName \n";
        #$graph->add_edge($hostName => $ruleBaseName, color => "blue");
        print "\t RULEBASE: $ruleBaseName \n";
    }
#    print "name is $hostName \n";
}

#print OUTFILE $graph->as_jpeg;
#close (OUTFILE);
