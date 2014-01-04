#!/usr/bin/perl

# $Id: Include.t 10414 2012-10-08 15:06:48Z don.johnson $

use lib "..";
use Test::More;

use Publish::Include;

BEGIN { use_ok( 'Publish::Include' ); }

my $object = Publish::Include->new();
ok( defined $object, 'new() returned something' );

done_testing()
