#!/usr/bin/perl -w
use CGI qw(:standard);
use HTML::Table;


use strict;

my $mainTable = new HTML::Table(-style=>'color: blue');

$mainTable->setBorder(3);

my $fullDate=`date`;
my $tibemsbin='/home/tibco/software/ems/bin/tibemsadmin';

#print header;
#print `whoami`;

print "<br><b>Merial EMS status report.  Generated on $fullDate";
print "<p>";
$mainTable->addRow("Server","Status","Connections","Pending Messages","Inbound","Outbound");

open (INFILE, "</var/www/cgi-bin/ems_url.list");

while (<INFILE>)
{
	chomp;
	my ($url,$password) = split(/,/);
	my $connections = '';
	my $status = '';
	my $emsReturnValue = '';
	my $uptime = '';
	my $pendMessages = '';
	my ($outbound,$inbound)  = '';

	#is the server up?
	system("$tibemsbin -server $url -user admin -password $password -script /var/www/cgi-bin/show.ems > /tmp/status.temp");

	if ($? == 0)
	{
	#yes it is,
	$uptime = process("Uptime");
	
	#let's get the num of pending messages
        $pendMessages = process("Messages");
	
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
	
