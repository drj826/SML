#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use lib "../lib";

######################################################################

use SML::Library;

my $id        = 'sml';
my $rendition = 'html';
my $style     = 'default';

my $library   = SML::Library->new(config_file=>'library.conf');
my $result    = $library->publish($id,$rendition,$style);

######################################################################

1;
