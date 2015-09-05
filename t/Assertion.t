#!/usr/bin/perl

# $Id: Assertion.t 259 2015-04-02 20:27:00Z drj826@gmail.com $

use lib "../lib";
use Test::More tests => 9;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $tcl     = $td->get_assertion_test_case_list;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Assertion;
  use_ok( 'SML::Assertion' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $args = {};

$args->{id}        = 'a1';
$args->{subject}   = 'The sky';
$args->{predicate} = 'is';
$args->{object}    = 'blue.';
$args->{library}   = $library;

my $obj = SML::Assertion->new(%{ $args });

isa_ok( $obj, 'SML::Assertion' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Assertion attribute accessors
   'get_subject',
   'get_predicate',
   'get_object',

   # SML::Assertion public methods

   # SML::Environment attribute accessors (inherited)

   # SML::Environment public methods (inherited)

   # SML::Division attribute accessors (inherited)
   'get_number',
   'set_number',
   'get_previous_number',
   'set_previous_number',
   'get_next_number',
   'set_next_number',
   'get_containing_division',
   'set_containing_division',
   'has_containing_division',
   'has_valid_syntax',
   'has_valid_semantics',
   'has_valid_property_cardinality',
   'has_valid_property_values',
   'has_valid_infer_only_conformance',
   'has_valid_required_properties',
   'has_valid_composition',
   'has_valid_id_uniqueness',

   # SML::Division public methods (inherited)
   'add_division',
   'add_part',
   'add_property',
   'add_property_element',
   'add_attribute',
   'contains_division',
   'has_property',
   'has_property_value',
   'has_attribute',
   'get_division_list',
   'has_sections',
   'get_section_list',
   'get_block_list',
   'get_element_list',
   'get_line_list',
   'get_preamble_line_list',
   'get_narrative_line_list',
   'get_first_part',
   'get_first_line',
   'get_property_list',
   'get_property',
   'get_property_value',
   'get_containing_document',
   'get_location',
   'get_section',
   'is_in_a',
   'validate',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    get_subject_ok($tc)   if defined $tc->{expected}{get_subject};
    get_predicate_ok($tc) if defined $tc->{expected}{get_predicate};
    get_object_ok($tc)    if defined $tc->{expected}{get_object};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_subject_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $expected  = $tc->{expected}{get_subject};
  my $args      = $tc->{args};
  my $assertion = SML::Assertion->new(%{$args});

  # act
  my $result = $assertion->get_subject;

  # assert
  is($result,$expected,"$tcname get_subject $result");
}

######################################################################

sub get_predicate_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $expected  = $tc->{expected}{get_predicate};
  my $args      = $tc->{args};
  my $assertion = SML::Assertion->new(%{$args});

  # act
  my $result = $assertion->get_predicate;

  # assert
  is($result,$expected,"$tcname get_predicate $result");
}

######################################################################

sub get_object_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $expected  = $tc->{expected}{get_object};
  my $args      = $tc->{args};
  my $assertion = SML::Assertion->new(%{$args});

  # act
  my $result = $assertion->get_object;

  # assert
  is($result,$expected,"$tcname get_object $result");
}

######################################################################

1;
