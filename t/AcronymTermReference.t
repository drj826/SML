#!/usr/bin/perl

# $Id: AcronymTermReference.t 125 2015-02-24 02:43:25Z drj826@gmail.com $

use lib "../lib";
use Test::More tests => 6;

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

my $td      = SML::TestData->new();
my $tcl     = $td->get_acronym_term_reference_test_case_list;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::AcronymTermReference;
  use_ok( 'SML::AcronymTermReference' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::AcronymTermReference->new
  (
   tag       => 'ac',
   acronym   => 'TLA',
   namespace => '',
   library   => $library,
  );

isa_ok( $obj, 'SML::AcronymTermReference' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Part public accessors (inherited)
   'get_id',
   'set_id',
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

   # SML::String public accessors (inherited)
   'get_containing_division',
   'get_containing_block',

   # SML::String public methods (inherited)
   'get_location',
   'get_containing_document',

   # SML::AcronymTermReference public accessors
   'get_tag',
   'get_acronym',
   'get_namespace',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    get_tag_ok($tc)       if defined $tc->{expected}{get_tag};
    get_acronym_ok($tc)   if defined $tc->{expected}{get_acronym};
    get_namespace_ok($tc) if defined $tc->{expected}{get_namespace};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_tag_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{get_tag};
  my $args     = $tc->{args};
  my $atr      = SML::AcronymTermReference->new(%{$args});

  # act
  my $result = $atr->get_tag;

  # assert
  is($result,$expected,"$tcname get_tag $result");
}

######################################################################

sub get_acronym_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{get_acronym};
  my $args     = $tc->{args};
  my $atr      = SML::AcronymTermReference->new(%{$args});

  # act
  my $result = $atr->get_acronym;

  # assert
  is($result,$expected,"$tcname get_acronym $result");
}

######################################################################

sub get_namespace_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{get_namespace};
  my $args     = $tc->{args};
  my $atr      = SML::AcronymTermReference->new(%{$args});

  # act
  my $result = $atr->get_namespace;

  # assert
  is($result,$expected,"$tcname get_namespace $result");
}

######################################################################

1;
