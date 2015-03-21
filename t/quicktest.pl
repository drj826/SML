#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

######################################################################

my $filename = 'td-000082.txt';
my $docid    = 'td-000082';

use SML::Library;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.application');

my $library  = SML::Library->new(config_filename=>'library.conf');
my $parser   = $library->get_parser;
my $fragment = $parser->create_fragment($filename);
my $document = $library->get_document($docid);

my $valid = $document->is_valid;

print "valid: $valid\n\n";

print $document->dump_part_structure, "\n\n";

######################################################################

1;
