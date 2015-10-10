#!/usr/bin/perl

# $Id: Ontology.t 264 2015-05-11 11:56:25Z drj826@gmail.com $

use lib "../lib";
use Test::More;
use Test::Exception;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.ontology');

# set sml.Library logger to WARN
my $logger_library = Log::Log4perl::get_logger('sml.Library');
$logger_library->level('WARN');

use Test::Log4perl;

# use Cwd;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $tcl     = $td->get_ontology_test_case_list;
my $library = $td->get_test_library_1;

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
   'get_library',

   # SML::Ontology public methods
   'add_rules_from_file',
   'get_allowed_property_value_list',
   'get_entity_allowed_property_list',
   'get_rule_for',
   'get_rule_with_id',
   'get_class_for_entity_name',
   'get_required_property_list',
   'has_entity_with_name',
   'allows_entity',
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
    add_rules_from_file_ok($tc)
      if defined $tc->{expected}{add_rules_from_file};

    get_allowed_property_value_list_ok($tc)
      if defined $tc->{expected}{get_allowed_property_value_list};

    get_entity_allowed_property_list_ok($tc)
      if defined $tc->{expected}{get_entity_allowed_property_list};

    get_rule_for_ok($tc)
      if defined $tc->{expected}{get_rule_for};

    get_rule_with_id_ok($tc)
      if defined $tc->{expected}{get_rule_with_id};

    get_class_for_entity_name_ok($tc)
      if defined $tc->{expected}{get_class_for_entity_name};

    get_required_property_list_ok($tc)
      if defined $tc->{expected}{get_required_property_list};

    has_entity_with_name_ok($tc)
      if defined $tc->{expected}{has_entity_with_name};

    allows_entity_ok($tc)
      if defined $tc->{expected}{allows_entity};

    allows_property_ok($tc)
      if defined $tc->{expected}{allows_property};

    allows_composition_ok($tc)
      if defined $tc->{expected}{allows_composition};

    allows_property_value_ok($tc)
      if defined $tc->{expected}{allows_property_value};

    property_is_universal_ok($tc)
      if defined $tc->{expected}{property_is_universal};

    property_is_imply_only_ok($tc)
      if defined $tc->{expected}{property_is_imply_only};

    property_allows_cardinality_ok($tc)
      if defined $tc->{expected}{property_allows_cardinality};
}

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    warn_add_rules_from_file_ok($tc)
      if defined $tc->{expected}{warning}{add_rules_from_file};
  }

######################################################################

sub add_rules_from_file_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $file_list = $tc->{file_list};
  my $library   = $tc->{library};
  my $ontology  = SML::Ontology->new(library=>$library);
  my $expected  = $tc->{expected}{add_rules_from_file};

  # act
  my $result = $ontology->add_rules_from_file($file_list);

  # assert
  is($result,$expected,"$tcname add_rules_from_file $result");
}

######################################################################

sub get_allowed_property_value_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{get_allowed_property_value_list};

  # act
  my $result = $ontology->get_allowed_property_value_list
    (
     $tc->{entity_name},
     $tc->{property_name},
    );

  # assert
  is_deeply($result,$expected,"$tcname get_allowed_property_value_list");
}

######################################################################

sub get_entity_allowed_property_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{get_entity_allowed_property_list};

  # act
  my $result = $ontology->get_entity_allowed_property_list
    (
     $tc->{entity_name},
    );

  # assert
  is_deeply($result,$expected,"$tcname get_entity_allowed_property_list");
}

######################################################################

sub get_rule_for_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{get_rule_for};

  # act
  my $result = $ontology->get_rule_for
    (
     $tc->{entity_name},
     $tc->{property_name},
     $tc->{name_or_value},
    );

  # assert
  isa_ok($result,$expected,"$tcname get_rule_for return value");
}

######################################################################

sub get_rule_with_id_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{get_rule_with_id};

  # act
  my $result = $ontology->get_rule_with_id
    (
     $tc->{rule_id},
    );

  # assert
  isa_ok($result,$expected,"$tcname get_rule_with_id return value");
}

######################################################################

sub get_class_for_entity_name_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{get_class_for_entity_name};

  # act
  my $result = $ontology->get_class_for_entity_name
    (
     $tc->{entity_name},
    );

  # assert
  is($result,$expected,"$tcname get_class_for_entity_name $result");
}

######################################################################

sub get_required_property_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{get_required_property_list};

  # act
  my $result = $ontology->get_required_property_list
    (
     $tc->{entity_name},
    );

  # assert
  is_deeply($result,$expected,"$tcname get_required_property_list");
}

######################################################################

sub has_entity_with_name_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{has_entity_with_name};

  # act
  my $result = $ontology->has_entity_with_name
    (
     $tc->{entity_name},
    );

  # assert
  is($result,$expected,"$tcname has_entity_with_name $result");
}

######################################################################

sub allows_entity_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{allows_entity};

  # act
  my $result = $ontology->allows_entity
    (
     $tc->{entity_name},
    );

  # assert
  is($result,$expected,"$tcname allows_entity $result");
}

######################################################################

sub allows_property_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{allows_property};

  # act
  my $result = $ontology->allows_property
    (
     $tc->{entity_name},
     $tc->{property_name},
    );

  # assert
  is($result,$expected,"$tcname allows_property $result");
}

######################################################################

sub allows_composition_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{allows_composition};

  # act
  my $result = $ontology->allows_composition
    (
     $tc->{division_a},
     $tc->{division_b},
    );

  # assert
  is($result,$expected,"$tcname allows_composition $result");
}

######################################################################

sub allows_property_value_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{allows_property_value};

  # act
  my $result = $ontology->allows_property_value
    (
     $tc->{entity_name},
     $tc->{property_name},
     $tc->{property_value},
    );

  # assert
  is($result,$expected,"$tcname allows_property_value $result");
}

######################################################################

sub property_is_universal_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{property_is_universal};

  # act
  my $result = $ontology->property_is_universal
    (
     $tc->{property_name},
    );

  # assert
  is($result,$expected,"$tcname property_is_universal $result");
}

######################################################################

sub property_is_imply_only_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{property_is_imply_only};

  # act
  my $result = $ontology->property_is_imply_only
    (
     $tc->{entity_name},
     $tc->{property_name},
    );

  # assert
  is($result,$expected,"$tcname property_is_imply_only $result");
}

######################################################################

sub property_allows_cardinality_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname    = $tc->{name};
  my $library   = $tc->{library};
  my $ontology  = $library->get_ontology;
  my $expected  = $tc->{expected}{property_allows_cardinality};

  # act
  my $result = $ontology->property_allows_cardinality
    (
     $tc->{entity_name},
     $tc->{property_name},
    );

  # assert
  is($result,$expected,"$tcname property_allows_cardinality $result");
}

######################################################################

sub warn_add_rules_from_file_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $file     = $tc->{rules_file};
  my $library  = $tc->{library};
  my $expected = $tc->{expected}{warning}{add_rules_from_file};
  my $ontology = SML::Ontology->new(library=>$library);

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
