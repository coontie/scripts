#!/usr/bin/perl -w

use strict;

use XML::Simple;

my $config = XMLin("/tmp/MER_OTC_Call_Center_Insight.xml");

print $config->{name};
