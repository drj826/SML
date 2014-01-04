#!/usr/bin/perl

use lib "../../../publish";

use Log::Log4perl;
Log::Log4perl->init("log.conf");

use SML::Library;

my $filespec    = shift;
my $config_file = 'library.conf';
my $library     = SML::Library->new(config_filespec=>$config_file);
my $parser      = $library->get_parser;
my $fragment    = $parser->parse($filespec);

$fragment->validate;
