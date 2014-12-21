#!/usr/bin/perl

# $Id: Division.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 61;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use Test::Log4perl;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   init_test_1 =>
   {
    name     => 'test-division',
    id       => 'td',
    expected => '1',
   },

   get_id_test_1 =>
   {
    name     => 'test-division',
    id       => 'td',
    expected => 'td',
   },

   get_name_test_1 =>
   {
    name     => 'test-division',
    id       => 'td',
    expected => 'test-division',
   },

   get_number_test_1 =>
   {
    name      => 'test-division',
    id        => 'td',
    number    => '4-4-4',
    expected  => '4-4-4',
   },

   get_containing_division_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => 'SML::Fragment',
   },

   get_containing_division_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    config    => 'library/library.conf',
    expected  => 'SML::Document',
   },

   get_containing_division_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    config    => 'library/library.conf',
    expected  => 'SML::Section',
   },

   get_containing_division_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    config    => 'library/library.conf',
    expected  => 'SML::Section',
   },

   get_part_list_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => 22,
   },

   get_part_list_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    config    => 'library/library.conf',
    expected  => 7,
   },

   get_part_list_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    config    => 'library/library.conf',
    expected  => 10,
   },

   get_part_list_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    config    => 'library/library.conf',
    expected  => 10,
   },

   get_line_list_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => 214,
   },

   get_line_list_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    config    => 'library/library.conf',
    expected  => 17,
   },

   get_line_list_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    config    => 'library/library.conf',
    expected  => 40,
   },

   get_line_list_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    config    => 'library/library.conf',
    expected  => 30,
   },

   get_division_list_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => 32,
   },

   get_division_list_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    config    => 'library/library.conf',
    expected  => 0,
   },

   get_division_list_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    config    => 'library/library.conf',
    expected  => 10,
   },

   get_division_list_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    config    => 'library/library.conf',
    expected  => 12,
   },

   get_section_list_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => 5,
   },

   get_block_list_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => 92,
   },

   get_block_list_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    config    => 'library/library.conf',
    expected  => 7,
   },

   get_block_list_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    config    => 'library/library.conf',
    expected  => 18,
   },

   get_block_list_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    config    => 'library/library.conf',
    expected  => 15,
   },

   get_element_list_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => 39,
   },

   get_element_list_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    config    => 'library/library.conf',
    expected  => 4,
   },

   get_element_list_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    config    => 'library/library.conf',
    expected  => 5,
   },

   get_element_list_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    config    => 'library/library.conf',
    expected  => 2,
   },

   get_preamble_line_list_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => 18,
   },

   get_preamble_line_list_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    config    => 'library/library.conf',
    expected  => 4,
   },

   get_preamble_line_list_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    config    => 'library/library.conf',
    expected  => 10,
   },

   get_preamble_line_list_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    config    => 'library/library.conf',
    expected  => 4,
   },

   get_narrative_line_list_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => 193,
   },

   get_narrative_line_list_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    config    => 'library/library.conf',
    expected  => 9,
   },

   get_narrative_line_list_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    config    => 'library/library.conf',
    expected  => 26,
   },

   get_narrative_line_list_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    config    => 'library/library.conf',
    expected  => 22,
   },

   get_first_part_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => 'SML::PreformattedBlock',
   },

   get_first_part_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    config    => 'library/library.conf',
    expected  => 'SML::Element',
   },

   get_first_part_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    config    => 'library/library.conf',
    expected  => 'SML::PreformattedBlock',
   },

   get_first_part_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    config    => 'library/library.conf',
    expected  => 'SML::PreformattedBlock',
   },

   get_first_line_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => '>>>DOCUMENT',
   },

   get_first_line_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    config    => 'library/library.conf',
    expected  => '* Introduction',
   },

   get_first_line_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    config    => 'library/library.conf',
    expected  => '>>>problem',
   },

   get_first_line_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    config    => 'library/library.conf',
    expected  => '---TABLE',
   },

   get_property_list_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    config    => 'library/library.conf',
    expected  => 9,
   },

   get_property_list_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    config    => 'library/library.conf',
    expected  => 4,
   },

   get_property_list_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    config    => 'library/library.conf',
    expected  => 5,
   },

   get_property_list_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    config    => 'library/library.conf',
    expected  => 2,
   },

   get_property_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    name      => 'title',
    config    => 'library/library.conf',
    expected  => 'SML::Property',
   },

   get_property_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    name      => 'type',
    config    => 'library/library.conf',
    expected  => 'SML::Property',
   },

   get_property_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    name      => 'title',
    config    => 'library/library.conf',
    expected  => 'SML::Property',
   },

   get_property_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    name      => 'id',
    config    => 'library/library.conf',
    expected  => 'SML::Property',
   },

   get_property_value_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'td-000020',
    name      => 'title',
    config    => 'library/library.conf',
    expected  => 'Section Structure With Regions',
   },

   get_property_value_test_2 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'introduction',
    name      => 'type',
    config    => 'library/library.conf',
    expected  => 'chapter',
   },

   get_property_value_test_3 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'problem-1',
    name      => 'title',
    config    => 'library/library.conf',
    expected  => 'Problem One',
   },

   get_property_value_test_4 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    divid     => 'tab-solution-types',
    name      => 'id',
    config    => 'library/library.conf',
    expected  => 'tab-solution-types',
   },

   invalid_explicit_property_declaration =>
   {
    testfile  => 'library/testdata/td-000063.txt',
    warning_1 => 'INVALID EXPLICIT DECLARATION OF INFER-ONLY PROPERTY',
    warning_2 => 'THE FRAGMENT IS NOT VALID',
   },

   missing_required_property =>
   {
    testfile  => 'library/testdata/td-000064.txt',
    warning_1 => 'MISSING REQUIRED PROPERTY',
    warning_2 => 'THE FRAGMENT IS NOT VALID',
   },

   get_id_path_test_1 =>
   {
    testfile  => 'library/testdata/td-000020.txt',
    config    => 'library/library.conf',
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Division;
  use_ok( 'SML::Division' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Division->new(name=>'div',id=>'my-div');
isa_ok( $obj, 'SML::Division' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'init',

   'get_id',
   'get_id_path',
   'get_name',
   'get_number',
   'get_containing_division',
   'get_part_list',
   'get_line_list',
   'get_division_list',
   'get_section_list',
   'get_block_list',
   'get_element_list',
   'get_preamble_line_list',
   'get_narrative_line_list',
   'get_first_part',
   'get_first_line',
   'get_property_list',
   'get_property',
   'get_property_value',
   'get_containing_document',
   'get_location',
   'get_section',
   'get_division_hash',
   'get_property_hash',
   'get_attribute_hash',

   'has_valid_semantics',
   'has_property',
   'has_property_value',
   'has_attribute',

   'add_division',
   'add_part',
   'add_property',
   'add_property_element',
   'add_attribute',

   'validate_semantics',

   'validate_property_cardinality',
   'validate_property_values',
   'validate_infer_only_conformance',
   'validate_required_properties',
   'validate_composition',
   'validate_id_uniqueness',

   'contains_division',
   'is_in_a',
   'as_sml',
   'as_text',
   'as_html',
   'start_html',
   'end_html',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

init_ok('init_test_1');

get_id_ok('get_id_test_1');

get_name_ok('get_name_test_1');

get_number_ok('get_number_test_1');

get_containing_division_ok('get_containing_division_test_1');
get_containing_division_ok('get_containing_division_test_2');
get_containing_division_ok('get_containing_division_test_3');
get_containing_division_ok('get_containing_division_test_4');

get_part_list_ok('get_part_list_test_1');
get_part_list_ok('get_part_list_test_2');
get_part_list_ok('get_part_list_test_3');
get_part_list_ok('get_part_list_test_4');

get_line_list_ok('get_line_list_test_1');
get_line_list_ok('get_line_list_test_2');
get_line_list_ok('get_line_list_test_3');
get_line_list_ok('get_line_list_test_4');

get_division_list_ok('get_division_list_test_1');
get_division_list_ok('get_division_list_test_2');
get_division_list_ok('get_division_list_test_3');
get_division_list_ok('get_division_list_test_4');

get_section_list_ok('get_section_list_test_1');

get_block_list_ok('get_block_list_test_1');
get_block_list_ok('get_block_list_test_2');
get_block_list_ok('get_block_list_test_3');
get_block_list_ok('get_block_list_test_4');

get_element_list_ok('get_element_list_test_1');
get_element_list_ok('get_element_list_test_2');
get_element_list_ok('get_element_list_test_3');
get_element_list_ok('get_element_list_test_4');

get_preamble_line_list_ok('get_preamble_line_list_test_1');
get_preamble_line_list_ok('get_preamble_line_list_test_2');
get_preamble_line_list_ok('get_preamble_line_list_test_3');
get_preamble_line_list_ok('get_preamble_line_list_test_4');

get_narrative_line_list_ok('get_narrative_line_list_test_1');
get_narrative_line_list_ok('get_narrative_line_list_test_2');
get_narrative_line_list_ok('get_narrative_line_list_test_3');
get_narrative_line_list_ok('get_narrative_line_list_test_4');

get_first_part_ok('get_first_part_test_1');
get_first_part_ok('get_first_part_test_2');
get_first_part_ok('get_first_part_test_3');
get_first_part_ok('get_first_part_test_4');

get_first_line_ok('get_first_line_test_1');
get_first_line_ok('get_first_line_test_2');
get_first_line_ok('get_first_line_test_3');
get_first_line_ok('get_first_line_test_4');

get_property_list_ok('get_property_list_test_1');
get_property_list_ok('get_property_list_test_2');
get_property_list_ok('get_property_list_test_3');
get_property_list_ok('get_property_list_test_4');

get_property_ok('get_property_test_1');
get_property_ok('get_property_test_2');
get_property_ok('get_property_test_3');
get_property_ok('get_property_test_4');

get_property_value_ok('get_property_value_test_1');
get_property_value_ok('get_property_value_test_2');
get_property_value_ok('get_property_value_test_3');
get_property_value_ok('get_property_value_test_4');

get_id_path_ok('get_id_path_test_1');

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

# warning_ok( 'invalid_explicit_property_declaration' );
# warning_ok( 'missing_required_property' );

######################################################################

sub get_id_ok {

  my $testid = shift;

  # arrange
  my $id       = $testdata->{$testid}{id};
  my $name     = $testdata->{$testid}{name};
  my $expected = $testdata->{$testid}{expected};
  my $division = SML::Division->new(id=>$id,name=>$name);

  # act
  my $result   = $division->get_id;

  # assert
  is($result, $expected, "get_id $testid");
}

######################################################################

sub get_name_ok {

  my $testid = shift;

  # arrange
  my $id       = $testdata->{$testid}{id};
  my $name     = $testdata->{$testid}{name};
  my $expected = $testdata->{$testid}{expected};
  my $division = SML::Division->new(id=>$id,name=>$name);

  # act
  my $result   = $division->get_name;

  # assert
  is($result, $expected, "get_name $testid");
}

######################################################################

sub get_number_ok {

  my $testid = shift;

  # arrange
  my $id       = $testdata->{$testid}{id};
  my $name     = $testdata->{$testid}{name};
  my $number   = $testdata->{$testid}{number};
  my $expected = $testdata->{$testid}{expected};
  my $division = SML::Division->new(id=>$id,name=>$name);

  $division->set_number($number);

  # act
  my $result   = $division->get_number;

  # assert
  is($result, $expected, "get_number $testid");
}

######################################################################

sub get_containing_division_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = $division->get_containing_division;

  # assert
  isa_ok($result, $expected, "get_containing_division ($divid) $result");
}

######################################################################

sub get_part_list_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = scalar @{ $division->get_part_list };

  # assert
  is($result, $expected, "get_part_list ($divid part count) $result");
}

######################################################################

sub get_line_list_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = scalar @{ $division->get_line_list };

  # assert
  is($result, $expected, "get_line_list ($divid line count) $result");
}

