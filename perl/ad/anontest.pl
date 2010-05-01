#!/usr/bin/perl -w

use Net::LDAP;

$ldap = Net::LDAP->new('am-usa01-dc002.nam.merial.net') or die "$@";

#ANONYMOUS BIND
$mesg = $ldap->bind;

$mesg = $ldap->search(base	=> "OU=Users,OU=USA01,DC=nam,DC=merial,DC=net",
			filter	=> '(&(CN=Kantor\, Igor))');

$mesg->code && die $mesg->error;

foreach $entry ($mesg->entries) {$entry->dump;}

#disconnect the anon bind
$mesg = $ldap->unbind;
