#!/usr/bin/perl

# $Id: Title.t 10442 2012-10-09 16:25:52Z don.johnson $

use lib "..";
use Test::More;

use SML::Util;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Title;
  use_ok( 'SML::Title' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

# arrange
my $util       = SML::Util->instance;
my $empty_line = $util->empty_line;

# act
my $object = SML::Title->new
  (
   name       => 'title',
   first_line => $empty_line,
  );

# assert
ok( defined $object, 'new() returned something' );

#---------------------------------------------------------------------

done_testing()
