#!/usr/bin/perl

# $Id$

# Document.pm (ci-000005) unit tests

use lib "..";
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

my $td  = SML::TestData->new;
my $tcl = $td->get_document_test_case_list;

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

my $obj = SML::Document->new(id=>'doc');
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
   'get_source_hash',
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
    add_note_ok($tc)      if defined $tc->{expected}{add_note};
    is_valid_ok($tc)      if defined $tc->{expected}{is_valid};
    warn_is_valid_ok($tc) if defined $tc->{expected}{warning}{is_valid};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

# warning_ok( 'invalid_non_unique_id' );

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
  my $library  = SML::Library->new(config_filename=>'library.conf');
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment($filename);
  my $document = $library->get_document($docid);

  # act
  my $result = $document->is_valid;

  # assert
  is($result,$expected,"$tcname is_valid $result");
}

######################################################################

sub warn_is_valid_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $filename = $tc->{testfile};
  my $docid    = $tc->{docid};
  my $library  = SML::Library->new(config_filename=>'library.conf');
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
