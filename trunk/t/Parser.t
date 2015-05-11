#!/usr/bin/perl

# $Id$

# tc-000005 -- unit test case for Parser.pm (ci-000003)

use lib "..";
use Test::More tests => 89;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

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
   'create_fragment',
   'create_string',

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
    create_fragment_ok($tc)         if defined $tc->{expected}{create_fragment};
    extract_division_name_ok($tc)   if defined $tc->{expected}{extract_division_name};
    extract_title_text_ok($tc)      if defined $tc->{expected}{extract_title_text};
    extract_preamble_lines_ok($tc)  if defined $tc->{expected}{extract_preamble_lines};
    extract_narrative_lines_ok($tc) if defined $tc->{expected}{extract_narrative_lines};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub create_fragment_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $filespec = $tc->{testfile};
  my $name     = $tc->{name};
  my $expected = $tc->{expected}{create_fragment};
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;

  # act
  my $fragment = $parser->create_fragment($filespec);
  my $result   = ref $fragment;

  # assert
  is($result,$expected,"$tcname create_fragment $result");
}

######################################################################

sub extract_division_name_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $name     = $tc->{name};
  my $filespec = $tc->{testfile};
  my $expected = $tc->{expected}{extract_division_name};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filespec);
  my $lines    = $fragment->get_line_list;

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
  my $name     = $tc->{name};
  my $filespec = $tc->{testfile};
  my $expected = $tc->{expected}{extract_title_text};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filespec);
  my $lines    = $fragment->get_line_list;

  # act
  my $result = $parser->extract_title_text($lines);

  # assert
  is($result,$expected,"$tcname extract_title_text $result");
}

######################################################################

sub extract_preamble_lines_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $name     = $tc->{name};
  my $filespec = $tc->{testfile};
  my $expected = $tc->{expected}{extract_preamble_lines};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filespec);
  my $lines    = $fragment->get_line_list;

  # act
  my $preamble_lines = $parser->extract_preamble_lines($lines);
  my $result         = scalar @{ $preamble_lines };

  # assert
  is($result,$expected,"$tcname extract_preamble_lines $result");
}

######################################################################

sub extract_narrative_lines_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $name     = $tc->{name};
  my $filespec = $tc->{testfile};
  my $expected = $tc->{expected}{extract_narrative_lines};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filespec);
  my $lines    = $fragment->get_line_list;

  # act
  my $narrative_lines = $parser->extract_narrative_lines($lines);
  my $result          = scalar @{ $narrative_lines };

  # assert
  is($result,$expected,"$tcname extract_narrative_lines $result");
}

######################################################################

1;
