#!/usr/bin/perl

# $Id$

######################################################################

use FindBin qw($Bin);
use Getopt::Long;

my $filespec;
my $docid;
my $doclibdir   = "$Bin/../library";
my $templatedir = "$Bin/../templates";
my $configdir   = "$Bin/../conf";
my $outputdir   = "$Bin/../..";
my $inclibdir   = "$Bin/../lib";
my $style       = 'default';

GetOptions
  (
   "f|filespec=s"    => \$filespec,     # fragment file
   "d|docid=s"       => \$docid,        # document ID
   "l|doclibdir:s"   => \$doclibdir,    # document library directory
   "t|templatedir:s" => \$templatedir,  # template directory
   "c|configdir:s"   => \$configdir,    # configuration directory
   "o|outputdir:s"   => \$outputdir,    # output directory
   "s|style:s"       => \$style,        # formatting style
  );

######################################################################

use lib "lib";

use Log::Log4perl;
Log::Log4perl->init("$doclibdir/log.conf");
my $logger = Log::Log4perl::get_logger('sml.script');

use Template;

use SML::Library;

my $library  = SML::Library->new(config_filename=>'library.conf');
my $parser   = $library->get_parser;
my $fragment = $parser->parse($filespec);
my $document = $library->get_document($docid);

die "DOCUMENT NOT IN LIBRARY: \'$docid\'" if not $document;

my $template_dir = "$templatedir/html/$style";
my $output_dir   = "$outputdir/$docid";
my $formatter    = $library->get_formatter;

$formatter->publish_html_by_section
  (
   $document,
   $template_dir,
   $output_dir,
  );

######################################################################

1;
