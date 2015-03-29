#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.ontology');

use Cwd;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $tcl     = $td->get_ontology_test_case_list;
my $library = $td->get_test_object('SML::Library','library');

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

my $obj = SML::Ontology->new();

# $obj->add_rules_from_file('library/ontology_rules_sml.conf');
# $obj->add_rules_from_file('library/ontology_rules_lib.conf');

isa_ok($obj,'SML::Ontology');

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
   'get_entity_allowed_property_list',
   'get_allowed_environment_list',
   'get_entity_type',
   'get_rule_for',
   'get_rule_with_id',
   'get_divisions_by_name_hash',
   'get_class_for_entity_name',
   'get_required_property_list',
   'contains_entity_named',
   'allows_entity',
   'allows_region',
   'allows_environment',
   'allows_property',
   'allows_composition',
   'allows_property_value',
   'property_is_universal',
   'property_is_imply_only',
   'property_allows_cardinality',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    add_rules_from_file_ok($tc) if defined $tc->{expected}{add_rules_from_file};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub add_rules_from_file_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $file     = $tc->{rules_file};
  my $ontology = SML::Ontology->new();
  my $expected = $tc->{expected}{add_rules_from_file};

  # act
  my $result = $ontology->add_rules_from_file($file);

  # assert
  is($result,$expected,"$tcname add_rules_from_file $result");
}

######################################################################

done_testing();
