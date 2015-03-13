#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

######################################################################

my $filename = 'td-000066.txt';
my $docid    = 'td-000066';

use SML::Library;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.application');

my $library  = SML::Library->new(config_filename=>'library.conf');
my $parser   = $library->get_parser;
my $fragment = $parser->create_fragment($filename);
my $document = $library->get_document($docid);

my $valid = $document->is_valid;

if ($valid)
  {
    print "document is valid\n";
  }

else
  {
    print "DOCUMENT IS NOT VALID\n";
  }

######################################################################

1;
