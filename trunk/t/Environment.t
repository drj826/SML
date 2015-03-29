#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 2;

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
  use SML::Environment;
  use_ok( 'SML::Environment' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $args = {};

$args->{id}      = 'env1';
$args->{name}    = 'environment';
$args->{library} = $library;

my $obj = SML::Environment->new(%{$args});
isa_ok($obj,'SML::Environment');

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Environment public attribute accessors
   # <none>

   # SML::Environment public methods
   # <none>
  );

# can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
