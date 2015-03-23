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

my $td  = SML::TestData->new();
my $tcl = $td->get_string_test_case_list;

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
    get_name_ok($tc)                if exists $tc->{expected}{get_name};
    get_content_ok($tc)             if exists $tc->{expected}{get_content};
    has_parts_ok($tc)               if exists $tc->{expected}{has_parts};
    render_ok($tc,'html','default') if exists $tc->{expected}{render}{html}{default};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_name_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $text     = $tc->{text};
  my $expected = $tc->{expected}{get_name};
  my $library  = $td->get_test_object('SML::Library','library');
  my $parser   = $library->get_parser;
  my $string   = $parser->create_string($text);

  # act
  my $result = $string->get_name;

  # assert
  is($result,$expected,"$tcname get_name $result")
}

######################################################################

sub get_content_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $text     = $tc->{text};
  my $expected = $tc->{expected}{get_content};
  my $library  = $td->get_test_object('SML::Library','library');
  my $parser   = $library->get_parser;
  my $string   = $parser->create_string($text);

  # act
  my $result = $string->get_content;

  # assert
  is($result,$expected,"$tcname get_content $result")
}

######################################################################

sub has_parts_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{has_parts};
  my $text     = $tc->{text};
  my $library  = $td->get_test_object('SML::Library','library');
  my $parser   = $library->get_parser;
  my $string   = $parser->create_string($text);

  # act
  my $result = $string->has_parts;

  # assert
  is($result,$expected,"$tcname has_parts $result");
}

######################################################################

sub render_ok {

  my $tc        = shift;
  my $rendition = shift;
  my $style     = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{render}{$rendition}{$style};
  my $text     = $tc->{text};
  my $library  = $td->get_test_object('SML::Library','library');
  my $parser   = $library->get_parser;
  my $string   = $parser->create_string($text);

  # act
  my $result = $string->render($rendition,$style);

  # assert
  my $summary = substr($result,0,20);
  is($result,$expected,"$tcname render $rendition $style ($summary...)");
}

######################################################################

done_testing()
