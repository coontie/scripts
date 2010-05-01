#!/usr/bin/perl -w

use strict;

use XML::Parser;
use XML::SimpleObject;
use Data::Dumper;

#master xml config file
my $file = 'test.xml';
my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $xmlobj = XML::SimpleObject->new( $parser->parsefile($file) );

print extractFromXML("nitrogen", "IS_perl_RUNNING", "message");

exit 0;

#this extracts one value for a given server name/command type pair
sub extractFromXML
{
	#the name of the server we're interested in
	my $serverSubmitted  = $_[0];
	#the command type we're interested in
	my $commandSubmitted = $_[1];
	#this is a final value inside the "command" branch - exec, expected value, message
	my $valueSubmitted   = $_[2];

	foreach my $server ($xmlobj->child("config")->children("server")) {
		my $serverName = $server->attribute('name');
		foreach my $command ($server->children('command')) {
			my $commandType = $command->attribute('type');
			my $currentValue = $command->child($valueSubmitted)->value;
			return $currentValue if (($serverName eq $serverSubmitted) and ($commandType eq $commandSubmitted));
		}
	}
}
