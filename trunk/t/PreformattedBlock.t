#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 4;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $library = $td->get_test_object('SML::Library','library');

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::PreformattedBlock;
  use_ok( 'SML::PreformattedBlock' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::PreformattedBlock->new(name=>'title',library=>$library);

isa_ok($obj,'SML::PreformattedBlock');

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_name',
   'add_line',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
   '_build_content',
  );

can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
