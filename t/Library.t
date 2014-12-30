#!/usr/bin/perl

# $Id: Library.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 4;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Library;
  use_ok( 'SML::Library' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $config_file = 'library/library.conf';
my $obj         = SML::Library->new(config_filespec=>$config_file);
ok( $obj->isa('SML::Library'), 'library is a SML::Library' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_id',
   'get_config_filespec',
   # 'get_sml_ontology_config_filespec',
   # 'get_lib_ontology_config_filespec',
   'get_sml',
   'get_parser',
   'get_reasoner',
   'get_formatter',
   'get_title',
   'get_author',
   'get_date',
   'get_revision',
   'get_fragment',
   'get_fragments',
   'get_document',
   'get_documents',
   'get_entity',
   'get_division',
   'get_property',
   'get_variable',
   'get_resource',
   'get_index_term',
   'get_property_value',
   'get_variable_value',
   'get_preamble_line_list',
   'get_narrative_line_list',
   'get_type',
   'get_outcome',
   'get_review',
   'get_outcome_entity_id_list',
   'get_review_entity_id_list',
   'get_outcome_date_list',
   'get_review_date_list',
   'get_outcome_status',
   'get_review_status',
   'get_outcome_description',
   'get_review_description',
   'get_division_hash',
   'get_outcome_hash',
   'get_review_hash',
   'get_index_hash',
   'get_glossary',
   'get_acronym_list',
   'get_references',
   'get_directory_path',
   'get_catalog_filespec',
   'get_file_list',
   'get_fragment_file_list',
   'get_reference_file_list',
   'get_script_file_list',
   'get_fragment_hash',
   'get_document_hash',
   'get_entity_hash',
   'get_variable_hash',
   'get_resource_hash',

   'has_fragment',
   'has_document',
   'has_entity',
   'has_division',
   'has_property',
   'has_variable',
   'has_resource',
   'has_index_term',
   'has_outcome',
   'has_review',

   'add_fragment',
   'add_entity',
   'add_division',
   'add_variable',
   'add_resource',
   'add_index_term',
   'add_fragment_file',
   'add_reference_file',
   'add_script_file',
   'add_outcome',
   'add_review',

   'summarize_content',
   'summarize_entities',
   'summarize_fragments',
   'summarize_divisions',
   'summarize_glossary',
   'summarize_acronyms',
   'summarize_variables',
   'summarize_resources',
   'summarize_index',
   'summarize_sources',
   'summarize_outcomes',
   'summarize_reviews',

   'replace_division_id',
   'update_status_from_outcome',

   'by_division_name_and_id',
   'by_date',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
   'BUILD',
   '_build_parser',
   '_build_reasoner',
   '_build_glossary',
   '_build_acronym_list',
   '_build_references',
  );

can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected output?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
