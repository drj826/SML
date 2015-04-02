#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 10;
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
my $tcl     = $td->get_definition_test_case_list;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Definition;
  use_ok( 'SML::Definition' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $args = {};

$args->{name}    = 'glossary';
$args->{library} = $library;

my $obj = SML::Definition->new(%{$args});
isa_ok($obj,'SML::Definition' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Definition public attribute accessor methods
   # <none>

   # SML::Definition public methods
   'get_term',
   'get_alt',
   'get_value',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    get_term_ok($tc)  if defined $tc->{expected}{get_term};
    get_alt_ok($tc)   if defined $tc->{expected}{get_alt};
    get_value_ok($tc) if defined $tc->{expected}{get_value};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    error_get_term_ok($tc) if defined $tc->{expected}{error}{get_term};
  }

######################################################################

sub get_term_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname     = $tc->{name};
  my $line       = $tc->{line};
  my $args       = $tc->{args};
  my $expected   = $tc->{expected}{get_term};
  my $definition = SML::Definition->new(%{$args});

  $definition->add_line($line);

  # act
  my $result = $definition->get_term;

  # assert
  is($result,$expected,"$tcname get_term $result");
}

######################################################################

sub get_alt_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname     = $tc->{name};
  my $line       = $tc->{line};
  my $args       = $tc->{args};
  my $expected   = $tc->{expected}{get_alt};
  my $definition = SML::Definition->new(%{$args});

  $definition->add_line($line);

  # act
  my $result = $definition->get_alt;

  # assert
  is($result,$expected,"$tcname get_alt $result");
}

######################################################################

sub get_value_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname     = $tc->{name};
  my $line       = $tc->{line};
  my $args       = $tc->{args};
  my $expected   = $tc->{expected}{get_value};
  my $definition = SML::Definition->new(%{$args});

  $definition->add_line($line);

  # act
  my $result = $definition->get_value;

  # assert
  is($result,$expected,"$tcname get_value $result");
}

######################################################################

sub error_get_term_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname     = $tc->{name};
  my $line       = $tc->{line};
  my $args       = $tc->{args};
  my $expected   = $tc->{expected}{error}{get_term};
  my $definition = SML::Definition->new(%{$args});

  $definition->add_line($line);

  Test::Log4perl->start( ignore_priority => "warn" );
  my $t1logger = Test::Log4perl->get_logger('sml.Definition');
  $t1logger->error(qr/$expected/);

  # act
  my $result = $definition->get_term;

  # assert
  Test::Log4perl->end("$tcname get_term $result");
}

######################################################################

1;
