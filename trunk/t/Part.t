#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new();
my $tcl     = $td->get_part_test_case_list;
# my $library = $td->get_test_object('SML::Library','library');
# my $parser  = $library->get_parser;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Part;
  use_ok( 'SML::Part' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Part->new(name=>'test');
isa_ok( $obj, 'SML::Part' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # public attribute accessors
   'get_id',
   'set_id',
   'get_id_path',
   'get_name',
   'get_content',
   'set_content',
   'get_part_list',

   # public methods
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
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    has_part_ok($tc) if defined $tc->{expected}{has_part};
    get_part_ok($tc) if defined $tc->{expected}{get_part};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub has_part_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $part_id  = $tc->{part_id};
  my $filename = $tc->{filename};
  my $docid    = $tc->{docid};
  my $expected = $tc->{expected}{has_part};
  my $library  = SML::Library->new(config_file=>'library.conf');
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filename);
  my $document = $library->get_document($docid);

  # act
  my $result = $document->has_part($part_id);

  # assert
  is($result,$expected,"$tcname has_part $result");
}

######################################################################

sub get_part_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $part_id  = $tc->{part_id};
  my $filename = $tc->{filename};
  my $docid    = $tc->{docid};
  my $expected = $tc->{expected}{get_part};
  my $library  = SML::Library->new(config_file=>'library.conf');
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filename);
  my $document = $library->get_document($docid);

  # act
  my $result = $document->get_part($part_id);

  # assert
  isa_ok($result,$expected,"$tcname get_part $result");
}

######################################################################

done_testing()
