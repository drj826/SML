#!/usr/bin/perl

# $Id: Element.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 5;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use Test::Log4perl;
my $t1logger = Test::Log4perl->get_logger('sml.element');
my $t2logger = Test::Log4perl->get_logger('sml.document');

my $config_file = 'library/library.conf';
my $library     = SML::Library->new(config_filespec=>$config_file);

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   invalid_filespec =>
   {
    testfile  => 'library/testdata/td-000066.txt',
    docid     => 'td-000066',
    warning_1 => 'INVALID FILE',
    warning_2 => 'THE DOCUMENT IS NOT VALID',
   },

   invalid_image_file =>
   {
    testfile  => 'library/testdata/td-000068.txt',
    docid     => 'td-000068',
    warning_1 => 'INVALID IMAGE FILE',
    warning_2 => 'THE DOCUMENT IS NOT VALID',
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Element;
  use_ok( 'SML::Element' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Element->new(name=>'element',);
isa_ok( $obj, 'SML::Element' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'has_valid_syntax',
   'has_valid_semantics',

   'get_name',
   'get_type',
   'get_value',

   'as_html',

   'validate_syntax',
   'validate_semantics',

   'validate_outcome_semantics',
   'validate_footnote_syntax',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

@private_methods =
  (
   '_type_of',
  );

can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
