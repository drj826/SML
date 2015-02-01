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
my $outputdir   = "$Bin/..";
my $inclibdir   = "$Bin/../lib";

GetOptions
  (
   "f|filespec=s"    => \$filespec,
   "d|docid=s"       => \$docid,
   "l|doclibdir:s"   => \$doclibdir,
   "t|templatedir:s" => \$templatedir,
   "c|configdir:s"   => \$configdir,
   "o|outputdir:s"   => \$outputdir,
   "i|inclibdir:s"   => \$inclibdir,
  );

######################################################################

use lib "lib";

use Log::Log4perl;
Log::Log4perl->init("$doclibdir/log.conf");
my $logger = Log::Log4perl::get_logger('sml.script');

use Template;

use SML::Library;

my $library   = SML::Library->new(config_filename=>'library.conf');
my $parser    = $library->get_parser;
my $fragment  = $parser->parse($filespec);
my $document  = $library->get_document($docid);
my $formatter = $library->get_formatter;

die "DOCUMENT NOT IN LIBRARY: \'$docid\'" if not $document;

$formatter->publish_html_by_section
  (
   $document,
   $templatedir,
   $outputdir,
  );

######################################################################

1;
