#!/usr/bin/perl

# $Id: Fragment.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 7;

use SML;
use SML::File;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   problem_region_in_fragment_1 =>
   {
    filespec  => 'library/testdata/td-000074.txt',
    divid     => 'my-problem',
    linecount => 19,
   },

   table_environment_in_fragment_1 =>
   {
    filespec  => 'library/testdata/td-000074.txt',
    divid     => 'tab-solution-types',
    linecount => 29,
   },

   section_in_fragment_1 =>
   {
    filespec  => 'library/testdata/td-000074.txt',
    divid     => 'introduction',
    linecount => 16,
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Fragment;
  use_ok( 'SML::Fragment' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

# arrange
my $config   = 'library/library.conf';
my $library  = SML::Library->new(config_filespec=>$config);
my $filespec = 'library/testdata/td-000001.txt';
my $file     = SML::File->new(filespec=>$filespec);

# act
my $obj = SML::Fragment->new(file=>$file);

# assert
isa_ok( $obj, 'SML::Fragment' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_name',
   'get_id',
   'get_line_list',
   'get_resource',
   'get_file',
   'get_included_from_line',
   'get_resource_hash',

   'has_resource',

   'add_resource',

   'has_valid_syntax',
   'has_valid_semantics',

   'extract_division_lines',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
   'BUILD',
   '_read_file',
  );

can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

extracts_division_lines_ok( 'problem_region_in_fragment_1' );
extracts_division_lines_ok( 'table_environment_in_fragment_1' );
extracts_division_lines_ok( 'section_in_fragment_1' );

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub extracts_division_lines_ok {

  my $testid    = shift;

  # arrange
  my $filespec  = $testdata->{$testid}{filespec};
  my $expected  = $testdata->{$testid}{linecount};
  my $target_id = $testdata->{$testid}{divid};
  my $file      = SML::File->new(filespec=>$filespec);
  my $fragment  = SML::Fragment->new(file=>$file);

  # act
  my $lines = $fragment->extract_division_lines($target_id);
  my $count = scalar @{ $lines };

  # assert
  is($count, $expected, "extract_division_lines returns expected number of lines ($testid)" );
}

######################################################################
