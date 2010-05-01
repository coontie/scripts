#!/usr/bin/perl 
# ioforkserv.pl 
use warnings;
use strict;

use IO::Socket;

# Turn on autoflushing
$| = 1;

my $port = 4444;

my $server = IO::Socket->new(
	Domain    => PF_INET,
	Proto     => 'tcp',
	LocalPort => $port,
	Listen    => SOMAXCONN,
	Reuse     => 1,
);

die "Bind failed: $!\n" unless $server;

# tell OS to clean up dead children
$SIG{CHLD} = 'IGNORE';

print "Multiplex monitoring server running on port $port...\n";
while (my $connection = $server->accept) {
	my $clientIPAddress = $connection->peerhost;
	my $clientPort = $connection->peerport;

	if (my $pid = fork) {
		close $connection;
		#print "Forked child $pid for new client $name:$port\n";
		next;   # on to the next connection
	} else {
	# child process  handle connection
	#print $connection "You're connected to the server!\n";


	#append .txt to the filename
	my $outputFileName = "./hosts/". $clientIPAddress. "\.txt";
	open (FH, ">>$outputFileName") or die ("Cannot open $outputFileName");
	my $currentDate=`date +'%m%d%y:%H%M%S'`;
	while (<$connection>) {
		#print "Client $name:$port says: $_";
		chomp($currentDate);
        #insert : instead of spaces
		s/\ /:/g;
		chomp;
		
		#print to file
		print FH "$currentDate:$_" . "\n";
	}
	close (FH);
	#print "Client $name:$port disconnected\n";
	$connection->shutdown(SHUT_RDWR);
	exit 0;
 	} #end of else
}


