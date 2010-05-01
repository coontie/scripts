#!/usr/bin/perl -w

use GraphViz::XML;
use strict;

my $xml = `cat ./configs/cib-prodrv01.usa.wachovia.net.xml`;

my $graph = GraphViz::XML->new($xml);
print $graph->as_jpeg;
