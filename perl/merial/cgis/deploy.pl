#!/usr/bin/perl
 
use strict;

# import module
use Getopt::Long;
use Digest::MD5;
use DBI;
 
my $dbh = DBI->connect( "dbi:SQLite:/home/tibco/perl/merial/deploy.db" ) || die "Cannot connect: $DBI::errstr";


#init the vars
my $domain;
my @projects;
my $all;

#this is used to force deployment regardless of the checksum match
my $force;

# get values
my $result = GetOptions ("domain=s" => \$domain,
			"project=s" => \@projects,
			"force" => \$force,
			"all" => \$all);
 
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

	#---------- new invocation hash computation section -------------
	#compute the hash of the xml file
	my $xmlHash = compute_hash($xmlFile);
	#compute the hash of the ear file
	my $earHash = compute_hash($earFile);
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
	if ($xmlHash eq $xmlHashDB) {
		#print " Checksum match for $xmlFile! \n";
		$skip = 1;
	} else
	{
		#print " Checksum mismatch for $xmlFile \n";
		$skip = 0;
	}

	#let's do the ear hashes now..
	if ($earHash eq $earHashDB) {
		#print " Checksum match for $earFile! \n";
		$skip = 1;
	} else
	{
		#print " Checksum mismatch for $earFile \n";
		$skip = 0;
	}

	#ok, now we have all the hashes compared and we know whether to skip or not.  We can now insert the new values into the DB
	$dbh->do( qq(insert into checksums (project,xml_hash,ear_hash) VALUES ("$project","$xmlHash","$earHash")) );


	#if -force was supplied, we're deploying anyway.
	$skip = 0 if defined $force;

	if ($skip == 0) {
		print "Deploying $project...\n";
		#this subroutine changes the RVD domain parameters to remote RV and changes the machine destination.  Values depend on the domain specified.
		#the change() sub below copies the original xml to /tmp!
		change ($sourceDir, $project);

		#deploy the project!
		system ("cd /var/www/cgi-bin/software/tibco/tra/5.5/bin/;./AppManage -deploy -ear $sourceDir/$project.ear -deployConfig /tmp/$project.xml -nostart -user meradmin -pw merial300 -domain $domain");
	} else
	{
		print "<br> Checksum match, skipping the deployment of $project \n";
	}

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

sub change {
	#note:  changes are made to a copy of the original xml, not to the original file
	my $sourceDir = shift;	
	my $projectName = shift;

	#original file -- stays intact
	my $filename = $sourceDir."/".$projectName."_".$domain.".xml";


	my %destinationHash = '';

	#dev settings
	$destinationHash{'MER_EAI_DEV'}{'machine'} = 'AM-USA01-tst13';
	$destinationHash{'MER_EAI_DEV'}{'daemon'} = 'tcp:am-usa01-tst13.internal.merial.com:7500';

	#int settings
	$destinationHash{'MER_EAI_INT'}{'machine'} = 'AM-USA01-tst11';
	$destinationHash{'MER_EAI_INT'}{'daemon'} = 'tcp:am-usa01-tst11.internal.merial.com:7500';

	#tst settings
	$destinationHash{'MER_EAI_TST'}{'machine'} = 'am-usa01-tst01';
	$destinationHash{'MER_EAI_TST'}{'daemon'} = 'tcp:am-usa01-tst01.internal.merial.com:7500';

	#tut settings
	$destinationHash{'MER_EAI_TUT'}{'machine'} = 'AM-USA01-TST09';
	$destinationHash{'MER_EAI_TUT'}{'daemon'} = 'tcp:am-usa01-tst09.internal.merial.com:7500';

	#tut settings
	$destinationHash{'MER_EAI_QA'}{'machine'} = 'am-usa01-tibq01';
	$destinationHash{'MER_EAI_QA'}{'daemon'} = 'tcp:am-usa01-tibq01.internal.merial.com:7500';

	#temp file -- gets modified
	my $tempfilename = "/tmp/$projectName".".xml";
	open (INFILE, $filename) || die "Cannot open $filename: $!";
	open (OUTFILE, ">$tempfilename") || die "Cannot open $tempfilename: $!";

	while (<INFILE>) {
		s|<daemon>tcp:7500</daemon>|<daemon>$destinationHash{$domain}{'daemon'}</daemon>|g;
		if (/machine/) {
			print OUTFILE "<machine>$destinationHash{$domain}{'machine'}</machine>\n";
		} else {
			print OUTFILE "$_";
		}
	}

	close INFILE;
	close OUTFILE;
}

sub compute_hash {
	my $filename = shift;
	open(FILE, $filename) or die "Can't open '$filename': $!";
	binmode(FILE);

	return Digest::MD5->new->addfile(*FILE)->hexdigest;
	close FILE;
}
