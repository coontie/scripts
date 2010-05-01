#!/usr/bin/perl -w


use Authen::Simple::ActiveDirectory;

my $ad = Authen::Simple::ActiveDirectory->new (
	host  => 'am-usa01-dc002.nam.merial.net',
	principal => 'nam.merial.net'
);

my $username = 'kantori';
my $password = 'mama';

if ( $ad->authenticate ($username, $password ) ) {
	print "Success!! \n";
	# successfull authentication
}
