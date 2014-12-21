#!/usr/bin/perl

# $Id: SML.t 15151 2013-07-08 21:01:16Z don.johnson $

# tc-000004 -- unit test case for SML.pm (ci-000002)

use lib "..";
use Test::More tests => 10;
use Test::Perl::Critic (-severity => 4);
use Test::Exception;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

my $result;
my $expected;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML;
  use_ok( 'SML' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $config_file = 'library/library.conf';
my $library     = SML::Library->new(config_filespec=>$config_file);
my $obj         = SML->instance;

isa_ok( $obj, 'SML' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'allows_insert',
   'allows_generate',
   'get_ontology_config_filespec',
   'get_syntax',
   'get_ontology',
   'get_util',
   'get_division_hash',
   'get_insert_name_hash',
   'get_generated_content_type_hash',
   'get_font_size_list',
   'get_font_weight_list',
   'get_font_shape_list',
   'get_font_family_list',
   'get_background_color_list',
   'get_division_name_list',
   'get_region_name_list',
   'get_environment_name_list',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
   '_build_syntax',
   '_build_util',
   '_build_division_names',
   '_build_region_names',
   '_build_environment_names',
   '_build_ontology',
   '_build_divisions',
  );

can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

values_ok(
  'get_environment_name_list',
  'ASSERTION,ATTACHMENT,AUDIO,BARETABLE,EPIGRAPH,FIGURE,FOOTER,HEADER,KEYPOINTS,LISTING,PREFORMATTED,REVISIONS,SIDEBAR,SOURCE,TABLE,VIDEO',
  'environment names correct'
);

#---------------------------------------------------------------------

# arrange
$expected = '1';

# act
$result   = $obj->allows_insert('NARRATIVE');

# assert
is($result,$expected,"allows insert name 'NARRATIVE'");

#---------------------------------------------------------------------

# arrange
$expected = '0';

# act
$result   = $obj->allows_insert('pizza');

# assert
is($result,$expected,"doesn't allow insert name 'pizza'");

#---------------------------------------------------------------------

# arrange
$expected = '1';

# act
$result   = $obj->allows_generate('problem-domain-listing');

# assert
is($result,$expected,"allows generate name 'problem-domain-listing'");

#---------------------------------------------------------------------

# arrange
$expected = '0';

# act
$result   = $obj->allows_generate('pizza');

# assert
is($result,$expected,"doesn't allow generate name 'pizza'");

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Test Methods
#---------------------------------------------------------------------

sub type_ok {

  # Check the return type of an attribute accessor.

  my $attribute = shift;
  my $expected  = shift;
  my $assertion = shift;

  # arrange

  # act
  my $result = ref $obj->$attribute;

  # assert
  is($result,$expected,$assertion);

}

######################################################################

sub values_ok {

  # Check the list of values returned by an attribute accessor.

  my $attribute = shift;
  my $expected  = shift;
  my $assertion = shift;

  # arrange

  # act
  my $result = join(',', sort @{ $obj->$attribute });

  # assert
  is($result,$expected,$assertion);
}

######################################################################
