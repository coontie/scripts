#!/usr/bin/perl -w


use IO::Socket;

#get a list of things to be monitored -- see below
getConfig();

$platform = `uname`;
$hostname = `hostname`;
chomp($platform);
chomp($hostname);

#log what to monitor
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
		'CPU',		'1',
		'MEMORY',	'1',
		'DISK',		'0',
	);
	$monitoring_server = 'cnjlog01'; 
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

	if ($thingToMonitor eq "MEMORY")
	{
		my ($finalMemory, $totalMem, $usedMem, $freeMem) = 0;
		if ($platform eq "Linux")
		{
			open(FREEMEM_PIPE,"free|grep Mem|"); 
   			while (<FREEMEM_PIPE>) { 
      				chomp; 
      				@freememField  = split(' ', $_, 7); 
      				$totalMem      = $freememField[1]; 
      				$usedMem       = $freememField[2]; 
      				$freeMem       = $freememField[3]; 
      				$buffersMem    = $freememField[5]; 
			}
   			close(FREEMEM_PIPE);  
		#convert to percentages
		$percentFreeMem = (($freeMem + $buffersMem)/$totalMem) * 100;

		#round to two decimals
		$finalMemory = sprintf("%.2f", $percentFreeMem);
		}
		#print "$totalMem $usedMem $freeMem"."\n";
		
		if ($platform eq "SunOS")
		{
			$scanRate = `vmstat 1 2 | tail -1 | awk '{print $12}'`;
			$finalMemory = $scanRate;
		}
		
		#print "free percent is $roundedPercentFreeMem \n";

		#ship it off to server
		submit($thingToMonitor,$finalMemory,$hostname);
	}
}

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

