#!/usr/bin/perl -w
use XML::Simple;
use Data::Dumper;


$configFile = XMLin('./config.3.xml');
print Dumper($configFile);
print $configFile->{server}->{cnyp2ps1}->{command}->{status}->{exec};
#print Dumper($configFile->{server});
