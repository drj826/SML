#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

######################################################################

use SML::Library;
use SML::Line;
use SML::Paragraph;

my $tc =
  {
   name     => 'cross_reference_1',
   content  => '[ref:introduction]',
   subclass => 'SML::Paragraph',
   filename => 'td-000020.txt',
   docid    => 'td-000020',
   expected =>
   {
    render =>
    {
     html =>
     {
      default => "<p><a href=\"td-000020-1.html#SECTION.1\">Section 1</a></p>\n\n",
     },
     latex =>
     {
      default => "Section~\\vref{introduction}\n\n",
     },
     xml =>
     {
      default => "<a href=\"td-000020-1.xml#SECTION.1\">Section 1</a>\n\n",
     },
    },
    error =>
    {
     no_doc => 'NOT IN DOCUMENT CONTEXT',
    },
   },
  },

my $rendition = 'html';
my $style     = 'default';

# Arrange
my $tcname    = $tc->{name};
my $content   = $tc->{content};
my $subclass  = $tc->{subclass};
my $expected  = $tc->{expected}{render}{$rendition}{$style};
my $filename  = $tc->{filename};
my $docid     = $tc->{docid};
my $library   = SML::Library->new(config_file=>'library.conf');
my $parser    = $library->get_parser;
my $fragment  = $parser->create_fragment($filename);
my $document  = $library->get_document($docid);
my $line      = SML::Line->new(content=>$content);
my $block     = $subclass->new;

$block->add_line($line);
$document->add_part($block);

foreach my $block (@{ $fragment->get_block_list }) {
  $parser->_parse_block($block);
}

# Act
my $result = $block->render($rendition,$style);

print "\'$result\'\n\n";

print "============================================================\n\n";

print $block->dump_part_structure, "\n";

######################################################################

1;
