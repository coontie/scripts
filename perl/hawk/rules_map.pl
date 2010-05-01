#!/usr/bin/perl -w

use strict;
use XML::Parser;
use XML::SimpleObject;
use GraphViz;

my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");


my @listOfFilesToProcess = `ls rbs/*.hrb`;

foreach my $configFile (@listOfFilesToProcess) {
    my $configXMLObject = XML::SimpleObject->new( $parser->parsefile($configFile) );
    my $graph = GraphViz->new(overlap => 'orthoyx', directed => 1, concentrate => 1, layout => 'circo');
    foreach my $rule ($configXMLObject->child('ruleBase')->children("rule")) {
        my $ruleName = $rule->child("name")->value;
`       open (OUTFILE, ">maps/hawk_map_$ruleName.jpg");
        graph->add_node($ruleName, color => "red");
        my @ruleNameArray = split (/:/,$ruleName);
        $ruleName = $ruleNameArray[1].":".$ruleNameArray[2];
        #print "RULE NAME:$ruleName \n";
        foreach my $test ($rule->children("test")) {
            my $testName = $test->child("name")->value;
            print "RULE NAME:$ruleName \t TEST: $testName\n";
            foreach my $consequence ($test->children("consequenceAction")) {
                my $consequenceName = $consequence->child("name")->value;
            }
        }
    }
}
#    print "name is $rulebaseName \n";
