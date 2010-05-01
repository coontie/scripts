#!/usr/bin/perl -w
use CGI qw(:standard);
use HTML::Table;
use Data::Dumper;
use Spreadsheet::WriteExcel;

#$debug = 1;

open (LOGFILE, ">report.log.txt");

$cpuTable = new HTML::Table;
$memoryTable = new HTML::Table;
$diskTable = new HTML::Table;
$networkTable = new HTML::Table;

$cpuTable->setBorder(3);
$memoryTable->setBorder(3);
$diskTable->setBorder(3);
$networkTable->setBorder(3);

$todayDate=`date +'%m%d%y'`;
#$todayTime=`date +'%I%M%S'`;
$fullDate=`date`;

$excelCPURow = 5;
$excelMEMRow = 5;
$excelDISKRow = 5;
$excelNETWORKRow = 5;


#print header;
print "<br>Please, be patient.  It takes a few minutes to generate the report -- over 10 million lines are parsed.";
print "<p>".$fullDate."</p>";
print "<p><b>Caxton performance report</b>";
print "<p>";

#clear out the pervious run
unlink("report.xls");

#retreive the 1st parameter from the command line
$thresholdCPU	= $ARGV[0];

#It's the 2nd param from the command line.
#If free memory percentage drops below this number, count it.
$thresholdMem	= $ARGV[1];

$thresholdDisk  = $ARGV[2];

@listOfFilesToProcess = `ls hosts/*.txt`;

#----------------------------Excel setup--------------------------
#Create a new Excel workbook

my $workbook = Spreadsheet::WriteExcel->new("report.xls");

#Add a worksheet
$worksheetCPU = $workbook->add_worksheet('CPU');
$worksheetMEM = $workbook->add_worksheet('MEMORY');
$worksheetDISK = $workbook->add_worksheet('DISK');
$worksheetNETWORK = $workbook->add_worksheet('NETWORK');

#Add and define a format for the page title
$format = $workbook->add_format(); # Add a format
$format->set_bold();
$format->set_color('red');
$format->set_align('center');

# Create a format for the column headings
my $header = $workbook->add_format();
$header->set_bold();
$header->set_size(12);
$header->set_color('blue');

#machine name
$worksheetCPU->set_column(0, 0,  15);
$worksheetMEM->set_column(0, 0,  15);
$worksheetDISK->set_column(0, 0,  15);
$worksheetNETWORK->set_column(0, 0,  20);
#counter
$worksheetCPU->set_column(1, 1,  20);
$worksheetMEM->set_column(1, 1,  20);
$worksheetDISK->set_column(1, 1,  20);
$worksheetNETWORK->set_column(1, 1,  20);
#comments
$worksheetCPU->set_column(2, 2,  35);
$worksheetMEM->set_column(2, 2,  35);

#inbound
$worksheetNETWORK->set_column(2, 2,  30);
#outbound
$worksheetNETWORK->set_column(3, 3,  30);
#net comments
$worksheetNETWORK->set_column(4, 4,  35);
#-----
#FS percentage
$worksheetDISK->set_column(2, 2, 25);

#disk comments
$worksheetDISK->set_column(3, 3, 25);

$worksheetCPU->write(0,1,'Caxton CPU systems report',$format);
$worksheetMEM->write(0,1,'Caxton MEMORY systems report',$format);
$worksheetDISK->write(0,1,'Caxton DISK systems report',$format);
$worksheetNETWORK->write(0,1,'Caxton NETWORK systems report',$format);

$worksheetCPU->write($excelCPURow,0,'Server Name',$header);
$worksheetCPU->write($excelCPURow,1,'CPU Shortages',$header);
$worksheetCPU->write($excelCPURow,2,'Comments',$header);

$worksheetMEM->write($excelMEMRow,0,'Server Name',$header);
$worksheetMEM->write($excelMEMRow,1,'Memory Shortages',$header);
$worksheetMEM->write($excelMEMRow,2,'Comments',$header);

