#!/usr/bin/perl -w

use Monitor;

my $mon = Monitor->new();

$mon->getConfig();

$mon->start();
