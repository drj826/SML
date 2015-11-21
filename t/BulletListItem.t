#!/usr/bin/perl

# $Id: BulletListItem.t 259 2015-04-02 20:27:00Z drj826@gmail.com $

use lib "../lib";
use Test::More tests => 5;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

# set sml.Library logger to WARN
my $logger_library = Log::Log4perl::get_logger('sml.Library');
$logger_library->level('WARN');

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

$args->{library}            = $library;
$args->{leading_whitespace} = '';

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
   'get_line_list',
   'get_containing_division',
   'set_containing_division',
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
   'get_name',
   'get_content',
   'set_content',
   'get_part_list',

   # SML::Part public methods (inherited)
   'init',
   'has_content',
   'contains_parts',
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
  my $tcname     = $tc->{name};
  my $expected   = $tc->{expected}{get_value};
  my $line       = $tc->{line};
  my $library    = $tc->{library};
  my $whitespace = $tc->{leading_whitespace};
  my $parser     = $library->get_parser;

  my $item = SML::BulletListItem->new
    (
     library            => $library,
     leading_whitespace => $whitespace,
    );

  $item->add_line($line);

  $parser->_begin_block($item);
  $parser->_end_block($item);

  # act
  my $result = $item->get_value;

  # assert
  is($result,$expected,"$tcname get_value $result");
}

######################################################################
