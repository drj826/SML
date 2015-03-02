#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

######################################################################

use SML::Library;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.application');

my $library = SML::Library->new(config_filename=>'library.conf');
my $parser  = $library->get_parser;

my $tc =
  {
   name => 'invalid_division_1',
   testfile => 'td-000064.txt',
   division_id => 'td-000064',
   expected =>
   {
    valid_semantics_warning =>
    [
     'INVALID EXPLICIT DECLARATION OF INFER-ONLY PROPERTY',
     'THE FRAGMENT IS NOT VALID',
    ],
   },
  };

my $tcname    = $tc->{name};
my $testfile  = $tc->{testfile};
my $id        = $tc->{division_id};
my $fragment  = $parser->create_fragment($testfile);
my $division  = $library->get_division($id);
my $warning_1 = $tc->{expected}{valid_semantics_warning}[0];
my $warning_2 = $tc->{expected}{valid_semantics_warning}[1];

print $fragment->dump_part_structure;

######################################################################

1;
