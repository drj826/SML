#!/usr/bin/perl

use lib "../lib";

use Log::Log4perl;
Log::Log4perl->init("../library/log.conf");
my $logger = Log::Log4perl::get_logger('sml.script');

use Template;

use SML::Library;

my $id       = shift;                   # document ID
my $filespec = shift;                   # document file

my $template_dir = '/home/drj826/semlang/templates/html/default';
my $output_dir   = "/home/drj826/$id";

my $library   = SML::Library->new(config_filename => 'library.conf');
my $parser    = $library->get_parser;
my $fragment  = $parser->parse($filespec);
my $document  = $library->get_document($id);
my $formatter = $library->get_formatter;

die "DOCUMENT NOT IN LIBRARY: \'$id\'" if not $document;

$formatter->publish_html_by_section
  (
   $document,
   $template_dir,
   $output_dir,
  );

######################################################################

1;
