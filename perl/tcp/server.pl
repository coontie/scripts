#!/usr/bin/perl
use IO::Socket;

$server = IO::Socket::INET->new
(
    LocalPort => 1116,
    Type      => SOCK_STREAM,
    Reuse     => 1,
    Listen    => 5
) or die "Could not open port.\n";

my $client = $server->accept();

while (<$client>)
{
	print $_;
}
close($server);
