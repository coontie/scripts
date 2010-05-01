#!/usr/bin/perl -w

use XML::Parser;
use XML::SimpleObject;

sleep 1000;

my $file = 'config.xml';
my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $xmlobj = XML::SimpleObject->new( $parser->parsefile($file) );

foreach my $servers ($xmlobj->child("config")->children("server")) {
	print "current \$servers is $servers \n";
	my $server = $servers->attribute('name');
	print "current \$server is $server \n";

}
