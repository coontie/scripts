#!/usr/bin/perl -w

use strict;
use SOAP::WSDL;

my $soap = SOAP::WSDL->new(
    wsdl => 'file://home/tibco/perl/soap/MER_OTC_GetCustomerAccountInfo_Concrete.wsdl',
	outputxml => 'true',
 );

print $soap->call('Order_Status', inputMessage => {
				Order_Status_Input_Root => [
					Order_Status_Input_Row => [ {Customer_Id => 92214 } ]]} ) || die "soap call failed!";

