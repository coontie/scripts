#!/usr/bin/perl

use IO::Socket::Multicast;

#for inbound
use constant GROUP => '226.1.1.2';
use constant PORT  => '2001';

my $socketIn = IO::Socket::Multicast->new(Proto=>'udp',LocalPort=>PORT);
$socketIn->mcast_add(GROUP) || die "Couldn't set group: $!\n";

while (1) {
	my $data = '';
	$socketIn->recv($data,1024);
	chomp ($data);
	print "Recvd $data \n";
	print "______\n";
    }

