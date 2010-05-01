#!/usr/bin/perl -w

use strict;
use Crypt::OpenPGP::Key::Public;

open (FILEOUT, ">./pgp.txt");
my $public = Crypt::OpenPGP::Key::Public->new('RSA');

print $public;
print FILEOUT $public;

close (FILEOUT);
