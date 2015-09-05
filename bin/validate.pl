#!/usr/bin/perl

# $Id: validate.pl 75 2015-01-31 17:38:53Z drj826@gmail.com $

use lib "../lib";

use Log::Log4perl;
Log::Log4perl->init("../library/log.conf");

use SML::Library;

my $filespec = shift;

my $library  = SML::Library->new(config_filename=>'library.conf');
my $parser   = $library->get_parser;
my $fragment = $parser->parse($filespec);

$fragment->validate;
