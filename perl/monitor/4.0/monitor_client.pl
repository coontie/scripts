#!/usr/bin/perl -w

use strict;

use IO::Socket;

#get a list of things to be monitored -- see below
getConfig();

#_____ where this stuff goes to_____
my $monitoring_server = 'oxygen.bstw.nc.fub.com'; 
my $port = 4444;
#________________________________

my $platform = '';
$platform = `uname`;
my $hostname = `hostname`;
chomp($platform);
chomp($hostname);

#log what to monitor

my ($key, $value, %thingsToMonitor);

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
		'NETWORK',	'1',
		'DISK',		'1',
		'DISK',		'1',
	);
}

sub getData
{
	my $thingToMonitor=$_[0];
	#print "getting data for $thingToMonitor \n";
	if ($thingToMonitor eq "CPU")
	{
		#get the last value from uptime -- 15min avg.  NF=last value
		my $value=`uptime|awk '{print \$NF}'`;
		submit($thingToMonitor,$value,$hostname);
	}

    #this does linux only!
    if ($thingToMonitor eq "NETWORK") {
	my ($networkRX, $networkTX) = 0;
	my @networkLine = '';
        open (NET_PIPE, "/bin/netstat -ni | grep eth0 |" );
        while (<NET_PIPE>) {
            chomp;
            @networkLine = split(' ', $_, 10);
            $networkRX = $networkLine[2];
            $networkTX = $networkLine[5];
        }
        my $final = $networkRX . " " . $networkTX;
        submit($thingToMonitor,$final,$hostname);
    }

	if ($thingToMonitor eq "DISK")
	{
		my $df = '';
		my ($percentageUsed, $fsName, $final) = '';
		my @freediskField = '';

		#force Linux to adhere to the Posix df output
		if ($platform eq "Linux")
		{
			$df = "df -Pl";
		}
		if ($platform eq "SunOS")
		{
			$df = "df -kl";
		}

		open (DISK_PIPE, "$df | grep % |" );
		while (<DISK_PIPE>)
		{
			chomp;
			@freediskField	= split(' ', $_, 6);
			$percentageUsed = $freediskField[4];
			$fsName		= $freediskField[5];
			$final 	= $fsName . " " . $percentageUsed;
			#print "fsname-percent" . $fsName, $percentageUsed, "\n";
			submit($thingToMonitor, $final, $hostname);
		}
		close(DISK_PIPE);
	}

	if ($thingToMonitor eq "MEMORY")
	{
		my ($percentFreeMem, $finalMemory, $totalMem, $usedMem, $freeMem, $buffersMem) = 0;
		my @freememField = '';
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
		
		my $vmstatOutput = 0;
		my @line = '';
		if ($platform eq 'SunOS')
		{
			$vmstatOutput = `vmstat 1 2 | tail -1`; 
			@line = split /\s+/, $vmstatOutput;
			#scan rate is the 12th field
			$finalMemory = $line[12];
		}
		
		#ship it off to server

		$finalMemory = $platform . " " . $finalMemory;

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