$worksheetDISK->write($excelDISKRow,0,'Server Name',$header);
$worksheetDISK->write($excelDISKRow,1,'File System Name',$header);
$worksheetDISK->write($excelDISKRow,2,'Utilization percentage',$header);
$worksheetDISK->write($excelDISKRow,3,'Comments',$header);

$worksheetNETWORK->write($excelNETWORKRow,0,'Router Name',$header);
$worksheetNETWORK->write($excelNETWORKRow,1,'Interface Name',$header);
$worksheetNETWORK->write($excelNETWORKRow,2,'Inbound max (bytes/sec)',$header);
$worksheetNETWORK->write($excelNETWORKRow,3,'Outbound max (bytes/sec)',$header);
$worksheetNETWORK->write($excelNETWORKRow,4,'Comments',$header);

$excelCPURow++;
$excelMEMRow++;
$excelDISKRow++;
$excelNETWORKRow++;

close(LOGFILE);

#----------------------------Excel setup--------------------------

#this is a hash of hashes of a hash, storing routerName->ifaceName->{inbound,outbound} values
my %networkHash = ();

foreach $file (@listOfFilesToProcess)
{
open (INFILE, "<$file");

#these keep track of how many times machines have exceeded threshold
my $problemCPUCounter 		= 0;
my $problemMemoryCounter 	= 0;
my %fsHash = ();


while (<INFILE>)
{
	chomp;

	#FS util number contains % -- get rid of them
	s/\%//g;

	@currentLine = split(':', $_);

	$currentDate		= $currentLine[0];
	#$currentTime		= $currentLine[1];
	$currentHostname	= $currentLine[2];

	#determines what we are looking at -- CPU/Memory/DISK/whatever
	$currentType		= $currentLine[3];

	#when the type is MEMORY, this is the platform type
	#when the type is DISK, this is the file system name
	#when the type is NETWORK, this is the router name
	$currentValue		= $currentLine[4];

	#if type is memory, this is either the scan rate or the free memory
	#if network, then this is the interface name on the router
	$currentUtilized	= $currentLine[5];

	#print "curType is $currentType currentHostname is $currentHostname currentValue is $currentValue \n";


	if (($currentType eq "CPU") and ($currentValue >= $thresholdCPU))
	{
		#Woa -- this is a hash of hashes.
		#notice that the counter is first ++ by 1, THEN stored
		$listOfHostsWithProblems{$currentHostname}->{$currentType} = ++$problemCPUCounter; 
		#print "adding 1 $currentType event to $currentHostname \n";
	}

	if ($currentType eq "NETWORK")
	{
		$currentInbound = $currentLine[6];	
		$currentOutbound= $currentLine[7];
		$currentRouterName	= $currentValue;
		$currentInterfaceName	= $currentUtilized;

		#initialize the entire hash to zeros
		$networkHash{$currentRouterName}{$currentInterfaceName}{'INBOUND'} = 0 unless defined $networkHash{$currentRouterName}{$currentInterfaceName}{'INBOUND'};
		$networkHash{$currentRouterName}{$currentInterfaceName}{'OUTBOUND'} = 0 unless defined $networkHash{$currentRouterName}{$currentInterfaceName}{'OUTBOUND'};

		#if the new value is larger than the stored value, set stored to new
		if ($networkHash{$currentRouterName}{$currentInterfaceName}{'INBOUND'} < $currentInbound)
		{
			$networkHash{$currentRouterName}{$currentInterfaceName}{'INBOUND'} = $currentInbound;
		}

		#if the new value is larger than the stored value, set stored to new
		if ($networkHash{$currentRouterName}{$currentInterfaceName}{'OUTBOUND'} < $currentOutbound)
		{
			$networkHash{$currentRouterName}{$currentInterfaceName}{'OUTBOUND'} = $currentOutbound;
		}
	} # end of type NETWORK

	if ($currentType eq "MEMORY") 
	{
		if (($currentValue eq "Linux") and ($currentUtilized <= $thresholdMem))
		{
			$listOfHostsWithProblems{$currentHostname}->{$currentType} = ++$problemMemoryCounter;
		}
	
		#remember, for SunOS we count all scan rates, no matter how small the number
		if (($currentValue eq "SunOS") and ($currentUtilized > 0))
		{
			$listOfHostsWithProblems{$currentHostname}->{$currentType} = ++$problemMemoryCounter;
		}
			
	}


	$fsHash{$currentHostname}{$currentValue} = 0 unless defined $fsHash{$currentHostname}{$currentValue};

	#Count each file system but only once per host, per day.
	#This is basically saying, if the type is disk and it's a today's report AND it has not been counted yet, count it.
	if (($currentType eq "DISK") and ($todayDate == $currentDate) and ($fsHash{$currentHostname}{$currentValue} == 0))
	{
	    if ($currentUtilized > $thresholdDisk)
	    {
		$diskTable->addRow($currentHostname, $currentValue, $currentUtilized);
		$worksheetDISK->write($excelDISKRow, 0, $currentHostname);
		$worksheetDISK->write($excelDISKRow, 1, $currentValue);
		$worksheetDISK->write($excelDISKRow, 2, $currentUtilized);

		#increment the row by 1
		$excelDISKRow++;

		#mark it as having been counted, so it is only counted once
		$fsHash{$currentHostname}->{$currentValue} = 1;
		#print "currentDate is $currentDate currentFreeSpace is $currentFreeSpace \n";
	    }
	} 
}

#print "\n";
}#end of foreach file
foreach my $router (keys(%networkHash))
{
	foreach my $interface (keys(%{$networkHash{$router}}))
	{
		$networkTable->addRow($router,$interface,$networkHash{$router}{$interface}{'INBOUND'},$networkHash{$router}{$interface}{'OUTBOUND'});
		$worksheetNETWORK->write($excelNETWORKRow, 0, $router);
		$worksheetNETWORK->write($excelNETWORKRow, 1, $interface);
		$worksheetNETWORK->write($excelNETWORKRow, 2, $networkHash{$router}{$interface}{'INBOUND'});
		$worksheetNETWORK->write($excelNETWORKRow, 3, $networkHash{$router}{$interface}{'OUTBOUND'});
		$excelNETWORKRow++;
	}
}

