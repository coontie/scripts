#!/usr/bin/perl -w

use strict;
#use Data::Dumper;

my $inputFile = 'ANALYSIS_LAG.CSV';
#my $inputFile = 'test.csv';

my %columnHash = ('Index_IR'			=> 28,
					'Index_LOTORISK'	=> 30,
					'Index_RISK'		=> 29,
					'StDev'				=> 19,
					'Sum'				=> 20,
					'Turnover'			=> 27);

#my %columnHash = ('Index_IR'			=> 1,
#					'Index_LOTORISK'	=> 2,
#					'Index_RISK'		=> 3,
#					'StDev'				=> 4,
#					'Sum'				=> 5,
#					'Turnover'			=> 6);
#
my %prepHash = %columnHash;					
my $currentDate = '';

foreach my $outputFile (keys %columnHash) {
	print "creating the headers for $outputFile \n";
	my $outputFilename = "OUTPUT_" . $outputFile . ".csv";
	open (CURRENT_OUTFILE, ">$outputFilename");
	print CURRENT_OUTFILE "Date,";
	open (INFILE, $inputFile) || die "$inputFile file not found \n ";
	#true if this is the first line in the file
	my $topLine = 1;
	my $header = '';
	while (<INFILE>)
	{
		chomp;
		my @currentLine = split (',', $_);
		my $sorted_on = $currentLine[1]. ",";
		#fourth column is the date -- it is THIRD in the array (0-based arrays)
		#skip the top line
		#print CURRENT_OUTFILE $sorted_on unless $topLine == 1;
		$header = $header.$sorted_on unless $topLine == 1;
		$topLine = 0;
	}
	close INFILE;
	#remove the trailing comma
	$header=~s/,$//g;
	print CURRENT_OUTFILE $header."\n";
	close CURRENT_OUTFILE;
}

foreach my $outputFile (keys %columnHash) {
	my $tempRow = '';
	open (INFILE, $inputFile) || die "analysis file not found \n ";
	my $currentColumn = $columnHash{$outputFile};
	print "current col=".$currentColumn."=\n";
	#true if this is the first line in the file
	my $topLine = 1;
	while (<INFILE>) {
		chomp;
		my @currentLine = split (',', $_);
		$currentDate = $currentLine[3].",";
		#string the entries in one column together in a row, skipping the top line
		$tempRow = $tempRow.$currentLine[$currentColumn - 1]."," unless $topLine == 1;
		#print "current temp row =" . $tempRow ."=\n";
		$topLine = 0;
	}
	#remove trailing CRs
	$tempRow=~s///g;
	$tempRow=~s/,$//g;
	$prepHash{$outputFile} = $tempRow;
#	print Dumper(%prepHash);
}

foreach my $outputFile (keys %prepHash) {
	my $outputFilename = "OUTPUT_" . $outputFile . ".csv";
	open (CURRENT_OUTFILE, ">>$outputFilename");
	#open (INFILE, $inputFile) || die "analysis file not found \n ";
	print "creating $outputFilename \n";
	#write the finally assembled string to a file
	print CURRENT_OUTFILE $currentDate.$prepHash{$outputFile} ."\n";
}	

close INFILE;
print CURRENT_OUTFILE "\n";
close CURRENT_OUTFILE;

print "FINISHED. \n";

exit 0;

sub println
{
	print "\n";
}