######################################################################

sub get_division_list_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = scalar @{ $division->get_division_list };

  # assert
  is($result, $expected, "get_division_list ($divid division count) $result");
}

######################################################################

sub get_section_list_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = scalar @{ $division->get_section_list };

  # assert
  is($result, $expected, "get_section_list ($divid section count) $result");
}

######################################################################

sub get_block_list_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = scalar @{ $division->get_block_list };

  # assert
  is($result, $expected, "get_block_list ($divid block count) $result");
}

######################################################################

sub get_element_list_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = scalar @{ $division->get_element_list };

  # assert
  is($result, $expected, "get_element_list ($divid element count) $result");
}

######################################################################

sub get_preamble_line_list_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = scalar @{ $division->get_preamble_line_list };

  # assert
  is($result, $expected, "get_preamble_line_list ($divid preamble line count) $result");
}

######################################################################

sub get_narrative_line_list_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = scalar @{ $division->get_narrative_line_list };

  # assert
  is($result, $expected, "get_narrative_line_list ($divid narrative line count) $result");
}

######################################################################

sub get_first_part_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = ref $division->get_first_part;

  # assert
  is($result, $expected, "get_first_part ($divid) $result");
}

######################################################################

sub get_first_line_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $line     = $division->get_first_line;
  my $result   = $line->get_content;

  chomp $result;

  # assert
  is($result, $expected, "get_first_line ($divid) $result");
}

