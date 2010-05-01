#!/usr/bin/perl -w
use XML::Parser;
use XML::SimpleObject;
use Data::Dumper;

my $file = 'config.3.xml';
my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $xmlobj = XML::SimpleObject->new( $parser->parsefile($file) );

#this code traverses the entire config file.
foreach $servers ($xmlobj->child("config")->children("server"))
{
	print $servers->attribute('name');
	foreach $command ($servers->children('command'))
	{
		print $command->attribute('type') . " ";
	}
	print "\n____________________\n";
}

