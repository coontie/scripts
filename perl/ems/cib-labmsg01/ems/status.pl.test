#!/usr/bin/perl -w
use CGI qw(:standard);
use HTML::Table;


use strict;

my $mainTable = new HTML::Table(-style=>'color: blue');

$mainTable->setBorder(3);

my $fullDate=`date`;
my $tibemsbin='/opt/tibco/ems/bin/tibemsadmin';
my $password='Sen4@pp3';

#print header;
print "<br><b>Wachovia EMS status report.  Generated on $fullDate";
print "<p>";
$mainTable->addRow("Environment","Status","Connections","Pending Messages","Inbound","Outbound");

open (INFILE, "<./ems_url.list");

while (<INFILE>)
{
	chomp;
	my $url=$_;
	my $connections = '';
	my $status = '';
	my $emsReturnValue = '';
	my $uptime = '';
	my $pendMessages = '';
	my ($outbound,$inbound) = '';

	#is the server up?
	system("$tibemsbin -server $url -user admin -password $password -script ./show.ems > /tmp/status.temp");

	if ($? == 0)
	{
	#yes it is,
	$uptime = process("Uptime");
	
	#let's get the num of pending messages
        $pendMessages = process("Messages");
	
	if ($url =~m/calypsorate1/) {
		$pendMessages = '<A HREF="graphs/cib-calypsorate1.gif">'.$pendMessages.'</A>';
	}

        if ($url =~m/calypsorate2/) {
                $pendMessages = '<A HREF="graphs/cib-calypsorate2.gif">'.$pendMessages.'</A>';
        }

	
	#now get the state
	$status = process("State");

	#lets get the total connections
        $connections = process("Connections");

	#Inbound Message Rate:
	$inbound = process("Inbound");

	#Outbound Message Rate
	$outbound = process("Outbound");

	} else
	{
		#no it is not up!
		$status = "TIMED OUT";	
		$connections = "-";
		$uptime = "-";
	}

	$mainTable->addRow($url,$status,$connections,$pendMessages,$inbound,$outbound);
}
$mainTable->print;
close (INFILE);

sub process {
	my $value = shift;
	my $emsReturnValue=`grep $value /tmp/status.temp`;
        chomp ($emsReturnValue);

        #it is the second value
        my @emsReturnValueArray = split (':', $emsReturnValue);
        my $returnValue = $emsReturnValueArray[1];
	return $returnValue;
}
	
