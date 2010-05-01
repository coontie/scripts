#!/usr/bin/perl -w

use strict;

use DBI;

my $dbh = DBI->connect( 'dbi:Sybase:ITSTEST',
                        'emsdbo',
                        'emsdbo1',
                      ) || die "Database connection not made: $DBI::errstr";
    

open (INFILE, "<1sdk.ts");

while (<INFILE>) {

    chomp ($_);
    my $currentObject = $_;
my $sql = qq{ select pendingMessageCount,pendingMessageSize from topichistory where name="$currentObject" and serverId=7 and TIMESTAMP between 'Jun 15 2007  7:30AM' and 'Jun 20 2007  7:30AM' };

#print "Executing the query $sql \n";
print "Analyzing $currentObject ...";
my $sth = $dbh->prepare( $sql );
$sth->execute();

my( $pendingMessageCount, $pendingMessageSize, @countArray, @sizeArray );
$sth->bind_columns( undef, \$pendingMessageCount, \$pendingMessageSize );

my $count = 0;

while( $sth->fetch() ) {
  #print $pendingMessageCount .":".$pendingMessageSize ." \n";
    push (@countArray,$pendingMessageCount);
    push (@sizeArray,$pendingMessageSize);
    $count++;
}

my ($average, $min, $max);

print "...DONE! \n";

@countArray = sort @countArray;
#pass by reference!
$average = sum(\@countArray) / $count;
$min = $countArray[0];
$max = $countArray[-1];

print "For $currentObject: \n";
print "Average pending messages: $average Min: $min  Max:  $max \n";

@sizeArray = sort @sizeArray;
#pass by reference!
$average = sum(\@sizeArray) / $count;
$min = $sizeArray[0];
$max = $sizeArray[-1];

print "Average size: $average Min: $min  Max:  $max \n";

$sth->finish();
print "__________________________\n";
}
$dbh->disconnect();

close INFILE;
sub sum
{
    my $localArray = shift;
    my $total = 0;

    #de-reference!
    foreach my $current (@$localArray) {
        $total = $total + $current;
    }
    return $total;
} 
