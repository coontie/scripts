#!/usr/bin/perl -w
use strict;

use Image::ExifTool;
use File::Find;

my $exifTool = new Image::ExifTool;
my $dir = "./";

#my @imgList = `ls -R *.jpg`;

find (\&process, $dir);

sub process ()
{
	if (-f and /jpg/) {
		my $img = $_;
		chomp $img;
		print "updating $img ";
		my $info = $exifTool->ImageInfo($img);
		my $stamp = $$info{'CreateDate'};
		print "extracted $stamp from $img \n";
		$_ = $stamp;
		s/://g;
		s/\ //g;
		my $newstamp = substr ($_,0,-2);
		print "setting date to $newstamp \n";

#	`touch -t $newstamp $img`;
	}
}

