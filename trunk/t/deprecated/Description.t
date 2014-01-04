#!/usr/bin/perl

# $Id: Description.t 10414 2012-10-08 15:06:48Z don.johnson $

use lib "..";
use Test::More;

use Publish::Description;

BEGIN { use_ok( 'Publish::Description' ); }

my $object = Publish::Description->new();
ok( defined $object, 'new() returned something' );

done_testing()
