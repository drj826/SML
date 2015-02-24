#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 2;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new();
my $tcl     = $td->get_formatter_test_case_list;
my $library = $td->get_library;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Formatter;
  use_ok( 'SML::Formatter' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Formatter->new(library=>$library);
isa_ok( $obj, 'SML::Formatter' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
  );

# can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed attributes?
#---------------------------------------------------------------------

my @attributes =
  (
  );

# can_ok( $obj, @attributes );

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

sub format_block_ok {

  my $testid = shift;

  # arrange
  my $text      = $testdata->{$testid}{text};
  my $style     = $testdata->{$testid}{style};
  my $expected  = $testdata->{$testid}{expected};
  my $config    = $testdata->{$testid}{config};
  my $library   = SML::Library->new(config_filename=>$config);
  my $line      = SML::Line->new();
  my $block     = SML::block->new();
  my $formatter = $library->get_formatter;

  # act
  my $result   = $formatter->format_block($block,$style);

  # assert
  is($result, $expected, "format $testid");
}

######################################################################

sub format_division_ok {

  my $testid = shift;

  # arrange
  my $text      = $testdata->{$testid}{text};
  my $style     = $testdata->{$testid}{style};
  my $expected  = $testdata->{$testid}{expected};
  my $config    = $testdata->{$testid}{config};
  my $library   = SML::Library->new(config_filename=>$config);
  my $line      = SML::Line->new();
  my $block     = SML::block->new();
  my $formatter = $library->get_formatter;

  # act
  my $result   = $formatter->format_block($block,$style);

  # assert
  is($result, $expected, "format $testid");
}

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
