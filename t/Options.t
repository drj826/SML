#!/usr/bin/perl

use lib "../lib";
use Test::More tests => 5;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Options;
  use_ok( 'SML::Options' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Options->new;
isa_ok( $obj, 'SML::Options' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Options public attribute accessors
   'get_config_filespec',
   'using_gui',
   'set_using_gui',
   'be_verbose',
   'set_be_verbose',
   'run_scripts',
   'set_run_scripts',
   'use_svn',
   'set_use_svn',
   'get_svn_executable',
   'set_svn_executable',
   'get_pdflatex_executable',
   'set_pdflatex_executable',
   'get_pdflatex_args',
   'set_pdflatex_args',
   'get_bibtex_executable',
   'set_bibtex_executable',
   'get_makeindex_executable',
   'set_makeindex_executable',
   'get_convert_executable',
   'set_convert_executable',

   'get_MAX_SEC_DEPTH',
   'get_MAX_RESOLVE_INCLUDES',
   'get_MAX_RUN_SCRIPTS',
   'get_MAX_RESOLVE_CONDITIONALS',
   'get_MAX_PARSE_LINES',
   'get_MAX_INSERT_CONTENT',
   'get_MAX_SUBSTITUTE_VARIABLES',
   'get_MAX_RESOLVE_LOOKUPS',
   'get_MAX_RESOLVE_TEMPLATES',
   'get_MAX_GENERATE_CONTENT',
   'get_MAX_ID_HIERARCHY_DEPTH',

   'get_status_icon_grey_filespec',
   'get_status_icon_green_filespec',
   'get_status_icon_yellow_filespec',
   'get_status_icon_red_filespec',

   'trigger_resource_updates',
   'use_formal_status',
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

# act
$obj = SML::Options->new(config_filespec=>'sml.conf');

# assert
ok( defined $obj, 'new with sml.conf config file' );

#---------------------------------------------------------------------

# act
$obj = SML::Options->new(config_filespec=>'sml.1.conf');

# assert
ok( defined $obj, 'new with sml.1.conf config file' );

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
