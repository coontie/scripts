#!/usr/bin/perl -w

use IO::Socket::Multicast;

use strict;

#for outbound transmission
use constant DESTINATION => '239.9.9.9:2000'; 

#setup the outbound UDP mcast socket
my $socketOut = IO::Socket::Multicast->new(Proto=>'udp',PeerAddr=>DESTINATION);

#we can cross 3 routers at most
$socketOut->mcast_ttl(10);

my $final = "foo";

$socketOut->send($final) || die "Couldn't send: $!";

