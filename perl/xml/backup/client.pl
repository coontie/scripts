#!/usr/bin/perl -w
use IO::Socket::Multicast;
use threads;
use threads::shared;
use Data::Dumper;
use strict;

#make this variable accessible from all threads
my %toDoHash : shared;
my $hostname : shared = `hostname`;

my $getConfigThread = threads->new(\&getConfig); # Spawn the thread
$getConfigThread->detach; # Now we officially don’t care any more

#for outbound transmission
use constant DESTINATION => '226.1.1.1:2000'; 

#setup the outbound UDP mcast socket
my $socketOut = IO::Socket::Multicast->new(Proto=>'udp',PeerAddr=>DESTINATION);
#we can cross 3 routers at most
$socketOut->mcast_ttl(3);

my $counter = 0;

while (1)
{
	#iterate thru all the commands, submitting the results one by one
	foreach my $type (keys %toDoHash)
	{
		#print "need to run $toDoHash{$type} \n";
		my $result = `$toDoHash{$type}` unless ($toDoHash{$type} eq "OFF");
		#print "got back $result \n";
		my $final = "$hostname:$type:$result";
		#print "sending $final \n";
		$socketOut->send($final) || die "Couldn't send: $!";
		#print $counter++;
	}
	sleep 5;
}

sub getConfig
{
	#for inbound receiving
	use constant GROUP => '226.1.1.2';
	use constant PORT  => '2001';

	#setup the inbound UDP mcast socket
	my $socketIn = IO::Socket::Multicast->new(Proto=>'udp',LocalPort=>PORT);
	$socketIn->mcast_add(GROUP) || die "Couldn't set group: $!\n";

	chomp ($hostname);

	#this blocks until smth has arrived via multicast.  Once that happens, the vars are set
	#and off we go again, waiting for a transmission
	my $data = '';
	while (1) {
		$socketIn->recv($data,1024);
		chomp ($data);
		#since the data comes in :-separated, we chop it up using ':' as the delimiter
		my @parsedData = split /:/, $data;
		#is it for me?
		my $destination = $parsedData[0];
		#what kind of a thing I'm looking for -- serviceID/serviceUP|DOWN msgs, etc..
		my $commandType = $parsedData[1];
		#the actual command to run from the OS to get the value needed
		my $command	= $parsedData[2];

		#if the hostname as it came from the XML file matches
		#anything in the FQDN (which is what the local hostname may be), then it's for me!
		$_ = $hostname;
		if (/$destination/) {
			$toDoHash{$commandType} = $command;
			#print Dumper (%toDoHash);
		}
	}
}
