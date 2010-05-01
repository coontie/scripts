#!/usr/bin/perl -w
use Spreadsheet::WriteExcel;

# Create a new Excel workbook
my $workbook = Spreadsheet::WriteExcel->new("perl.xls");
# Add a worksheet
$worksheet = $workbook->add_worksheet();
#  Add and define a format
$format = $workbook->add_format(); # Add a format
$format->set_bold();
$format->set_color('red');
$format->set_align('center');
# Write a formatted and unformatted string, row and column notation.
$col = $row = 1;
$worksheet->write($row, $col, "Caxton Systems Report", $format);
# Write a number and a formula using A1 notation
#$worksheet->write('A3', "Server Name");
#$worksheet->write('B3', "Description");

$currentFile=`ls hosts/*.txt`;
open (INFILE, "<$currentFile") or die ("Cannot open $currentFile");;
$row = "A";
while (<INFILE>)
{
#	if (/CPU/)
#	{
		@splitLine = split (':');
		$lengthOfTheLine = $#splitLine;
		print $row;
		for ($i=0;$i<=$lengthOfTheLine;$i++)
		{
			print $splitLine[$i] . "-";
		}
#	}
	$row++;
	print "\n";
}
close (INFILE);
