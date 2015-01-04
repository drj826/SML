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

my $library  = SML::Library->new(config_filename=>'library.conf');
my $parser   = $library->get_parser;
my $fragment = $parser->parse($filespec);
my $document = $library->get_document($id);

die "DOCUMENT NOT IN LIBRARY: \'$id\'" if not $document;

my $tt_config =
  {
   INCLUDE_PATH => "$template_dir",
   OUTPUT_PATH  => "$output_dir",
  };

my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

my $vars =
  {
   document => $document,
  };

foreach my $page ('titlepage','toc','glossary','index','references')
  {
    my $outfile = "$id.$page.html";
    $logger->info("formatting $outfile");
    $tt->process("$page.tt",$vars,$outfile) || die $tt->error(), "\n";
  }

foreach my $section (@{ $document->get_section_list })
  {
    my $num = $section->get_number;

    $num =~ s/\./-/g;

    my $outfile = "$id.$num.html";

    my $vars =
      {
       document => $document,
       section  => $section,
      };

    $logger->info("formatting $outfile");
    $tt->process('section_page.tt',$vars,$outfile)
      || die $tt->error(), "\n";
  }

######################################################################

1;
