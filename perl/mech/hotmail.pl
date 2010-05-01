#!/usr/bin/perl -w

use WWW::Hotmail;
  
  my $hotmail = WWW::Hotmail->new();
  
  $hotmail->login('coontie@hotmail.com', "")
   or die $WWW::Hotmail::errstr;
  
  my @msgs = $hotmail->messages();
  die $WWW::Hotmail::errstr if ($!);

  print "You have ".scalar(@msgs)." messages\n";

  for (@msgs) {
        print "messge from ".$_->from."\n";
        # retrieve the message from hotmail
 #       my $mail = $_->retrieve;
        # deliver it locally
 #       $mail->accept;
        # forward the message
 #       $mail->resend('myother@email.address.com');
        # delete it from the inbox
 #       $_->delete;
  }
  
