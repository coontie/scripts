#!/usr/bin/perl -w

use strict;
use File::Util;
use Data::Dumper;


my($f) = File::Util->new();
my(@files) = $f->list_dir('./messages/','--files-only');
my %container;

for my $file (@files) {
	print "processing $file \n";
	open (INFILE, "<./messages/$file");
	while (<INFILE>) {
		if (/ou=messaging/) {
		my @line = split(/,/, $_);
		my $ou = $line[1];
			if ($ou =~ /ou=1/) {
 				$container{$ou} = 0 unless defined ($container{$ou});
				$container{$ou}++;
			}
		#print "ou is $ou \n";
		}
	}
	close INFILE;
}
#print Dumper(%container);

my $total = 0;

for my $ou ( keys %container ) {
        my $value = $container{$ou};
        print "$ou was accessed $value times\n";
	$total = $total + $value;
}

print "Total acces: $total \n";
