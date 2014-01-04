#!/usr/bin/perl

# $Id: Fragment.t 9805 2012-09-10 15:37:54Z don.johnson $

use lib "..";
use Test::More;

use SML::Fragment;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

BEGIN { use_ok( 'SML::Fragment' ); }

my $object = SML::Fragment->new(filespec=>'Fragment.t');
ok( defined $object, 'new() returned something' );

done_testing()
