#!/usr/bin/perl

use lib "../lib";
use Test::More;

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

my $td      = SML::TestData->new();
my $tcl     = $td->get_string_test_case_list;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::String;
  use_ok( 'SML::String' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::String->new(content=>'my test content',library=>$library);

isa_ok($obj,'SML::String');

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Part public attribute methods
   'get_name',
   'get_content',
   'get_part_list',

   # SML::Part public methods
   'init',
   'has_parts',
   'add_part',
   'get_containing_document',

   # SML::String public attribute methods
   'get_containing_block',
   'set_containing_block',
   'clear_containing_block',

   # SML::String public methods
   'add_part',
   'get_location',
   'get_containing_document',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{$tcl})
  {
    get_name_ok($tc)                 if exists $tc->{expected}{get_name};
    get_content_ok($tc)              if exists $tc->{expected}{get_content};
    has_parts_ok($tc)                if exists $tc->{expected}{has_parts};
    render_ok($tc,'sml','default')   if exists $tc->{expected}{render}{sml}{default};
    render_ok($tc,'html','default')  if exists $tc->{expected}{render}{html}{default};
    render_ok($tc,'latex','default') if exists $tc->{expected}{render}{latex}{default};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_name_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $text     = $tc->{text};
  my $expected = $tc->{expected}{get_name};
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;
  my $string   = $parser->create_string($text);

  # act
  my $result = $string->get_name;

  # assert
  is($result,$expected,"$tcname get_name $result")
}

######################################################################

sub get_content_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $text     = $tc->{text};
  my $expected = $tc->{expected}{get_content};
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;
  my $string   = $parser->create_string($text);

  # act
  my $result = $string->get_content;

  # assert
  is($result,$expected,"$tcname get_content $result")
}

######################################################################

sub has_parts_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{has_parts};
  my $text     = $tc->{text};
  my $library  = $tc->{library};
  my $parser   = $library->get_parser;
  my $string   = $parser->create_string($text);

  # act
  my $result = $string->has_parts;

  # assert
  is($result,$expected,"$tcname has_parts $result");
}

######################################################################

sub render_ok {

  my $tc        = shift;                # test case
  my $rendition = shift;                # e.g. html
  my $style     = shift;                # e.g. default

  # arrange
  my $tcname   = $tc->{name};
  my $text     = $tc->{text};
  my $library  = $tc->{library};
  my $expected = $tc->{expected}{render}{$rendition}{$style};
  my $parser   = $library->get_parser;
  my $string   = $parser->create_string($text);

  # act
  my $result  = $string->render($rendition,$style);
  my $summary = $result;
  $summary = substr($result,0,20) . '...' if length($result) > 20;

  # print "STRUCTURE:\n\n";
  # print $string->dump_part_structure, "\n\n";

  # assert
  is($result,$expected,"$tcname render $rendition $style \'$summary\'");
}

######################################################################

done_testing()
