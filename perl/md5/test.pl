#!/usr/bin/perl -w

use Digest::MD5;

#my $file = shift || "/etc/passwd";
my $file = "/mnt/deploy/DEPLOYMENT/MER_EAI_DEV/ERP_EVENT_SERVICES_FR_MER_EAI_DEV.xml";
open(FILE, $file) or die "Can't open '$file': $!";
binmode(FILE);

print Digest::MD5->new->addfile(*FILE)->hexdigest, " $file\n";
