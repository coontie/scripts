#!/usr/bin/perl -w

  use IPC::ShareLite;

  $share = new IPC::ShareLite( -key     => 1971,
                               -create  => 'yes',
                               -destroy => 'no' ) or die $!;

  $share->store("FOO");
  $str = $share->fetch;
print $str;
