#!/usr/bin/perl -w

use strict;
use Net::LDAPS;
use Crypt::X509;

#set who we are
my $hostname = "nitrogen";

#we are going secure
my $ldap = Net::LDAPS->new('cnyitlin02') or die "$@";

#only get servers
my $base = 'ou=Servers,dc=composers,dc=caxton,dc=com';

#do a search, get only our own entry (filter)
my $mesg = $ldap->search(
						port => '636',
						base => $base,
						filter => "cn=$hostname",
					);

#if code is non-zero, die immediately
die ldap_error_text($mesg->code) if $mesg->code;

#we are only interested in userCert attribute of the entry
my $attr = "userCertificate";

#pop the entry off the stack, there's only one
#no need for a while() loop
my $entry = $mesg->shift_entry;

print $entry->dn . "\n";
my $cert = $entry->get_value($attr);

my $decoded = Crypt::X509->new( cert => $cert);

#my $pub_key = $decoded->SigEncAlg;
my $pub_key = $decoded->pubkey;

print "key is $pub_key \n";
