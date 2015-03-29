#!/usr/bin/perl

# $Id$

use lib "..";
use Test::More tests => 6;

use SML;
use SML::File;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $tcl     = $td->get_fragment_test_case_list;
my $library = $td->get_test_object('SML::Library','library');

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Fragment;
  use_ok( 'SML::Fragment' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

# arrange
my $filespec = 'library/testdata/td-000001.txt';
my $file     = SML::File->new(filespec=>$filespec);

# act
my $obj = SML::Fragment->new(file=>$file,library=>$library);

# assert
isa_ok( $obj, 'SML::Fragment' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Fragment public attribute accessors
   'get_file',
   'get_line_list',

   # SML::Fragment public methods
   'extract_division_lines',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    extract_division_lines_ok($tc) if defined $tc->{expected}{extract_division_lines};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub extract_division_lines_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $filespec = $tc->{filespec};
  my $divid    = $tc->{divid};
  my $library  = $tc->{library};
  my $file     = SML::File->new(filespec=>$filespec);
  my $expected = $tc->{expected}{extract_division_lines};
  my $fragment = SML::Fragment->new(file=>$file,library=>$library);

  # act
  my $lines  = $fragment->extract_division_lines($divid);
  my $result = scalar @{ $lines };

  # assert
  is($result,$expected,"$tcname extract_division_lines $result");
}

######################################################################

1;
