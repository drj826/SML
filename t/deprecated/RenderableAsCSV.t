#!/usr/bin/perl

# $Id: RenderableAsCSV.t 9805 2012-09-10 15:37:54Z don.johnson $

use lib "..";
use Test::More;

use SML::RenderableAsCSV;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

BEGIN { use_ok( 'SML::RenderableAsCSV' ); }

done_testing()
