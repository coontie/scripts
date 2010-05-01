#!/usr/bin/perl -w

use Net::SSH::Perl;

my $host = "cnjvcs01";
my $user = "servermon";
my $pass = "s3v3rm0N";

my $cmd = "whoami";

my $ssh = Net::SSH::Perl->new($host);
$ssh->login($user, $pass);
my($stdout, $stderr, $exit) = $ssh->cmd($cmd);

while (<$stdout>)
{
	print $_;
}

