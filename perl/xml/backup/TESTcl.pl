#!/usr/bin/perl
use IO::Socket::Multicast;

use strict;

#for outbound transmission
use constant DESTINATION => '226.1.1.1:2000'; 
#for inbound receiving
use constant GROUP => '230.34.5.143';
use constant PORT  => '58920';

my $socketOut = IO::Socket::Multicast->new(Proto=>'udp',PeerAddr=>DESTINATION);
my $socketIn = IO::Socket::Multicast->new(Proto=>'udp',LocalPort=>PORT);
$socketIn->mcast_add(GROUP) || die "Couldn't set group: $!\n";

getConfig();

sub getConfig
{
	my $data = '';
	$socketIn->recv($data,1024);
	if ($data eq "OK") { print "GOT IT! \n"; } else { getConfig(); }
}
