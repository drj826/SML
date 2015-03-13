#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 3;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new();
my $tcl     = $td->get_formatter_test_case_list;
# my $library = $td->get_test_object('SML::Library','library');

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Formatter;
  use_ok( 'SML::Formatter' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $library = SML::Library->new(config_file=>'library.conf');
my $obj = SML::Formatter->new(library=>$library);
isa_ok( $obj, 'SML::Formatter' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Formatter public attribute accessors
   'get_library',

   # SML::Formatter public methods
   'publish_html_by_section',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

1;
