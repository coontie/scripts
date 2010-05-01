#!/usr/bin/perl -w

use strict;

use Crypt::RSA;
use Crypt::RSA::Key::Public;
use Crypt::RSA::Key::Private;
use Net::LDAPS;
use IO::Socket::Multicast;
use Benchmark::Timer;

#for outbound transmission
use constant DESTINATION => '239.9.9.9:2000'; 

#setup the outbound UDP mcast socket
my $socketOut = IO::Socket::Multicast->new(Proto=>'udp',PeerAddr=>DESTINATION);

#we can cross 1 routers at most
$socketOut->mcast_ttl(3);

#set who to send msgs to
my $hostname = $ARGV[0];

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

#we are only interested in publicKey attribute of the entry
my $attr = "publicKey";

#pop the entry off the stack, there's only one, no need for a while() loop
my $entry= $mesg->shift_entry;

#extract the public key from the entry
my $ldapPublicKey = $entry->get_value($attr);

#print "got $ldapPublicKey from ldap \n";
#we get back from ldap an assoc array of the RSA pub key
#we need to write it to a file so that it can be properly processed
#by Key::Public
open (TEMPFILE, ">./temp.tmp");
print TEMPFILE $ldapPublicKey;
close TEMPFILE;

my $publicKey = new Crypt::RSA::Key::Public ( Filename => './temp.tmp');
my $rmResult = `rm ./temp.tmp`;

#my $privateKey = new Crypt::RSA::Key::Private ( Filename => 'keys/cnyitlin03.key.private');
#$privateKey->reveal ( Password => 'caxton');


#print "encrypting... \n";

my $rsa = new Crypt::RSA;

my $timer = Benchmark::Timer->new ();
for (1 .. 100)
{
		$timer->start('tag');
		my $message = `ps -ef | sha1sum`;
		chomp $message;
		my $ciphertext = $rsa->encrypt(Message => $message, Key	=> $publicKey,) || die "encrypting bombed\n";
		$socketOut->send($ciphertext) || die "Couldn't send: $!";
		$timer->stop('tag');
}

print $timer->report;

#my $cleartext = $rsa->decrypt(Ciphertext => $ciphertext, Key => $privateKey,) || die "decrypting bombed\n";

#print "CLEAR TEXT is $cleartext \n";
