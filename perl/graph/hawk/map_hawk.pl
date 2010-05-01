#!/usr/bin/perl -w

use strict;
use XML::Parser;
use XML::SimpleObject;
use GraphViz;

#my @configList = `ls configs_md/*`;
#my @configList = "./test.xml";

open (OUTFILE, ">./hawk_map.jpg");

my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $graph = GraphViz->new(overlap => 'orthoyx', directed => 1, concentrate => 1, layout => 'circo');

my $configFile = "./rbmap.hrm";

my $configXMLObject = XML::SimpleObject->new( $parser->parsefile($configFile) );

foreach my $rulebase ($configXMLObject->child('RuleBaseMap')->child('RuleBases')->children("RuleBase")) {
    my $rulebaseName = $rulebase->attribute('Name');
    $graph->add_node($rulebaseName, color => "red");
    foreach my $member ($rulebase->children("Member")) {
        my $memberName=$member->value;
#        print "member name is $memberName \n";
        $graph->add_edge($rulebaseName => $memberName, color => "blue");
    }
#    print "name is $rulebaseName \n";
}

print OUTFILE $graph->as_jpeg;
close (OUTFILE);
