#!/usr/bin/perl

# $Id: DefinitionListItem.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 5;
# use Test::Exception;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

# use Test::Log4perl;
# my $t1logger = Test::Log4perl->get_logger('sml.DefinitionListItem');

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

   definition_list_item_1 =>
   {
    content    => '= term 1 = definition of term 1',
    term       => 'term 1',
    definition => 'definition of term 1',
   },

   bad_definition_list_item_1 =>
   {
    content => 'This is not a definition list item',
    error   => 'DEFINITION LIST ITEM SYNTAX ERROR',
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::DefinitionListItem;
  use_ok( 'SML::DefinitionListItem' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::DefinitionListItem->new(name=>'dlitem',id=>'dlitem-1');
isa_ok( $obj, 'SML::DefinitionListItem' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_name',
   # 'get_type',
   'get_term',
   'get_definition',
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

get_term_ok(       'definition_list_item_1', 'al-000408' );
get_definition_ok( 'definition_list_item_1', 'al-000409' );

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

# error_ok( 'get_term',       'bad_definition_list_item_1' );
# error_ok( 'get_definition', 'bad_definition_list_item_1' );

######################################################################

sub get_term_ok {

  my $testid     = shift;
  my $allocation = shift;

  # Arrange
  my $content  = $testdata->{$testid}{content};
  my $expected = $testdata->{$testid}{term};

  my $item = SML::DefinitionListItem->new(name=>'dlitem',id=>'dlitem-1');
  my $line = SML::Line->new(content=>$content);

  $item->add_line($line);

  # Act
  my $string = $item->get_term;
  my $term   = $string->get_content;

  # Assert
  is($term, $expected, "get_term $testid");
}

######################################################################

sub get_definition_ok {

  my $testid     = shift;
  my $allocation = shift;

  # Arrange
  my $content  = $testdata->{$testid}{content};
  my $expected = $testdata->{$testid}{definition};

  my $item = SML::DefinitionListItem->new(name=>'dlitem',id=>'dlitem-1');
  my $line = SML::Line->new(content=>$content);

  $item->add_line($line);

  # Act
  my $string     = $item->get_definition;
  my $definition = $string->get_content;

  # Assert
  is($definition, $expected, "get_definition $testid");
}

######################################################################

# sub error_ok {

#   my $method = shift;
#   my $testid = shift;

#   # arrange
#   my $content    = $testdata->{$testid}{content};
#   my $error      = $testdata->{$testid}{error};
#   my $definition = SML::DefinitionListItem->new();

#   Test::Log4perl->start( ignore_priority => "warn" );
#   $t1logger->error(qr/$error/);

#   # act
#   my $result = $definition->$method;

#   # assert
#   Test::Log4perl->end("ERROR: $error ($testid)");
# }

######################################################################
