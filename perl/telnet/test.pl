#!/usr/bin/perl -w
use Net::Telnet;
$t = new Net::Telnet (Timeout => 10,
                      Prompt => '/ $/');
$t->open("cnjlog01");
my $username = "ikantor";
$t->login($username, $passwd);
@lines = $t->cmd("who");
print @lines;
