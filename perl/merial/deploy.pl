#!/usr/bin/perl
 
use strict;

# import module
use Getopt::Long;
use Digest::MD5;
use DBI;
 
my $dbLocation = '/var/www/cgi-bin/deploy.db';
#my $dbLocation = '/home/tibco/perl/merial/deploy.db';

my $dbh = DBI->connect( "dbi:SQLite:$dbLocation" ) || die "Cannot connect: $DBI::errstr";


#init the vars
my $domain;
my $username;
my @projects;
my $all;

#this is used to force deployment regardless of the checksum match
my $force;

# get values
my $result = GetOptions ("domain=s" => \$domain,
			"username=s" => \$username,
			"project=s" => \@projects,
			"force" => \$force,
			"all" => \$all);
 
my $domainAdminUsername = 'meradmin';

#however, change it for some env, leave alone for all others.
$domainAdminUsername = 'meradmin_qa' if ($domain eq 'MER_EAI_Q01');
$domainAdminUsername = 'meradmin_dev' if ($domain eq 'MER_EAI_DEV');
$domainAdminUsername = 'meradmin_tut' if ($domain eq 'MER_EAI_TUT');

#default Merial domain admin password
my $domainAdminPassword = 'merial300';


#domain must be specified!
usage ("Missing --domain option! \n") unless defined $domain;

#where projects live
my $sourceDir = '/mnt/deploy/DEPLOYMENT/'.$domain;

if (defined @projects) {
	#-project and -all are mutually exclusive!
	#bail out if user gave both.
	usage ("Cannot specify both -all and -project! \n") if defined $all;

	#we're here, that means a project has been specified.  Good -- else clause below will be skipped.
} else 
{
	#ok, so -project is not specified.  How about -all?
	#fail if not
	usage ("Must specify either -project or -all! \n") unless defined $all;

	#right, so -all is specified, let's build @projects from the domain dir
	opendir (DIR,$sourceDir);
	@projects = grep(/\.ear$/,readdir(DIR));
	closedir(DIR);

	#we need to get rid of the .ear extension because the project name is also used to create the .xml path
	foreach (@projects) {
		s/\.ear//g;
	}
	
	#ok, now we have a list of all ear files for that domain!  Let's proceed...
}

#who am i?
my $currentUser = `/usr/bin/whoami`;

#print "<p>Running as $currentUser";


#every project must have a corresponding xml.  If no xml = exit.
print "<br> Checking to make sure the xml files are there...\n ";

foreach my $project (@projects) {
	#build the path to the required xml file
	my $xmlFile = $sourceDir.'/'.$project."_".$domain.".xml";
	my $earFile = $sourceDir.'/'.$project.".ear";

	if (-e $xmlFile) {
		print "<br>Found <tt>$xmlFile</tt> \n";
	} else {
		print "<p><b>Missing $xmlFile - exiting! \n</b>";
		die ("\n");
	}

	#do not skip by default!
	my $skip = 0;

	my ($xmlHash,$earHash) = '';

	#---------- new invocation hash computation section -------------
	#compute the hash of the xml file
	$xmlHash = compute_hash($xmlFile);
	#compute the hash of the ear file
	$earHash = compute_hash($earFile);
	#---------- new invocation hash computation section end-------------

	#OK, now we have 2 new hashes.  Let's see if there is a match in the DB
	#get the old hash from the DB, and prepare the statements.  We only want 1 row and we're getting both hashes previously stored for a given project.
	my $select_statement = qq(select xml_hash,ear_hash from checksums where id=(select max(id) from checksums where project="$project"));

	#create the handle
	my $sth = $dbh->prepare ($select_statement);

	#make the execution plan for the statement
	$sth->execute() or die "Cannot execute" . $sth->errstr;

	#define the result vars and fetch the data.
	my ($xmlHashDB, $earHashDB);
	my @row_array = $sth->fetchrow_array();

	#first column is xml, second column is ear checksum
	$xmlHashDB = $row_array[0];
	$earHashDB = $row_array[1];

	#we'll compare the xml hashes first.  we set skip to 1 if match is found, 0 otherwise
	if (($xmlHash eq $xmlHashDB) && ($earHash eq $earHashDB)) {
#		print "<tt><br>Checksum match for $xmlFile! \n";
#		print "<p>$xmlHash : $xmlHashDB";
		$skip = 1;
	} else
	{
#		print "New files detected \n";
		$skip = 0;
	}

	print "<br>";



	#if -force was supplied, we're deploying anyway.
	$skip = 0 if defined $force;

	my $deploymentResult = 'SUCCESS';

	if ($skip == 0) {
		print "<p>Deploying $project...\n";
		print "<pre>";

		#deploy the project!
		print "<br>";
		#system ("cd /var/www/cgi-bin/software/tibco/tra/5.5/bin/;./AppManage -deploy -ear $sourceDir/$project.ear -deployConfig /tmp/$project.xml -nostart -user $domainAdminUsername -pw $domainAdminPassword -domain $domain");
		system ("cd /var/www/cgi-bin/software/tibco/tra/5.5/bin/;./AppManage -deploy -ear $sourceDir/$project.ear -deployConfig $xmlFile -nostart -user $domainAdminUsername -pw $domainAdminPassword -domain $domain");
		#print "<p>".$sourceDir,$project,$domainAdminUsername,$domainAdminPassword,$domain;
		if ($? != 0) {
			$deploymentResult = 'FAILURE';
			print "<p><p><b>Failure detected</b>, showing the today's errors:<br>";
			print "<p>ApplicationManagement.log:";
			system "tail -100 /home/tibco/software/tibco/tra/domain/$domain/logs/ApplicationManagement.log | grep -i error | grep \"`date '+%b %d'`\"";
			print "<p>Administrator.log:";
			system "tail -100 /home/tibco/software/tibco/tra/domain/$domain/logs/Administrator.log | grep -i error | grep \"`date '+%b %d'`\"";
			print "<p>Command: AppManage -deploy -ear $sourceDir/$project.ear -deployConfig $xmlFile -nostart -user $domainAdminUsername -pw $domainAdminPassword -domain $domain";
		}
		print "</pre>";
	} else
	{
		print "<br> Checksum match, skipping the deployment of $project \n";
	}

	#ok, now we have all the hashes compared and we know whether to skip or not.  We can now insert the new values into the DB
	$dbh->do( qq(insert into checksums (project,xml_hash,ear_hash,username,env,result) VALUES ("$project","$xmlHash","$earHash","$username","$domain","$deploymentResult")) );

	print "\n";
}

exit 0;

sub usage {
	my $message = shift;
	print $message;
	print "\n";
	print "USAGE: Multiple projects: ./deploy.pl --domain MyDomain --project MyProject1 --project MyProject2 \n";
	print "USAGE: All projects: ./deploy.pl --domain MyDomain --all \n";
	print "USAGE: To force deployment regardless of checksum: ./deploy.pl --domain MyDomain --all -force\n";
	die("\n");
}

sub compute_hash {
	my $filename = shift;
	open(FILE, $filename) or die "Can't open '$filename': $!";
	binmode(FILE);

	return Digest::MD5->new->addfile(*FILE)->hexdigest;
	close FILE;
}
