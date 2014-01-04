#!/usr/bin/perl

# $Id: Utilities.t 10414 2012-10-08 15:06:48Z don.johnson $

use lib "..";
use Test::More;

use Publish::Utilities;

BEGIN { use_ok( 'Publish::Utilities' ); }

my $object = Publish::Utilities->new();
ok( defined $object, 'new() returned something' );

done_testing()
