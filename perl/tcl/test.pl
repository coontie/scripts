#!/usr/bin/perl -w
use IO::Socket::Multicast;
use threads;
use threads::shared;
use Data::Dumper;
use Tk;

use strict;

my $listenerThread = threads->new(\&listen);
$listenerThread->detach;

my $mainWindow = MainWindow->new;

share ($mainWindow);


$mainWindow->Button(-text => 'Exit',
		-command => [$mainWindow => 'destroy']
		)->pack;
MainLoop;

sub listen
{
#for inbound
	use constant GROUP => '226.1.1.1';
	use constant PORT  => '2000';

#subscribe to this mcast group
	my $socketIn = IO::Socket::Multicast->new(Proto=>'udp',LocalPort=>PORT);
	$socketIn->mcast_add(GROUP) || die "Couldn't set group: $!\n";

	while (1)
	{
		my $data = '';
		$socketIn->recv($data,1024);
		chomp ($data);
#since the data comes in :-separated, we chop it up using ':' as the delimiter
		my @parsedData = split /:/, $data;
#is it for me?
		my $destination = $parsedData[0];
		print "\n $destination \n";
		$mainWindow->Button(-text => $destination)->pack;
	}	
}
