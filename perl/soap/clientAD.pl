#!/usr/bin/perl -w

use strict;
use SOAP::WSDL;

my $soap = SOAP::WSDL->new(
    wsdl => 'file://home/tibco/perl/soap/Authentication.wsdl' , 	outputxml => 'true'
 );

my $username = $ARGV[0];
my $password = $ARGV[1];

my $result = $soap->call('Authenticate_User-service', UserInput => {UserName => $username, UserPassword => $password, Domain => 'nam' });

print "\n $result \n";

