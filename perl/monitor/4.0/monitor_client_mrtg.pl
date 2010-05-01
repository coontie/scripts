#!/usr/bin/perl -w

use IO::Socket;

#get a list of things to be monitored -- see below
getConfig();

my $platform = '';
$platform = `uname`;
$hostname = `hostname`;
chomp($platform);
chomp($hostname);

while(($key, $value) = each(%thingsToMonitor)) {
    #print "$key => $value\n";
	if ($value)
	{
		#print "we are monitoring $key \n";
		getData($key);
	}
}


#what to monitor.  Now set through a hash, in the future will get info
#from a local config file or a network-based XML config file retrieval
sub getConfig
{
	%thingsToMonitor=(
		'CPU',		'0',
		'MEMORY',	'0',
		'DISK',		'0',
		'NETWORK',	'1',
			);
	$monitoring_server = 'cnyitlin02'; 
	$port = 4444;
}

sub getData
{
	my $thingToMonitor=$_[0];
	#print "getting data for $thingToMonitor \n";
	if ($thingToMonitor eq "CPU")
	{
		#get the last value from uptime -- 15min avg
		my $value=`uptime|awk '{print \$NF}'`;
		submit($thingToMonitor,$value,$hostname);
	}

	if ($thingToMonitor eq "NETWORK")
	{
		#this file contains the list of all the routers
		#we want to monitor
		open (MASTERFILE, "</home/httpd/mrtg/wan_overview.html");
		while (<MASTERFILE>)
		{
			if (/HREF/)
			{
				chomp;
				@currentLine = split ('\/',$_);
				#prepend the correct absolute path
				#to get the location of the current router log files
				$wanRouter = "/home/httpd/mrtg/".$currentLine[1];
				#get all the log files for this router
				@wanRouterInterfaceList = `ls $wanRouter/*.log`;
				#print "wan file name is $wanRouter \n";
				#print "iface list is @wanRouterInterfaceList \n";
				foreach $interface (@wanRouterInterfaceList)
				{
					chomp($interface);
					#print "iface is $interface \n";
					@interfaceLine = split '\.', $interface;
					@routerLine    = split '\/', $interface;
					$interfaceName = $interfaceLine[6];
					$routerName 	= $routerLine[4];

					#print "interface name is $interfaceName router name is $routerName\n";
					#get the 2nd line from the top -- most recent values,
					#top line is all counters.
					$line = `head -2 $interface | tail -1`;
					@lineChopped		= split / /,$line;
					#print $line;
					chomp @lineChopped;
					#The maximum incoming transfer rate 
					#in bytes per second for the current interval
					$maxIncomingRate	= $lineChopped[3];

					#The maximum outgoing transfer rate 
					#in bytes per second for the current interval
					$maxOutgoingRate	= $lineChopped[4];
					#print "in= $maxIncomingRate , out= $maxOutgoingRate \n";
					$finalNetwork = $routerName." ".$interfaceName." ".$maxIncomingRate." ".$maxOutgoingRate;
					#print "$finalNetwork \n";
					submit($thingToMonitor,$finalNetwork,$hostname);
				}
			}
		} #end of while masterfile
		close (MASTERFILE);
	} #end of networking section
} #end of getData()

sub submit
{
		my $thingToMonitor=$_[0];
		my $value=$_[1];
		my $hostname = $_[2];
		my $server = IO::Socket->new(
						Domain   => PF_INET,
						Proto     => 'tcp',
						PeerAddr => $monitoring_server,
						PeerPort => $port,
						);
		die "Bind failed: $!\n" unless $server;
		my $final = $hostname . " " . $thingToMonitor . " " . $value;
		print $server $final;
		close $server;
}

