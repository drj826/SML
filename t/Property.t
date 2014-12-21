#!/usr/bin/perl

# $Id: Property.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 6;
use Test::Perl::Critic (-severity => 4);

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

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
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
  );

# can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

# arrange
my $element_0 = SML::Element->new(name=>'el0');
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
my $element_1 = SML::Element->new(name=>'el1');

$property->add_element($element_1);

# act
$answer = $property->is_multi_valued;

# assert
is($answer,$expected,'returns correct is_multi_valued = 1');

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
