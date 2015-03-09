#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 4;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

# use Test::Log4perl;
# my $t1logger = Test::Log4perl->get_logger('sml.element');
# my $t2logger = Test::Log4perl->get_logger('sml.document');

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td  = SML::TestData->new;
my $tcl = $td->get_element_test_case_list;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Element;
  use_ok( 'SML::Element' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Element->new(name=>'element',);
isa_ok( $obj, 'SML::Element' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Element public attribute accessors
   # <none>

   # SML::Element public methods
   'get_value',
   'validate_element_allowed',
   'validate_outcome_semantics',
   'validate_footnote_syntax',
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
  my $name     = $tc->{element_name};
  my $text     = $tc->{text};
  my $line     = SML::Line->new(content=>$text);
  my $element  = SML::Element->new(name=>$name);
  my $expected = $tc->{expected}{get_value};

  $element->add_line($line);

  # act
  my $result = $element->get_value;

  # assert
  is($result,$expected,"$tcname get_value $result");
}

######################################################################

1;