foreach my $host (keys(%listOfHostsWithProblems)) 
{
   foreach my $type (keys(%{$listOfHostsWithProblems{$host}})) 
   {
	#print "$host: $type: $listOfHostsWithProblems{$host}{$type}\n";
	if ($type eq 'CPU') {
   		$cpuTable->addRow($host,$listOfHostsWithProblems{$host}{$type});
		$worksheetCPU->write($excelCPURow,0,$host);
		$worksheetCPU->write($excelCPURow,1,$listOfHostsWithProblems{$host}{$type});
		$excelCPURow++;
	}

	if ($type eq 'MEMORY') {
		$memoryTable->addRow($host,$listOfHostsWithProblems{$host}{$type});
                $worksheetMEM->write($excelMEMRow,0,$host);
                $worksheetMEM->write($excelMEMRow,1,$listOfHostsWithProblems{$host}{$type});
                $excelMEMRow++;
 
	}
   }
}
#print Dumper(%networkHash);
print "<p>Download the report in Excel format <a href=\"\/reports\/report.xls\">here</a>";
print "<p>UNIX Servers with load factors above $thresholdCPU";
print "<br>";
$cpuTable->print;
print "<br>";
print "<p>";
print "UNIX Servers with memory issues";
$memoryTable->print;
print "<p>";
print "UNIX Servers with disk issues";
$diskTable->print;
print "<p>";
print "Network statistics";
$networkTable->print;
close (INFILE);
