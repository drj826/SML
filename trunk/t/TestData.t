#!/usr/bin/perl

# $Id: TestData.t 125 2015-02-24 02:43:25Z drj826@gmail.com $

use lib "..";
use Test::More;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td = SML::TestData->new();
my $tcl = $td->get_test_data_test_case_list;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::TestData;
  use_ok( 'SML::TestData' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::TestData->new;
isa_ok( $obj, 'SML::TestData' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::TestData public attribute accessors
   'get_division_test_case_list',
   'get_formatter_test_case_list',
   'get_part_test_case_list',
   'get_cross_reference_test_case_list',
   'get_block_test_case_list',
   'get_string_test_case_list',
   'get_acronym_list_test_case_list',
   'get_block_test_case_list',
   'get_library_test_case_list',
   'get_parser_test_case_list',
   'get_string_test_case_list',

   # SML::TestData public methods
   'add_test_object',
   'has_test_object',
   'get_test_object',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    get_test_object_ok($tc) if defined $tc->{expected}{get_test_object};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_test_object_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname      = $tc->{name};
  my $object_type = $tc->{object_type};
  my $object_name = $tc->{object_name};
  my $expected    = $tc->{expected}{get_test_object};
  my $td          = $tc->{test_data};

  # act
  my $result = ref $td->get_test_object($object_type,$object_name);

  # assert
  is($result,$expected,"$tcname get_test_object $result");
}

######################################################################

done_testing()
