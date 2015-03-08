#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new();
my $tcl     = $td->get_string_test_case_list;
my $library = $td->get_test_object('SML::Library','library');
my $parser  = $library->get_parser;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::String;
  use_ok( 'SML::String' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::String->new(content=>'my test content');
isa_ok( $obj, 'SML::String' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Part public attribute methods
   'get_name',
   'get_content',
   'get_part_list',

   # SML::Part public methods
   'init',
   'has_parts',
   'add_part',
   'get_containing_document',

   # SML::String public attribute methods
   'get_containing_block',
   'set_containing_block',
   'clear_containing_block',

   # SML::String public methods
   'add_part',
   'get_location',
   'get_containing_document',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{$tcl})
  {
    get_name_ok($tc);
    get_content_ok($tc);

    if ( exists $tc->{expected}{has_parts} )
      {
	has_parts_ok($tc);
      }
    if ( exists $tc->{expected}{html}{default} )
      {
	render_html_default_ok($tc);
      }

  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_name_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name  = $tc->{name};
  my $text     = $tc->{text};
  my $expected = $tc->{expected}{name};
  my $string   = $parser->create_string($text);

  # act
  my $result = $string->get_name;

  # assert
  is($result,$expected,"get_name $tc_name $result")
}

######################################################################

sub get_content_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name  = $tc->{name};
  my $text     = $tc->{text};
  my $expected = $tc->{expected}{content};
  my $string   = $parser->create_string($text);

  # act
  my $result = $string->get_content;

  # assert
  is($result,$expected,"get_content $tc_name $result")
}

######################################################################

sub render_html_default_ok {

  my $tc = shift;

  # arrange
  my $tc_name  = $tc->{name};
  my $expected = $tc->{expected}{html}{default};
  my $text     = $tc->{text};
  my $string   = $parser->create_string($text);

  # act
  my $html = $string->render('html','default');

  # assert
  is($html,$expected,"render html default $tc_name");
}

######################################################################

sub has_parts_ok {

  my $tc = shift;

  # arrange
  my $tc_name  = $tc->{name};
  my $expected = $tc->{expected}{has_parts};
  my $text     = $tc->{text};
  my $string   = $parser->create_string($text);

  # act
  my $result = $string->has_parts;

  # assert
  is($result,$expected,"has_parts $tc_name $result");
}

######################################################################

done_testing()
