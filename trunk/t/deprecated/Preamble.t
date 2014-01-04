#!/usr/bin/perl

# $Id: Preamble.t 9805 2012-09-10 15:37:54Z don.johnson $

use lib "..";
use Test::More;

use SML::Preamble;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

BEGIN { use_ok( 'SML::Preamble' ); }

my $object = SML::Preamble->new();
ok( defined $object, 'new() returned something' );

done_testing()
