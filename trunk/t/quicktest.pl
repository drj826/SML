#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

######################################################################

use SML::Library;

my $file = 'td-000001.txt';

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.application');

my $library = SML::Library->new(config_filename=>'library.conf');
my $parser  = $library->get_parser;

my $fragment = $parser->create_fragment($file);

print "OUTPUT:\n";
print $fragment->render('html','default'), "\n\n";

print "PART_STRUCTURE:\n";
print $fragment->dump_part_structure, "\n";

######################################################################

1;
