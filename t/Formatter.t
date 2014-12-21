#!/usr/bin/perl

# $Id: Formatter.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 3;
use Test::Perl::Critic (-severity => 3);

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

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

my $obj = SML::Formatter->new();
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
  my $library   = SML::Library->new(config_filespec=>$config);
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
  my $library   = SML::Library->new(config_filespec=>$config);
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
