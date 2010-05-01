#!/usr/bin/perl -w

@dirs = `ls`;

for $dir (@dirs)
{
	print "-".$dir;
}
