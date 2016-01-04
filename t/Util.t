#!/usr/bin/perl

use lib "../lib";
use Test::More tests => 4;

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

my $td      = SML::TestData->new();
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Util;
  use_ok( 'SML::Util' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Util->new(library=>$library);
isa_ok( $obj, 'SML::Util' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_options',
   'get_blank_line',
   'get_empty_block',
   'get_empty_file',
   'get_empty_document',
   'get_default_section',
   'trim_whitespace',
   'compress_whitespace',
   'remove_newlines',
   'wrap',
   'hyphenate',
   'remove_literals',
   'remove_keystroke_symbols',
   'walk_directory',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
   '_build_blank_line',
   '_build_default_section',
  );

can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
