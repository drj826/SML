#!/usr/bin/perl

# $Id: RenderableAsHTML.t 9805 2012-09-10 15:37:54Z don.johnson $

use lib "..";
use Test::More;

use SML::RenderableAsHTML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

BEGIN { use_ok( 'SML::RenderableAsHTML' ); }

done_testing()
