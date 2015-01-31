#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 5;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   conditional_1 =>
   {
    token => 'version_1',
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Conditional;
  use_ok( 'SML::Conditional' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Conditional->new(id=>'c1',token=>'v2');
isa_ok( $obj, 'SML::Conditional' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_name',
   'get_token',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed attributes?
#---------------------------------------------------------------------

my @attributes =
  (
   'token',
  );

can_ok( $obj, @attributes );

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

get_token_ok( 'conditional_1' );

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_token_ok {

  my $testid = shift;

  # arrange
  my $token       = $testdata->{$testid}{token};
  my $expected    = $testdata->{$testid}{token};
  my $conditional = SML::Conditional->new(id=>$testid,token=>$token);

  # act
  my $result = $conditional->get_token;

  # assert
  is($result,$expected,"get_token $testid");
}

######################################################################
