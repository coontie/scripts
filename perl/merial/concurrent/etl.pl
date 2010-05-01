#!/usr/bin/perl -w

use strict;
use DBI;
use Time::Interval;

#my $dbh = DBI->connect( 'dbi:Oracle:host=bptdev1o.merial.net;port=1533;sid=BPTDEV1',
#			'apps',
#			'deappsv1',
#my $dbh = DBI->connect( 'dbi:Oracle:host=bpttst2o.merial.net;port=1583;sid=BPTTST2',
#			'merview',
#			'bptview',
#			) || die "Database connection failed: $DBI::errstr";

my $dbh = DBI->connect( 'dbi:Oracle:host=am-usa39-lin203-vip.merial.net;port=1608;sid=BPTPRF71', 'apps', 'printer') || die "Database connection failed: $DBI::errstr";



my $sql_getnames = qq{select user_program_name from XXIT_PERF_PROG_PARAMS};
my $sth = $dbh->prepare($sql_getnames) || die "dbh prepare failed $DBI::errstr";
$sth->execute();

my @program_list;
while (my $current_name = $sth->fetchrow_array) {
#	print "--->$current_name \n";
	push @program_list, $current_name;
}

foreach my $program (@program_list) {
	my $concurrent_program_id = '';

	my $sql_getresults = qq{select concurrent_program_id,request_id, to_char(actual_start_date,'DD-MON-YY HH24:MI:SS') as actual_start_date,
			to_char(actual_completion_date,'DD-MON-YY HH24:MI:SS') as actual_completion_date,
			to_char(to_date('00:00:00','HH24:MI:SS') + (actual_completion_date - actual_start_date), 'HH24:MI:SS')  "TOTAL_RUNTIME"
				from apps.fnd_concurrent_requests where concurrent_program_id in
				(select concurrent_program_id from apps.fnd_concurrent_programs_tl where user_concurrent_program_name = ? 
				and language='US' and PHASE_CODE = 'C' and STATUS_CODE = 'C')} ;


	$sth = $dbh->prepare($sql_getresults) or die "Cannot prepare" . $dbh->errstr;
#	print "Executing query for $program \n";
	$sth->execute($program) or die "Cannot execute" .$sth->errstr;
	while (my @row_array = $sth->fetchrow_array()) {
		#timing
		my ($days,$hours,$minutes) = split(/:/,$row_array[4],3);
		my $totalMinutes = convertInterval(days=>0,hours=>$hours,minutes=>$minutes,ConvertTo=>'minutes');
		$concurrent_program_id=$row_array[0];
		print join (',',@row_array)."\n";
	}	

} #end of foreach
$dbh->disconnect();
