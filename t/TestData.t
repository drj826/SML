#!/usr/bin/perl

# $Id: TestData.t 125 2015-02-24 02:43:25Z drj826@gmail.com $

use lib "../lib";
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

done_testing()
