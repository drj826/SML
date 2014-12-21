#!/usr/bin/perl

# $Id: Source.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 4;
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
  use SML::Source;
  use_ok( 'SML::Source' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Source->new(id=>'src1');
isa_ok( $obj, 'SML::Source' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_name',
   'get_number',
   'get_file',
   'get_author',
   'get_date',
   'get_address',
   'get_annote',
   'get_booktitle',
   'get_chapter',
   'get_crossref',
   'get_edition',
   'get_editor',
   'get_howpublished',
   'get_institution',
   'get_journal',
   'get_key',
   'get_month',
   'get_note',
   'get_organization',
   'get_pages',
   'get_publisher',
   'get_school',
   'get_series',
   'get_source',
   'get_subtitle',
   'get_source_type',
   'get_volume',
   'get_year',
   'get_appearance',
   'get_color',
   'get_icon',
   'get_mimetype',
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
