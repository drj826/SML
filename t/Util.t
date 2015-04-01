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

my $obj = SML::Util->new;
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
