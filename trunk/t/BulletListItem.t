#!/usr/bin/perl

# $Id: BulletListItem.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 6;
use Test::Perl::Critic (-severity => 3);

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
    sml   => '- top level item',
    value => 'top level item',
   },

   indented_item =>
   {
    sml   => '  - indented item',
    value => 'indented item',
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::BulletListItem;
  use_ok( 'SML::BulletListItem' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::BulletListItem->new(name=>'bullet-list-item');
isa_ok( $obj, 'SML::BulletListItem' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_name',
   'get_type',
   'get_value',
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

get_value_ok( 'top_level_item', 'al-000406' );
get_value_ok( 'indented_item',  'al-000406' );

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_value_ok {

  my $testid     = shift;
  my $allocation = shift;

  #-------------------------------------------------------------------
  # Arrange
  #
  my $content  = $testdata->{$testid}{'sml'};
  my $expected = $testdata->{$testid}{'value'};

  my $line = SML::Line->new(content=>$content);
  my $item = SML::BulletListItem->new(name=>'bullet_list_item');

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
