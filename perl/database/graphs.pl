#!/usr/bin/perl -w

use strict;

require 'save.pl';

use DBI;
use GD::Graph::linespoints;


my $dbh = DBI->connect( 'dbi:Sybase:ITSTEST',
                        'emsdbo',
                        'emsdbo1',
                      ) || die "Database connection not made: $DBI::errstr";

#list of servers to chart
open (SERVER_FILE, "<config/server.list") || die "can't open server file";

#list of metrics
open (METRIC_FILE, "<config/metrics.list") || die "can't open metrics file";

my @serverList = ();
my @metricList = ();

while (<SERVER_FILE>) {
    chomp;
    push @serverList, $_;
}

while (<METRIC_FILE>) {
    chomp;
    push @metricList, $_;
}

close SERVER_FILE;
close METRIC_FILE;

foreach my $server (@serverList) {
    foreach my $metric (@metricList) {
        my $sql = qq{ select TIMESTAMP,$metric
            from serverhistory where datediff(hour, TIMESTAMP, getdate()) < 36 and serverId=(select serverId from serverinfo where name='$server') 
            order by TIMESTAMP};

        #print "Executing the query $sql \n";
        my $sth = $dbh->prepare( $sql );
        $sth->execute();

        my( $TIMESTAMP, $result ) = 0;
        $sth->bind_columns( undef, \$TIMESTAMP, \$result );

        #current fow coming back from fetch()
        my @row = ();

        #future dataset to be plotted
        my @data = ();

        print "server: $server \n";
        while( $sth->fetch() ) {
#            print $TIMESTAMP .":".$result ." \n";
            $row[0] = $TIMESTAMP;
            $row[1] = $result;
            for (my $i = 0; $i <= $#row; $i++)
            {
                undef $row[$i] if ($row[$i] eq 'undef');
                push @{$data[$i]}, $row[$i];
            }
        }

        #pass a reference to data
        generate_graph(\@data,$server,$metric);
    }
}

sub generate_graph
{
    #de-ref
    my $dataRef = shift;
    my @data_to_plot = @$dataRef;

    my $serverName = shift;
    my $metric_to_plot = shift;

    my $min = 100;

    my $my_graph = new GD::Graph::linespoints(1100,500);

        $my_graph->set(
        x_label => 'Time',
        y_label => '',
        x_labels_vertical => 1,
        title => $serverName,
#        y_max_value => $max,
#        y_min_value => $min,
        x_label_skip => 10,
        marker_size => 1,
#       y_tick_number => 6,
#       y_label_skip => 6,
#       markers => [ 1, 5 ],

        transparent => 0,
    );

    $my_graph->set_legend($metric_to_plot);
    $my_graph->plot(\@data_to_plot)->gif;
    my $filename = $serverName.".".$metric_to_plot;
    save_chart($my_graph, "graphs/$filename");
}
