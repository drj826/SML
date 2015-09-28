#!/usr/bin/perl

# $Id: Block.t 259 2015-04-02 20:27:00Z drj826@gmail.com $

use lib "../lib";
use Test::More;
use Test::Exception;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use Test::Log4perl;
my $t1logger = Test::Log4perl->get_logger('sml.Block');

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new();
my $tcl     = $td->get_block_test_case_list;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Block;
  use_ok( 'SML::Block' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $args = {};

$args->{name}    = 'PARAGRAPH';
$args->{library} = $library;

my $obj = SML::Block->new(%{$args});

isa_ok( $obj, 'SML::Block' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Block public attribute accessors
   'get_name_path',
   'get_line_list',
   'get_containing_division',
   'set_containing_division',
   'has_containing_division',
   'has_valid_syntax',
   'has_valid_semantics',

   # SML::Block public methods
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
    renders_ok($tc,'sml','default')   if defined $tc->{expected}{render}{sml}{default};
    renders_ok($tc,'html','default')  if defined $tc->{expected}{render}{html}{default};
    renders_ok($tc,'latex','default') if defined $tc->{expected}{render}{latex}{default};
    has_valid_syntax_ok($tc)          if defined $tc->{expected}{has_valid_syntax};
    valid_syntax_warning_ok($tc)      if defined $tc->{expected}{valid_syntax_warning};
    has_valid_semantics_ok($tc)       if defined $tc->{expected}{has_valid_semantics};
    valid_semantics_warning_ok($tc)   if defined $tc->{expected}{valid_semantics_warning};
    has_parts_ok($tc)                 if defined $tc->{expected}{has_parts};
  }

######################################################################

sub renders_ok {

  my $tc        = shift;                # test case
  my $rendition = shift;                # e.g. html
  my $style     = shift;                # e.g. default

  # Arrange
  my $tcname    = $tc->{name};
  my $content   = $tc->{content};
  my $subclass  = $tc->{subclass};
  my $expected  = $tc->{expected}{render}{$rendition}{$style};
  my $filename  = $tc->{filename};
  my $docid     = $tc->{docid};
  my $library   = $tc->{library};
  my $parser    = $library->get_parser;
  my $fragment  = $parser->create_fragment($filename);
  my $document  = $library->get_document($docid);
  my $line      = SML::Line->new(content=>$content);
  my $block     = $subclass->new(library=>$library);

  $block->add_line($line);
  $document->add_part($block);

  foreach my $block (@{ $fragment->get_block_list })
    {
      $parser->_parse_block($block);
    }

  # Act
  my $result = $block->render($rendition,$style);

  my $summary = substr($result,0,20);
  $summary =~ s/[\n\r]+//g;

  # Assert
  is($result,$expected,"$tcname renders $rendition $style ($summary...)");
}

######################################################################

sub has_valid_syntax_ok {

  my $tc        = shift;                # test case

  # Arrange
  my $tcname    = $tc->{name};
  my $content   = $tc->{content};
  my $subclass  = $tc->{subclass};
  my $expected  = $tc->{expected}{has_valid_syntax};
  my $filename  = $tc->{filename};
  my $docid     = $tc->{docid};
  my $library   = $tc->{library};
  my $parser    = $library->get_parser;
  my $fragment  = $parser->create_fragment($filename);
  my $document  = $library->get_document($docid);
  my $line      = SML::Line->new(content=>$content);
  my $block     = $subclass->new(library=>$library);

  $block->add_line($line);
  $document->add_part($block);

  foreach my $block (@{ $fragment->get_block_list })
    {
      $parser->_parse_block($block);
    }

  # Act
  my $result = $block->has_valid_syntax;

  # Assert
  is($result, $expected, "$tcname has_valid_syntax $result");
}

######################################################################

sub has_valid_semantics_ok {

  my $tc = shift;                       # test case

  # Arrange
  my $tcname    = $tc->{name};
  my $content   = $tc->{content};
  my $subclass  = $tc->{subclass};
  my $expected  = $tc->{expected}{has_valid_semantics};
  my $filename  = $tc->{filename};
  my $docid     = $tc->{docid};
  my $library   = $tc->{library};
  my $parser    = $library->get_parser;
  my $fragment  = $parser->create_fragment($filename);
  my $document  = $library->get_document($docid);
  my $line      = SML::Line->new(content=>$content);
  my $block     = $subclass->new(library=>$library);

  $block->add_line($line);
  $document->add_part($block);

  foreach my $block (@{ $fragment->get_block_list })
    {
      $parser->_parse_block($block);
    }

  # Act
  my $result = $block->has_valid_semantics;

  # Assert
  is($result, $expected, "$tcname has_valid_semantics $result");
}

######################################################################

sub valid_syntax_warning_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $content  = $tc->{content};
  my $subclass = $tc->{subclass};
  my $expected = $tc->{expected}{valid_syntax_warning};
  my $filename = $tc->{filename};
  my $docid    = $tc->{docid};
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filename);
  my $document = $library->get_document($docid);
  my $line     = SML::Line->new(content=>$content);
  my $block    = $subclass->new(library=>$library);

  $block->add_line($line);
  $document->add_part($block);

  foreach my $block (@{ $fragment->get_block_list })
    {
      $parser->_parse_block($block);
    }

  Test::Log4perl->start( ignore_priority => "info" );
  $t1logger->warn(qr/$expected/);

  # act
  my $result = $block->has_valid_syntax;

  # assert
  Test::Log4perl->end("$tcname warns $expected");
}

######################################################################

sub valid_semantics_warning_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $content  = $tc->{content};
  my $subclass = $tc->{subclass};
  my $expected = $tc->{expected}{valid_semantics_warning};
  my $filename = $tc->{filename};
  my $docid    = $tc->{docid};
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filename);
  my $document = $library->get_document($docid);
  my $line     = SML::Line->new(content=>$content);
  my $block    = $subclass->new(library=>$library);

  $block->add_line($line);
  $document->add_part($block);

  foreach my $block (@{ $fragment->get_block_list })
    {
      $parser->_parse_block($block);
    }

  Test::Log4perl->start( ignore_priority => "info" );
  $t1logger->warn(qr/$expected/);

  # act
  my $result = $block->has_valid_semantics;

  # assert
  Test::Log4perl->end("$tcname warns $expected");
}

######################################################################

sub has_parts_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $content  = $tc->{content};
  my $subclass = $tc->{subclass};
  my $expected = $tc->{expected}{has_parts};
  my $filename = $tc->{filename};
  my $docid    = $tc->{docid};
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filename);
  my $document = $library->get_document($docid);
  my $line     = SML::Line->new(content=>$content);
  my $block    = $subclass->new(library=>$library);

  $block->add_line($line);
  $document->add_part($block);

  foreach my $block (@{ $fragment->get_block_list })
    {
      $parser->_parse_block($block);
    }

  # act
  my $result = $block->has_parts;

  # assert
  is($result,$expected,"$tcname has_parts");
}

######################################################################

done_testing()
