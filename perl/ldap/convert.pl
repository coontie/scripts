#!/usr/bin/perl -w

use strict;
use Getopt::Std;
my %options;
getopts('f:', \%options);

usage("Missing file name") unless $options{'f'};

my $importFile = $options{'f'};

open (IMPORT, "<$importFile") or die "file $importFile not found";

my ($uid, $gid, $ou, $unix_name, $given_name, $login_shell, $home_dir, $hosts_allowed);
my ($fName, $lName);

while (<IMPORT>)
{
		($uid, $gid, $ou, $unix_name, $given_name, $login_shell, $home_dir, $hosts_allowed) = split (':', $_);
		($fName, $lName) = split (" ", $given_name);
		print <<RESULT;

#$unix_name, $ou, composers.caxton.com
dn: uid=$unix_name,ou=$ou,dc=composers,dc=caxton,dc=com
givenName: $fName
sn: $lName
loginShell: $login_shell
uidNumber: $uid
gidNumber: $gid
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetorgperson
objectClass: posixAccount
objectClass: account
objectClass: shadowaccount
uid: $unix_name
cn: $given_name
homeDirectory: $home_dir
host: *

# $unix_name, Groups, composers.caxton.com
dn: cn=$unix_name,ou=Groups,dc=composers,dc=caxton,dc=com
cn: $unix_name
gidNumber: $uid
memberUid: $gid
objectClass: top
objectClass: posixgroup

RESULT

}

close (IMPORT);

sub usage {
    print "\n!! ",@_," !!\n";
    print <<USAGE;

Usage $0 -f colon_separated_file.txt

uid:gid:ou:unix_name:given_name:login_shell:home_dir:hosts_allowed

ou = Organizational Unit (must be created prior to the import!)

USAGE
    exit 1;
}
