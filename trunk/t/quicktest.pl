#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

######################################################################

use SML::Library;

my $filename = 'td-000001.txt';
my $docid    = 'td-000001';
my $library  = SML::Library->new(config_file=>'library.conf');
my $parser   = $library->get_parser;
my $fragment = $parser->create_fragment($filename);
my $document = $library->get_document($docid);

print $document->dump_part_structure,"\n\n";

print $document->render('sml','default'),"\n\n";

######################################################################

1;
