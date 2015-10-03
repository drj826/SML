#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl->get_logger("sml.application");

use lib "../lib";

use SML::Library;

my $library = SML::Library->new(config_filename=>'library.conf');

$library->publish('sml','html','default');

1;
