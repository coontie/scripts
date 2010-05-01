#!/usr/bin/perl -w

use Mail::SendEasy;

my $to = 'igor.kantor@wachovia.com';
#my $to = 'aldrin.sorreda@wachovia.com';
my $from = 'igor.kantor@wachovia.com';

#my $msgToSend = $_[0];
my $msgToSend = "hi";

my $mail = new Mail::SendEasy(
		smtp => 'smtp.capmark.funb.com' ,
		) ;

my $status = $mail->send(
		from    => $from,
		from_title => 'Ig' ,
		reply   => $from ,
		error   => $from ,
		to      => $to ,
		subject => "hi" ,
		msg     => "$msgToSend" ,
		html    => "<b>$msgToSend</b>" ,
		msgid   => "0101" ,
		) ;

if (!$status) { print $mail->error ;}
