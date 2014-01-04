#!/usr/bin/perl

# $Id: Storable.t 9805 2012-09-10 15:37:54Z don.johnson $

use lib "..";
use Test::More;

use SML::Storable;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

BEGIN { use_ok( 'SML::Storable' ); }

done_testing()
