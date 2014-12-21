#!/usr/bin/perl

# $Id: Svninfo.t 15151 2013-07-08 21:01:16Z don.johnson $

# Svninfo.pm unit tests

use lib "..";
use Test::More tests => 5;
use Test::Perl::Critic (-severity => 4);

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
  use SML::Svninfo;
  use_ok( 'SML::Svninfo' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $filespec = 'library/testdata/td-000001.txt';
my $obj      = SML::Svninfo->new(filespec=>$filespec);
isa_ok( $obj, 'SML::Svninfo' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_filespec',
   'get_revision',
   'get_date',
   'get_author',
   'get_days_old',
   'get_text',

   'has_been_modified',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
   'BUILD',
  );

can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