######################################################################

sub get_property_list_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = scalar @{ $division->get_property_list };

  # assert
  is($result, $expected, "get_property_list ($divid property count) $result");
}

######################################################################

sub get_property_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $name     = $testdata->{$testid}{name};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = ref $division->get_property($name);

  # assert
  is($result, $expected, "get_property ($divid $name) $result");
}

######################################################################

sub get_property_value_ok {

  my $testid = shift;

  # arrange
  my $testfile = $testdata->{$testid}{testfile};
  my $divid    = $testdata->{$testid}{divid};
  my $name     = $testdata->{$testid}{name};
  my $config   = $testdata->{$testid}{config};
  my $expected = $testdata->{$testid}{expected};
  my $library  = SML::Library->new(config_filespec=>$config);
  my $parser   = $library->get_parser;
  my $fragment = $parser->parse($testfile);
  my $division = $library->get_division($divid);

  # act
  my $result   = $division->get_property_value($name);

  # assert
  is($result, $expected, "get_property_value ($divid $name) $result");
}

######################################################################

sub init_ok {

  my $testid = shift;

  # arrange
  my $id       = $testdata->{$testid}{id};
  my $name     = $testdata->{$testid}{name};
  my $expected = $testdata->{$testid}{expected};
  my $division = SML::Division->new(id=>$id,name=>$name);

  # act
  my $result = $division->init;

  # assert
  is($result, $expected, "init $testid");
}

