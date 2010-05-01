#!/usr/bin/perl -w

for (my $i=1; $i < 1000; $i++) {
#        my $time = time();
	my $y = sin($i) + sin(3*$i)/3 + sin(5*$i)/5 + sin(7*$i)/7 + sin(9*$i)/9;
        print $i .":". $y;
        print "\n";
}




