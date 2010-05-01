#!/usr/bin/perl -w
use strict;

use Spreadsheet::WriteExcel;

my $path = '/home/ig/scripts/ems/collect/configs';
my @serverListPath = `ls -d $path/*`;

my @serverList;

foreach (@serverListPath) {
    my $currentServer = `basename $_`;
    chomp ($currentServer);
    push(@serverList,$currentServer);
}


foreach my $server (@serverList) {
    print "current server $server \n";

    #new file
    my $workbook = Spreadsheet::WriteExcel->new("results/$server.xls");

    #Add and define a format for the page title
    my $format = $workbook->add_format(); # Add a format
    $format->set_bold();
    $format->set_color('red');
    $format->set_align('center');

    # Create a format for the column headings
    my $header = $workbook->add_format();
    $header->set_bold();
    $header->set_size(9);
    $header->set_color('blue');

    my $worksheetUSERS = $workbook->add_worksheet('USERS');
    my $worksheetQUEUES = $workbook->add_worksheet('QUEUES');
    my $worksheetTOPICS = $workbook->add_worksheet('TOPICS');
    my $worksheetACL = $workbook->add_worksheet('ACL');
    
    #set the titles of each workbook
    $worksheetUSERS->write(0,1,'USERS',$format);
    $worksheetQUEUES->write(0,1,'QUEUES',$format);
    $worksheetTOPICS->write(0,1,'TOPICS',$format);
    $worksheetACL->write(0,1,'ACL',$format);

    my $currentRow = 2;

    #set the column headers
    $worksheetUSERS->write($currentRow,0,'USERNAME',$header);
    $worksheetUSERS->write($currentRow,1,'DESCRIPTION',$header);

    $worksheetQUEUES->write($currentRow,0,'NAME',$header);
    $worksheetQUEUES->write($currentRow,1,'PROPERTIES',$header);

    $worksheetTOPICS->write($currentRow,0,'NAME',$header);
    $worksheetTOPICS->write($currentRow,1,'PROPERTIES',$header);

    $worksheetACL->write($currentRow,0,'NAME',$header);
    $worksheetACL->write($currentRow,1,'USER',$header);
    $worksheetACL->write($currentRow,2,'PERMS',$header);

    $worksheetUSERS->set_column(0, 0,  15);
    $worksheetUSERS->set_column(1, 1,  60);

    $worksheetQUEUES->set_column(0, 0, 60);
    $worksheetQUEUES->set_column(1, 1, 60);

    $worksheetTOPICS->set_column(0, 0, 60);
    $worksheetTOPICS->set_column(1, 1, 60);
    
    $worksheetACL->set_column(0, 0, 60);
    $worksheetACL->set_column(1, 1, 60);
    $worksheetACL->set_column(2, 2, 60);

    open (INFILE, "< $path/$server/nested/users.conf");
    $currentRow++;
    while (<INFILE>)
    {
        chomp;
        if ((/\#/) || (/^$/)) {
        } else {
            my @currentLine = split (':', $_);
            my $name = $currentLine[0];
            my $description = $currentLine[2];
            $worksheetUSERS->write($currentRow, 0, $name);
            $worksheetUSERS->write($currentRow, 1, $description);
            $currentRow++;
        }  
    }
    close (INFILE);

    #reset the row counter
    $currentRow = 3;

    open (INFILE, "< $path/$server/nested/queues.conf");
    while (<INFILE>)
    {
#        print $_;
        chomp;
        if ((/\#/) || (/^$/)) {
        } else {
            my @currentLine = split;
            my $name = $currentLine[0];
            my $description = $currentLine[1];
#            print "user: $name desc: $description \n";
            $worksheetQUEUES->write($currentRow, 0, $name);
            $worksheetQUEUES->write($currentRow, 1, $description);
            $currentRow++;
        }  
    }
    close (INFILE);

    #reset the row counter
    $currentRow = 3;

    open (INFILE, "< $path/$server/nested/topics.conf");
    while (<INFILE>)
    {
#        print $_;
        chomp;
        if ((/\#/) || (/^$/)) {
        } else {
            my @currentLine = split;
            my $name = $currentLine[0];
            my $description = $currentLine[1];
#            print "user: $name desc: $description \n";
            $worksheetTOPICS->write($currentRow, 0, $name);
            $worksheetTOPICS->write($currentRow, 1, $description);
            $currentRow++;
        }  
    }
    close (INFILE);

    #reset the row counter
    $currentRow = 3;
    open (INFILE, "< $path/$server/nested/acl.conf");
    while (<INFILE>)
    {
        chomp;
        if ((/\#/) || (/^$/)) {
        } else {
            my @currentLine = split;
            my $name = $currentLine[0];
            #get rid of USER=
            my $user = substr $currentLine[1], 5;
            
            #get rid of PERM=
            my $perms = substr $currentLine[2], 5;

            #print "ACL: name $name user: $user perms: $perms \n";

            $worksheetACL->write($currentRow, 0, $name);
            $worksheetACL->write($currentRow, 1, $user);
            $worksheetACL->write($currentRow, 2, $perms);

            #only increment the row count if the perm is not ADMIN, o/w overwrite.
            $currentRow++ unless ($name eq "ADMIN");
            }  
    }
    close (INFILE);
}
