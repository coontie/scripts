#!/bin/bash
cd /home/ig/perl/database
. /home/ig/sybase/32bit/SYBASE.sh
./graphs.pl
scp graphs/* cib-labmsg01.usa.wachovia.net:/srv/www/htdocs/ems/graphs/
