#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 5;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Property;
  use_ok( 'SML::Property' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Property->new(id=>'prop1',name=>'size');
isa_ok( $obj, 'SML::Property' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_name',
   'get_id',
   'get_value',
   'get_division',
   'get_element_list',
   'get_element_count',
   'get_elements_as_enum_list',

   'add_element',

   'is_multi_valued',

   'has_value',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

# arrange
my $element_0 = SML::Element->new(name=>'el0',library=>$library);
my $property  = SML::Property->new(id=>'diameter',name=>'pr1');
my $expected  = 0;

$property->add_element($element_0);

# act
my $answer = $property->is_multi_valued;

# assert
is($answer,$expected,'returns correct is_multi_valued = 0');

#---------------------------------------------------------------------

# arrange
$expected = 1;
my $element_1 = SML::Element->new(name=>'el1',library=>$library);

$property->add_element($element_1);

# act
$answer = $property->is_multi_valued;

# assert
is($answer,$expected,'returns correct is_multi_valued = 1');

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
