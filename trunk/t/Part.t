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
my $library = $td->get_test_library_1;

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

my $obj = SML::Part->new(name=>'test',library=>$library);
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
    has_part_ok($tc)               if defined $tc->{expected}{has_part};
    get_part_ok($tc)               if defined $tc->{expected}{get_part};
    render_ok($tc,'sml','default') if defined $tc->{expected}{render}{sml}{default};
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
  my $library  = $tc->{library};
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
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filename);
  my $document = $library->get_document($docid);

  # act
  my $result = $document->get_part($part_id);

  # assert
  isa_ok($result,$expected,"$tcname get_part $result");
}

######################################################################

sub render_ok {

  my $tc        = shift;                # test case
  my $rendition = shift;                # e.g. sml, html, latex
  my $style     = shift;                # e.g. default

  # arrange
  my $tcname   = $tc->{name};
  my $text     = $tc->{text};
  my $library  = $tc->{library};
  my $expected = $tc->{expected}{render}{$rendition}{$style};
  my $parser   = $library->get_parser;
  my $part     = $parser->create_string($text);

  # act
  my $result  = $part->render($rendition,$style);
  my $summary = $result;
  $summary = substr($result,0,20) . '...' if length($result) > 20;

  print "STRUCTURE:\n\n";
  print $part->dump_part_structure, "\n\n";

  # assert
  is($result,$expected,"$tcname render $rendition $style \'$summary\'");
}

######################################################################

done_testing()
