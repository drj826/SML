#!/usr/bin/perl

# $Id: Library.t 264 2015-05-11 11:56:25Z drj826@gmail.com $

use lib "../lib";
use Test::More tests => 13;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use SML::TestData;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $td      = SML::TestData->new();
my $tcl     = $td->get_library_test_case_list;
my $library = $td->get_test_library_1;

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

ok( $library->isa('SML::Library'), 'library is a SML::Library' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Library public attribute accessors
   'get_id',
   'get_name',
   'get_revision',
   'get_sml',
   'get_ontology',
   'get_ontology_rule_filespec_list',
   'get_parser',
   'get_reasoner',
   'get_formatter',
   'get_glossary',
   'get_acronym_list',
   'get_references',
   'get_directory_path',
   'get_include_path',
   'get_division_name_list',
   'get_region_name_list',
   'get_environment_name_list',

   # SML::Library public methods
   'has_filespec',
   'get_filespec',

   'add_fragment',
   'add_document',
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


   'has_fragment',
   'get_fragment',

   'has_document',
   'get_document',

   'get_document_list',
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

can_ok( $library, @public_methods );

#---------------------------------------------------------------------
# Returns expected output?
#---------------------------------------------------------------------

foreach my $tc (@{$tcl})
  {
    get_id_ok($tc);
    get_name_ok($tc);
    get_revision_ok($tc);
    get_sml_ok($tc);
    get_parser_ok($tc);
    get_reasoner_ok($tc);
    get_formatter_ok($tc);
    get_glossary_ok($tc);
    get_acronym_list_ok($tc);
    get_references_ok($tc);
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_id_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name   = $tc->{name};
  my $config_fn = $tc->{config_filename};
  my $library   = SML::Library->new(config_filename=>$config_fn);
  my $expected  = $tc->{expected}{get_id};

  # act
  my $result = $library->get_id;

  # assert
  is($result,$expected,"$tc_name: get_id \'$result\'")
}

######################################################################

sub get_name_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name   = $tc->{name};
  my $config_fn = $tc->{config_filename};
  my $library   = SML::Library->new(config_filename=>$config_fn);
  my $expected  = $tc->{expected}{get_name};

  # act
  my $result = $library->get_name;

  # assert
  is($result,$expected,"$tc_name: get_name \'$result\'")
}

######################################################################

sub get_revision_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name   = $tc->{name};
  my $config_fn = $tc->{config_filename};
  my $library   = SML::Library->new(config_filename=>$config_fn);
  my $expected  = $tc->{expected}{get_revision};

  # act
  my $result = $library->get_revision;

  # assert
  like($result,$expected,"$tc_name: get_revision \'$result\'")
}

######################################################################

sub get_sml_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name   = $tc->{name};
  my $config_fn = $tc->{config_filename};
  my $library   = SML::Library->new(config_filename=>$config_fn);
  my $expected  = $tc->{expected}{get_sml};

  # act
  my $result = $library->get_sml;

  # assert
  isa_ok($result,$expected,"$result")
}

######################################################################

sub get_parser_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name   = $tc->{name};
  my $config_fn = $tc->{config_filename};
  my $library   = SML::Library->new(config_filename=>$config_fn);
  my $expected  = $tc->{expected}{get_parser};

  # act
  my $result = $library->get_parser;

  # assert
  isa_ok($result,$expected,"$result")
}

######################################################################

sub get_reasoner_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name   = $tc->{name};
  my $config_fn = $tc->{config_filename};
  my $library   = SML::Library->new(config_filename=>$config_fn);
  my $expected  = $tc->{expected}{get_reasoner};

  # act
  my $result = $library->get_reasoner;

  # assert
  isa_ok($result,$expected,"$result")
}

######################################################################

sub get_formatter_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name   = $tc->{name};
  my $config_fn = $tc->{config_filename};
  my $library   = SML::Library->new(config_filename=>$config_fn);
  my $expected  = $tc->{expected}{get_formatter};

  # act
  my $result = $library->get_formatter;

  # assert
  isa_ok($result,$expected,"$result")
}

######################################################################

sub get_glossary_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name   = $tc->{name};
  my $config_fn = $tc->{config_filename};
  my $library   = SML::Library->new(config_filename=>$config_fn);
  my $expected  = $tc->{expected}{get_glossary};

  # act
  my $result = $library->get_glossary;

  # assert
  isa_ok($result,$expected,"$result")
}

######################################################################

sub get_acronym_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name   = $tc->{name};
  my $config_fn = $tc->{config_filename};
  my $library   = SML::Library->new(config_filename=>$config_fn);
  my $expected  = $tc->{expected}{get_acronym_list};

  # act
  my $result = $library->get_acronym_list;

  # assert
  isa_ok($result,$expected,"$result")
}

######################################################################

sub get_references_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tc_name   = $tc->{name};
  my $config_fn = $tc->{config_filename};
  my $library   = SML::Library->new(config_filename=>$config_fn);
  my $expected  = $tc->{expected}{get_references};

  # act
  my $result = $library->get_references;

  # assert
  isa_ok($result,$expected,"$result")
}

######################################################################
