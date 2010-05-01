#!/usr/bin/perl -w

use strict;

use XML::XPath;
use XML::XPath::XMLParser;

my $file = XML::XPath->new(filename => '/mnt/deploy/DEPLOYMENT/MER_EAI_DEV/EDI_SITE_DATA.xml');

my $path = '/application/repoInstances/rvRepoInstance/daemon';

my $nodeset = $file->find($path);

foreach my $node ($nodeset->get_nodelist) {
	print XML::XPath::XMLParser::as_string($node), "\n";
	$file->setNodeText($path,"foo");
}
