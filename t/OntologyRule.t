#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 3;

use SML::Ontology;

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
  use SML::OntologyRule;
  use_ok( 'SML::OntologyRule' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $ontology = SML::Ontology->new(library=>$library);

my $args = {};

$args->{ontology}        = $ontology;
$args->{id}              = 'rul001';
$args->{rule_type}       = 'cls';
$args->{entity_name}     = 'TABLE';
$args->{property_name}   = 'exists';
$args->{value_type}      = 'Str';
$args->{name_or_value}   = '';
$args->{inverse_rule_id} = '';
$args->{cardinality}     = 1;
$args->{required}        = 0;
$args->{imply_only}      = 0;

my $obj = SML::OntologyRule->new(%{$args});

isa_ok( $obj, 'SML::OntologyRule' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::OntologyRule public attribute accessors
   'get_id',
   'get_ontology',
   'get_rule_type',
   'get_entity_name',
   'get_property_name',
   'get_value_type',
   'get_name_or_value',
   'get_inverse_rule_id',
   'get_cardinality',
   'is_required',
   'is_imply_only',

   # SML::OntologyRule public methods
   # <none>
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
