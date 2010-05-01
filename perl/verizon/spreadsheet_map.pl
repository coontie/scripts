#!/usr/bin/perl -w

use strict;

use GraphViz;
use Spreadsheet::ParseExcel;

#source excel file
my $file = '/home/ig/downloads/verizon/InterfacesTraceabilityTemplate_Draft.xls';

my $excel = Spreadsheet::ParseExcel::Workbook->Parse($file);


my $height = 1.2;
my $width = 2;

my %hash = ();

my $edgeFontSize = 8;
my $nodeFontSize = 8;

#use req traceability matrix only.
my $sheet = ${$excel->{Worksheet}}[0];

printf("Sheet: %s\n", $sheet->{Name});
$sheet->{MaxRow} ||= $sheet->{MinRow};

foreach my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
        my $capabilityL1 = $sheet->{Cells}[$row][3]->{Val};
	my $capabilityL2 = $sheet->{Cells}[$row][6]->{Val};
        my $source = $sheet->{Cells}[$row][9]->{Val};
        my $destination = $sheet->{Cells}[$row][10]->{Val};
	print "L1: $capabilityL1 L2: $capabilityL2 src: $source dst: $destination\n";
}
