package Monitor;

#constructor
sub new
{
	my $self = {};
	bless ($self);
	return $self;
}

sub getConfig
{
	$self = shift;
	%thingsToMonitor=(
		'CPU',
		'MEMORY',
		'DISK'};
	$self->{monitorCPU}=0;
	$self->{monitorMEMORY}=1;
}

sub start
{
	if ($self->{monitorCPU})
	{
		print "monitor cpu \n";
	}
}

return 1;
