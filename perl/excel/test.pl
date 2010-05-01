#!/usr/bin/perl -w

use strict;
use Spreadsheet::ParseExcel;

my $file = '/home/tibco/perl/merial/france/france.xls';

my $excel = Spreadsheet::ParseExcel::Workbook->Parse($file);

#use FR Rice List sheet only!
my $sheet = ${$excel->{Worksheet}}[0];

printf("Sheet: %s\n", $sheet->{Name});
$sheet->{MaxRow} ||= $sheet->{MinRow};

foreach my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
        my $team = $sheet->{Cells}[$row][0];
        my $riceID = $sheet->{Cells}[$row][2];
	my $riceType = $sheet->{Cells}[$row][1];

	if ($riceType->{Val} eq 'Interface') {
        	print "row num: " . $row." team:".$team->{Val} . " rice ID: " . $riceID->{Val}. "\n";
	}
}
