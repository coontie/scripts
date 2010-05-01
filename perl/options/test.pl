#!/usr/bin/perl -w

use strict;

use Getopt::Std;

my %options;

getopts('u:g:o:n:l:h:a', \%options);

usage("Missing unix username") unless $options{'u'};
usage("Missing UID") unless $options{'n'};

my $uname = $options{'u'};
my $name = $options{'n'};

print "user name is $uname name is $name \n";


sub usage
{
	print $_[0] . "\n" ;
	exit 1;
}
