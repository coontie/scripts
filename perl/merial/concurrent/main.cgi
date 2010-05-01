#!/usr/bin/perl -w

use strict;
use CGI::FormBuilder;
use CGI qw(:all);
use CGI::Carp qw ( fatalsToBrowser );
use HTML::Table;
use GD::Graph::linespoints;
use Time::Interval;
use DBI;

#my $dbh = DBI->connect( 'dbi:Oracle:host=bptdev1o.merial.net;port=1533;sid=BPTDEV1', 'apps', 'deappsv1') || die "Database connection failed: $DBI::errstr";
my $dbh = DBI->connect( 'dbi:Oracle:host=am-usa39-lin203-vip.merial.net;port=1608;sid=BPTPRF71', 'apps', 'printer') || die "Database connection failed: $DBI::errstr";


#my $sql_getnames = qq{ select user_program_name from XXIT_PERF_PROG_PARAMS };
my $sql_getnames = qq{ SELECT DISTINCT DECODE (program_type, 'P', user_program_name, parent_user_program_name) display, program_type FROM xxit_perf_prog_params};

my $sth = $dbh->prepare($sql_getnames) || die "$sql_getnames prepare failed: $DBI::errstr";
$sth->execute() || die "execute failed.\n";

#my @program_list = $sth->fetchrow_array;
my %program_type;
my @program_name_list;

while (my @current_name = $sth->fetchrow_array) {
	#print "----------------------|name is $current_name[0] \n";
	push @program_name_list, $current_name[0] if (defined $current_name[0]);
	$program_type{$current_name[0]}=$current_name[1];
}

#my @program_list=('Merial Jacobson Ship Confirm Interface','Merial Jacobson Pick Request Interface','Interface Trip Stop');

push @program_name_list, 'Merial Sales Rep Assignment Table Population';

my $form = CGI::FormBuilder->new( submit => [qw(Display Execute_Program)], reset=>1 );

$form->field(name 	=> 'programs',
		options => \@program_name_list,
		multiple => 1,
		required => 1
);

$form->field(name       => 'table_data',
                label => 'Display raw data?',
                required => 1,
                value => 'Yes',
                options => [qw(Yes No)]);

$form->field(name       => 'display_graph',
                label => 'Display graph?',
                required => 1,
                value => 'No',
                options => [qw(Yes No)]);

#$form->field(name	=> 'database',
#		label => 'Pick an instance',
#		required => 1,
#		value => 'BPTDEV1',
#		options => [qw(BPTDEV1 BPTTST2)]);


if ($form->submitted eq 'Display' && $form->validate) {

	print header;
	my @request_id_array = ();
	my @total_runtime_array = ();
	my @data_array = ();

	foreach($form->field('programs')) {
		#create the table skeleton, border on, bg color light grey
		my $mainTable = new HTML::Table(-style=>'color: blue', -border=>1, -bgcolor=>'lightgrey');

		#set the top row to be a header, in bold
		$mainTable->addRow('CONCURRENT_PROGRAM_ID','REQUEST_ID','ACTUAL_START_DATE','ACTUAL_COMPLETION_DATE','TOTAL_RUNTIME');
		$mainTable->setRowHead(1);

		my $concurrent_program_id = '';

		my $graph = new GD::Graph::linespoints(1000,400);

		$graph->set(x_label => 'Request number', 
				y_label => 'Total Runtime (sec)', 
				markers => 7, 
				x_labels_vertical => 1,
				marker_size => .5) or die $graph->error;

		print "<p>Results for ". $_ . ":";
		print "<p>";

		my $sql_getresults = qq{select concurrent_program_id,request_id, to_char(actual_start_date,'DD-MON-YY HH24:MI:SS') as actual_start_date,
			to_char(actual_completion_date,'DD-MON-YY HH24:MI:SS') as actual_completion_date,
			to_char(to_date('00:00:00','HH24:MI:SS') + (actual_completion_date - actual_start_date), 'HH24:MI:SS')  "TOTAL_RUNTIME"
				from apps.fnd_concurrent_requests where concurrent_program_id in
				(select concurrent_program_id from apps.fnd_concurrent_programs_tl where user_concurrent_program_name = ? 
				and language='US' and PHASE_CODE = 'C' and STATUS_CODE = 'C')
				order by actual_start_date} ;

		my $csv_file_name = $_;
		$csv_file_name =~ s/\ /_/g;
		$csv_file_name = $csv_file_name.'.csv';
#		print "<p> file name is ".$csv_file_name;
		open (CSV_FILE,">/var/www/html/tmp/csvs/$csv_file_name") || die "cannot open $csv_file_name for writing";

		$sth = $dbh->prepare($sql_getresults) or die "Cannot prepare" . $dbh->errstr;
		$sth->execute($_) or die "Cannot execute" .$sth->errstr;
		while (my @row_array = $sth->fetchrow_array()) {
			$mainTable->addRow(@row_array);
			my $newLine = join (',',@row_array)."\n";
			print CSV_FILE $newLine;

			#request ID
			push @request_id_array, $row_array[2];
			
			#timing
			my ($days,$hours,$minutes) = split(/:/,$row_array[4],3);
			my $totalMinutes = convertInterval(days=>0,hours=>$hours,minutes=>$minutes,ConvertTo=>'minutes');
			push @total_runtime_array, $totalMinutes;
			$concurrent_program_id=$row_array[0];
		}	

		close (CSV_FILE);
		print '<a href="/tmp/csvs/'.$csv_file_name.'">'.$_.' in CSV format.</a>';
		print "<p>";

		my $filename = $concurrent_program_id.".png";

		#create the 2D array required for plotting
		@data_array = (\@request_id_array, \@total_runtime_array);

		#render the table
		$mainTable->print unless ($form->field('table_data') eq 'No');

		#output the graph
		open (IMG, ">/var/www/html/tmp/$filename") or die $!;
		binmode IMG;
		print IMG $graph->plot(\@data_array)->png unless (@total_runtime_array == 0);
		close IMG;

		print "<br> <img src=\"/tmp/$filename\">" unless ($form->field('display_graph') eq 'No');

		#reset the arrays back to empty
		undef $mainTable;
		undef @request_id_array;
		undef @total_runtime_array;
		undef @data_array;
	} #end of foreach

$dbh->disconnect();

} elsif ($form->submitted eq 'Execute_Program') {
	print header;
	print "<p>Submitting...<br>";
	foreach($form->field('programs')) {
		my $current_program_type = $program_type{$_};
		open (OUTFILE, ">/var/www/cgi-bin/concurrent/perf.sql");
		print OUTFILE "set serveroutput on size 10000 \n";
		print OUTFILE "exec xxit_perf_pkg.submit (\'$current_program_type\',\'$_\') \n"; 
		print OUTFILE "exit\n";
		close OUTFILE;
		print "Executing $_ ... \n";
		print "<pre>";	
		system ('/var/www/cgi-bin/concurrent/perf_test.sh');
		#print "EXECUTION FUNCTIONALITY CURRENTLY DISABLED!!!";
		system ('cat /var/www/cgi-bin/concurrent/perf.sql');
		print "</pre>";
	}

} else {
	print $form->render(header => 1);
}

