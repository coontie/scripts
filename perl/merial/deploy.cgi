#!/usr/bin/perl -w

use strict;
use CGI qw(param);
use CGI::Carp qw ( fatalsToBrowser );
use CGI::FormBuilder;
use CGI::Session;
use XML::Simple;
use Authen::Simple::ActiveDirectory;

#set up the connection to the MS Active Directory
my $ad = Authen::Simple::ActiveDirectory->new (
        host  => 'am-usa01-dc002.nam.merial.net',
        principal => 'nam.merial.net'
);


my $cgi = CGI->new;

my @projects = ();

#password check, set it to FAIL by default = 0
my $passwordOK = 0;

#extract the value submitted from the html form.
#NOTE: this is not how we're gonna get the value post-submission, we'll use ->cgi_param instead, see below
my $environment = $cgi->param('env');

#default Merial BW domain admin username, used for XML extraction only.
my $domainAdminUsername = 'meradmin';

#however, change it for Q01 env, leave alone for all others, used for XML extraction only.
$domainAdminUsername = 'meradmin_qa' if ($environment eq 'MER_EAI_Q01');

#default Merial domain admin password
my $domainAdminPassword = 'merial300';

#where the .ear files live
my $stagingArea = "/mnt/deploy/DEPLOYMENT/$environment";

#get a list of all .ear files
opendir(DIR, $stagingArea);
@projects = grep(/\.ear$/,readdir(DIR));
closedir(DIR);

#strip out the .ear extension
foreach (@projects) {
	s/\.ear//g;
}

#instantiate the form
my $form = CGI::FormBuilder->new(
	#needed for the $environment parameter that's coming from outside the form.  lost otherwise!
	keepextras => 1,
	text => "Deploying to $environment.",
	#submit => [qw(Deploy XML)],
	submit => [qw(Deploy)],
	reset  => 1
);

# Initialize session
my $session = CGI::Session->new('driver:File',
                                 $form->sessionid,
                                 { Directory=>'/tmp' });

#add the projects gleaned from the smb gather above
$form->field(name     => 'projects',
             options  => \@projects,
	     required => 1,	#<-- must select something
             multiple => 1);

#add the force binary option
$form->field(name	=> 'force',
		label => 'Force deployment?',
		required => 1,
		value => 'No',
		options => [qw(Yes No)]);

$form->field(name	=> 'username',
		label 	=> 'Username: ');

$form->field(name	=> 'password',
		label 	=> 'Password:',
		type	=> 'password');

if ($form->submitted eq 'Deploy' && $form->validate) {
	# Automatically save all parameters
        $session->save_param($form);

	#print the HTML header
	print "Content-Type: text/html\n\n";

	if (checkCreds($form->field('username'),$form->field('password'),$environment)) {
		#we need to get the target environment -- INT/QA or whatever.
		my $environment = $form->cgi_param('env');
		my $username = $form->field('username');
		print "<b>Please wait while your projects are deployed...</b>";
		foreach ($form->field('projects'))	 {
			deploy($_, $environment, $username);
		}

		print "<p> The log files for this deployment are located in<tt> /home/tibco/software/tibco/tra/domain/".$environment."/logs/ </tt>\n";
		print "<p><b>Done.</b>";
		print '<p><a href=/tibco/menu_deploy.html>Main menu</a>';
	}

} elsif ($form->submitted eq 'XML') {
	#we need to get the target environment -- INT/QA/DEV or whatever.
	my $environment = $form->cgi_param('env');

	#print the HTML header
	print "Content-Type: text/html\n\n";
        if (checkCreds($form->field('username'),$form->field('password'),$environment)) {
		foreach ($form->field('projects')){
			generate_xml($_, $environment);
		} 
	}
} else {
    # Ensure we have the right sessionid (might be new)
    $form->sessionid($session->id);

    print $form->render(header => 1);
}

sub deploy {
	my $deployment=shift;
	my $env = shift;
	my $username = shift;
	my $ignore_checksum = "--force" if ($form->field('force') eq "Yes");
	print "<p>Deploying $deployment...";
	system("/var/www/cgi-bin/deploy.pl --username $username --domain $env --project $deployment $ignore_checksum");
	#print "./deploy.pl --domain $env --project $deployment $ignore_checksum \n";
}

sub generate_xml {
	my $deployment=shift;
	my $env = shift;
	my $xml_location = '/mnt/deploy/DEPLOYMENT/'.$env.'/'.$deployment."_".$env.'.xml';
	if (-e $xml_location) {
		my $xml = XMLin($xml_location);
		my $ear_location = $xml->{name};
		print "<p>Syncing XML for ".$ear_location;
		print "<br>";
		#print "<p>AppManage -export -out /tmp/$deployment -app $ear_location -user meradmin -pw merial300 -domain $env ";
		system("cd /home/tibco/software/tibco/tra/5.5/bin/;/home/tibco/software/tibco/tra/5.5/bin/AppManage -export -out /tmp/$deployment -app $ear_location -user $domainAdminUsername -pw $domainAdminPassword -domain $env");
	} else
	{
		print "<p>--->$xml_location NOT FOUND!";
	}

	
	#system ("cd /var/www/cgi-bin/software/tibco/tra/5.5/bin/;./AppManage -export -out $xml_location -ear $ear_location");
	#print '<a href=/tibco/ear_xmls/'.$deployment.'.xml>'.$deployment.'</a><br>';
}

sub checkCreds {
	my $username = shift;
	my $password = shift;
	my $env = shift;
	if ( $ad->authenticate ($username, $password ) ) {
        	return 1;
        	# successfull authentication
	} else {
		print "<p>Wrong username or password entered!";
		return 0;
	}
}
