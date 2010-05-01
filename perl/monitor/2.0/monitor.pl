#!/usr/bin/perl -w


use IO::Socket;

#get a list of things to be monitored -- see below
getConfig();

my $host = 'oxygen'; 
my $port = 4444;


#log what to monitor

while(($key, $value) = each(%thingsToMonitor)) {
	#print "$key => $value\n";
	if ($value)
	{
		print "we are monitoring $key \n";
		getData($key);
	}
}


#what to monitor.  Now set through a hash, in the future will get info
#from a local config file or a network-based XML config file retrieval
sub getConfig
{
	%thingsToMonitor=(
		'CPU',		'1',
		'MEMORY',	'1',
		'DISK',		'0',
	);
}

sub getData
{
	my $thingToMonitor=$_[0];
	#print "getting data for $thingToMonitor \n";
	if ($thingToMonitor eq "CPU")
	{
		#open (UPTIME_PIPE, "uptime|awk '{i=NF;print $i}'|");
		#$counter=0;
		#while (<UPTIME_PIPE>)
		#{
		#	chomp;
		#	@hostUptime	= split(' ', $_);
		#	#9th value is the 15min average
		#	$value		= $hostUptime[9];
		#	#submit the info to the server
		#	submit($value);
		#	print $value;
		#	$counter++;
		#}
		my $value=`uptime|awk '{print \$NF}'`;
		submit($value);
	}
	#close (UPTIME_PIPE);
}

sub submit
{
	my $host = 'oxygen'; 
	my $port = 4444;
	my $value=$_[0];
	my $server = IO::Socket->new(
		Domain   => PF_INET,
		Proto     => 'tcp',
		PeerAddr => $host,
		PeerPort => $port,
	);

	print $server $value;
	close $server;
}

