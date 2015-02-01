#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

use SML;
use SML::File;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

my $library = SML::Library->new(config_filename=>'library.conf');
my $parser  = $library->get_parser;

$parser->parse('td-000001.txt');
my $document = $library->get_document('td-000001');

print $library->summarize_content;

######################################################################

1;
