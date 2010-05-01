#!/usr/bin/perl -w
use strict;
use XML::Writer;
use IO::File;

my $output = new IO::File(">output.xml");

my $hostname = `hostname`;
my $localPort = 60011;

my $writer = new XML::Writer(OUTPUT => $output,DATA_MODE => 'true', DATA_INDENT => 2);
$writer->startTag("rendezvous", "url" => "http://foo.com");
$writer->startTag("configuration", timestamp => 20061204114828-0500);
$writer->startTag("rvrd-parameters");
$writer->emptyTag("logging", connections => "no", "subject-data" => "no", "subject-interest" => "no");
$writer->endTag("rvrd-parameters");
$writer->endTag("configuration");
$writer->endTag("rendezvous");
$writer->end();
$output->close();
