#!/usr/bin/perl -w
use IO::Socket::Multicast;
use XML::Parser;
use XML::SimpleObject;
use Data::Dumper;
use threads;
use threads::shared;
use Mail::SendEasy;

use Thread::Queue;
my $q = new Thread::Queue;

use strict;

my %masterHash = ();
my %prevReported = ();

#for outbound
use constant DESTINATION => '226.1.1.2:2001'; 

#for inbound
use constant GROUP => '226.1.1.1';
use constant PORT  => '2000';

my $socketOut = IO::Socket::Multicast->new(Proto=>'udp',PeerAddr=>DESTINATION);
my $socketIn = IO::Socket::Multicast->new(Proto=>'udp',LocalPort=>PORT);
$socketIn->mcast_add(GROUP) || die "Couldn't set group: $!\n";
$socketOut->mcast_ttl(3);

#master xml config file
my $file = 'config.xml';
my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
my $xmlobj = XML::SimpleObject->new( $parser->parsefile($file) );

#this thread publishes the config file over multicast every 15s
my $publishConfigThread = threads->new(\&publishConfig); # Spawn the thread
$publishConfigThread->detach; # Now we officially don’t care any more

#this thread receives the results from the clients and puts them on a queue for processing
my $receiveResults = threads->new(\&receiveResults); # Spawn the thread
$receiveResults->detach; # Now we officially don’t care any more

#main driver
while (1) {
    #only do stuff if there are items pending in the queue, o/w just loop endlessly
    if ($q->pending > 0) {
	my $mainData = $q->dequeue;
	my ($fromHost, $commandType, $value) = "";
	($fromHost, $commandType, $value) = ( split (/:/, $mainData) ) [0,1,2];
	$masterHash{$fromHost}{$commandType} = $value;
	foreach my $host (keys(%masterHash)) {
	    foreach my $cmdType (keys(%{$masterHash{$host}})) {
		#print "$host: $cmdType: $masterHash{$host}{$cmdType}\n";
		my $cmdRcvdValue = $masterHash{$host}{$cmdType};
		foreach my $servers ($xmlobj->child("config")->children("server")) {
		    my $server = $servers->attribute('name');
		    foreach my $command ($servers->children('command')) {
			$_ = $host;
			if (/$server/) {
			    my $commandAttribute = $command->attribute('type');
			    if ($commandAttribute eq $cmdType) {
				my $cmdExpValue = $command->child('expected_value')->value;
				$cmdRcvdValue = 'NOTHING' unless defined ($cmdRcvdValue);
				if ($cmdExpValue eq $cmdRcvdValue) {
				    #print "$cmdExpValue = $cmdRcvdValue \n";
				    if ( defined ($prevReported{$host}{$cmdType}) ) {
					if ($prevReported{$host}{$cmdType} eq 'TRUE') {
					    my $msg = "Previously reported problem with $cmdType on $host is now fixed.\n";
					    sendMail($msg);
					    logMsg($msg);
				        }
				    }
				    $prevReported{$host}{$cmdType} = 'FALSE';
				}
				else {
				    #complain unless Do Not Care is set -- this is a way to turn off monitoring
				    #for a given command. Also, do not complain the we got back an empty value,
					#we should always get smth back.
				    complain($host,$cmdType,$cmdExpValue,$cmdRcvdValue) unless ($cmdExpValue eq "DNC");
				}
			    } #end of if ($commandAttribute eq $cmdType)
			} #end of if (/$server/)
		    } #end of foreach my $command ($servers->children('command'))
		} #end of foreach my $servers ($xmlobj->child("config")->children("server")) 
	    } #end of foreach my $cmdType (keys(%{$masterHash{$host}})) 
	}
    }
}

sub complain
{
    my $problemHost    	= $_[0];
    my $problemCmd 	= $_[1];
    my $expectedValue  	= $_[2];
    my $valueGotInstead	= $_[3];
    #we have to set this in case the problem already exists upon server startup
    #which leads to $prevReported being undefined
    $prevReported{$problemHost}{$problemCmd} = 'FALSE' unless defined ($prevReported{$problemHost}{$problemCmd});
    #only complain if it hasn't been reported previously
    #that way we don't mailbomb people with the same problem.
    if ($prevReported{$problemHost}{$problemCmd} eq 'FALSE') {
	my $msg = "When $problemHost checked $problemCmd it expected $expectedValue but got $valueGotInstead instead. \n";
	sendMail($msg);
	logMsg($msg);
	$prevReported{$problemHost}{$problemCmd} = 'TRUE';
    }
}

sub logMsg
{
    open (LOGFILE, ">>./server.log");
    my $currentDate = `date`; 
    chomp ($currentDate);
    my $msgToLog = $_[0];
    print LOGFILE $currentDate . ":" . $msgToLog;
    close (LOGFILE);
}

sub sendMail
{

    my $to = 'ikantor@caxton.com';
    my $from = 'unix@caxton.com';

    my $msgToSend = $_[0];

    my $mail = new Mail::SendEasy(
	    smtp => 'cnyexchfe01' ,
	    ) ;

    my $status = $mail->send(
	    from    => 'unix@caxton.com' ,
	    from_title => 'RMDS Monitor' ,
	    reply   => $from ,
	    error   => $from ,
	    to      => $to ,
	    subject => "RMDS Problem report" ,
	    msg     => "$msgToSend" ,
	    html    => "<b>$msgToSend</b>" ,
	    msgid   => "0101" ,
	    ) ;

    if (!$status) { print $mail->error ;}

}

sub receiveResults
{
    while (1) {
	my $data = '';
	$socketIn->recv($data,1024);
	chomp ($data);
	$q->enqueue($data);
	#print "Recvd $data \n";
	#print "FROM THREAD: " . $q->pending . "items in the queue \n";
    }
}
	
sub publishConfig
{
    while (1) {
    #this code traverses the entire config file.
	foreach my $servers ($xmlobj->child("config")->children("server")) {
	    my $server = $servers->attribute('name');
	    foreach my $command ($servers->children('command')) {
		my $commandAttribute = $command->attribute('type');
		my $commandExecValue = $command->child('exec')->value;
		my $final = "$server:$commandAttribute:$commandExecValue";
		#print "publishing $final \n";
		$socketOut->send($final) || die "Couldn't send: $!";
	    }
	}
	sleep 5;
    } #end of while
} #end of publishConfig sub
