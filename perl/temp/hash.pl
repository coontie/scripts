#!/usr/bin/perl -w

use Data::Dumper;
@array = qw (a a b c);

print "initial array =  @array\n";

@nodups = sort ( keys %{{map {$_ => 1} @array}} );

print "no dups = @nodups \n";

%fooHash = map {$_ => 1} @array;
@dups = keys %{{map {$_ => 1} @array}};
@dups2 = keys %fooHash;

foreach $k (keys (%fooHash))
{
        print $k, "=>", $fooHash{$k}, "\n";
}

print "dups array: @dups \n";
print "dups2 array: @dups2 \n";
