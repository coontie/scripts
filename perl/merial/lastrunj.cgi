#!/usr/bin/perl -wT

use strict;

print "Content-type: text/html \n\n";
print <<HEADER;
<html>
<head>
	<title>Deployments log</title>
	<link rel="stylesheet" href="/tablesorter/jq.css" type="text/css" media="print, projection, screen" />
	<link rel="stylesheet" href="/tablesorter/themes/blue/style.css" type="text/css" id="" media="print, projection, screen" />
	<script type="text/javascript" src="/tablesorter/jquery-latest.js"></script>
	
	<script type="text/javascript" src="/tablesorter/jquery.tablesorter.js"></script>
	<script type="text/javascript" src="/tablesorter/addons/pager/jquery.tablesorter.pager.js"></script>
	<script type="text/javascript">
	\$(function() {
		\$("table")
			.tablesorter({widthFixed: true, widgets: ['zebra']})
			.tablesorterPager({container: \$("#pager")});
	});
	</script>
</head>
<body>
<div id="main">
	<h1>Deployments:</h1>
	<div id="demo">
		<table cellspacing="1" class="tablesorter">
		<thead>
				<tr>
					<th>ID</th>
					<th>Project Name</th>
					<th>Date</th>
					<th>Username</th>
					<th>Environment</th>
					<th>Result</th>
				</tr>
			</thead>
HEADER

#start printing the table here:
my $dbLocation = '/var/www/cgi-bin/deploy.db';

use DBI;
my $dbh = DBI->connect( "dbi:SQLite:$dbLocation" ) || die "Cannot connect: $DBI::errstr";

#my $select_statement = qq(select id, project, time, env, result from checksums order by id desc limit 40);
my $select_statement = qq(select id, project, time, username, env, result from checksums order by id desc);

#create the handle
my $sth = $dbh->prepare ($select_statement);

#make the execution plan for the statement
$sth->execute() or die "Cannot execute" . $sth->errstr;
while (my @row_array = $sth->fetchrow_array()) {
	print "<tr>";
	print '<td>'.$row_array[0].'</td><td>'.$row_array[1].'</td><td>'.$row_array[2].'</td><td>'.$row_array[3].'</td><td>'.$row_array[4].'</td>'.'<td>'.$row_array[5].'</td>'."\n";
	print "</tr>";
}

print <<END
</table>
<div id="pager" class="pager">
	<form>
		<img src="/tablesorter/addons/pager/icons/first.png" class="first"/>
		<img src="/tablesorter/addons/pager/icons/prev.png" class="prev"/>
		<input type="text" class="pagedisplay"/>
		<img src="/tablesorter/addons/pager/icons/next.png" class="next"/>
		<img src="/tablesorter/addons/pager/icons/last.png" class="last"/>
		<select class="pagesize">
			<option selected="selected"  value="10">10</option>

			<option value="20">20</option>
			<option value="30">30</option>
			<option  value="40">40</option>
		</select>
	</form>
</div>

	</div>
</body>
</html>
END
