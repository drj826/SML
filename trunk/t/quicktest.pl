#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

######################################################################

my $file = 'td-000005.txt';

use SML::Library;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.application');

my $library = SML::Library->new(config_filename=>'library.conf');
my $parser  = $library->get_parser;

my $tc =
  {
   name     => 'cross_reference_1',
   content  => '[ref:introduction]',
   filename => 'td-000020.txt',
   docid    => 'td-000020',
   expected =>
   {
    html =>
    {
     default => "<a href=\"td-000020-1.html#SECTION.1\">Section 1</a>\n\n",
    },
    latex =>
    {
     default => "Section~\\vref{introduction}\n\n",
    },
    xml =>
    {
     default => "<a href=\"td-000020-1.xml#SECTION.1\">Section 1</a>\n\n",
    },
    error =>
    {
     no_doc => 'NOT IN DOCUMENT CONTEXT',
    },
   },
  };

my $rendition = 'latex';
my $style     = 'default';
my $content   = $tc->{content};
my $expected  = $tc->{expected}{$rendition}{$style};
my $filename  = $tc->{filename};
my $docid     = $tc->{docid};
my $fragment  = $parser->create_fragment($filename);
my $document  = $library->get_document($docid);
my $line      = SML::Line->new(content=>$content);
my $block     = SML::Block->new;

$block->add_line($line);
$document->add_part($block);

foreach my $block (@{ $fragment->get_block_list })
  {
    $parser->_parse_block($block);
  }

print "INPUT:\n";
print $tc->{content}, "\n\n";

print "OUTPUT:\n";
print $block->render($rendition,$style), "\n\n";

print "PART_STRUCTURE:\n";
print $block->dump_part_structure, "\n";

######################################################################

1;
