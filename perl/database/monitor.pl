#!/usr/bin/perl -w

use strict;

use DBI;
use Mail::SendEasy;


my $dbh = DBI->connect( 'dbi:Sybase:ITSTEST',
                        'emsdbo',
                        'emsdbo1',
                      ) || die "Database connection not made: $DBI::errstr";
    

my $sql = "set rowcount 1
           select upTime,TIMESTAMP from serverhistory where serverId=7 order by TIMESTAMP desc";

#print "Executing the query $sql \n";
#print "executing.. \n";
my $sth = $dbh->prepare( $sql );

my $prevUptime = 0;

my $complained = 0;
while (1) {
    $sth->execute();

    my( $upTime, $TIMESTAMP, );
    $sth->bind_columns( undef, \$upTime, \$TIMESTAMP );

    my $count = 0;

    while( $sth->fetch() ) {
        open (OUTFILE, ">>./monitor.log");
        my $log_entry = $upTime.":".$TIMESTAMP."\n";
        print OUTFILE $log_entry;
        close OUTFILE;
        if ($upTime > $prevUptime) {
            $prevUptime = $upTime;
            $complained = 0;
#            print "OK \n";
        } else {
#            print "complaining...\n" unless ($complained == 1);
            complain() unless ($complained == 1);
            $complained = 1;
        }
    }
    sleep 360;
}

sub complain
{
    my $to = 'cibtibco.engineering@wachovia.com';
    my $from = $to;
    my $msgToSend = "EMS monitor has stopped collecting data.";
    
    my $mail = new Mail::SendEasy(
        smtp => 'smtp.capmark.funb.com' ,
        ) ;
    
    my $status = $mail->send(
        from    => $from,
        from_title => 'Tibco' ,
        reply   => $from ,
        error   => $from ,
        to      => $to ,
        subject => $msgToSend,
        msg     => $msgToSend,
        html    => $msgToSend,
        msgid   => "0101" ,
        ) ;

    if (!$status) { print $mail->error ;}
}
