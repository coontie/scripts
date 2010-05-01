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
$worksheetMAIN->write(0,1,'CONFIG FILE SUMMARY',$format);


my %column_to_name_map = (  0=>'SERVER NAME',
                            1=>'STORE MINIMUM',
                            2=>'STORE CRC',
                            3=>'MAX MESSAGE MEM',
                            4=>'LISTEN URL',
                            5=>'FLOW CONTROL',
                            6=>'LOG FILE',
                            7=>'MAX STAT MEMORY' );

my %column_to_value_map = ( # 0=>'server',
                            1=>'store_minimum',
                            2=>'store_crc',
                            3=>'max_msg_memory',
                            4=>'listen',
                            5=>'flow_control',
                            6=>'logfile',
                            7=>'max_stat_memory' );

#set the column headers
foreach my $key (sort keys %column_to_name_map) {
    $worksheetMAIN->write($currentRow,$key,$column_to_name_map{$key},$header);
}

$currentRow++;

#begin the file processing
foreach my $mainConfig (@serverListPath) {
    chomp $mainConfig;

    #from the path, extract the server name itself, it matches the dir name
    my @serverLine = split ('/', $mainConfig);
    my $server = $serverLine[7];

#   print "processing server $server \n";


    for (my $i = 0; $i < 8; $i++) {
        $worksheetMAIN->set_column($i, $i, 5);
    }
        $worksheetMAIN->set_column(6, 6, 60);

    print "opening file $mainConfig \n";
    open (INFILE, "<$mainConfig") || die "can't open $mainConfig";
    $worksheetMAIN->write($currentRow, 0, $server);
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
            foreach my $key (keys %column_to_value_map) {
#                $_=$name;
                if ($name eq $column_to_value_map{$key}) {
                     print "row: $currentRow key $key name: $name value: $value \n" unless (not defined ($value));
                    $worksheetMAIN->write($currentRow, $key, $value);
                }
            }
#            print $_;
        }  
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
