#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 5;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

# create a yyyy-mm-dd date stamp
#
use Date::Pcalc;
my ($yyyy,$mm,$dd) = Date::Pcalc::Today();
$mm = '0' . $mm until length $mm == 2;
$dd = '0' . $dd until length $dd == 2;
my $date = "$yyyy-$mm-$dd";

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   top_level_item =>
   {
    sml   => '+ top level item',
    value => 'top level item',
   },

   indented_item =>
   {
    sml   => '  + indented item',
    value => 'indented item',
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::EnumeratedListItem;
  use_ok( 'SML::EnumeratedListItem' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::EnumeratedListItem->new(name=>'li1');
isa_ok( $obj, 'SML::EnumeratedListItem' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_value',
  );

can_ok( $obj, @public_methods );

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

value_ok('top_level_item','al-000407');
value_ok('indented_item', 'al-000407');

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub value_ok {

  my $testid     = shift;
  my $allocation = shift;

  #-------------------------------------------------------------------
  # Arrange
  #
  my $sml      = $testdata->{$testid}{'sml'};
  my $expected = $testdata->{$testid}{'value'};

  my $line     = SML::Line->new(content=>$sml);
  my $item     = SML::EnumeratedListItem->new(name=>'eli');

  $item->add_line($line);

  #-------------------------------------------------------------------
  # Act
  #
  my $value = $item->get_value;

  #-------------------------------------------------------------------
  # Assert
  #
  is($value, $expected, "$date $allocation $testid returns correct value OK");
}

######################################################################
