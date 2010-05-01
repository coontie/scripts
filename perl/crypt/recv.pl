#!/usr/bin/perl

use IO::Socket::Multicast;
use Crypt::RSA;

#for inbound
use constant GROUP => '239.9.9.9';
use constant PORT  => '2000';

my $socketIn = IO::Socket::Multicast->new(Proto=>'udp',LocalPort=>PORT);
$socketIn->mcast_add(GROUP) || die "Couldn't set group: $!\n";

while (1) {
		my $data = '';
		$socketIn->recv($data,1024);
		chomp ($data);
		print "Recvd $data \n";
		print "______\n";
}

