#!/usr/bin/perl

# $Id: Listitem.t 259 2015-04-02 20:27:00Z drj826@gmail.com $

use lib "../lib";
use Test::More tests => 3;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

# set sml.Library logger to WARN
my $logger_library = Log::Log4perl::get_logger('sml.Library');
$logger_library->level('WARN');

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::ListItem;
  use_ok( 'SML::ListItem' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $args = {};

$args->{library}            = $library;
$args->{leading_whitespace} = '';

my $obj = SML::ListItem->new(%{$args});

isa_ok($obj,'SML::ListItem');

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::ListItem public attribute accessors
   # <none>

   # SML::ListItem public methods
   'get_value',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
