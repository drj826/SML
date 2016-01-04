#!/usr/bin/perl

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
  use SML::Conditional;
  use_ok( 'SML::Conditional' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $args = {};

$args->{id}      = 'c1';
$args->{token}   = 'v2';
$args->{library} = $library;

my $obj = SML::Conditional->new(%{$args});
isa_ok( $obj, 'SML::Conditional' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_name',
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
