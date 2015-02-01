#!/usr/bin/perl

# $Id$

# tc-000005 -- unit test case for Parser.pm (ci-000003)

use lib "..";
use Test::More tests => 89;

use SML::Library;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use SML::TestData;

my $library = SML::Library->new(config_filename=>'library.conf');

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $td = SML::TestData->new();
my $tcl = $td->get_parser_test_case_list;

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

my $obj = SML::Parser->new(library=>$library);
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
   'extract_division_name',
   'extract_title_text',
   'extract_preamble_lines',
   'extract_narrative_lines',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{$tcl})
  {
    if ( defined $tc->{expected}{should_parse_ok} )
      {
	parse_ok($tc);
      }

    if ( defined $tc->{expected}{divname} )
      {
	extract_division_name_ok($tc);
      }

    if ( defined $tc->{expected}{title} )
      {
	extract_title_text_ok($tc);
      }

    if ( defined $tc->{expected}{preamble_size} )
      {
	extract_preamble_lines_ok($tc);
      }

    if ( defined $tc->{expected}{narrative_size} )
      {
	extract_preamble_lines_ok($tc);
      }
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub parse_ok {

  my $tc = shift;

  # arrange
  my $library  = SML::Library->new(config_filename=>'library.conf');
  my $parser   = $library->get_parser;
  my $filespec = $tc->{testfile};
  my $name     = $tc->{name};
  my $expected = $tc->{expected}{should_parse_ok};

  # act
  my $fragment = $parser->parse($filespec);
  my $result   = 0;

  if ( $fragment )
    {
      $result = 1;
    }

  # assert
  is($result, $expected, "parse $filespec $name");
}

######################################################################

sub extract_division_name_ok {

  my $tc = shift;

  # arrange
  my $library  = SML::Library->new(config_filename=>'library.conf');
  my $parser   = $library->get_parser;
  my $name     = $tc->{name};
  my $filespec = $tc->{testfile};
  my $expected = $tc->{expected}{divname};
  my $fragment = $parser->parse($filespec);
  my $lines    = $fragment->get_line_list;

  # act
  my $result = $parser->extract_division_name($lines);

  # assert
  is($result, $expected, "extract_division_name $filespec $name");
}

######################################################################

sub extract_title_text_ok {

  my $tc = shift;

  # arrange
  my $library  = SML::Library->new(config_filename=>'library.conf');
  my $parser   = $library->get_parser;
  my $name     = $tc->{name};
  my $filespec = $tc->{testfile};
  my $expected = $tc->{expected}{title};
  my $fragment = $parser->parse($filespec);
  my $lines    = $fragment->get_line_list;

  # act
  my $result = $parser->extract_title_text($lines);

  # assert
  is($result, $expected, "extract_title_text $filespec $name");
}

######################################################################

sub extract_preamble_lines_ok {

  my $tc = shift;

  # arrange
  my $library     = SML::Library->new(config_filename=>'library.conf');
  my $parser      = $library->get_parser;
  my $name        = $tc->{name};
  my $filespec    = $tc->{testfile};
  my $expected    = $tc->{expected}{preamble_size};
  my $fragment    = $parser->parse($filespec);
  my $lines       = $fragment->get_line_list;

  # act
  my $preamble_lines = $parser->extract_preamble_lines($lines);
  my $result         = scalar @{ $preamble_lines };

  # assert
  is($result, $expected, "extract_preamble_lines $filespec $name");
}

######################################################################

sub extract_narrative_lines_ok {

  my $tc = shift;

  # arrange
  my $library     = SML::Library->new(config_filename=>'library.conf');
  my $parser      = $library->get_parser;
  my $name        = $tc->{name};
  my $filespec    = $tc->{testfile};
  my $expected    = $tc->{expected}{narrative_size};
  my $fragment    = $parser->parse($filespec);
  my $lines       = $fragment->get_line_list;

  # act
  my $narrative_lines = $parser->extract_narrative_lines($lines);
  my $result          = scalar @{ $narrative_lines };

  # assert
  is($result, $expected, "extract_narrative_lines $filespec $name");
}

######################################################################
