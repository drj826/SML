#!/usr/bin/perl

# $Id: Narrative.t 9805 2012-09-10 15:37:54Z don.johnson $

use lib "..";
use Test::More;

use SML::Narrative;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

BEGIN { use_ok( 'SML::Narrative' ); }

my $object = SML::Narrative->new(id=>'my-narrative');
ok( defined $object, 'new() returned something' );

done_testing()
