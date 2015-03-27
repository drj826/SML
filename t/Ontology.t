#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 3;

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

$obj->add_rules_from_file('library/ontology_rules_sml.conf');
$obj->add_rules_from_file('library/ontology_rules_lib.conf');

isa_ok( $obj, 'SML::Ontology' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Ontology public attribute accessors
   # <none>

   # SML::Ontology public methods
   'add_rules_from_file',
   'get_allowed_property_value_list',
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
   'get_required_property_list',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
