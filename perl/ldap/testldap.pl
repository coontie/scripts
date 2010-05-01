#!/usr/bin/perl -w

use strict;

use Net::LDAP;

my $server = "cnyldap01";

my $ldap = Net::LDAP->new($server) or "$@";

$ldap->bind("cn=admin,dc=composers,dc=caxton,dc=com", password=>"cLusTrX5");

#while(<>) {
#        chomp $_;
#        ($uid,$givenName,$sn,$mail) = split(/:/,$_);
        $cn="$givenName $sn";
        $dn="uid=$uid,ou=People,dc=leapster,dc=org";
        $result = $ldap->add($dn,
                attr => [ 'uid' => $uid,
                          'cn' => $cn,
                          'sn' => $sn,
                          'mail' => $mail,
                          'givenName' => $givenName,
                          'objectclass' => [ 'person', 'inetOrgPerson']
                        ]
           );
        $result->code && warn "error: ", $result->error;
}
