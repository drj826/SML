#!/usr/bin/perl

use lib "../lib";
use Test::More;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl->get_logger('sml.application');

# set sml.Library logger to WARN
my $logger_library = Log::Log4perl::get_logger('sml.Library');
$logger_library->level('WARN');

# set sml.Parser logger to WARN
my $logger_parser = Log::Log4perl::get_logger('sml.Parser');
$logger_parser->level('WARN');

# set sml.Division logger to ERROR
my $logger_division = Log::Log4perl::get_logger('sml.Division');
$logger_division->level('ERROR');

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new();
my $tcl     = $td->get_parser_test_case_list;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Parser;
  use_ok('SML::Parser');
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = $library->get_parser;
isa_ok( $obj, 'SML::Parser' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # attribute accessors
   'get_library',

   # public methods
   'parse',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{$tcl})
  {
    parse_ok($tc) if defined $tc->{expected}{parse};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub parse_ok {

  my $tc = shift;

  # arrange
  my $tcname   = $tc->{name};
  my $divid    = $tc->{divid};
  my $library  = $tc->{library};
  my $expected = $tc->{expected}{parse};
  my $parser   = $library->get_parser;

  # act
  my $division = $parser->parse($divid);
  my $result   = ref $division;

  # my $structure = $division->dump_part_structure;
  # $logger->info("STRUCTURE:\n$structure");

  # assert
  is($result,$expected,"$tcname parse $result");
}

######################################################################

done_testing();
