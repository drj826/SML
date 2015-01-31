#!/usr/bin/perl

# $Id$

use lib "../lib";

use Log::Log4perl;
Log::Log4perl->init("../library/log.conf");

use SML::Library;

my $filespec = shift;

my $library  = SML::Library->new(config_filename=>'library.conf');
my $parser   = $library->get_parser;
my $fragment = $parser->parse($filespec);

$fragment->validate;
