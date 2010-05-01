#!/usr/bin/perl -w
use strict;

use WWW::Mechanize;
use Mail::SendEasy;

my $mech = WWW::Mechanize->new(autocheck => 1);

my $start = qq|https://services.aamc.org/eras/myeras2006/index.cfm|;

$mech->get($start);
$mech->field('aamc_id','12172971');
$mech->field('Password','comment');
$mech->submit(); # to get login cookie
$mech->follow_link(url_regex => qr/Messages/i );

# Assign the page content to $page
#my $page = $mech->content;

my $prevTotal = 1000;

while (1)
{
	#get all links that have "Subject" in them
	my @msgList = $mech->find_all_links(text_regex => qr/Subject:/i);

	#count the elements in the array
	my $msgCount = @msgList;
	if ($msgCount > $prevTotal) { 
		sendMail('oksanaz@hotmail.com'); 
		sendMail('6469423283@vtext.com'); 
	}
	$prevTotal = $msgCount;

	print "Total count: " . $msgCount . "\n";
	for (my $i=0; $i<@msgList; $i++)
	{
		print $msgList[$i]->text() . "\n";
	}

	sleep 210;

	$mech->reload();
}

sub sendMail
{

    my $to = $_[0];
    my $from = 'ikantor@caxton.com';

    my $msgToSend = "New msg on ERAS!";

    my $mail = new Mail::SendEasy(
	    smtp => 'cnyexchfe01' ,
	    ) ;

    my $status = $mail->send(
	    from    => $from ,
	    from_title => 'ERAS' ,
	    reply   => $from ,
	    error   => $from ,
	    to      => $to ,
	    subject => "ERAS" ,
	    msg     => "$msgToSend" ,
	    html    => "<b>$msgToSend</b>" ,
	    msgid   => "0101" ,
	    ) ;

    if (!$status) { print $mail->error ;}

}

