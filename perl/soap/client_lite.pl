#!/usr/bin/perl -w
use strict;


#use SOAP::Lite +trace => 'debug';
use SOAP::Lite;

#  print SOAP::Lite
#    -> uri('http://www.soaplite.com/Demo')                                     
#    -> proxy('http://services.soaplite.com/hibye.cgi')
#    -> hi()
#    -> result;

my $service = SOAP::Lite->service('file:/home/tibco/perl/soap/MER_OTC_GetCustomerAccountInfo_Concrete.wsdl');

my $data = {Order_Status_Input_Root => { Order_Status_Input_Row => { Customer_Id => '92214' }} };

print $service->Order_Status($data);

print "finished.  \n";
