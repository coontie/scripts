#!/usr/bin/perl -w

use Compress::LZW;

open (OUTFILE, ">./out.txt");

my $fatdata = `ps -ef`;
my $compressed = compress($fatdata);
print OUTFILE "compressed $compressed \n";
my $origdata    = decompress($compressed);

close (OUTFILE);

#print "original $origdata \n";
