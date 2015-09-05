#!/usr/bin/perl

# $Id: Document.t 286 2015-07-11 12:59:53Z drj826@gmail.com $

# Document.pm (ci-000005) unit tests

use lib "../lib";
use Test::More;
use Test::Exception;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use Test::Log4perl;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $tcl     = $td->get_document_test_case_list;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Document;
  use_ok( 'SML::Document' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Document->new(id=>'doc',library=>$library);
isa_ok( $obj, 'SML::Document' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Document public attribute accessors
   'get_glossary',
   'get_acronym_list',
   'get_references',
   'get_author',
   'get_date',
   'get_revision',
   'is_valid',

   # SML::Document public methods
   'add_note',
   'add_index_term',
   'has_note',
   'has_index_term',
   'has_glossary_term',
   'has_acronym',
   'has_source',
   'get_acronym_definition',
   'get_note',
   'get_index_term',
   'replace_division_id',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    get_glossary_ok($tc)           if defined $tc->{expected}{get_glossary};
    add_note_ok($tc)               if defined $tc->{expected}{add_note};
    is_valid_ok($tc)               if defined $tc->{expected}{is_valid};
    render_ok($tc,'sml','default') if defined $tc->{expected}{render}{sml}{default};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    warn_is_valid_ok($tc) if defined $tc->{expected}{warning}{is_valid};
  }

######################################################################

sub get_glossary_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $filename = $tc->{testfile};
  my $docid    = $tc->{docid};
  my $library  = $tc->{library};
  my $expected = $tc->{expected}{get_glossary};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filename);
  my $document = $library->get_document($docid);

  # act
  my $result = $document->get_glossary;

  # assert
  isa_ok($result,$expected,"$tcname get_glossary");
}

######################################################################

sub add_note_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $note     = $tc->{note};
  my $document = $tc->{document};
  my $expected = $tc->{expected}{add_note};

  # act
  my $result = $document->add_note($note);

  # assert
  is($result,$expected,"$tcname add_note $result")
}

######################################################################

sub is_valid_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $filename = $tc->{testfile};
  my $docid    = $tc->{docid};
  my $expected = $tc->{expected}{is_valid};
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filename);
  my $document = $library->get_document($docid);

  # act
  my $result = $document->is_valid;

  # assert
  is($result,$expected,"$tcname is_valid $result");
}

######################################################################

sub render_ok {

  my $tc        = shift;                # test case
  my $rendition = shift;                # e.g. html
  my $style     = shift;                # e.g. default

  # arrange
  my $tcname   = $tc->{name};
  my $filename = $tc->{testfile};
  my $docid    = $tc->{docid};
  my $library  = $tc->{library};
  my $expected = $tc->{expected}{render}{$rendition}{$style};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filename);
  my $document = $library->get_document($docid);

  # act
  my $result  = $document->render($rendition,$style);
  my $summary = $result;
  $summary = substr($result,0,20) . '...' if length($result) > 20;

  # print "STRUCTURE:\n\n";
  # print $document->dump_part_structure, "\n\n";

  open my $fh, '>', 'library/testdata/expected/sml/default/result.txt';
  print $fh $result;
  close $fh;

  # assert
  is($result,$expected,"$tcname renders $rendition $style");
}

######################################################################

sub warn_is_valid_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $filename = $tc->{testfile};
  my $docid    = $tc->{docid};
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filename);
  my $document = $library->get_document($docid);
  my $expected = $tc->{expected}{warning}{is_valid};

  Test::Log4perl->start( ignore_priority => "info" );

  my $logger_hash = {};

  foreach my $warning (@{ $expected })
    {
      my $logger  = $warning->[0];
      my $message = $warning->[1];

      $logger_hash->{$logger} = Test::Log4perl->get_logger($logger);
      $logger_hash->{$logger}->warn(qr/$message/);
    }

  # act
  my $result = $document->is_valid;

  # assert
  Test::Log4perl->end("$tcname is_valid WARNS OK");
}

######################################################################

done_testing();
