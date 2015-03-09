#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 5;
# use Test::Exception;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td  = SML::TestData->new;
my $tcl = $td->get_definition_list_item_test_case_list;

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

my $obj = SML::DefinitionListItem->new();
isa_ok( $obj, 'SML::DefinitionListItem' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::DefinitionListItem public attribute accessors
   'get_term',
   'get_definition',

   # SML::DefinitionListItem public methods
   # <none>
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    get_term_ok($tc)       if defined $tc->{expected}{get_term};
    get_definition_ok($tc) if defined $tc->{expected}{get_definition};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_term_ok {

  my $tc = shift;                       # test case

  # Arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{get_term};
  my $text     = $tc->{text};
  my $line     = SML::Line->new(content=>$text);
  my $item     = SML::DefinitionListItem->new();

  $item->add_line($line);

  # Act
  my $term   = $item->get_term;
  my $result = $term->get_content;

  # Assert
  is($result,$expected,"$tcname get_term $result");
}

######################################################################

sub get_definition_ok {

  my $tc = shift;                       # test case

  # Arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{get_definition};
  my $text     = $tc->{text};
  my $line     = SML::Line->new(content=>$text);
  my $item     = SML::DefinitionListItem->new();

  $item->add_line($line);

  # Act
  my $definition = $item->get_definition;
  my $result     = $definition->get_content;

  # Assert
  is($result,$expected,"$tcname get_term $result");
}

######################################################################

1;
