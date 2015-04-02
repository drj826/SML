#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 5;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $tcl     = $td->get_bullet_list_item_test_case_list;
my $library = $td->get_test_library_1;

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

my $args = {};

$args->{library} = $library;

my $obj = SML::BulletListItem->new(%{$args});
isa_ok( $obj, 'SML::BulletListItem' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::BulletListItem public attribute accessors
   # <none>

   # SML::BulletListItem public methods
   'get_value',

   # SML::ListItem public attribute accessors (inherited)
   # <none>

   # SML::ListItem public methods (inherited)
   # get_value (overridden by SML::BulletListItem)

   # SML::Block public attribute accessors (inherited)
   'get_name_path',
   'get_line_list',
   'set_line_list',
   'clear_line_list',
   'has_line_list',
   'get_containing_division',
   'set_containing_division',
   'clear_containing_division',
   'has_containing_division',
   'has_valid_syntax',
   'has_valid_semantics',

   # SML::Block public methods (inherited)
   'add_line',
   'add_part',
   'get_first_line',
   'get_location',
   'is_in_a',

   # SML::Part public attribute accessors (inherited)
   'get_id',
   'get_id_path',
   'get_name',
   'get_content',
   'set_content',
   'get_part_list',

   # SML::Part public methods (inherited)
   'init',
   'has_content',
   'has_parts',
   'has_part',
   'get_part',
   'add_part',
   'get_containing_document',
   'is_in_section',
   'get_containing_section',
   'render',
   'dump_part_structure',
   'get_library',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    get_value_ok($tc) if defined $tc->{expected}{get_value};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_value_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{get_value};
  my $line     = $tc->{line};
  my $args     = $tc->{args};
  my $item     = SML::BulletListItem->new(%{$args});

  $item->add_line($line);

  # act
  my $result = $item->get_value;

  # assert
  is($result,$expected,"$tcname get_value $result");
}

######################################################################
