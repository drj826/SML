#!/usr/bin/perl

# $Id: Parser.t 264 2015-05-11 11:56:25Z drj826@gmail.com $

# tc-000005 -- unit test case for Parser.pm (ci-000003)

use lib "../lib";
use Test::More;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl->get_logger('sml.application');

# set sml.Library logger to WARN
my $logger_library = Log::Log4perl::get_logger('sml.Library');
$logger_library->level('WARN');

# set sml.Parser logger to WARN
my $logger_parser = Log::Log4perl::get_logger('sml.Parser');
$logger_parser->level('WARN');

# set sml.Division logger to ERROR
my $logger_division = Log::Log4perl::get_logger('sml.Division');
$logger_division->level('ERROR');

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new();
my $tcl     = $td->get_parser_test_case_list;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Parser;
  use_ok('SML::Parser');
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = $library->get_parser;
isa_ok( $obj, 'SML::Parser' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # attribute accessors
   'get_library',

   # public methods
   'parse',
   'create_string',

   'extract_division_name',
   'extract_title_text',
   'extract_data_segment_lines',
   'extract_narrative_lines',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{$tcl})
  {
    parse_ok($tc)                   if defined $tc->{expected}{parse};
    extract_division_name_ok($tc)   if defined $tc->{expected}{extract_division_name};
    extract_title_text_ok($tc)      if defined $tc->{expected}{extract_title_text};
    extract_data_segment_lines_ok($tc)  if defined $tc->{expected}{extract_data_segment_lines};
    extract_narrative_lines_ok($tc) if defined $tc->{expected}{extract_narrative_lines};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub parse_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $divid    = $tc->{divid};
  my $library  = $tc->{library};
  my $expected = $tc->{expected}{parse};
  my $parser   = $library->get_parser;

  # act
  my $division = $parser->parse($divid);
  my $result   = ref $division;

  # my $structure = $division->dump_part_structure;
  # $logger->info("STRUCTURE:\n$structure");

  # assert
  is($result,$expected,"$tcname parse $result");
}

######################################################################

sub extract_division_name_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{extract_division_name};
  my $division = $library->get_division($divid);
  my $lines    = $division->get_line_list;
  my $parser   = $library->get_parser;

  # act
  my $result = $parser->extract_division_name($lines);

  # assert
  is($result,$expected,"$tcname extract_division_name $result");
}

######################################################################

sub extract_title_text_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{extract_title_text};
  my $division = $library->get_division($divid);
  my $lines    = $division->get_line_list;
  my $parser   = $library->get_parser;

  # act
  my $result = $parser->extract_title_text($lines);

  # assert
  is($result,$expected,"$tcname extract_title_text $result");
}

######################################################################

sub extract_data_segment_lines_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{extract_data_segment_lines};
  my $division = $library->get_division($divid);
  my $lines    = $division->get_line_list;
  my $parser   = $library->get_parser;

  # act
  my $data_segment_lines = $parser->extract_data_segment_lines($lines);
  my $result         = scalar @{ $data_segment_lines };

  # assert
  is($result,$expected,"$tcname extract_data_segment_lines $result");
}

######################################################################

sub extract_narrative_lines_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{extract_narrative_lines};
  my $division = $library->get_division($divid);
  my $lines    = $division->get_line_list;
  my $parser   = $library->get_parser;

  # act
  my $narrative_lines = $parser->extract_narrative_lines($lines);
  my $result          = scalar @{ $narrative_lines };

  # assert
  is($result,$expected,"$tcname extract_narrative_lines $result");
}

######################################################################

done_testing();
