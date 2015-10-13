#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl->get_logger("sml.application");

use lib "../lib";

use SML::Library;

my $library = SML::Library->new(config_filename=>'test-library-1.conf');

my $division = $library->get_division('td-000020');

$logger->info( $division->dump_part_structure );

1;
