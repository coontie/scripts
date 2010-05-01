#!/usr/bin/perl -w

use strict;
use XML::Parser;
use XML::SimpleObject;

#my @configList = `ls configs_md/*`;
#my @configList = "./test.xml";


my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");

#my $configFile = "rbs/devems05_ems_base.hrb";

my @listOfFilesToProcess = `ls rbs/*.hrb`;

foreach my $configFile (@listOfFilesToProcess) {
    my $configXMLObject = XML::SimpleObject->new( $parser->parsefile($configFile) );
    my $rulebaseName = $configXMLObject->child('ruleBase')->child('name')->value;
    print "RULEBASE: $rulebaseName \n";
    foreach my $rule ($configXMLObject->child('ruleBase')->children("rule")) {
        my $ruleName = $rule->child("name")->value;
        #print "RULE NAME:$ruleName \n";
        my $methodName = $rule->child("dataSource")->child('methodName')->value;
        if (($methodName eq "getQueues") || ($methodName eq "getTopics")) {
            my $objectName =  $rule->child("dataSource")->child('dataElement')->child("dataObject")->value;
            print "\t OBJECT: $objectName\n";
        }
        foreach my $test ($rule->children("test")) {
            my $testName = $test->child("name")->value;
            print "\t\t TEST: $testName\n";
                foreach my $conseq ($test->children("consequenceAction")) {
                    my $conseqName = $conseq->child("name")->value;
                    print "\t\t\t CONSEQUENCE: $conseqName \n" unless ($conseqName eq "postCondition");
                }
        }
    }
}
#    print "name is $rulebaseName \n";
