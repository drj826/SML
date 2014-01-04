#!/usr/bin/perl

# $Id: DataElement.t 9805 2012-09-10 15:37:54Z don.johnson $

use lib "..";
use Test::More;

use Publish::DataElement;

BEGIN { use_ok( 'Publish::DataElement' ); }

my $object = Publish::DataElement->new(name=>'title');
ok( defined $object, 'new() returned something' );

done_testing()
