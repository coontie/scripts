#!/usr/bin/perl -w
use strict;
use WWW::Mechanize;

my $name = "Igor Kantor";
my $url = "http://directory.wachovia.net/corpdir/html/EmployeeSearch.html";
my $agent = WWW::Mechanize->new();

$agent->get($url);

$agent->form_name("searchForm");

$agent->field("SSt1",$name);

$agent->submit();

#print $agent->content;

my @links = $agent->find_all_links(url_regex => qr[/uid/]);

print @links;
