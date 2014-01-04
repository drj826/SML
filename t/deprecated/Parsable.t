#!/usr/bin/perl

# $Id: Parsable.t 10414 2012-10-08 15:06:48Z don.johnson $

use lib "..";
use Test::More;

use SML::Parsable;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

BEGIN { use_ok( 'SML::Parsable' ); }

done_testing()
