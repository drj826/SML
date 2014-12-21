#!/usr/bin/perl

# $Id: AcronymList.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 12;
use Test::Perl::Critic (-severity => 3);

use SML;
use SML::Definition;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   acronym_1 =>
   {
    content     => 'acronym:: TLA = Three Letter Acronym',
    acronym     => 'TLA',
    description => 'Three Letter Acronym',
    alt         => '',
    add_ok      => 1,
   },

   acronym_2 =>
   {
    content     => 'acronym:: FRD {tsa} = (TSA) Functional Requirements Document',
    acronym     => 'FRD',
    description => '(TSA) Functional Requirements Document',
    alt         => 'tsa',
    add_ok      => 1,
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::AcronymList;
  use_ok( 'SML::AcronymList' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::AcronymList->new;
isa_ok( $obj, 'SML::AcronymList' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_acronym_hash',
   'add_acronym',
   'has_acronym',
   'get_acronym',
   'get_acronym_list',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

get_acronym_hash_ok();

add_acronym_ok( 'acronym_1' );
add_acronym_ok( 'acronym_2' );

has_acronym_ok( 'acronym_1' );
has_acronym_ok( 'acronym_2' );

get_acronym_ok( 'acronym_1' );
get_acronym_ok( 'acronym_2' );

get_acronym_list_ok();

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_acronym_hash_ok {

  # arrange
  my $expected = 'HASH';
  my $al       = SML::AcronymList->new;

  # act
  my $result = ref $al->get_acronym_hash;

  # assert
  is($result, $expected, "get_acronym_hash");
}

######################################################################

sub add_acronym_ok {

  my $testid = shift;

  # arrange
  my $content      = $testdata->{$testid}{content};
  my $expected     = $testdata->{$testid}{add_ok};
  my $line         = SML::Line->new(content=>$content);
  my $acronym_list = SML::AcronymList->new;
  my $definition   = SML::Definition->new;

  $definition->add_line($line);

  # act
  my $result = $acronym_list->add_acronym($definition);

  # assert
  is($result, $expected, "add_acronym $testid");
}

######################################################################

sub has_acronym_ok {

  my $testid = shift;

  # arrange
  my $content      = $testdata->{$testid}{'content'};
  my $acronym      = $testdata->{$testid}{'acronym'};
  my $alt          = $testdata->{$testid}{'alt'};
  my $line         = SML::Line->new(content=>$content);
  my $acronym_list = SML::AcronymList->new;
  my $definition   = SML::Definition->new;
  my $expected     = 1;

  $definition->add_line($line);

  my $count        = $acronym_list->add_acronym($definition);

  # act
  my $result = $acronym_list->has_acronym($acronym,$alt);

  # assert
  is($result, $expected, "has_acronym $testid");
}

######################################################################

sub get_acronym_ok {

  my $testid = shift;

  # arrange
  my $content      = $testdata->{$testid}{'content'};
  my $acronym      = $testdata->{$testid}{'acronym'};
  my $alt          = $testdata->{$testid}{'alt'};
  my $line         = SML::Line->new(content=>$content);
  my $acronym_list = SML::AcronymList->new;
  my $definition   = SML::Definition->new;
  my $expected     = 'SML::Definition';

  $definition->add_line($line);

  my $count        = $acronym_list->add_acronym($definition);

  # act
  my $result = ref $acronym_list->get_acronym($acronym,$alt);

  # assert
  is($result, $expected, "get_acronym $testid");
}

######################################################################

sub get_acronym_list_ok {

  # arrange
  my $expected = 'ARRAY';
  my $al       = SML::AcronymList->new;

  # act
  my $result = ref $al->get_acronym_list;

  # assert
  is($result, $expected, "get_acronym_list")
}

######################################################################
