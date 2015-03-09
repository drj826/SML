#!/usr/bin/perl

# $Id$

# Document.pm (ci-000005) unit tests

use lib "..";
use Test::More tests => 5;
use Test::Exception;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use Test::Log4perl;
my $t1logger = Test::Log4perl->get_logger('sml.Document');

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
   'validate',
   'validate_id_uniqueness',
   'replace_division_id',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    add_note_ok($tc) if defined $tc->{expected}{add_note};
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

sub warning_ok {

  my $testid = shift;

  my $testfile  = $testdata->{$testid}{testfile};
  my $docid     = $testdata->{$testid}{docid};
  my $warning_1 = $testdata->{$testid}{warning_1};
  my $warning_2 = $testdata->{$testid}{warning_2};

  my $config    = 'library.conf';
  my $library   = SML::Library->new(config_filename=>$config);
  my $parser    = $library->get_parser;

  my $t1logger  = Test::Log4perl->get_logger('sml.Document');

  Test::Log4perl->start( ignore_priority => "info" );
  $t1logger->warn(qr/$warning_1/);
  $t1logger->warn(qr/$warning_2/);

  my $fragment = $parser->create_fragment($testfile);
  my $document = $library->get_document($docid);

  # act
  $document->validate;

  # assert
  Test::Log4perl->end("WARNING: $warning_1 ($testid)");

}

######################################################################
