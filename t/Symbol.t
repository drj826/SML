#!/usr/bin/perl

# $Id: Symbol.t 125 2015-02-24 02:43:25Z drj826@gmail.com $

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
my $tcl = $td->get_symbol_test_case_list;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Symbol;
  use_ok( 'SML::Symbol' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $args = {};
$args->{library} = $td->get_test_library_1;

my $obj = SML::Symbol->new(%{$args});
isa_ok( $obj, 'SML::Symbol' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Part inherited public attribute methods
   'get_name',
   'get_content',
   'get_part_list',

   # SML::Part inherited public methods
   'init',
   'has_parts',
   'add_part',
   'get_containing_document',

   # SML::String inherited public attribute methods
   'get_containing_block',
   'set_containing_block',
   'clear_containing_block',

   # SML::String inherited public methods
   'add_part',
   'get_location',
   'get_containing_document',

   # SML::Symbol public attribute accessor methods
   'get_preceding_character',
   'get_following_character',

   # SML::Symbol public methods
   # <none>
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{$tcl})
  {
    get_name_ok($tc)                 if exists $tc->{expected}{get_name};
    get_content_ok($tc)              if exists $tc->{expected}{get_content};
    has_parts_ok($tc)                if exists $tc->{expected}{has_parts};
    render_ok($tc,'sml','default')   if exists $tc->{expected}{render}{sml}{default};
    render_ok($tc,'html','default')  if exists $tc->{expected}{render}{html}{default};
    render_ok($tc,'latex','default') if exists $tc->{expected}{render}{latex}{default};
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
  my $library  = $tc->{library};
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
  my $library  = $tc->{library};
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
  my $library  = $tc->{library};
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
  my $text     = $tc->{text};
  my $library  = $tc->{library};
  my $expected = $tc->{expected}{render}{$rendition}{$style};
  my $parser   = $library->get_parser;
  my $string   = $parser->create_string($text);

  # act
  my $result  = $string->render($rendition,$style);
  my $summary = $result;
  $summary = substr($result,0,20) . '...' if length($result) > 20;

  # print "STRUCTURE:\n\n";
  # print $string->dump_part_structure, "\n\n";

  # assert
  is($result,$expected,"$tcname render $rendition $style \'$summary\'");
}

######################################################################

done_testing()
