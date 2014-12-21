#!/usr/bin/perl

# $Id: File.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 12;
use Test::Perl::Critic (-severity => 4);

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

# use Test::Log4perl;
# my $t1logger = Test::Log4perl->get_logger('sml.file');

my $sml     = SML->instance;
my $util    = $sml->get_util;
my $options = $util->get_options;
my $doc;
my $file;
my $expected;
my $result;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   valid_file =>
   {
    filespec    => 'library/testdata/td-000001.txt',
    filename    => 'td-000001.txt',
    directories => 'library/testdata/',
    sha_digest  => '3fc9a6743c4b2eb4d0cd27fd5ad90a75e94897da',
    md5_digest  => '0aeb40f8e68ce0faf0d780e732213408',
    valid       => 1,
   },

   bogus_file =>
   {
    filespec    => 'library/testdata/bogus.txt',
    filename    => 'bogus.txt',
    directories => 'library/testdata/',
    valid       => 0,
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::File;
  use_ok( 'SML::File' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $filespec = $testdata->{valid_file}{filespec};
my $obj = SML::File->new(filespec=>$filespec);
isa_ok( $obj, 'SML::File' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'is_valid',

   'get_filespec',
   'get_filename',
   'get_directories',
   'get_path',
   'get_filespec',
   'get_filename',
   'get_directories',
   'get_path',
   'get_text',
   'get_lines',
   'get_sha_digest',
   'get_md5_digest',
   'get_svninfo',
   'get_fragment',

   'has_been_parsed',

   'validate',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
   'BUILD',
   '_build_filename',
   '_build_directories',
   '_build_path',
   '_build_sha_digest',
   '_build_md5_digest',
  );

can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

get_text_ok(         'valid_file' );
filename_ok(      'valid_file' );
directories_ok(   'valid_file' );
sha_digest_ok(    'valid_file' );
md5_digest_ok(    'valid_file' );
validates_ok(     'valid_file' );
not_validates_ok( 'bogus_file' );

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_text_ok {

  my $testid = shift;

  # arrange
  my $filespec = $testdata->{$testid}{filespec};
  my $file     = SML::File->new(filespec=>$filespec);
  my $expected = <<'END_OF_TEXT';
>>>DOCUMENT

######################################################################

title:: Simple Document With One Paragraph

id:: td-000001

######################################################################

The purpose of this simple document is to test applications designed
to process SML formatted files.  This is a ~~very~~ simple document
with only one paragraph.

<<<DOCUMENT
END_OF_TEXT

  # act
  my $result = $file->get_text;

  # assert
  is( $result, $expected, "get_file $testid file correctly" );
}

######################################################################

sub filename_ok {

  my $testid = shift;

  # arrange
  my $filespec = $testdata->{$testid}{filespec};
  my $expected = $testdata->{$testid}{filename};
  my $file     = SML::File->new(filespec=>$filespec);

  # act
  my $result = $file->get_filename;

  # assert
  is( $result, $expected, "returns expected $testid filename" );
}

######################################################################

sub directories_ok {

  my $testid = shift;

  # arrange
  my $filespec = $testdata->{$testid}{filespec};
  my $expected = $testdata->{$testid}{directories};
  my $file     = SML::File->new(filespec=>$filespec);

  # act
  my $result = $file->get_directories;

  # assert
  is( $result, $expected, "returns expected $testid directories" );
}

######################################################################

sub sha_digest_ok {

  my $testid = shift;

  # arrange
  my $filespec = $testdata->{$testid}{filespec};
  my $expected = $testdata->{$testid}{sha_digest};
  my $file     = SML::File->new(filespec=>$filespec);

  # act
  my $result = $file->get_sha_digest;

  # assert
  is( $result, $expected, "returns expected $testid SHA digest" );
}

######################################################################

sub md5_digest_ok {

  my $testid = shift;

  # arrange
  my $filespec = $testdata->{$testid}{filespec};
  my $expected = $testdata->{$testid}{md5_digest};
  my $file     = SML::File->new(filespec=>$filespec);

  # act
  my $result = $file->get_md5_digest;

  # assert
  is( $result, $expected, "returns expected $testid MD5 digest" );
}

######################################################################

sub validates_ok {

  my $testid = shift;

  # arrange
  my $filespec = $testdata->{$testid}{filespec};
  my $expected = $testdata->{$testid}{valid};
  my $file     = SML::File->new(filespec=>$filespec);

  # act
  my $result = $file->validate;

  # assert
  is( $result, $expected, "validates valid $testid file" );
}

######################################################################

sub not_validates_ok {

  my $testid = shift;

  # arrange
  my $filespec = $testdata->{$testid}{filespec};
  my $expected = $testdata->{$testid}{valid};
  my $file     = SML::File->new(filespec=>$filespec);

  # act
  my $result = $file->validate;

  # assert
  is( $result, $expected, "doesn't validate invalid $testid file" );
}

######################################################################

# sub warning_ok {

#   my $testid = shift;

#   # arrange
#   my $filespec = $testdata->{$testid}{filespec};
#   my $warning  = $testdata->{$testid}{warning};

#   Test::Log4perl->start( ignore_priority => "info" );
#   $t1logger->warn(qr/$warning/);

#   # act
#   my $file = SML::File->new(filespec=>$filespec);

#   # assert
#   Test::Log4perl->end("WARNING: $warning ($testid)");
# }

######################################################################
