package RMDS;

my $name = "";

#constructor
sub new
{
	my $self = {};
	bless ($self);
	return $self;
}

sub setName
{
	shift;
	$name = shift;
}

sub getName
{
    return $name;
}

return 1;

