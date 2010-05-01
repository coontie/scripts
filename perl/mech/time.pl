#!/usr/bin/perl -w
use strict;

use WWW::Mechanize;
#use Mail::SendEasy;

my $mech = WWW::Mechanize->new(autocheck => 1);

my $start = qq|https://mtclocks.wachovia.net/clocks/Gatekeeper|;

$mech->get($start);
my @forms = $mech->forms();
foreach my $form (@forms) {
    print $form->dump() . " \n";
}
