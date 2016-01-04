#!/usr/bin/perl

use lib "../lib";
use Test::More tests => 5;
# use Test::Exception;

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
my $tcl     = $td->get_definition_list_item_test_case_list;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::DefinitionListItem;
  use_ok( 'SML::DefinitionListItem' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::DefinitionListItem->new(library=>$library);
isa_ok($obj,'SML::DefinitionListItem' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::DefinitionListItem public attribute accessors
   'get_term',
   'get_definition',

   # SML::DefinitionListItem public methods
   # <none>
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    get_term_ok($tc)       if defined $tc->{expected}{get_term};
    get_definition_ok($tc) if defined $tc->{expected}{get_definition};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_term_ok {

  my $tc = shift;                       # test case

  # Arrange
  my $tcname   = $tc->{name};
  my $line     = $tc->{line};
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;
  my $expected = $tc->{expected}{get_term};

  my $item = SML::DefinitionListItem->new
    (
     library => $library,
    );

  $item->add_line($line);

  $parser->_begin_block($item);
  $parser->_end_block($item);

  # Act
  my $result = $item->get_term;

  # Assert
  is($result,$expected,"$tcname get_term $result");
}

######################################################################

sub get_definition_ok {

  my $tc = shift;                       # test case

  # Arrange
  my $tcname   = $tc->{name};
  my $line     = $tc->{line};
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;
  my $expected = $tc->{expected}{get_definition};

  my $item = SML::DefinitionListItem->new
    (
     library => $library,
    );

  $item->add_line($line);

  $parser->_begin_block($item);
  $parser->_end_block($item);

  # Act
  my $result = $item->get_definition;

  # Assert
  is($result,$expected,"$tcname get_term $result");
}

######################################################################

1;
