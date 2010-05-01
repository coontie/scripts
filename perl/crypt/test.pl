#!/usr/bin/perl -w

use strict;

use Crypt::RSA;
use  Crypt::RSA::Key::Public;
use IO::Socket::Multicast;

#for outbound transmission
use constant DESTINATION => '239.9.9.9:2000'; 

#setup the outbound UDP mcast socket
my $socketOut = IO::Socket::Multicast->new(Proto=>'udp',PeerAddr=>DESTINATION);

#we can cross 1 routers at most
$socketOut->mcast_ttl(3);

my $rsa = new Crypt::RSA;

#my ($public, $private) = $rsa->keygen (Size => 512) or die $rsa->errstr();

my $public_key = new Crypt::RSA::Key::Public(Filename => 'keys/key.public');
$socketOut->send($public_key) || die "Couldn't send: $!";


