#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 4;

use SML::Ontology;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::OntologyRule;
  use_ok( 'SML::OntologyRule' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $ontology = SML::Ontology->new;

my $obj = SML::OntologyRule->new
  (
   ontology        => $ontology,
   id              => 'rul001',
   rule_type       => 'cls',
   entity_name     => 'table',
   property_name   => 'exists',
   value_type      => 'Str',
   name_or_value   => '',
   inverse_rule_id => '',
   cardinality     => '1',
   required        => 0,
   imply_only      => 0,
  );

isa_ok( $obj, 'SML::OntologyRule' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_id',
   'get_ontology',
   'get_rule_type',
   'get_entity_name',
   'get_property_name',
   'get_value_type',
   'get_name_or_value',
   'get_cardinality',

   'is_required',
   'is_imply_only',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
   'BUILD',
  );

can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