######################################################################

sub warning_ok {

  my $testid = shift;

  my $testfile  = $testdata->{$testid}{testfile};
  my $warning_1 = $testdata->{$testid}{warning_1};
  my $warning_2 = $testdata->{$testid}{warning_2};

  my $config    = 'library/library.conf';
  my $library   = SML::Library->new(config_filespec=>$config);
  my $parser    = $library->get_parser;

  my $t1logger  = Test::Log4perl->get_logger('sml.division');
  my $t2logger  = Test::Log4perl->get_logger('sml.fragment');

  Test::Log4perl->start( ignore_priority => "info" );
  $t1logger->warn(qr/$warning_1/);
  $t2logger->warn(qr/$warning_2/);

  my $fragment  = $parser->parse($testfile);

  # act
  $fragment->validate_semantics;

  # assert
  Test::Log4perl->end("WARNING: $warning_1 ($testid)");

}

######################################################################

sub get_id_path_ok {

  my $testid = shift;

  # arrange
  my $testfile      = $testdata->{$testid}{testfile};
  my $config        = $testdata->{$testid}{config};
  my $library       = SML::Library->new(config_filespec=>$config);
  my $parser        = $library->get_parser;
  my $fragment      = $parser->parse($testfile);
  my $division_list = $fragment->get_division_list;

  # act
  foreach my $division (@{ $division_list })
    {
      my $path    = $division->get_id_path;

      print "$path\n";
    }

  # assert
  my $result   = 1;
  my $expected = 1;
  is($result, $expected, "get_id_path $testid")
}

######################################################################
