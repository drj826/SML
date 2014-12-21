#!/usr/bin/perl

# $Id: Ontology.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 4;
use Test::Perl::Critic (-severity => 4);

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.ontology');

use Cwd;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Ontology;
  use_ok( 'SML::Ontology' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML->instance->get_ontology;

$obj->add_rules('library/ontology_rules_sml.conf');
$obj->add_rules('library/ontology_rules_lib.conf');

isa_ok( $obj, 'SML::Ontology' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_rule_hash',
   'get_types_by_entity_name_hash',
   'get_property_rules_lookup_hash',
   'get_properties_by_entity_name_hash',
   'get_allowed_property_values_hash',
   'get_allowed_compositions_hash',
   'get_imply_only_properties_hash',
   'get_cardinality_of_properties_hash',
   'get_required_properties_hash',

   'add_rules',
   'get_allowed_property_values',
   'contains_entity_named',
   'allowed_properties',
   'allowed_environments',
   'type_of',
   'has_entity',
   'allows_region',
   'allows_environment',
   'allows_property',
   'allows_composition',
   'rule_for',
   'rule_with_id',
   'property_is_universal',
   'property_is_imply_only',
   'property_allows_cardinality',
   'divisions_by_name',
   'allows_property_value',
   'class_for_entity_name',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
