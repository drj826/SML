#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 10;

use SML;
use SML::Definition;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use SML::TestData;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $td  = SML::TestData->new();
my $tcl = $td->get_acronym_list_test_case_list;

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
   'add_acronym',
   'has_acronym',
   'get_acronym',
   'get_acronym_list',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{$tcl})
  {
    if ( defined $tc->{expected}{add_ok} )
      {
	add_acronym_ok($tc);
      }

    if ( defined $tc->{expected}{has_ok} )
      {
	has_acronym_ok($tc);
      }

    if ( defined $tc->{expected}{get_ok} )
      {
	get_acronym_ok($tc);
      }
  }

get_acronym_list_ok();

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub add_acronym_ok {

  my $tc = shift;                       # test case

  # arrange
  my $name         = $tc->{name};
  my $content      = $tc->{content};
  my $expected     = $tc->{expected}{add_ok};
  my $line         = SML::Line->new(content=>$content);
  my $acronym_list = SML::AcronymList->new;
  my $definition   = SML::Definition->new;

  $definition->add_line($line);

  # act
  my $result = $acronym_list->add_acronym($definition);

  # assert
  is($result, $expected, "add_acronym $name");
}

######################################################################

sub has_acronym_ok {

  my $tc = shift;                       # test case

  # arrange
  my $name         = $tc->{name};
  my $content      = $tc->{content};
  my $acronym      = $tc->{acronym};
  my $alt          = $tc->{alt};
  my $line         = SML::Line->new(content=>$content);
  my $acronym_list = SML::AcronymList->new;
  my $definition   = SML::Definition->new;
  my $expected     = $tc->{expected}{has_ok};

  $definition->add_line($line);

  my $count        = $acronym_list->add_acronym($definition);

  # act
  my $result = $acronym_list->has_acronym($acronym,$alt);

  # assert
  is($result, $expected, "has_acronym $name");
}

######################################################################

sub get_acronym_ok {

  my $tc = shift;                       # test case

  # arrange
  my $name         = $tc->{name};
  my $content      = $tc->{content};
  my $acronym      = $tc->{acronym};
  my $alt          = $tc->{alt};
  my $line         = SML::Line->new(content=>$content);
  my $acronym_list = SML::AcronymList->new;
  my $definition   = SML::Definition->new;
  my $expected     = 'SML::Definition';

  $definition->add_line($line);

  my $count        = $acronym_list->add_acronym($definition);

  # act
  my $result = ref $acronym_list->get_acronym($acronym,$alt);

  # assert
  is($result, $expected, "get_acronym $name");
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
