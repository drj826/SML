#!/usr/bin/perl

# $Id: EnumeratedListItem.t 259 2015-04-02 20:27:00Z drj826@gmail.com $

use lib "../lib";
use Test::More tests => 5;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $tcl     = $td->get_enumerated_list_item_test_case_list;
my $library = $td->get_test_library_1;

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

my $obj = SML::EnumeratedListItem->new(library=>$library);
isa_ok( $obj, 'SML::EnumeratedListItem' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::EnumeratedListItem public attribute accessors
   # <none>

   # SML::EnumeratedListItem public methods
   'get_value',
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
  my $text     = $tc->{text};
  my $library  = $tc->{library};
  my $line     = SML::Line->new(content=>$text);
  my $expected = $tc->{expected}{get_value};
  my $item     = SML::EnumeratedListItem->new(library=>$library);

  $item->add_line($line);

  # act
  my $result = $item->get_value;

  # assert
  is($result,$expected,"$tcname get_value $result");
}

######################################################################

1;
