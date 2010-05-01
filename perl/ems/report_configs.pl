#!/usr/bin/perl -w
use strict;

use Spreadsheet::WriteExcel;

my $path = '/home/ig/scripts/ems/collect/configs';
my @serverListPath = `ls $path/*/*.conf`;

#my @serverList;

#foreach (@serverListPath) {
#    my $currentServer = `basename $_`;
#    chomp ($currentServer);
#    push(@serverList,$currentServer);
#}

#start with row 2 in the spreadsheet
my $currentRow = 2;

#new file
my $workbook = Spreadsheet::WriteExcel->new("results_config.xls");

#Add and define a format for the page title
my $format = $workbook->add_format(); # Add a format
$format->set_bold();
$format->set_color('red');
$format->set_align('center');

# Create a format for the column headings
my $header = $workbook->add_format();
$header->set_bold();
$header->set_size(9);
$header->set_color('blue');

my $worksheetMAIN = $workbook->add_worksheet('MAIN');

#set the titles of each workbook
$worksheetMAIN->write(0,0,'CONFIG FILE SUMMARY',$format);

$currentRow++;

#begin the file processing
foreach my $mainConfig (@serverListPath) {
    chomp $mainConfig;
    my $column = 0;

    print "opening file $mainConfig \n";
    open (INFILE, "<$mainConfig") || die "can't open $mainConfig";
    while (<INFILE>)
    {
        chomp;
        if ((/\#/) || (/^$/)) {
        } else {
            my @currentLine = split ('=', $_);
            my $name = $currentLine[0];
            my $value = $currentLine[1];
            #must trim leading/trailing spaces, o/w 'eq' below doesn't work
            $name = trim ($name);
            if (defined $value) {
                $value = trim ($value) }
            else { $value = ''});
            print "row: $currentRow col: $column val: $value \n" unless (not defined $value);
#            $worksheetMAIN->write($currentRow, $column, $value);
            }
        $column++;
    } #done with this file
    $currentRow++;
    #move onto the next file, next server, next row
    close (INFILE);
}

sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}
