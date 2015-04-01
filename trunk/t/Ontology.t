#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More;
use Test::Exception;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.ontology');

use Test::Log4perl;

# use Cwd;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $tcl     = $td->get_ontology_test_case_list;
my $library = $td->get_test_object('SML::Library','library');

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Ontology;
  use_ok( 'SML::Ontology' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Ontology->new(library=>$library);

isa_ok($obj,'SML::Ontology');

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Ontology public attribute accessors
   # <none>

   # SML::Ontology public methods
   'add_rules_from_file',
   'get_allowed_property_value_list',
   'get_entity_allowed_property_list',
   'get_allowed_environment_list',
   'get_entity_type',
   'get_rule_for',
   'get_rule_with_id',
   'get_divisions_by_name_hash',
   'get_class_for_entity_name',
   'get_required_property_list',
   'contains_entity_named',
   'allows_entity',
   'allows_region',
   'allows_environment',
   'allows_property',
   'allows_composition',
   'allows_property_value',
   'property_is_universal',
   'property_is_imply_only',
   'property_allows_cardinality',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    add_rules_from_file_ok($tc) if defined $tc->{expected}{add_rules_from_file};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    warn_add_rules_from_file_ok($tc) if defined $tc->{expected}{warning}{add_rules_from_file};
  }

######################################################################

sub add_rules_from_file_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $file_list = $tc->{file_list};
  my $library   = SML::Library->new(config_filename=>'library.conf');
  my $ontology  = SML::Ontology->new(library=>$library);
  my $expected  = $tc->{expected}{add_rules_from_file};

  # act
  my $result = $ontology->add_rules_from_file($file_list);

  # assert
  is($result,$expected,"$tcname add_rules_from_file $result");
}

######################################################################

sub warn_add_rules_from_file_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $file     = $tc->{rules_file};
  my $library  = SML::Library->new(config_filename=>'library.conf');
  my $ontology = SML::Ontology->new(library=>$library);
  my $expected = $tc->{expected}{warning}{add_rules_from_file};

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
  my $result = $ontology->add_rules_from_file($file);

  # assert
  Test::Log4perl->end("$tcname add_rules_from_file WARNS OK");
}

######################################################################

done_testing();
