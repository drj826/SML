#!/usr/bin/perl

# $Id: Assertion.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 11;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   assertion_1 =>
   {
    name      => 'ASSERTION',
    subject   => 'My eyes',
    predicate => 'are',
    object    => 'blue',
   },

   assertion_2 =>
   {
    name      => 'ASSERTION',
    subject   => 'rq-000331',
    predicate => 'is_part_of',
    object    => 'rq-000026',
   },

  };

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

my $obj = SML::Assertion->new(id=>'ASSERTION-0');
isa_ok( $obj, 'SML::Assertion' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'init',

   'add_division',
   'add_part',
   'add_property',
   'add_property_element',
   'add_attribute',

   'get_name',
   'get_id',
   'get_number',
   'get_containing_division',
   'get_part_list',
   'get_division_hash',
   'get_property_hash',
   'get_attribute_hash',
   'get_division_list',
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
   'get_location',
   'get_section',

   'has_valid_syntax',
   'has_valid_semantics',
   'has_property',
   'has_property_value',
   'has_attribute',

   'is_in_a',

   'contains_division',

   'validate',
   'validate_syntax',
   'validate_semantics',
   'validate_property_cardinality',
   'validate_property_values',
   'validate_infer_only_conformance',
   'validate_required_properties',
   'validate_composition',
   'validate_id_uniqueness',

   'get_subject',
   'get_predicate',
   'get_object',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
  );

# can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

get_name_ok( 'assertion_1' );
get_name_ok( 'assertion_2' );

get_subject_ok( 'assertion_1' );
get_subject_ok( 'assertion_2' );

get_predicate_ok( 'assertion_1' );
get_predicate_ok( 'assertion_2' );

get_object_ok( 'assertion_1' );
get_object_ok( 'assertion_2' );

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_name_ok {

  my $testid = shift;

  # arrange
  my $name      = $testdata->{$testid}{'name'};
  my $subject   = $testdata->{$testid}{'subject'};
  my $predicate = $testdata->{$testid}{'predicate'};
  my $object    = $testdata->{$testid}{'object'};
  my $expected  = $name;

  my $assertion = SML::Assertion->new
    (
     id        => $testid,
     name      => $name,
     subject   => $subject,
     predicate => $predicate,
     object    => $object,
    );

  # act
  my $result = $assertion->get_name;

  # assert
  is($result,$expected, "get_name $testid");
}

######################################################################

sub get_subject_ok {

  my $testid = shift;

  # arrange
  my $name      = $testdata->{$testid}{'name'};
  my $subject   = $testdata->{$testid}{'subject'};
  my $predicate = $testdata->{$testid}{'predicate'};
  my $object    = $testdata->{$testid}{'object'};
  my $expected  = $subject;

  my $assertion = SML::Assertion->new
    (
     id        => $testid,
     name      => $name,
     subject   => $subject,
     predicate => $predicate,
     object    => $object,
    );

  # act
  my $result = $assertion->get_subject;

  # assert
  is($result,$expected, "get_subject $testid");
}

######################################################################

sub get_predicate_ok {

  my $testid = shift;

  # arrange
  my $name      = $testdata->{$testid}{'name'};
  my $subject   = $testdata->{$testid}{'subject'};
  my $predicate = $testdata->{$testid}{'predicate'};
  my $object    = $testdata->{$testid}{'object'};
  my $expected  = $predicate;

  my $assertion = SML::Assertion->new
    (
     id        => $testid,
     name      => $name,
     subject   => $subject,
     predicate => $predicate,
     object    => $object,
    );

  # act
  my $result = $assertion->get_predicate;

  # assert
  is($result,$expected, "get_predicate $testid");
}

######################################################################

sub get_object_ok {

  my $testid = shift;

  # arrange
  my $name      = $testdata->{$testid}{'name'};
  my $subject   = $testdata->{$testid}{'subject'};
  my $predicate = $testdata->{$testid}{'predicate'};
  my $object    = $testdata->{$testid}{'object'};
  my $expected  = $object;

  my $assertion = SML::Assertion->new
    (
     id        => $testid,
     name      => $name,
     subject   => $subject,
     predicate => $predicate,
     object    => $object,
    );

  # act
  my $result = $assertion->get_object;

  # assert
  is($result,$expected, "get_object $testid");
}

######################################################################
