#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use SML;
use SML::File;
use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

my $config_file = 'library/library.conf';
my $library     = SML::Library->new(config_filespec=>$config_file);
my $parser      = $library->get_parser;

$parser->parse('library/frd-sml.txt');

print $library->summarize_content;
