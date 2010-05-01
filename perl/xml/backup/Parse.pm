package Parse;

BEGIN
{
	use XML::Parser;
	use XML::SimpleObject;
	use Data::Dumper;
	use Exporter();

	@ISA = qw(Exporter);
	@EXPORT = qw(&init);
	sub init
	{
		my $file = 'config.3.xml';
		my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
		my $xmlobj = XML::SimpleObject->new( $parser->parsefile($file) );

		#this code traverses the entire config file.
		foreach $servers ($xmlobj->child("config")->children("server"))
		{
			print $servers->attribute('name');
			foreach $command ($servers->children('command'))
			{
				print $command->attribute('type') . " ";
			}
			print "\n____________________\n";
		}

	} #end of init sub
} #end of the package def

return 1;

END { }
