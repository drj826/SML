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
  use SML::Paragraph;
  use_ok( 'SML::Paragraph' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Paragraph->new(library=>$library);

isa_ok($obj,'SML::Paragraph');

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_name',
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
