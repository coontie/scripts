#!/usr/bin/perl -w

use strict;

use XML::Simple;
use Data::Dumper;

my $config = XMLin("test.xml", GroupTags => { searchpath => 'neighbor' });
my $config = XMLin("test.xml");
#print Dumper($config);

#print $config->{'configuration'}->{'rvrd-parameters'}->{'router'}->{name};

my @neighborArray = $config->{'configuration'}->{'rvrd-parameters'}->{'router'}->{'neighbor'};

print Dumper($neighborArray[0]);

