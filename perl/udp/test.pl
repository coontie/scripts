#!/usr/bin/perl -w

use IO::Socket;

$socket = IO::Socket::INET->new
(
    Proto => 'udp',
    PeerPort  => 48129,
    LocalPort => 48129,
    PeerAddr  => '24.105.129.50'
);

$socket->send('HELLO');
