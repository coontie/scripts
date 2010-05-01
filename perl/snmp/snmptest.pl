#!/usr/bin/perl
use strict;
use Net::SNMP;
my ($session, $error) = Net::SNMP->session(
		-hostname  => shift || 'localhost',
		-community => shift || 'public',
		-port      => shift || 161 
		);
if (!defined($session)) {
	printf("ERROR: %s.\n", $error);
	exit 1;
}
my $sysUpTime = '1.3.6.1.2.1.1.3.0';
my $result = $session->get_request(
		-varbindlist => [$sysUpTime]
		);
if (!defined($result)) {
	printf("ERROR: %s.\n", $session->error);
	$session->close;
	exit 1;
}
printf("sysUpTime for host '%s' is %s\n",
		$session->hostname, $result->{$sysUpTime} 
      );
$session->close;
exit 0;
