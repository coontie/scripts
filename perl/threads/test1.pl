#!/usr/bin/perl -w
use threads;
           $thr = threads->new(\&sub1);

           @ReturnData = $thr->join;
           print "Thread returned @ReturnData";

           sub sub1 { return "Fifty-six", "foo", 2; }


