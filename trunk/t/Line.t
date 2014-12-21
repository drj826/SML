#!/usr/bin/perl

# $Id: Line.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 5;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Line;
  use_ok( 'SML::Line' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Line->new(content=>'test line of text');
isa_ok( $obj, 'SML::Line' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_filespec',
   'get_content',
   'get_file',
   'get_included_from_line',
   'get_num',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
  );

# can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

is( $obj->get_content,  'test line of text', 'returns expected content'  );
is( $obj->get_location, 'UNKNOWN',           'returns expected line location'  );

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
