#!/usr/bin/perl

# $Id: Parser.t 15151 2013-07-08 21:01:16Z don.johnson $

# tc-000005 -- unit test case for Parser.pm (ci-000003)

use lib "..";
use Test::More tests => 52;

use SML::Library;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

my $config_file = 'library.conf';
my $library     = SML::Library->new(config_filename=>$config_file);

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   simple_fragment =>
   {
    testfile => 'td-000001.txt',
    docid    => 'td-000001',
   },

   fragment_containing_comment_division =>
   {
    testfile => 'td-000002.txt',
    docid    => 'td-000002',
   },

   fragment_containing_comment_line =>
   {
    testfile => 'td-000003.txt',
    docid    => 'td-000003',
   },

   fragment_containing_conditional_division =>
   {
    testfile => 'td-000004.txt',
    docid    => 'td-000004',
   },

   fragment_containing_region_division =>
   {
    testfile => 'td-000005.txt',
    docid    => 'td-000005',
   },

   fragment_containing_environment_division =>
   {
    testfile => 'td-000006.txt',
    docid    => 'td-000006',
   },

   fragment_containing_lists =>
   {
    testfile => 'td-000007.txt',
    docid    => 'td-000007',
   },

   fragment_containing_generate_element =>
   {
    testfile => 'td-000008.txt',
    docid    => 'td-000008',
   },

   fragment_containing_image_element =>
   {
    testfile => 'td-000011.txt',
    docid    => 'td-000011',
   },

   fragment_containing_footnote_element =>
   {
    testfile => 'td-000012.txt',
    docid    => 'td-000012',
   },

   fragment_containing_glossary_element =>
   {
    testfile => 'td-000013.txt',
    docid    => 'td-000013',
   },

   fragment_containing_var_element =>
   {
    testfile => 'td-000014.txt',
    docid    => 'td-000014',
   },

   fragment_containing_acronym_element =>
   {
    testfile => 'td-000015.txt',
    docid    => 'td-000015',
   },

   fragment_containing_index_element =>
   {
    testfile => 'td-000016.txt',
    docid    => 'td-000016',
   },

   fragment_containing_sections_and_regions =>
   {
    testfile => 'td-000020.txt',
    docid    => 'td-000020',
   },

   fragment_containing_raw_include_element =>
   {
    testfile => 'td-000021.txt',
    docid    => 'td-000021',
   },

   fragment_containing_included_entity =>
   {
    testfile => 'td-000023.txt',
    docid    => 'td-000023',
   },

   fragment_containing_included_section_style_1 =>
   {
    testfile => 'td-000018.txt',
    docid    => 'td-000018',
   },

   fragment_containing_included_section_style_2 =>
   {
    testfile => 'td-000019.txt',
    docid    => 'td-000019',
   },

   fragment_containing_include_from_subdir =>
   {
    testfile => 'td-000073.txt',
    docid    => 'td-000073',
   },

   fragment_containing_variable_substitutions =>
   {
    testfile => 'td-000025.txt',
    docid    => 'td-000025',
   },

   fragment_containing_template =>
   {
    testfile => 'td-000060.txt',
    docid    => 'td-000060',
   },

   fragment_containing_default_includes =>
   {
    testfile => 'td-000061.txt',
    docid    => 'td-000061',
   },

   fragment_containing_glossary_term_reference_1 =>
   {
    testfile => 'td-000026.txt',
    docid    => 'td-000026',
   },

   fragment_containing_glossary_term_reference_2 =>
   {
    testfile => 'td-000077.txt',
    docid    => 'td-000077',
   },

   fragment_containing_source_citation =>
   {
    testfile => 'td-000028.txt',
    docid    => 'td-000028',
   },

   fragment_containing_cross_reference =>
   {
    testfile => 'td-000032.txt',
    docid    => 'td-000032',
   },

   fragment_containing_id_reference =>
   {
    testfile => 'td-000034.txt',
    docid    => 'td-000034',
   },

   fragment_containing_page_reference =>
   {
    testfile => 'td-000036.txt',
    docid    => 'td-000036',
   },

   fragment_containing_bold_markup =>
   {
    testfile => 'td-000038.txt',
    docid    => 'td-000038',
   },

   fragment_containing_italics_markup =>
   {
    testfile => 'td-000040.txt',
    docid    => 'td-000040',
   },

   fragment_containing_fixedwidth_markup =>
   {
    testfile => 'td-000042.txt',
    docid    => 'td-000042',
   },

   fragment_containing_underline_markup =>
   {
    testfile => 'td-000044.txt',
    docid    => 'td-000044',
   },

   fragment_containing_superscript_markup =>
   {
    testfile => 'td-000046.txt',
    docid    => 'td-000046',
   },

   fragment_containing_subscript_markup =>
   {
    testfile => 'td-000048.txt',
    docid    => 'td-000048',
   },

   fragment_containing_file_element =>
   {
    testfile => 'td-000065.txt',
    docid    => 'td-000065',
   },

   fragment_containing_image_element =>
   {
    testfile => 'td-000067.txt',
    docid    => 'td-000067',
   },

   fragment_containing_insert_element =>
   {
    testfile => 'td-000009.txt',
    docid    => 'td-000009',
   },

   fragment_containing_script_element =>
   {
    testfile => 'td-000010.txt',
    docid    => 'td-000010',
   },

   fragment_containing_problem_division =>
   {
    testfile => 'td-000022.txt',
    divname  => 'problem',
    title    => 'Sample Problem For `Include\' Tests',
    preamble_size  => 17,
    narrative_size => 8,
   },

   fragment_containing_listing_environment =>
   {
    testfile => 'td-000075.txt',
    divname  => 'LISTING',
    title    => 'Sample Listing',
    preamble_size  => 5,
    narrative_size => 32,
   },

   fragment_containing_section =>
   {
    testfile => 'td-000076.txt',
    divname  => 'SECTION',
    title    => 'Section Fragment',
    preamble_size  => 2,
    narrative_size => 1,
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Parser;
  use_ok('SML::Parser');
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Parser->new(library=>$library);
isa_ok( $obj, 'SML::Parser' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'parse',

   # 'is_valid',

   # 'get_fragment',
   # 'get_line_list',
   # 'get_review_hash',
   # 'get_source_hash',
   # 'get_index_hash',
   # 'get_table_data_hash',
   # 'get_baretable_data_hash',
   # 'get_block',
   # 'get_division_stack',
   # 'get_column',
   # 'get_count_total_hash',
   # 'get_count_method_hash',
   # 'get_gen_content_hash',
   # 'get_to_be_gen_hash',
   # 'get_acronym_hash',
   # 'get_template_hash',
   # 'get_section_counter_hash',
   # 'get_division_counter_hash',

   'extract_division_name',
   'extract_title_text',
   'extract_preamble_lines',
   'extract_narrative_lines',

   # 'in_preamble',
   # 'requires_processing',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

parse_ok( 'simple_fragment' );
parse_ok( 'fragment_containing_comment_division' );
parse_ok( 'fragment_containing_comment_line' );
parse_ok( 'fragment_containing_conditional_division' );
parse_ok( 'fragment_containing_region_division' );
parse_ok( 'fragment_containing_environment_division' );
parse_ok( 'fragment_containing_lists' );
parse_ok( 'fragment_containing_generate_element' );
parse_ok( 'fragment_containing_image_element' );
parse_ok( 'fragment_containing_footnote_element' );
parse_ok( 'fragment_containing_glossary_element' );
parse_ok( 'fragment_containing_var_element' );
parse_ok( 'fragment_containing_acronym_element' );
parse_ok( 'fragment_containing_index_element' );
parse_ok( 'fragment_containing_sections_and_regions' );
parse_ok( 'fragment_containing_raw_include_element' );
parse_ok( 'fragment_containing_included_entity' );
parse_ok( 'fragment_containing_included_section_style_1' );
parse_ok( 'fragment_containing_included_section_style_2' );
parse_ok( 'fragment_containing_include_from_subdir' );
parse_ok( 'fragment_containing_variable_substitutions' );
parse_ok( 'fragment_containing_template' );
parse_ok( 'fragment_containing_default_includes' );
parse_ok( 'fragment_containing_glossary_term_reference_1' );
parse_ok( 'fragment_containing_glossary_term_reference_2' );
parse_ok( 'fragment_containing_source_citation' );
parse_ok( 'fragment_containing_cross_reference' );
parse_ok( 'fragment_containing_id_reference' );
parse_ok( 'fragment_containing_page_reference' );
parse_ok( 'fragment_containing_bold_markup' );
parse_ok( 'fragment_containing_italics_markup' );
parse_ok( 'fragment_containing_fixedwidth_markup' );
parse_ok( 'fragment_containing_underline_markup' );
parse_ok( 'fragment_containing_superscript_markup' );
parse_ok( 'fragment_containing_subscript_markup' );
parse_ok( 'fragment_containing_file_element' );
parse_ok( 'fragment_containing_image_element' );
parse_ok( 'fragment_containing_insert_element' );
parse_ok( 'fragment_containing_script_element' );

extract_division_name_ok( 'fragment_containing_problem_division' );
extract_division_name_ok( 'fragment_containing_listing_environment' );
extract_division_name_ok( 'fragment_containing_section' );

extract_title_text_ok( 'fragment_containing_problem_division' );
extract_title_text_ok( 'fragment_containing_listing_environment' );
extract_title_text_ok( 'fragment_containing_section' );

extract_preamble_lines_ok( 'fragment_containing_problem_division' );
extract_preamble_lines_ok( 'fragment_containing_listing_environment' );

extract_narrative_lines_ok( 'fragment_containing_problem_division' );
extract_narrative_lines_ok( 'fragment_containing_listing_environment' );

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub parse_ok {

  # Test that a fragment parses OK.

  my $testid = shift;

  # arrange
  my $config_file = 'library.conf';
  my $library     = SML::Library->new(config_filename=>$config_file);
  my $parser      = $library->get_parser;
  my $filespec    = $testdata->{$testid}{'testfile'};
  my $expected    = 1;

  # act
  my $fragment = $parser->parse($filespec);
  my $result   = $fragment->validate;

  # assert
  is($result, $expected, "parse $testid");
}

######################################################################

sub extract_division_name_ok {

  my $testid = shift;

  # arrange
  my $config_file = 'library.conf';
  my $library     = SML::Library->new(config_filename=>$config_file);
  my $parser      = $library->get_parser;
  my $filespec    = $testdata->{$testid}{'testfile'};
  my $expected    = $testdata->{$testid}{'divname'};
  my $fragment    = $parser->parse($filespec);
  my $lines       = $fragment->get_line_list;

  # act
  my $result = $parser->extract_division_name($lines);

  # assert
  is($result, $expected, "extract_division_name from $testid");
}

######################################################################

sub extract_title_text_ok {

  my $testid = shift;

  # arrange
  my $config_file = 'library.conf';
  my $library     = SML::Library->new(config_filename=>$config_file);
  my $parser      = $library->get_parser;
  my $filespec    = $testdata->{$testid}{'testfile'};
  my $expected    = $testdata->{$testid}{'title'};
  my $fragment    = $parser->parse($filespec);
  my $lines       = $fragment->get_line_list;

  # act
  my $result = $parser->extract_title_text($lines);

  # assert
  is($result, $expected, "extract_title_text from $testid");
}

######################################################################

sub extract_preamble_lines_ok {

  my $testid = shift;

  # arrange
  my $config_file = 'library.conf';
  my $library     = SML::Library->new(config_filename=>$config_file);
  my $parser      = $library->get_parser;
  my $filespec    = $testdata->{$testid}{'testfile'};
  my $expected    = $testdata->{$testid}{'preamble_size'};
  my $fragment    = $parser->parse($filespec);
  my $lines       = $fragment->get_line_list;

  # act
  my $preamble_lines = $parser->extract_preamble_lines($lines);
  my $result         = scalar @{ $preamble_lines };

  # assert
  is($result, $expected, "extract_preamble_lines from $testid");
}

######################################################################

sub extract_narrative_lines_ok {

  my $testid = shift;

  # arrange
  my $config_file = 'library.conf';
  my $library     = SML::Library->new(config_filename=>$config_file);
  my $parser      = $library->get_parser;
  my $filespec    = $testdata->{$testid}{'testfile'};
  my $expected    = $testdata->{$testid}{'narrative_size'};
  my $fragment    = $parser->parse($filespec);
  my $lines       = $fragment->get_line_list;

  # act
  my $narrative_lines = $parser->extract_narrative_lines($lines);
  my $result          = scalar @{ $narrative_lines };

  # assert
  is($result, $expected, "extract_narrative_lines from $testid");
}

######################################################################
