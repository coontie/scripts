#!/usr/bin/perl -w

  use IPC::ShareLite;

  $share = new IPC::ShareLite( -key     => 1971,
                               -create  => 'no',
                               -destroy => 'yes' ) or die $!;

  $str = $share->fetch;
  #$share->store("");
print $str;
