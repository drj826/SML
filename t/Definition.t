#!/usr/bin/perl

# $Id: Definition.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 9;
use Test::Exception;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use Test::Log4perl;
my $t1logger = Test::Log4perl->get_logger('sml.definition');

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   definition_1 =>
   {
    content => 'glossary:: BPEL = Business Process Execution Language',
    term    => 'BPEL',
    alt     => '',
    value   => 'Business Process Execution Language',
   },

   bad_definition_1 =>
   {
    content => 'This is not a definition',
    error   => 'DEFINITION SYNTAX ERROR',
   },

  };

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

my $obj = SML::Definition->new;
isa_ok( $obj, 'SML::Definition' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_value',
   'get_term',
   'get_alt',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
  );

# can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

get_value_ok( 'definition_1' );
get_term_ok( 'definition_1' );
get_alt_ok( 'definition_1' );

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

error_ok( 'get_term',  'bad_definition_1' );
error_ok( 'get_alt',   'bad_definition_1' );
error_ok( 'get_value', 'bad_definition_1' );

######################################################################

sub get_term_ok {

  my $testid = shift;

  # arrange
  my $content    = $testdata->{$testid}{content};
  my $expected   = $testdata->{$testid}{term};
  my $line       = SML::Line->new(content=>$content);
  my $definition = SML::Definition->new();

  $definition->add_line($line);

  # act
  my $result = $definition->get_term;

  # assert
  is($result,$expected,"get_term $testid");
}

######################################################################

sub get_alt_ok {

  my $testid = shift;

  # arrange
  my $content    = $testdata->{$testid}{content};
  my $expected   = $testdata->{$testid}{alt};
  my $line       = SML::Line->new(content=>$content);
  my $definition = SML::Definition->new();

  $definition->add_line($line);

  # act
  my $result = $definition->get_alt;

  # assert
  is($result,$expected,"get_alt $testid");
}

######################################################################

sub get_value_ok {

  my $testid = shift;

  # arrange
  my $content    = $testdata->{$testid}{content};
  my $expected   = $testdata->{$testid}{value};
  my $line       = SML::Line->new(content=>$content);
  my $definition = SML::Definition->new();

  $definition->add_line($line);

  # act
  my $result = $definition->get_value;

  # assert
  is($result,$expected,"get_value $testid");
}

######################################################################

sub error_ok {

  my $method = shift;
  my $testid = shift;

  # arrange
  my $content    = $testdata->{$testid}{content};
  my $error      = $testdata->{$testid}{error};
  my $definition = SML::Definition->new();

  Test::Log4perl->start( ignore_priority => "warn" );
  $t1logger->error(qr/$error/);

  # act
  my $result = $definition->$method;

  # assert
  Test::Log4perl->end("ERROR: $error ($testid)");
}

######################################################################
