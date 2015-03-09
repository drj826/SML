#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

######################################################################

use SML::Library;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.application');

use Test::Log4perl;

my $library = SML::Library->new(config_filename=>'library.conf');
my $parser  = $library->get_parser;

my $tc =
  {
   name        => 'invalid_semantics_division_1',
   testfile    => 'td-000063.txt',
   division_id => 'parent-problem',
   expected =>
   {
    valid_semantics_warning => 'INVALID EXPLICIT DECLARATION OF INFER-ONLY PROPERTY',
   },
  };

  # arrange
  my $tcname   = $tc->{name};
  my $testfile = $tc->{testfile};
  my $id       = $tc->{division_id};
  my $fragment = $parser->create_fragment($testfile);
  my $division = $library->get_division($id);
  my $expected = $tc->{expected}{valid_semantics_warning};
# my $t1logger = Test::Log4perl->get_logger('sml.Division');

#  Test::Log4perl->start( ignore_priority => "info" );
#  $t1logger->warn(qr/$expected/);

  # act
my $result = $division->has_valid_semantics;

  # assert
#  Test::Log4perl->end("$tcname $expected");

######################################################################

1;
