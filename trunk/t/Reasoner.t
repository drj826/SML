#!/usr/bin/perl

# $Id: Reasoner.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 3;

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
  use SML::Reasoner;
  use_ok( 'SML::Reasoner' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

# arrange
my $config_file = 'library.conf';
my $library     = SML::Library->new(config_filename=>$config_file);

# act
my $obj = SML::Reasoner->new(id=>'reasoner-0',library=>$library);

# assert
isa_ok( $obj, 'SML::Reasoner' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_library',
   'infer_inverse_property',
   'infer_status_from_outcomes',
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

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
