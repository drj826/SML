#!/usr/bin/perl

use lib "../lib";

use Log::Log4perl;
Log::Log4perl->init("../library/log.conf");
my $logger = Log::Log4perl::get_logger('sml.script');

use SML::Library;

my $id       = shift;                   # document ID
my $filespec = shift;                   # document file

my $library  = SML::Library->new(config_filename=>'library.conf');
my $parser   = $library->get_parser;
my $fragment = $parser->parse($filespec);
my $document = $library->get_document($id);
my $title    = $document->get_property_value('title');

$logger->info("$id: $title");
