#!/usr/bin/perl

# $Id$

package SML::TestData;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.TestData');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has acronym_list_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_acronym_list_test_case_list',
   lazy    => 1,
   builder => '_build_acronym_list_test_case_list',
  );

######################################################################

has acronym_term_reference_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_acronym_term_reference_test_case_list',
   lazy    => 1,
   builder => '_build_acronym_term_reference_test_case_list',
  );

######################################################################

has assertion_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_assertion_test_case_list',
   lazy    => 1,
   builder => '_build_assertion_test_case_list',
  );

######################################################################

# attachment
# audio
# baretable

######################################################################

has block_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_block_test_case_list',
   lazy    => 1,
   builder => '_build_block_test_case_list',
  );

######################################################################

has bullet_list_item_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_bullet_list_item_test_case_list',
   lazy    => 1,
   builder => '_build_bullet_list_item_test_case_list',
  );

######################################################################

# citation_reference
# command_reference
# comment_block
# comment_division
# conditional

######################################################################

has cross_reference_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_cross_reference_test_case_list',
   lazy    => 1,
   builder => '_build_cross_reference_test_case_list',
  );

######################################################################

has definition_list_item_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_definition_list_item_test_case_list',
   lazy    => 1,
   builder => '_build_definition_list_item_test_case_list',
  );

######################################################################

has definition_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_definition_test_case_list',
   lazy    => 1,
   builder => '_build_definition_test_case_list',
  );

######################################################################

# demo

######################################################################

has division_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_division_test_case_list',
   lazy    => 1,
   builder => '_build_division_test_case_list',
  );

######################################################################

has document_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_document_test_case_list',
   lazy    => 1,
   builder => '_build_document_test_case_list',
  );

######################################################################

has element_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_element_test_case_list',
   lazy    => 1,
   builder => '_build_element_test_case_list',
  );

######################################################################

# email_address
# entity

######################################################################

has enumerated_list_item_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_enumerated_list_item_test_case_list',
   lazy    => 1,
   builder => '_build_enumerated_list_item_test_case_list',
  );

######################################################################

# environment
# epigraph
# exercise
# figure

######################################################################

has file_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_file_test_case_list',
   lazy    => 1,
   builder => '_build_file_test_case_list',
  );

######################################################################

# file_reference
# footnote_reference
# formattable

######################################################################

has formatter_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_formatter_test_case_list',
   lazy    => 1,
   builder => '_build_formatter_test_case_list',
  );

######################################################################

has fragment_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_fragment_test_case_list',
   lazy    => 1,
   builder => '_build_fragment_test_case_list',
  );

######################################################################

# glossary_definition_reference
# glossary
# glossary_term_reference
# id_reference
# index_reference
# inline
# keypoints

######################################################################

has library_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_library_test_case_list',
   lazy    => 1,
   builder => '_build_library_test_case_list',
  );

######################################################################

# line
# listing
# list_item
# literal_string
# note

######################################################################

has ontology_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_ontology_test_case_list',
   lazy    => 1,
   builder => '_build_ontology_test_case_list',
  );

######################################################################

# ontology_rule
# options
# page_reference
# paragraph

######################################################################

has parser_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_parser_test_case_list',
   lazy    => 1,
   builder => '_build_parser_test_case_list',
  );

######################################################################

has part_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_part_test_case_list',
   lazy    => 1,
   builder => '_build_part_test_case_list',
  );

######################################################################

# path_reference
# preformatted_block
# preformatted_division
# property
# quotation
# reasoner
# references
# region
# resource
# resources
# revisions
# section
# sidebar
# slide
# source
# status_reference

######################################################################

has string_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_string_test_case_list',
   lazy    => 1,
   builder => '_build_string_test_case_list',
  );

######################################################################

# svninfo
# symbol
# syntax_error_string
# syntax
# table_cell
# table
# table_row

######################################################################

has test_data_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_test_data_test_case_list',
   lazy    => 1,
   builder => '_build_test_data_test_case_list',
  );

######################################################################

# url_reference
# user_entered_text
# util
# variable_reference
# video
# xml_tag

######################################################################
######################################################################
######################################################################

has test_library_1 =>
  (
   is      => 'ro',
   isa     => 'SML::Library',
   reader  => 'get_test_library_1',
   lazy    => 1,
   builder => '_build_test_library_1',
  );

######################################################################

has test_document_1 =>
  (
   is      => 'ro',
   isa     => 'SML::Document',
   reader  => 'get_test_document_1',
   lazy    => 1,
   builder => '_build_test_document_1',
  );

######################################################################

has test_definition_1 =>
  (
   is      => 'ro',
   isa     => 'SML::Definition',
   reader  => 'get_test_definition_1',
   lazy    => 1,
   builder => '_build_test_definition_1',
  );

######################################################################

has test_definition_2 =>
  (
   is      => 'ro',
   isa     => 'SML::Definition',
   reader  => 'get_test_definition_2',
   lazy    => 1,
   builder => '_build_test_definition_2',
  );

######################################################################

has test_definition_3 =>
  (
   is      => 'ro',
   isa     => 'SML::Definition',
   reader  => 'get_test_definition_3',
   lazy    => 1,
   builder => '_build_test_definition_3',
  );

######################################################################

has test_definition_4 =>
  (
   is      => 'ro',
   isa     => 'SML::Definition',
   reader  => 'get_test_definition_4',
   lazy    => 1,
   builder => '_build_test_definition_4',
  );

######################################################################

has test_note_1 =>
  (
   is      => 'ro',
   isa     => 'SML::Note',
   reader  => 'get_test_note_1',
   lazy    => 1,
   builder => '_build_test_note_1',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _build_acronym_list_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'acronym_1',
      definition => $self->get_test_definition_1,
      acronym => 'TLA',
      alt => '',
      expected =>
      {
       add_acronym => 1,
       has_acronym => 1,
       get_acronym => 'SML::Definition',
      },
     },

     {
      name => 'acronym_2',
      definition => $self->get_test_definition_4,
      acronym => 'FRD',
      alt => 'ieee',
      expected =>
      {
       add_acronym => 1,
       has_acronym => 1,
       get_acronym => 'SML::Definition',
      }
     },

     {
      name => 'acronym_3',
      definition => $self->get_test_definition_3,
      acronym => 'bogus',
      alt => '',
      expected =>
      {
       add_acronym => 1,
       has_acronym => 0,
       get_acronym => '',
      }
     },

     {
      name => 'bad_acronym_1',
      definition => 'bogus definition',
      acronym => 'bogus',
      alt => '',
      expected =>
      {
       error =>
       {
	add_acronym => 'NOT A DEFINITION',
       },
      }
     },

     {
      name => 'bad_acronym_2',
      acronym => 'bogus',
      alt => '',
      expected =>
      {
       warning =>
       {
	get_acronym => 'FAILED ACRONYM LOOKUP',
       },
      }
     },
    ];
}

######################################################################

sub _build_acronym_term_reference_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'acronym_term_reference_1',
      args =>
      {
       tag => 'ac',
       acronym => 'TLA',
       namespace => '',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       get_tag => 'ac',
       get_acronym => 'TLA',
       get_namespace => '',
      },
     },
    ];
}

######################################################################

sub _build_assertion_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'assertion_1',
      args =>
      {
       id        => 'a1',
       subject   => 'My eyes',
       predicate => 'are',
       object    => 'blue',
       library   => $self->get_test_library_1,
      },
      expected =>
      {
       get_subject   => 'My eyes',
       get_predicate => 'are',
       get_object    => 'blue',
      },
     },

     {
      name => 'assertion_2',
      args =>
      {
       id        => 'a2',
       subject   => 'rq-000331',
       predicate => 'is_part_of',
       object    => 'rq-000026',
       library   => $self->get_test_library_1,
      },
      expected =>
      {
       get_subject   => 'rq-000331',
       get_predicate => 'is_part_of',
       get_object    => 'rq-000026',
      },
     },
    ];
}

######################################################################

sub _build_block_test_case_list {

  my $self = shift;

  return
    [
     {
      name     => 'cross_reference_1',
      content  => '[ref:introduction]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
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

     {
      name     => 'cross_reference_2',
      content  => '[r:introduction]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
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

     {
      name     => 'cross_reference_3',
      content  => '[ref:system-model]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020-2.html#SECTION.2\">Section 2</a></p>\n\n",
	},
	latex =>
	{
	 default => "Section~\\vref{system-model}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'cross_reference_4',
      content  => '[r:system-model]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020-2.html#SECTION.2\">Section 2</a></p>\n\n",
	},
	latex =>
	{
	 default => "Section~\\vref{system-model}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'url_reference_1',
      content  => '[url:http://www.cnn.com/]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"http://www.cnn.com/\">http://www.cnn.com/</a></p>\n\n",
	},
	latex =>
	{
	 default => "\\urlstyle{sf}\\url{http://www.cnn.com/}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"http://www.cnn.com/\">http://www.cnn.com/</a>\n\n",
	},
       },
      },
     },

     {
      name     => 'url_reference_2',
      content  => '[url:http://www.cnn.com/|CNN News]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"http://www.cnn.com/\">CNN News</a></p>\n\n",
	},
	latex =>
	{
	 default => "\\urlstyle{sf}\\href{http://www.cnn.com/}{CNN News}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"http://www.cnn.com/\">CNN News</a>\n\n",
	},
       },
      },
     },

     {
      name     => 'footnote_reference_1',
      content  => '[f:introduction:1]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><span style=\"font-size: 8pt;\"><sup><a href=\"#footnote.introduction.1\">1<\/a><\/sup><\/span></p>\n\n",
	},
	latex =>
	{
	 default => "\\footnote{This is a footnote.}\n\n",
	},
	xml =>
	{
	 default => "<span style=\"font-size: 8pt;\"><sup><a href=\"#footnote.introduction.1\">1<\/a><\/sup><\/span>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'glossary_reference_1',
      content  => '[g:sml:document]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.glossary.html#document:sml\">document</a></p>\n\n",
	},
	latex =>
	{
	 default => "\\gls{document:sml}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'glossary_reference_2',
      content  => '[G:sml:document]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.glossary.html#document:sml\">Document</a></p>\n\n",
	},
	latex =>
	{
	 default => "\\Gls{document:sml}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'glossary_reference_3',
      content  => '[gls:sml:document]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.glossary.html#document:sml\">document</a></p>\n\n",
	},
	latex =>
	{
	 default => "\\gls{document:sml}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'glossary_reference_4',
      content  => '[Gls:sml:document]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.glossary.html#document:sml\">Document</a></p>\n\n",
	},
	latex =>
	{
	 default => "\\Gls{document:sml}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'acronym_reference_1',
      content  => '[a:sml:TLA]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a></p>\n\n",
	},
	latex =>
	{
	 default => "\\ac{TLA:sml}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'acronym_reference_2',
      content  => '[ac:sml:TLA]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a></p>\n\n",
	},
	latex =>
	{
	 default => "\\ac{TLA:sml}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'acronym_reference_3',
      content  => '[acs:sml:TLA]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a></p>\n\n",
	},
	latex =>
	{
	 default => "\\acs{TLA:sml}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'acronym_reference_4',
      content  => '[acl:sml:TLA]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.acronyms.html#TLA:sml\">Three Letter Acronym</a></p>\n\n",
	},
	latex =>
	{
	 default => "\\acl{TLA:sml}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.acronyms.html#TLA:sml\">Three Letter Acronym</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'index_reference_1',
      content  => '[i:structured manuscript language]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>structured manuscript language</p>\n\n",
	},
	latex =>
	{
	 default => "structured manuscript language \\index{structured manuscript language}\n\n",
	},
	xml =>
	{
	 default => "structured manuscript language\n\n",
	},
       },
      },
     },

     {
      name     => 'index_reference_2',
      content  => '[index:structured manuscript language]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>structured manuscript language</p>\n\n",
	},
	latex =>
	{
	 default => "structured manuscript language \\index{structured manuscript language}\n\n",
	},
	xml =>
	{
	 default => "structured manuscript language\n\n",
	},
       },
      },
     },

     {
      name     => 'id_reference_1',
      content  => '[id:introduction]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
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
	 default => "\\hyperref[introduction]{introduction}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020-1.html#SECTION.1\">Section 1</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'thepage_reference_1',
      content  => '[thepage]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p></p>\n\n",
	},
	latex =>
	{
	 default => "\\thepage\n\n",
	},
	xml =>
	{
	 default => "\n\n",
	},
       },
      },
     },

     {
      name     => 'page_reference_1',
      content  => '[page:introduction]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020-1.html#SECTION.1\">link</a></p>\n\n",
	},
	latex =>
	{
	 default => "p. \\pageref{introduction}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020-1.html#SECTION.1\">link</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'page_reference_2',
      content  => '[pg:introduction]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020-1.html#SECTION.1\">link</a></p>\n\n",
	},
	latex =>
	{
	 default => "p. \\pageref{introduction}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020-1.html#SECTION.1\">link</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'version_reference_1',
      content  => '[theversion]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>2.0</p>\n\n",
	},
	latex =>
	{
	 default => "2.0\n\n",
	},
	xml =>
	{
	 default => "2.0\n\n",
	},
       },
       success => 'valid version reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'revision_reference_1',
      content  => '[therevision]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>4444</p>\n\n",
	},
	latex =>
	{
	 default => "4444\n\n",
	},
	xml =>
	{
	 default => "4444\n\n",
	},
       },
       success => 'valid revision reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'date_reference_1',
      content  => '[thedate]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>2012-09-11</p>\n\n",
	},
	latex =>
	{
	 default => "2012-09-11\n\n",
	},
	xml =>
	{
	 default => "2012-09-11\n\n",
	},
       },
       success => 'valid date reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_1',
      content  => '[status:td-000020]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"status_yellow.png\" border=\"0\"/></p>\n\n",
	},
	latex =>
	{
	 default => "\\textcolor{fg-yellow}{\$\\blacksquare\$}\n\n",
	},
	xml =>
	{
	 default => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
	},
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_2',
      content  => '[status:grey]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"status_grey.png\" border=\"0\"/></p>\n\n",
	},
	latex =>
	{
	 default => "\\textcolor{fg-grey}{\$\\blacksquare\$}\n\n",
	},
	xml =>
	{
	 default => "<image src=\"status_grey.png\" border=\"0\"/>\n\n",
	},
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_3',
      content  => '[status:green]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"status_green.png\" border=\"0\"/></p>\n\n",
	},
	latex =>
	{
	 default => "\\textcolor{fg-green}{\$\\blacksquare\$}\n\n",
	},
	xml =>
	{
	 default => "<image src=\"status_green.png\" border=\"0\"/>\n\n",
	},
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_4',
      content  => '[status:yellow]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"status_yellow.png\" border=\"0\"/></p>\n\n",
	},
	latex =>
	{
	 default => "\\textcolor{fg-yellow}{\$\\blacksquare\$}\n\n",
	},
	xml =>
	{
	 default => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
	},
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_5',
      content  => '[status:red]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"status_red.png\" border=\"0\"/></p>\n\n",
	},
	latex =>
	{
	 default => "\\textcolor{fg-red}{\$\\blacksquare\$}\n\n",
	},
	xml =>
	{
	 default => "<image src=\"status_red.png\" border=\"0\"/>\n\n",
	},
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_6',
      content  => '[status:problem-1]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"status_green.png\" border=\"0\"/></p>\n\n",
	},
	latex =>
	{
	 default => "\\textcolor{fg-green}{\$\\blacksquare\$}\n\n",
	},
	xml =>
	{
	 default => "<image src=\"status_green.png\" border=\"0\"/>\n\n",
	},
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'citation_reference_1',
      content  => '[cite:cms15]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>[<a href=\"td-000020.source.html#cms15\">cms15</a>]</p>\n\n",
	},
	latex =>
	{
	 default => "\\cite{cms15}\n\n",
	},
	xml =>
	{
	 default => "[<a href=\"td-000020.source.html#cms15\">cms15</a>]\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'citation_reference_2',
      content  => '[cite:cms15, pg 44]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>[<a href=\"td-000020.source.html#cms15\">cms15, pg 44</a>]</p>\n\n",
	},
	latex =>
	{
	 default => "\\cite[pg 44]{cms15}\n\n",
	},
	xml =>
	{
	 default => "[<a href=\"td-000020.source.html#cms15\">cms15, pg 44</a>]\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'file_reference_1',
      content  => '[file:app.ini]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><tt>app.ini</tt></p>\n\n",
	},
	latex =>
	{
	 default => "\\path{app.ini}\n\n",
	},
	xml =>
	{
	 default => "<tt>app.ini</tt>\n\n",
	},
       },
      },
     },

     {
      name     => 'file_reference_2',
      content  => '[file:My Document.doc]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><tt>My Document.doc</tt></p>\n\n",
	},
	latex =>
	{
	 default => "\\path{My Document.doc}\n\n",
	},
	xml =>
	{
	 default => "<tt>My Document.doc</tt>\n\n",
	},
       },
      },
     },

     {
      name     => 'path_reference_1',
      content  => '[path:/path/to/folder]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><tt>/path/to/folder</tt></p>\n\n",
	},
	latex =>
	{
	 default => "\\path{/path/to/folder}\n\n",
	},
	xml =>
	{
	 default => "<tt>/path/to/folder</tt>\n\n",
	},
       },
      },
     },

     {
      name     => 'path_reference_2',
      content  => '[path:/path/to/my folder]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><tt>/path/to/my folder</tt></p>\n\n",
	},
	latex =>
	{
	 default => "\\path{/path/to/my folder}\n\n",
	},
	xml =>
	{
	 default => "<tt>/path/to/my folder</tt>\n\n",
	},
       },
      },
     },

     {
      name     => 'path_reference_3',
      content  => '[path:C:\path\to\my folder\]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><tt>C:\\path\\to\\my folder\\</tt></p>\n\n",
	},
	# latex =>
	# {
	# 	default => "\\path{C:\\path\\to\\my folder}\$\\backslash\$\n\n",
	# },
	xml =>
	{
	 default => "<tt>C:\\path\\to\\my folder\\</tt>\n\n",
	},
       },
      },
     },

     {
      name     => 'user_entered_text_1',
      content  => '[enter:USERNAME]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><b><tt>USERNAME</tt></b></p>\n\n",
	},
	latex =>
	{
	 default => "\\textbf{\\texttt{USERNAME}}\n\n",
	},
	xml =>
	{
	 default => "<b><tt>USERNAME</tt></b>\n\n",
	},
       },
      },
     },

     {
      name     => 'command_reference_1',
      content  => '[cmd:pwd]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><tt>pwd</tt></p>\n\n",
	},
	latex =>
	{
	 default => "\\path{pwd}\n\n",
	},
	xml =>
	{
	 default => "<tt>pwd</tt>\n\n",
	},
       },
      },
     },

     {
      name     => 'command_reference_2',
      content  => '[cmd:ls -al | grep -i bin | sort]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><tt>ls -al | grep -i bin | sort</tt></p>\n\n",
	},
	latex =>
	{
	 default => "\\path{ls -al | grep -i bin | sort}\n\n",
	},
	xml =>
	{
	 default => "<tt>ls -al | grep -i bin | sort</tt>\n\n",
	},
       },
      },
     },

     {
      name     => 'xml_tag_1',
      content  => '<html>',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&lt;html&gt;</p>\n\n",
	},
	latex =>
	{
	 default => "<html>\n\n",
	},
	xml =>
	{
	 default => "&lt;html&gt;\n\n",
	},
       },
      },
     },

     {
      name     => 'xml_tag_2',
      content  => '<para style="indented">',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&lt;para style=\"indented\"&gt;</p>\n\n",
	},
	latex =>
	{
	 default => "<para style=\"indented\">\n\n",
	},
	xml =>
	{
	 default => "&lt;para style=\"indented\"&gt;\n\n",
	},
       },
      },
     },

     {
      name     => 'literal_string_1',
      content  => '{lit:[cite:Goossens94]}',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>[cite:Goossens94]</p>\n\n",
	},
	latex =>
	{
	 default => "[cite:Goossens94]\n\n",
	},
	xml =>
	{
	 default => "[cite:Goossens94]\n\n",
	},
       },
      },
     },

     {
      name     => 'email_address_1',
      content  => '[email:joe@example.com]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"mailto:joe\@example.com\">joe\@example.com</a></p>\n\n",
	},
	latex =>
	{
	 default => "joe\@example.com\n\n",
	},
	xml =>
	{
	 default => "<a href=\"mailto:joe\@example.com\">joe\@example.com</a>\n\n",
	},
       },
      },
     },

     {
      name     => 'take_note_symbol',
      content  => '[take_note]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><b>(take note!)</b></p>\n\n",
	},
	latex =>
	{
	 default => "\\marginpar{\\Huge\\Writinghand}\n\n",
	},
	xml =>
	{
	 default => "<b>(take note!)</b>\n\n",
	},
       },
      },
     },

     {
      name     => 'smiley_symbol',
      content  => ':-)',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&#9786;</p>\n\n",
	},
	latex =>
	{
	 default => "\\large\\Smiley\n\n",
	},
	xml =>
	{
	 default => "&#9786;\n\n",
	},
       },
      },
     },

     {
      name     => 'frowny_symbol',
      content  => ':-(',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&#9785;</p>\n\n",
	},
	latex =>
	{
	 default => "\\large\\Frowny\n\n",
	},
	xml =>
	{
	 default => "&#9785;\n\n",
	},
       },
      },
     },

     {
      name     => 'keystroke_symbol_1',
      content  => '[[Enter]]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><span class=\"keystroke\">Enter</span></p>\n\n",
	},
	latex =>
	{
	 default => "\\keystroke{Enter}\n\n",
	},
	xml =>
	{
	 default => "<span class=\"keystroke\">Enter</span>\n\n",
	},
       },
      },
     },

     {
      name     => 'keystroke_symbol_2',
      content  => '[[Ctrl]]-[[Alt]]-[[Del]]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><span class=\"keystroke\">Ctrl</span>-<span class=\"keystroke\">Alt</span>-<span class=\"keystroke\">Del</span></p>\n\n",
	},
	latex =>
	{
	 default => "\\keystroke{Ctrl}-\\keystroke{Alt}-\\keystroke{Del}\n\n",
	},
	xml =>
	{
	 default => "<span class=\"keystroke\">Ctrl</span>-<span class=\"keystroke\">Alt</span>-<span class=\"keystroke\">Del</span></p>\n\n",
	},
       },
      },
     },

     {
      name     => 'left_arrow_symbol',
      content  => '<-',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&#8592;</p>\n\n",
	},
	latex =>
	{
	 default => "\$\\leftarrow\$\n\n",
	},
	xml =>
	{
	 default => "&#8592;\n",
	},
       },
      },
     },

     {
      name     => 'right_arrow_symbol',
      content  => '->',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&#8594;</p>\n\n",
	},
	latex =>
	{
	 default => "\$\\rightarrow\$\n\n",
	},
	xml =>
	{
	 default => "&#8594;\n\n",
	},
       },
      },
     },

     {
      name     => 'latex_symbol',
      content  => 'LaTeX',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>L<sup>a</sup>T<sub>e</sub>X</p>\n\n",
	},
	latex =>
	{
	 default => "\\LaTeX{}\n\n",
	},
	xml =>
	{
	 default => "LaTeX\n\n",
	},
       },
      },
     },

     {
      name     => 'tex_symbol',
      content  => 'TeX',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>T<sub>e</sub>X</p>\n\n",
	},
	latex =>
	{
	 default => "\\TeX{}\n\n",
	},
	xml =>
	{
	 default => "TeX\n\n",
	},
       },
      },
     },

     {
      name     => 'copyright_symbol',
      content  => '[c]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&copy;</p>\n\n",
	},
	latex =>
	{
	 default => "\\tiny\$^{\\copyright}\$\\normalsize\n\n",
	},
	xml =>
	{
	 default => "&copy;\n\n",
	},
       },
      },
     },

     {
      name     => 'trademark_symbol',
      content  => '[tm]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&trade;</p>\n\n",
	},
	latex =>
	{
	 default => "\\tiny\$^{\\texttrademark}\$\\normalsize\n\n",
	},
	xml =>
	{
	 default => "&trade;\n\n",
	},
       },
      },
     },

     {
      name     => 'reg_trademark_symbol',
      content  => '[rtm]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&reg;</p>\n\n",
	},
	latex =>
	{
	 default => "\\tiny\$^{\\textregistered}\$\\normalsize\n\n",
	},
	xml =>
	{
	 default => "&reg;\n\n",
	},
       },
      },
     },

     {
      name     => 'open_dblquote_symbol',
      content  => '``',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&#8220;</p>\n\n",
	},
	latex =>
	{
	 default => "\`\`\n\n",
	},
	xml =>
	{
	 default => "&#8220;\n\n",
	},
       },
      },
     },

     {
      name     => 'close_dblquote_symbol',
      content  => '\'\'',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&#8221;</p>\n\n",
	},
	latex =>
	{
	 default => "\'\'\n\n",
	},
	xml =>
	{
	 default => "&#8221;\n\n",
	},
       },
      },
     },

     {
      name     => 'open_sglquote_symbol',
      content  => '`',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&#8216;</p>\n\n",
	},
	latex =>
	{
	 default => "\`\n\n",
	},
	xml =>
	{
	 default => "&#8216;\n\n",
	},
       },
      },
     },

     {
      name     => 'close_sglquote_symbol',
      content  => '\'',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&#8217;</p>\n\n",
	},
	latex =>
	{
	 default => "\'\n\n",
	},
	xml =>
	{
	 default => "&#8217;\n\n",
	},
       },
      },
     },

     {
      name     => 'section_symbol',
      content  => '[section]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&sect;</p>\n\n",
	},
	latex =>
	{
	 default => "{\\S}\n\n",
	},
	xml =>
	{
	 default => "&sect;\n\n",
	},
       },
      },
     },

     {
      name     => 'emdash_symbol',
      content  => '--',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&mdash;</p>\n\n",
	},
	latex =>
	{
	 default => "--\n\n",
	},
	xml =>
	{
	 default => "&mdash;\n\n",
	},
       },
      },
     },

     {
      name     => 'bold_1',
      content  => '!!bold text!!',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><b>bold text</b></p>\n\n",
	},
	latex =>
	{
	 default => "\\textbf{bold text}\n\n",
	},
	xml =>
	{
	 default => "<b>bold text</b>\n\n",
	},
       },
      },
     },

     {
      name     => 'italics_1',
      content  => '~~italicized text~~',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><i>italicized text</i></p>\n\n",
	},
	latex =>
	{
	 default => "\\textit{italicized text}\n\n",
	},
	xml =>
	{
	 default => "<i>italicized text</i>\n\n",
	},
       },
      },
     },

     {
      name     => 'underline_1',
      content  => '__underlined text__',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><u>underlined text</u></p>\n\n",
	},
	latex =>
	{
	 default => "\\underline{underlined text}\n\n",
	},
	xml =>
	{
	 default => "<u>underlined text</u>\n\n",
	},
       },
      },
     },

     {
      name     => 'fixedwidth_1',
      content  => '||fixedwidth text||',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><tt>fixedwidth text</tt></p>\n\n",
	},
	latex =>
	{
	 default => "\\texttt{fixedwidth text}\n\n",
	},
	xml =>
	{
	 default => "<tt>fixedwidth text</tt>\n\n",
	},
       },
      },
     },

     {
      name     => 'superscript_1',
      content  => '^^superscripted text^^',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><sup>superscripted text</sup></p>\n\n",
	},
	latex =>
	{
	 default => "\\textsuperscript{superscripted text}\n\n",
	},
	xml =>
	{
	 default => "<sup>superscripted text</sup>\n\n",
	},
       },
      },
     },

     {
      name     => 'subscript_1',
      content  => ',,subscripted text,,',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><sub>subscripted text</sub></p>\n\n",
	},
	latex =>
	{
	 default => "\\subscript{subscripted text}\n\n",
	},
	xml =>
	{
	 default => "<sub>subscripted text</sub>\n\n",
	},
       },
      },
     },

     {
      name     => 'valid_bold_block',
      content  => 'This is a valid !!bold!! block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_bold_block',
      content  => 'This is an INVALID !!bold block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       valid_syntax_warning => 'INVALID BOLD MARKUP',
      },
     },

     {
      name     => 'valid_italics_block',
      content  => 'This is a valid ~~italics~~ block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_italics_block',
      content  => 'This is an INVALID ~~italics block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       valid_syntax_warning => 'INVALID ITALICS MARKUP',
      },
     },

     {
      name     => 'valid_fixedwidth_block',
      content  => 'This is a valid ||fixed-width|| block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_fixedwidth_block',
      content  => 'This is an INVALID ||fixed-width block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       valid_syntax_warning => 'INVALID FIXED-WIDTH MARKUP',
      },
     },

     {
      name     => 'valid_underline_block',
      content  => 'This is a valid __underline__ block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_underline_block',
      content  => 'This is an INVALID __underline block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       valid_syntax_warning => 'INVALID UNDERLINE MARKUP',
      },
     },

     {
      name     => 'valid_superscript_block',
      content  => 'This is a valid ^^superscript^^ block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_superscript_block',
      content  => 'This is an INVALID ^^superscript block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       valid_syntax_warning => 'INVALID SUPERSCRIPT MARKUP',
      },
     },

     {
      name     => 'valid_subscript_block',
      content  => 'This is a valid ,,subscript,, block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_subscript_block',
      content  => 'This is an INVALID ,,subscript block',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       valid_syntax_warning => 'INVALID SUBSCRIPT MARKUP',
      },
     },

     {
      name     => 'valid_cross_reference_1',
      content  => 'Here is a valid cross reference: [ref:introduction].',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 1,
      },
     },

     {
      name     => 'valid_cross_reference_2',
      content  => 'Here is a valid cross reference: [r:introduction].',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 1,
      },
     },

     {
      name     => 'invalid_cross_reference_1',
      content  => 'Here is an INVALID cross reference: [ref:bogus].',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 0,
       valid_semantics_warning => 'INVALID CROSS REFERENCE',
      },
     },

     {
      name     => 'invalid_cross_reference_2',
      content  => 'Here is an INVALID cross reference: [r:bogus].',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 0,
       valid_semantics_warning => 'INVALID CROSS REFERENCE',
      },
     },

     {
      name     => 'incomplete_cross_reference_1',
      content  => 'Here is an incomplete cross reference: [ref:introduction.',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       has_valid_semantics => 1,
       valid_syntax_warning => 'INVALID CROSS REFERENCE SYNTAX',
      },
     },

     {
      name     => 'incomplete_cross_reference_2',
      content  => 'Here is an incomplete cross reference: [r:introduction.',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       has_valid_semantics => 1,
       valid_syntax_warning => 'INVALID CROSS REFERENCE SYNTAX',
      },
     },

     {
      name     => 'valid_id_reference',
      content  => 'Here is a valid id reference: [id:introduction].',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 1,
       success => 'valid ID reference passes validation',
      },
     },

     {
      name     => 'invalid_id_reference',
      content  => 'Here is an INVALID id reference: [id:bogus].',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 0,
       valid_semantics_warning => 'INVALID ID REFERENCE',
      },
     },

     {
      name     => 'incomplete_id_reference',
      content  => 'Here is an incomplete id reference: [id:introduction.',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       has_valid_semantics => 1,
       valid_syntax_warning => 'INVALID ID REFERENCE SYNTAX',
      },
     },

     {
      name     => 'valid_page_reference_1',
      content  => 'Here is a valid page reference: [page:introduction].',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 1,
       success => 'valid page reference 1 passes validation',
      },
     },

     {
      name     => 'valid_page_reference_2',
      content  => 'Here is a valid page reference: [pg:introduction].',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 1,
       success => 'valid page reference 2 passes validation',
      },
     },

     {
      name     => 'invalid_page_reference_1',
      content  => 'Here is an INVALID page reference: [page:bogus].',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 0,
       valid_semantics_warning => 'INVALID PAGE REFERENCE',
      },
     },

     {
      name     => 'invalid_page_reference_2',
      content  => 'Here is an INVALID page reference: [pg:bogus].',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 0,
       valid_semantics_warning => 'INVALID PAGE REFERENCE',
      },
     },

     {
      name     => 'incomplete_page_reference_1',
      content  => 'Here is an incomplete page reference: [page:introduction.',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       has_valid_semantics => 1,
       valid_syntax_warning => 'INVALID PAGE REFERENCE SYNTAX',
      },
     },

     {
      name     => 'incomplete_page_reference_2',
      content  => 'Here is an incomplete page reference: [pg:introduction.',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       has_valid_semantics => 1,
       valid_syntax_warning => 'INVALID PAGE REFERENCE SYNTAX',
      },
     },

     {
      name     => 'invalid_glossary_term_reference_1',
      content  => '[g:sml:bogus]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 0,
       valid_semantics_warning => 'TERM NOT IN GLOSSARY',
      },
     },

     {
      name     => 'incomplete_glossary_term_reference_1',
      content  => '[g:sml:bogus',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       has_valid_semantics => 1,
       valid_syntax_warning => 'INVALID GLOSSARY TERM REFERENCE SYNTAX',
      },
     },

     {
      name     => 'invalid_glossary_def_reference_1',
      content  => '[def:sml:bogus]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 0,
       valid_semantics_warning => 'DEFINITION NOT IN GLOSSARY',
      },
     },

     {
      name     => 'incomplete_glossary_def_reference_1',
      content  => '[def:sml:bogus',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       has_valid_semantics => 1,
       valid_syntax_warning => 'INVALID GLOSSARY DEFINITION REFERENCE SYNTAX',
      },
     },

     {
      name     => 'invalid_acronym_reference_1',
      content  => '[ac:sml:bogus]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 0,
       valid_semantics_warning => 'ACRONYM NOT IN ACRONYM LIST',
      },
     },

     {
      name     => 'incomplete_acronym_reference_1',
      content  => '[ac:sml:bogus',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       has_valid_semantics => 1,
       valid_syntax_warning => 'INVALID ACRONYM REFERENCE SYNTAX',
      },
     },

     {
      name     => 'invalid_source_citation_1',
      content  => '[cite:bogus]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 1,
       has_valid_semantics => 0,
       valid_semantics_warning => 'INVALID SOURCE CITATION',
      },
     },

     {
      name     => 'incomplete_source_citation_1',
      content  => '[cite:bogus',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       has_valid_syntax => 0,
       has_valid_semantics => 1,
       valid_syntax_warning => 'INVALID SOURCE CITATION SYNTAX',
      },
     },

     {
      name     => 'get_name_path_test_1',
      testfile => 'td-000020.txt',
      config   => 'library.conf',
     },

    ];
}

######################################################################

sub _build_bullet_list_item_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'top_level_item',
      line => SML::Line->new(content=>'- top level item'),
      args =>
      {
       library => $self->get_test_library_1,
      },
      expected =>
      {
       get_value => 'top level item',
      },
     },

     {
      name => 'indented_item',
      line => SML::Line->new(content=>'  - indented item'),
      args =>
      {
       library => $self->get_test_library_1,
      },
      expected =>
      {
       get_value => 'indented item',
      },
     },
    ];
}

######################################################################

sub _build_cross_reference_test_case_list {

  my $self = shift;

  return
    [
    ];
}

######################################################################

sub _build_definition_list_item_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'definition_list_item_1',
      line => SML::Line->new(content=>'= term 1 = definition of term 1'),
      args =>
      {
       library => $self->get_test_library_1,
      },
      expected =>
      {
       get_term => 'term 1',
       get_definition => 'definition of term 1',
      },
     },

     {
      name => 'bad_definition_list_item_1',
      line => SML::Line->new(content=>'This is not a definition list item'),
      args =>
      {
       library => $self->get_test_library_1,
      },
      expected =>
      {
       error => 'DEFINITION LIST ITEM SYNTAX ERROR',
      },
     },
    ];
}

######################################################################

sub _build_definition_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'definition_1',
      line => SML::Line->new(content=>'glossary:: BPEL = Business Process Execution Language'),
      args =>
      {
       name => 'glossary',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       get_term => 'BPEL',
       get_alt => '',
       get_value => 'Business Process Execution Language',
      },
     },

     {
      name => 'definition_2',
      line => SML::Line->new(content=>'glossary:: FRD {ieee} = (IEEE) Functional Requirements Document'),
      args =>
      {
       name => 'glossary',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       get_term => 'FRD',
       get_alt => 'ieee',
       get_value => '(IEEE) Functional Requirements Document',
      },
     },

     {
      name => 'bad_definition_1',
      line => SML::Line->new(content=>'This is not a definition'),
      args =>
      {
       name => 'glossary',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       error =>
       {
	get_term => 'DEFINITION SYNTAX ERROR',
       },
      },
     },
    ];
}

######################################################################

sub _build_division_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'division_1',
      division_number => '4-4-4',
      args =>
      {
       id      => 'td',
       name    => 'test-division',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       init       => 1,
       get_id     => 'td',
       get_name   => 'test-division',
       get_number => '4-4-4',
      }
     },

     {
      name     => 'division_2',
      testfile => 'td-000020.txt',
      property_name => 'title',
      args =>
      {
       id      => 'td-000020',
       library => $self->get_test_library_1,
      },
      expected  =>
      {
       get_containing_division => 'SML::Fragment',
       get_first_part          => 'SML::PreformattedBlock',
       get_property            => 'SML::Property',
       get_property_value      => 'Section Structure With Regions',
       get_first_line          => '>>>DOCUMENT',
       get_part_list           => 22,
       get_line_list           => 216,
       get_division_list       => 32,
       get_section_list        => 5,
       get_block_list          => 93,
       get_element_list        => 40,
       get_preamble_line_list  => 18,
       get_narrative_line_list => 195,
       get_property_list       => 9,
      },
     },

     {
      name     => 'division_3',
      testfile => 'td-000020.txt',
      property_name => 'type',
      args =>
      {
       id      => 'introduction',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       get_containing_division => 'SML::Document',
       get_first_part          => 'SML::Element',
       get_property            => 'SML::Property',
       get_property_value      => 'chapter',
       get_first_line          => '* Introduction',
       get_part_list           => 7,
       get_line_list           => 17,
       get_division_list       => 0,
       get_block_list          => 7,
       get_element_list        => 4,
       get_preamble_line_list  => 4,
       get_narrative_line_list => 9,
       get_property_list       => 4,
      },
     },

     {
      name     => 'division_4',
      testfile => 'td-000020.txt',
      property_name => 'title',
      args =>
      {
       id      => 'problem-1',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       get_containing_division => 'SML::Section',
       get_first_part          => 'SML::PreformattedBlock',
       get_property            => 'SML::Property',
       get_property_value      => 'Problem One',
       get_first_line          => '>>>problem',
       get_part_list           => 11,
       get_line_list           => 42,
       get_division_list       => 10,
       get_block_list          => 19,
       get_element_list        => 6,
       get_preamble_line_list  => 12,
       get_narrative_line_list => 26,
       get_property_list       => 6,
      },
     },

     {
      name     => 'division_5',
      testfile => 'td-000020.txt',
      property_name => 'id',
      args =>
      {
       id      => 'tab-solution-types',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       get_containing_division => 'SML::Section',
       get_first_part          => 'SML::PreformattedBlock',
       get_property            => 'SML::Property',
       get_property_value      => 'tab-solution-types',
       get_first_line          => '---TABLE',
       get_part_list           => 10,
       get_line_list           => 30,
       get_division_list       => 12,
       get_block_list          => 15,
       get_element_list        => 2,
       get_preamble_line_list  => 4,
       get_narrative_line_list => 22,
       get_property_list       => 2,
      },
     },

     {
      name     => 'invalid_semantics_division_1',
      testfile => 'td-000063.txt',
      args =>
      {
       id      => 'parent-problem',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       warning =>
       {
	has_valid_semantics => 'INVALID EXPLICIT DECLARATION OF INFER-ONLY PROPERTY',
       },
      },
     },

     {
      name     => 'invalid_semantics_division_2',
      testfile => 'td-000064.txt',
      args =>
      {
       id      => 'problem-1',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       warning =>
       {
	has_valid_semantics => 'MISSING REQUIRED PROPERTY',
       },
      },
     },

     {
      name     => 'invalid_semantics_division_3',
      testfile => 'td-000070.txt',
      args =>
      {
       id      => 'td-000070',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       warning =>
       {
	has_valid_semantics => 'INVALID NON-UNIQUE ID',
       },
      },
     },

     {
      name     => 'invalid_semantics_division_4',
      testfile => 'td-000079.txt',
      args =>
      {
       id      => 'problem-1',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       warning =>
       {
	has_valid_semantics => 'INVALID PROPERTY CARDINALITY',
       },
      },
     },

     {
      name     => 'invalid_semantics_division_5',
      testfile => 'td-000080.txt',
      args =>
      {
       id      => 'problem-1',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       warning =>
       {
	has_valid_semantics => 'INVALID PROPERTY VALUE',
       },
      },
     },

     {
      name     => 'invalid_semantics_division_6',
      testfile => 'td-000081.txt',
      args =>
      {
       id      => 'solution-1',
       library => $self->get_test_library_1,
      },
      expected =>
      {
       warning =>
       {
	has_valid_semantics => 'INVALID COMPOSITION',
       },
      },
     },

     #################################################################

     {
      name => 'get_id_path_test_1',
      testfile  => 'td-000020.txt',
      config    => 'library.conf',
     },
    ];
}

######################################################################

sub _build_document_test_case_list {

  my $self = shift;

  return
    [
     {
      name     => 'td-000001',
      testfile => 'td-000001.txt',
      docid    => 'td-000001',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000002',
      testfile => 'td-000002.txt',
      docid    => 'td-000002',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000003',
      testfile => 'td-000003.txt',
      docid    => 'td-000003',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000004',
      testfile => 'td-000004.txt',
      docid    => 'td-000004',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000005',
      testfile => 'td-000005.txt',
      docid    => 'td-000005',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000006',
      testfile => 'td-000006.txt',
      docid    => 'td-000006',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000007',
      testfile => 'td-000007.txt',
      docid    => 'td-000007',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000008',
      testfile => 'td-000008.txt',
      docid    => 'td-000008',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000009',
      testfile => 'td-000009.txt',
      docid    => 'td-000009',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000010',
      testfile => 'td-000010.txt',
      docid    => 'td-000010',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000011',
      testfile => 'td-000011.txt',
      docid    => 'td-000011',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000012',
      testfile => 'td-000012.txt',
      docid    => 'td-000012',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000013',
      testfile => 'td-000013.txt',
      docid    => 'td-000013',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000014',
      testfile => 'td-000014.txt',
      docid    => 'td-000014',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000015',
      testfile => 'td-000015.txt',
      docid    => 'td-000015',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000016',
      testfile => 'td-000016.txt',
      docid    => 'td-000016',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000017',
      testfile => 'td-000017.txt',
      docid    => 'td-000017',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000018',
      testfile => 'td-000018.txt',
      docid    => 'td-000018',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000019',
      testfile => 'td-000019.txt',
      docid    => 'td-000019',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000020',
      testfile => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000021',
      testfile => 'td-000021.txt',
      docid    => 'td-000021',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000023',
      testfile => 'td-000023.txt',
      docid    => 'td-000023',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000025',
      testfile => 'td-000025.txt',
      docid    => 'td-000025',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000026',
      testfile => 'td-000026.txt',
      docid    => 'td-000026',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000027',
      testfile => 'td-000027.txt',
      docid    => 'td-000027',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'TERM NOT IN GLOSSARY'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000028',
      testfile => 'td-000028.txt',
      docid    => 'td-000028',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000029',
      testfile => 'td-000029.txt',
      docid    => 'td-000029',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID SOURCE CITATION'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       }
      },
     },

     {
      name     => 'td-000030',
      testfile => 'td-000030.txt',
      docid    => 'td-000030',
      expected =>
      {
       fatal =>
       {
	is_valid =>
	[
	 ['sml.Parser' => 'INVALID BEGIN REGION'],
	 ['sml.Parser' => 'INVALID END REGION'],
	],
       }
      },
     },

     {
      name     => 'td-000031',
      testfile => 'td-000031.txt',
      docid    => 'td-000031',
      expected =>
      {
       fatal =>
       {
	is_valid =>
	[
	 ['sml.Parser' => 'UNDEFINED REGION'],
	],
       }
      },
     },

     {
      name     => 'td-000032',
      testfile => 'td-000032.txt',
      docid    => 'td-000032',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000033',
      testfile => 'td-000033.txt',
      docid    => 'td-000033',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID CROSS REFERENCE'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000034',
      testfile => 'td-000034.txt',
      docid    => 'td-000034',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000035',
      testfile => 'td-000035.txt',
      docid    => 'td-000035',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID ID REFERENCE'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000036',
      testfile => 'td-000036.txt',
      docid    => 'td-000036',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000037',
      testfile => 'td-000037.txt',
      docid    => 'td-000037',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID PAGE REFERENCE'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000038',
      testfile => 'td-000038.txt',
      docid    => 'td-000038',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000039',
      testfile => 'td-000039.txt',
      docid    => 'td-000039',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID BOLD MARKUP'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000040',
      testfile => 'td-000040.txt',
      docid    => 'td-000040',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000041',
      testfile => 'td-000041.txt',
      docid    => 'td-000041',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID ITALICS MARKUP'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000042',
      testfile => 'td-000042.txt',
      docid    => 'td-000042',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000043',
      testfile => 'td-000043.txt',
      docid    => 'td-000043',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID FIXED-WIDTH MARKUP'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000044',
      testfile => 'td-000044.txt',
      docid    => 'td-000044',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000045',
      testfile => 'td-000045.txt',
      docid    => 'td-000045',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID UNDERLINE MARKUP'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000046',
      testfile => 'td-000046.txt',
      docid    => 'td-000046',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000047',
      testfile => 'td-000047.txt',
      docid    => 'td-000047',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID SUPERSCRIPT MARKUP'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000048',
      testfile => 'td-000048.txt',
      docid    => 'td-000048',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000049',
      testfile => 'td-000049.txt',
      docid    => 'td-000049',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID SUBSCRIPT MARKUP'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000050',
      testfile => 'td-000050.txt',
      docid    => 'td-000050',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID GLOSSARY TERM REFERENCE SYNTAX'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000051',
      testfile => 'td-000051.txt',
      docid    => 'td-000051',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'DEFINITION NOT IN GLOSSARY'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000052',
      testfile => 'td-000052.txt',
      docid    => 'td-000052',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID GLOSSARY DEFINITION REFERENCE SYNTAX'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000053',
      testfile => 'td-000053.txt',
      docid    => 'td-000053',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'ACRONYM NOT IN ACRONYM LIST'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000054',
      testfile => 'td-000054.txt',
      docid    => 'td-000054',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID ACRONYM REFERENCE SYNTAX'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000055',
      testfile => 'td-000055.txt',
      docid    => 'td-000055',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID SOURCE CITATION'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000056',
      testfile => 'td-000056.txt',
      docid    => 'td-000056',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID SOURCE CITATION SYNTAX'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000057',
      testfile => 'td-000057.txt',
      docid    => 'td-000057',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID CROSS REFERENCE SYNTAX'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000058',
      testfile => 'td-000058.txt',
      docid    => 'td-000058',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID ID REFERENCE SYNTAX'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000059',
      testfile => 'td-000059.txt',
      docid    => 'td-000059',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'INVALID PAGE REFERENCE SYNTAX'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000060',
      testfile => 'td-000060.txt',
      docid    => 'td-000060',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000061',
      testfile => 'td-000061.txt',
      docid    => 'td-000061',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000063',
      testfile => 'td-000063.txt',
      docid    => 'td-000063',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Division' => 'INVALID EXPLICIT DECLARATION OF INFER-ONLY PROPERTY'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000064',
      testfile => 'td-000064.txt',
      docid    => 'td-000064',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Division' => 'MISSING REQUIRED PROPERTY'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000065',
      testfile => 'td-000065.txt',
      docid    => 'td-000065',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000066',
      testfile => 'td-000066.txt',
      docid    => 'td-000066',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
       	is_valid =>
       	[
       	 ['sml.Block'    => 'FILE NOT FOUND'],
       	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
       	 # ['sml.Fragment' => 'FILE NOT FOUND'],
       	],
       },
      },
     },

     {
      name     => 'td-000067',
      testfile => 'td-000067.txt',
      docid    => 'td-000067',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000068',
      testfile => 'td-000068.txt',
      docid    => 'td-000068',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Block'    => 'FILE NOT FOUND'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000069',
      testfile => 'td-000069.txt',
      docid    => 'td-000069',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000070',
      testfile => 'td-000070.txt',
      docid    => 'td-000070',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Division' => 'INVALID NON-UNIQUE ID'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000071',
      testfile => 'td-000071.txt',
      docid    => 'td-000071',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000072',
      testfile => 'td-000072.txt',
      docid    => 'td-000072',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000073',
      testfile => 'td-000073.txt',
      docid    => 'td-000073',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000077',
      testfile => 'td-000077.txt',
      docid    => 'td-000077',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000078',
      testfile => 'td-000078.txt',
      docid    => 'td-000078',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'td-000079',
      testfile => 'td-000079.txt',
      docid    => 'td-000079',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Division' => 'INVALID PROPERTY CARDINALITY'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000080',
      testfile => 'td-000080.txt',
      docid    => 'td-000080',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Division' => 'INVALID PROPERTY VALUE'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000081',
      testfile => 'td-000081.txt',
      docid    => 'td-000081',
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Division' => 'INVALID COMPOSITION'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      name     => 'td-000082',
      testfile => 'td-000082.txt',
      docid    => 'td-000082',
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      name     => 'add_note_1',
      document => $self->get_test_document_1,
      note     => $self->get_test_note_1,
      expected =>
      {
       add_note => 1,
      },
     },
    ];
}

######################################################################

sub _build_element_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'element_1',
      text => 'title:: This is My Title',
      element_name => 'title',
      library => $self->get_test_library_1,
      expected =>
      {
       get_value => 'This is My Title',
       validate_element_allowed => 0,
      },
     },

     {
      name     => 'invalid_filespec',
      testfile => 'td-000066.txt',
      docid    => 'td-000066',
      library => $self->get_test_library_1,
      expected =>
      {
       warning =>
       {
	validate =>
	[
	 'INVALID FILE',
	 'THE DOCUMENT IS NOT VALID',
	]
       },
      },
     },

     {
      name     => 'invalid_image_file',
      testfile => 'td-000068.txt',
      docid    => 'td-000068',
      library => $self->get_test_library_1,
      expected =>
      {
       warning =>
       {
	validate =>
	[
	 'INVALID IMAGE FILE',
	 'THE DOCUMENT IS NOT VALID',
	],
       },
      },
     },
    ];
}

######################################################################

sub _build_enumerated_list_item_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'top_level_item',
      text => '+ top level item',
      library => $self->get_test_library_1,
      expected =>
      {
       get_value => 'top level item',
      },
     },

     {
      name => 'indented_item',
      text => '  + indented item',
      library => $self->get_test_library_1,
      expected =>
      {
       get_value => 'indented item',
      },
     },

    ];
}

######################################################################

sub _build_file_test_case_list {

  my $self = shift;

  return
    [
     {
      name     => 'file_1',
      filespec => 'library/testdata/td-000001.txt',
      expected =>
      {
       get_sha_digest => '3fc9a6743c4b2eb4d0cd27fd5ad90a75e94897da',
       get_md5_digest => '0aeb40f8e68ce0faf0d780e732213408',
       is_valid => 1,
      },
     },

     {
      name     => 'bad_file_1',
      filespec => 'library/testdata/bogus.txt',
      expected =>
      {
       is_valid => 0,
      },
     },
    ];
}

######################################################################

sub _build_formatter_test_case_list {

  my $self = shift;

  return
    [
    ];
}

######################################################################

sub _build_fragment_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'fragment_1',
      filespec => 'library/testdata/td-000074.txt',
      divid => 'my-problem',
      library => $self->get_test_library_1,
      expected =>
      {
       extract_division_lines => 19,
      },
     },

     {
      name => 'fragment_2',
      filespec => 'library/testdata/td-000074.txt',
      divid => 'tab-solution-types',
      library => $self->get_test_library_1,
      expected =>
      {
       extract_division_lines => 29,
      },
     },

     {
      name => 'fragment_3',
      filespec => 'library/testdata/td-000074.txt',
      divid => 'introduction',
      library => $self->get_test_library_1,
      expected =>
      {
       extract_division_lines => 16,
      },
     },
    ];
}

######################################################################

sub _build_library_test_case_list {

  my $self = shift;

  return
    [
     {
      name            => 'library_1',
      config_filename => 'library.conf',
      expected =>
      {
       get_id           => 'sml_engineering_library',
       get_name         => 'SML Engineering Library',
       get_revision     => '/\d+/',
       get_sml          => 'SML',
       get_parser       => 'SML::Parser',
       get_reasoner     => 'SML::Reasoner',
       get_formatter    => 'SML::Formatter',
       get_glossary     => 'SML::Glossary',
       get_acronym_list => 'SML::AcronymList',
       get_references   => 'SML::References',
      },
     },
    ];
}

######################################################################

sub _build_ontology_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'ontology_1',
      library => $self->get_test_library_1,
      file_list =>
      [
       'library/ontology_rules_sml.conf',
       'library/ontology_rules_lib.conf',
      ],
      entity_name => 'problem',
      environment_name => 'TABLE',
      property_name => 'status',
      property_value => 'green',
      name_or_value => 'STRING',
      rule_id => 'prb005',
      division_a => 'TABLE',
      division_b => 'SECTION',
      expected  =>
      {
       add_rules_from_file => 1,
       get_allowed_property_value_list =>
       [
	'grey',
	'green',
	'yellow',
	'red',
       ],
       get_entity_allowed_property_list =>
       [
	'allocation',
	'assignee',
	'assignment',
	'associated',
	'attr',
	'author',
	'changed_by',
	'child',
	'class_of',
	'copyright',
	'created_by',
	'date',
	'date_changed',
	'date_created',
	'derived',
	'derived_from',
	'description',
	'directed_by',
	'directs',
	'effort',
	'extended_by',
	'extends',
	'generalizes',
	'id',
	'instance_of',
	'next',
	'order',
	'owner',
	'parent',
	'previous',
	'priority',
	'realized_by',
	'realizes',
	'request',
	'revision',
	'solution',
	'specializes',
	'stakeholder',
	'state',
	'status',
	'task',
	'test',
	'title',
	'type',
	'used_by',
	'uses',
	'validated_by',
	'version',
	'work_product',
       ],
       get_allowed_environment_list =>
       [
	'ASSERTION',
	'ATTACHMENT',
	'AUDIO',
	'BARETABLE',
	'EPIGRAPH',
	'FIGURE',
	'FOOTER',
	'HEADER',
	'KEYPOINTS',
	'LISTING',
	'PREFORMATTED',
	'REVISIONS',
	'SIDEBAR',
	'SOURCE',
	'TABLE',
	'VIDEO',
       ],
       get_rule_for => 'SML::OntologyRule',
       get_rule_with_id => 'SML::OntologyRule',
       get_class_for_entity_name => 'SML::Entity',
       get_required_property_list =>
       [
	'description',
	'id',
	'title',
	'type',
       ],
       has_entity_with_name => 1,
       allows_entity => 1,
       allows_region => 1,
       allows_environment => 1,
       allows_property => 1,
       allows_composition => 1,
       allows_property_value => 1,
      },
     },

     {
      name => 'ontology_2',
      library => $self->get_test_library_1,
      file_list =>
      [
       'library/ontology_rules_sml.conf',
       'library/ontology_rules_lib.conf',
      ],
      entity_name => 'bogus',
      property_name => 'bogus',
      property_value => 'bogus',
      environment_name => 'bogus',
      division_a => 'TABLE',
      division_b => 'TABLE',
      expected =>
      {
       has_entity_with_name => 0,
       allows_entity => 0,
       allows_region => 0,
       allows_environment => 0,
       allows_property => 0,
       allows_composition => 0,
       allows_property_value => 1,
      },
     },

     {
      name => 'ontology_3',
      library => $self->get_test_library_1,
      file_list =>
      [
       'library/ontology_rules_sml.conf',
       'library/ontology_rules_lib.conf',
      ],
      entity_name => 'problem',
      property_name => 'status',
      property_value => 'pink',
      expected =>
      {
       allows_property_value => 0,
       property_is_universal => 0,
       property_is_imply_only => 0,
       property_allows_cardinality => 1,
      },
     },

     {
      name => 'ontology_4',
      library => $self->get_test_library_1,
      file_list =>
      [
       'library/ontology_rules_sml.conf',
       'library/ontology_rules_lib.conf',
      ],
      property_name => 'glossary',
      expected =>
      {
       property_is_universal => 1,
      },
     },

     {
      name => 'ontology_3',
      library => $self->get_test_library_1,
      file_list =>
      [
       'library/ontology_rules_sml.conf',
       'library/ontology_rules_lib.conf',
      ],
      entity_name => 'problem',
      property_name => 'child',
      expected =>
      {
       property_is_imply_only => 1,
       property_allows_cardinality => 'many',
      },
     },

    ];
}

######################################################################

sub _build_parser_test_case_list {

  my $self = shift;

  return
    [
     {
      name     => 'simple_fragment',
      testfile => 'td-000001.txt',
      docid    => 'td-000001',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_comment_division',
      testfile => 'td-000002.txt',
      docid    => 'td-000002',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_comment_line',
      testfile => 'td-000003.txt',
      docid    => 'td-000003',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_conditional_division',
      testfile => 'td-000004.txt',
      docid    => 'td-000004',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_region_division',
      testfile => 'td-000005.txt',
      docid    => 'td-000005',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_environment_division',
      testfile => 'td-000006.txt',
      docid    => 'td-000006',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_lists',
      testfile => 'td-000007.txt',
      docid    => 'td-000007',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_generate_element',
      testfile => 'td-000008.txt',
      docid    => 'td-000008',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_insert_element',
      testfile => 'td-000009.txt',
      docid    => 'td-000009',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_script_element',
      testfile => 'td-000010.txt',
      docid    => 'td-000010',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_image_element',
      testfile => 'td-000011.txt',
      docid    => 'td-000011',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_footnote_element',
      testfile => 'td-000012.txt',
      docid    => 'td-000012',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_glossary_element',
      testfile => 'td-000013.txt',
      docid    => 'td-000013',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_var_element',
      testfile => 'td-000014.txt',
      docid    => 'td-000014',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_acronym_element',
      testfile => 'td-000015.txt',
      docid    => 'td-000015',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_index_element',
      testfile => 'td-000016.txt',
      docid    => 'td-000016',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_index_element',
      testfile => 'td-000017.txt',
      docid    => 'td-000017',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_included_section_style_1',
      testfile => 'td-000018.txt',
      docid    => 'td-000018',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_included_section_style_2',
      testfile => 'td-000019.txt',
      docid    => 'td-000019',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_sections_and_regions',
      testfile => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_raw_include_element',
      testfile => 'td-000021.txt',
      docid    => 'td-000021',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_problem_division',
      testfile => 'td-000022.txt',
      expected =>
      {
       create_fragment => 'SML::Fragment',
       extract_division_name  => 'problem',
       extract_title_text    => 'Sample Problem For `Include\' Tests',
       extract_preamble_lines  => 17,
       extract_narrative_lines => 8,
      }
     },

     {
      name     => 'fragment_containing_included_entity',
      testfile => 'td-000023.txt',
      docid    => 'td-000023',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'single_paragraph',
      testfile => 'td-000024.txt',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_variable_substitutions',
      testfile => 'td-000025.txt',
      docid    => 'td-000025',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_glossary_term_reference_1',
      testfile => 'td-000026.txt',
      docid    => 'td-000026',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_source_citation',
      testfile => 'td-000028.txt',
      docid    => 'td-000028',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_source_citation',
      testfile => 'td-000029.txt',
      docid    => 'td-000029',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     # {
     #  name     => 'fragment_containing_invalid_begin_region',
     #  testfile => 'td-000030.txt',
     #  docid    => 'td-000030',
     #  expected =>
     #  {
     #   create_fragment => 'SML::Fragment',
     #  },
     # },

     # {
     #  name     => 'fragment_containing_undefined_region',
     #  testfile => 'td-000031.txt',
     #  docid    => 'td-000031',
     #  expected =>
     #  {
     #   create_fragment => 'SML::Fragment',
     #  },
     # },

     {
      name     => 'fragment_containing_cross_reference',
      testfile => 'td-000032.txt',
      docid    => 'td-000032',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_cross_reference',
      testfile => 'td-000033.txt',
      docid    => 'td-000033',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_id_reference',
      testfile => 'td-000034.txt',
      docid    => 'td-000034',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_id_reference',
      testfile => 'td-000035.txt',
      docid    => 'td-000035',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_page_reference',
      testfile => 'td-000036.txt',
      docid    => 'td-000036',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_page_reference',
      testfile => 'td-000037.txt',
      docid    => 'td-000037',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_bold_markup',
      testfile => 'td-000038.txt',
      docid    => 'td-000038',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_bold_markup',
      testfile => 'td-000039.txt',
      docid    => 'td-000039',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_italics_markup',
      testfile => 'td-000040.txt',
      docid    => 'td-000040',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_italics_markup',
      testfile => 'td-000041.txt',
      docid    => 'td-000041',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_fixedwidth_markup',
      testfile => 'td-000042.txt',
      docid    => 'td-000042',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_fixedwidth_markup',
      testfile => 'td-000043.txt',
      docid    => 'td-000043',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_underline_markup',
      testfile => 'td-000044.txt',
      docid    => 'td-000044',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_underline_markup',
      testfile => 'td-000045.txt',
      docid    => 'td-000045',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_superscript_markup',
      testfile => 'td-000046.txt',
      docid    => 'td-000046',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_superscript_markup',
      testfile => 'td-000047.txt',
      docid    => 'td-000047',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_subscript_markup',
      testfile => 'td-000048.txt',
      docid    => 'td-000048',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_subscript_markup',
      testfile => 'td-000049.txt',
      docid    => 'td-000049',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_glossary_term_syntax',
      testfile => 'td-000050.txt',
      docid    => 'td-000050',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_glossary_definition_reference',
      testfile => 'td-000051.txt',
      docid    => 'td-000051',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_glossary_definition_reference_syntax',
      testfile => 'td-000052.txt',
      docid    => 'td-000052',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_acronym_reference',
      testfile => 'td-000053.txt',
      docid    => 'td-000053',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_acronym_reference_syntax',
      testfile => 'td-000054.txt',
      docid    => 'td-000054',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_source_citation',
      testfile => 'td-000055.txt',
      docid    => 'td-000055',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_source_citation_syntax',
      testfile => 'td-000056.txt',
      docid    => 'td-000056',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_cross_reference_syntax',
      testfile => 'td-000057.txt',
      docid    => 'td-000057',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_id_reference_syntax',
      testfile => 'td-000058.txt',
      docid    => 'td-000058',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_page_reference_syntax',
      testfile => 'td-000059.txt',
      docid    => 'td-000059',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_template',
      testfile => 'td-000060.txt',
      docid    => 'td-000060',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_default_includes',
      testfile => 'td-000061.txt',
      docid    => 'td-000061',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_source_references',
      testfile => 'td-000062.txt',
      docid    => 'td-000062',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_explicit_declaration_of_infer_only_property',
      testfile => 'td-000063.txt',
      docid    => 'td-000063',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_entity_with_missing_required_property',
      testfile => 'td-000064.txt',
      docid    => 'td-000064',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_file_element',
      testfile => 'td-000065.txt',
      docid    => 'td-000065',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_reference_to_missing_file',
      testfile => 'td-000066.txt',
      docid    => 'td-000066',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_image_element',
      testfile => 'td-000067.txt',
      docid    => 'td-000067',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_reference_to_missing_image_file',
      testfile => 'td-000068.txt',
      docid    => 'td-000068',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_block_content',
      testfile => 'td-000069.txt',
      docid    => 'td-000069',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_invalid_non_unique_id',
      testfile => 'td-000070.txt',
      docid    => 'td-000070',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_baretable',
      testfile => 'td-000071.txt',
      docid    => 'td-000071',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_many_block_and_string_samples',
      testfile => 'td-000072.txt',
      docid    => 'td-000072',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_include_from_subdir',
      testfile => 'td-000073.txt',
      docid    => 'td-000073',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_divisions_for_extraction',
      testfile => 'td-000074.txt',
      docid    => 'td-000074',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_listing_environment',
      testfile => 'td-000075.txt',
      expected =>
      {
       create_fragment => 'SML::Fragment',
       extract_division_name  => 'LISTING',
       extract_title_text    => 'Sample Listing',
       extract_preamble_lines  => 5,
       extract_narrative_lines => 32,
      }
     },

     {
      name     => 'fragment_containing_section',
      testfile => 'td-000076.txt',
      expected =>
      {
       create_fragment => 'SML::Fragment',
       extract_division_name  => 'SECTION',
       extract_title_text    => 'Section Fragment',
       extract_preamble_lines  => 1,
      }
     },

     {
      name     => 'fragment_containing_glossary_term_reference_2',
      testfile => 'td-000077.txt',
      docid    => 'td-000077',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

     {
      name     => 'fragment_containing_title_with_linebreak',
      testfile => 'td-000078.txt',
      docid    => 'td-000078',
      expected =>
      {
       create_fragment => 'SML::Fragment',
      },
     },

    ];
}

######################################################################

sub _build_part_test_case_list {

  my $self = shift;

  return
    [
     {
      name     => 'part_test_1',
      part_id  => 'introduction',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       has_part => 1,
       get_part => 'SML::Section',
      },
     },

     {
      name     => 'part_test_2',
      part_id  => 'problem-1',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       has_part => 1,
       get_part => 'SML::Entity',
      },
     },

     {
      name     => 'part_test_3',
      part_id  => 'bogus_id',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       has_part => 0,
      },
     },

    ];
}

######################################################################

sub _build_string_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'plain_string_1',
      text => 'This is a plain string.',
      expected =>
      {
       get_name => 'string',
       get_content => 'This is a plain string.',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => 'This is a plain string.',
	},
       },
      },
     },

     {
      name => 'bold_string_1',
      text => '!!this is bold!!',
      expected =>
      {
       get_name => 'bold_string',
       get_content => 'this is bold',
       has_parts => 1,
       render =>
       {
	html =>
	{
	 default => '<b>this is bold</b>',
	},
       },
      },
     },

     {
      name => 'italics_string_1',
      text => '~~this is italics~~',
      expected =>
      {
       get_name => 'italics_string',
       get_content => 'this is italics',
       has_parts => 1,
       render =>
       {
	html =>
	{
	 default => '<i>this is italics</i>',
	},
       },
      },
     },

     {
      name => 'fixed_width_string_1',
      text => '||this is fixed width||',
      expected =>
      {
       get_name => 'fixedwidth_string',
       get_content => 'this is fixed width',
       has_parts => 1,
       render =>
       {
	html =>
	{
	 default => '<tt>this is fixed width</tt>',
	},
       },
      },
     },

     {
      name => 'underline_string_1',
      text => '__this is underlined__',
      expected =>
      {
       get_name => 'underline_string',
       get_content => 'this is underlined',
       has_parts => 1,
       render =>
       {
	html =>
	{
	 default => '<u>this is underlined</u>',
	},
       },
      },
     },

     {
      name => 'superscript_string_1',
      text => '^^this is superscripted^^',
      expected =>
      {
       get_name => 'superscript_string',
       get_content => 'this is superscripted',
       has_parts => 1,
       render =>
       {
	html =>
	{
	 default => '<sup>this is superscripted</sup>',
	},
       },
      },
     },

     {
      name => 'subscript_string_1',
      text => ',,this is subscripted,,',
      expected =>
      {
       get_name => 'subscript_string',
       get_content => 'this is subscripted',
       has_parts => 1,
       render =>
       {
	html =>
	{
	 default => '<sub>this is subscripted</sub>',
	},
       },
      },
     },

     {
      name => 'linebreak_symbol_1',
      text => '[linebreak]',
      expected =>
      {
       get_name => 'linebreak_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '<br/>',
	},
       },
      },
     },

     {
      name => 'user_entered_text_1',
      text => '[enter:bogus]',
      expected =>
      {
       get_name => 'USER_ENTERED_TEXT',
       get_content => 'bogus',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '<b><tt>bogus</tt></b>',
	},
       },
      },
     },

     {
      name => 'user_entered_text_2',
      text => '[en:bogus]',
      expected =>
      {
       get_name => 'USER_ENTERED_TEXT',
       get_content => 'bogus',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '<b><tt>bogus</tt></b>',
	},
       },
      },
     },

     {
      name => 'file_reference_1',
      text => '[file:bogus.txt]',
      expected =>
      {
       get_name => 'FILE_REF',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '<tt>bogus.txt</tt>',
	},
       },
      },
     },

     {
      name => 'path_reference_1',
      text => '[path:path/to/bogus]',
      expected =>
      {
       get_name => 'PATH_REF',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '<tt>path/to/bogus</tt>',
	},
       },
      },
     },

     {
      name => 'url_reference_1',
      text => '[url:http://www.google.com/]',
      expected =>
      {
       get_name => 'URL_REF',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '<a href="http://www.google.com/">http://www.google.com/</a>',
	},
       },
      },
     },

     {
      name => 'url_reference_2',
      text => '[url:http://www.google.com/|google]',
      expected =>
      {
       get_name => 'URL_REF',
       get_content => 'google',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '<a href="http://www.google.com/">google</a>',
	},
       },
      },
     },

     {
      name => 'command_reference_1',
      text => '[cmd:ls -al | grep bogus]',
      expected =>
      {
       get_name => 'COMMAND_REF',
       get_content => 'ls -al | grep bogus',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '<tt>ls -al | grep bogus</tt>',
	},
       },
      },
     },

     {
      name => 'smiley_symbol_1',
      text => ':-)',
      expected =>
      {
       get_name => 'smiley_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&#9786;',
	},
       },
      },
     },

     {
      name => 'frowny_symbol_1',
      text => ':-(',
      expected =>
      {
       get_name => 'frowny_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&#9785;',
	},
       },
      },
     },

     {
      name => 'keystroke_symbol_1',
      text => '[[ESC]]',
      expected =>
      {
       get_name => 'keystroke_symbol',
       get_content => 'ESC',
       has_parts => 1,
       render =>
       {
	html =>
	{
	 default => '<span class="keystroke">ESC</span>',
	},
       },
      },
     },

     {
      name => 'left_arrow_symbol_1',
      text => '<-',
      expected =>
      {
       get_name => 'left_arrow_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&#8592;',
	},
       },
      },
     },

     {
      name => 'right_arrow_symbol_1',
      text => '->',
      expected =>
      {
       get_name => 'right_arrow_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&#8594;',
	},
       },
      },
     },

     {
      name => 'latex_symbol_1',
      text => 'LaTeX',
      expected =>
      {
       get_name => 'latex_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => 'L<sup>a</sup>T<sub>e</sub>X',
	},
       },
      },
     },

     {
      name => 'tex_symbol_1',
      text => 'TeX',
      expected =>
      {
       get_name => 'tex_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => 'T<sub>e</sub>X',
	},
       },
      },
     },

     {
      name => 'copyright_symbol_1',
      text => '[c]',
      expected =>
      {
       get_name => 'copyright_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&copy;',
	},
       },
      },
     },

     {
      name => 'trademark_symbol_1',
      text => '[tm]',
      expected =>
      {
       get_name => 'trademark_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&trade;',
	},
       },
      },
     },

     {
      name => 'registered_trademark_symbol_1',
      text => '[rtm]',
      expected =>
      {
       get_name => 'reg_trademark_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&reg;',
	},
       },
      },
     },

     {
      name => 'open_dblquote_symbol_1',
      text => '``',
      expected =>
      {
       get_name => 'open_dblquote_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&#8220;',
	},
       },
      },
     },

     {
      name => 'close_dblquote_symbol_1',
      text => '\'\'',
      expected =>
      {
       get_name => 'close_dblquote_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&#8221;',
	},
       },
      },
     },

     {
      name => 'open_sglquote_symbol_1',
      text => '`',
      expected =>
      {
       get_name => 'open_sglquote_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&#8216;',
	},
       },
      },
     },

     {
      name => 'close_sglquote_symbol_1',
      text => '\'',
      expected =>
      {
       get_name => 'close_sglquote_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&#8217;',
	},
       },
      },
     },

     {
      name => 'section_symbol_1',
      text => '[section]',
      expected =>
      {
       get_name => 'section_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&sect;',
	},
       },
      },
     },

     {
      name => 'emdash_symbol_1',
      text => '--',
      expected =>
      {
       get_name => 'emdash_symbol',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '&mdash;',
	},
       },
      },
     },

     {
      name => 'email_address_1',
      text => '[email:help@example.com]',
      expected =>
      {
       get_name => 'EMAIL_ADDR',
       get_content => '',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '<a href="mailto:help@example.com">help@example.com</a>',
	},
       },
      },
     },

     {
      name => 'email_address_2',
      text => '[email:john.smith@example.com|John Smith]',
      expected =>
      {
       get_name => 'EMAIL_ADDR',
       get_content => 'John Smith',
       has_parts => 0,
       render =>
       {
	html =>
	{
	 default => '<a href="mailto:john.smith@example.com">John Smith</a>',
	},
       },
      },
     },

     {
      name => 'bold_inside_italics_1',
      text => '~~this is !!bold!! inside italics~~',
      expected =>
      {
       get_name => 'italics_string',
       get_content => 'this is !!bold!! inside italics',
       has_parts => 3,
       render =>
       {
	html =>
	{
	 default => '<i>this is <b>bold</b> inside italics</i>',
	},
       },
      },
     },

     {
      name => 'italics_inside_bold_1',
      text => '!!this is ~~italics~~ inside bold!!',
      expected =>
      {
       get_name => 'bold_string',
       get_content => 'this is ~~italics~~ inside bold',
       has_parts => 3,
       render =>
       {
	html =>
	{
	 default => '<b>this is <i>italics</i> inside bold</b>',
	},
       },
      },
     },

     {
      name => 'string_with_italics_and_bold_1',
      text => 'this string has ~~italics~~ and !!bold!!',
      expected =>
      {
       get_name => 'string',
       get_content => 'this string has ~~italics~~ and !!bold!!',
       has_parts => 4,
       render =>
       {
	html =>
	{
	 default => 'this string has <i>italics</i> and <b>bold</b>',
	},
       },
      },
     },

     {
      name => 'variable_reference_1',
      text => '[var:bogus]',
      expected =>
      {
       get_name => 'VARIABLE_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'glossary_term_reference_1',
      text => '[g:bogus]',
      expected =>
      {
       get_name => 'GLOSS_TERM_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'glossary_term_reference_2',
      text => '[G:bogus]',
      expected =>
      {
       get_name => 'GLOSS_TERM_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'glossary_term_reference_3',
      text => '[gls:bogus]',
      expected =>
      {
       get_name => 'GLOSS_TERM_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'glossary_term_reference_4',
      text => '[Gls:bogus]',
      expected =>
      {
       get_name => 'GLOSS_TERM_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'glossary_definition_reference_1',
      text => '[def:bogus]',
      expected =>
      {
       get_name => 'GLOSS_DEF_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'acronym_term_reference_1',
      text => '[a:bogus]',
      expected =>
      {
       get_name => 'ACRONYM_TERM_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'acronym_term_reference_2',
      text => '[ac:bogus]',
      expected =>
      {
       get_name => 'ACRONYM_TERM_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'acronym_term_reference_3',
      text => '[acs:bogus]',
      expected =>
      {
       get_name => 'ACRONYM_TERM_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'acronym_term_reference_4',
      text => '[acl:bogus]',
      expected =>
      {
       get_name => 'ACRONYM_TERM_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'cross_reference_1',
      text => '[r:bogus]',
      expected =>
      {
       get_name => 'CROSS_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'cross_reference_2',
      text => '[ref:bogus]',
      expected =>
      {
       get_name => 'CROSS_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'id_reference_1',
      text => '[id:bogus]',
      expected =>
      {
       get_name => 'ID_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'page_reference_1',
      text => '[page:bogus]',
      expected =>
      {
       get_name => 'PAGE_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'page_reference_2',
      text => '[pg:bogus]',
      expected =>
      {
       get_name => 'PAGE_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'footnote_reference_1',
      text => '[f:introduction:1]',
      expected =>
      {
       get_name => 'FOOTNOTE_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'index_reference_1',
      text => '[index:bogus]',
      expected =>
      {
       get_name => 'INDEX_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'index_reference_2',
      text => '[i:bogus]',
      expected =>
      {
       get_name => 'INDEX_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'thepage_symbol_1',
      text => '[thepage]',
      expected =>
      {
       get_name => 'thepage_ref',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'theversion_symbol_1',
      text => '[theversion]',
      expected =>
      {
       get_name => 'theversion_ref',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'therevision_symbol_1',
      text => '[therevision]',
      expected =>
      {
       get_name => 'therevision_ref',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'thedate_symbol_1',
      text => '[thedate]',
      expected =>
      {
       get_name => 'thedate_ref',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'status_reference_1',
      text => '[status:bogus]',
      expected =>
      {
       get_name => 'STATUS_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'citation_reference_1',
      text => '[cite:bogus]',
      expected =>
      {
       get_name => 'CITATION_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'citation_reference_2',
      text => '[c:bogus]',
      expected =>
      {
       get_name => 'CITATION_REF',
       get_content => '',
       has_parts => 0,
      },
     },

     {
      name => 'take_note_symbol_1',
      text => '[take_note]',
      expected =>
      {
       get_name => 'take_note_symbol',
       get_content => '',
       has_parts => 0,
      },
     },

    ];
}

######################################################################

sub _build_test_data_test_case_list {

  my $self = shift;

  return
    [
     {
      name        => 'test_data_1',
      object_type => 'SML::Note',
      object_name => '1',
      test_data   => $self,
      expected =>
      {
       get_test_object => 'SML::Note',
      },
     },

     {
      name        => 'test_data_2',
      object_type => 'SML::Document',
      object_name => 'td-000020',
      test_data   => $self,
      expected =>
      {
       get_test_object => 'SML::Document',
      },
     },
    ];
}

######################################################################

sub _build_test_object_hash {

  # The test object hash built by this private method provides
  # known-good objects for unit testing.

  my $self = shift;

  my $toh  = {};                        # test object hash

  use SML::Library;
  use SML::Document;
  use SML::Definition;
  use SML::Note;

  #-------------------------------------------------------------------
  # library object
  {
    my $library = SML::Library->new(config_filename=>'library.conf');
    $toh->{'SML::Library'}{library} = $library;
  }

  #-------------------------------------------------------------------
  # document objects
  {
    my $library  = SML::Library->new(config_filename=>'library.conf');
    my $parser   = $library->get_parser;
    my $fragment = $parser->create_fragment('td-000020.txt');
    my $document = $library->get_document('td-000020');

    $toh->{'SML::Document'}{'td-000020'} = $document;
  }

  #-------------------------------------------------------------------
  # definition objects
  {
    my $library = $toh->{'SML::Library'}{library};

    my $pair_list =
      [
       ['tla' => 'acronym:: TLA = Three Letter Acronym'],
       ['fla' => 'acronym:: FLA = Four Letter Acronym'],
       ['sla' => 'acronym:: SLA = Six Letter Acronym'],
       ['frd' => 'acronym:: FRD {ieee} = (IEEE) Functional Requirements Document'],
      ];

    foreach my $pair (@{ $pair_list })
      {
	my $name = $pair->[0];
	my $text = $pair->[1];
	my $line = SML::Line->new(content=>$text);
	my $definition = SML::Definition->new(name=>'acronym',library=>$library);

	$definition->add_line($line);

	$toh->{'SML::Definition'}{$name} = $definition;
      }
  }

  #-------------------------------------------------------------------
  # note objects
  {
    my $library = $toh->{'SML::Library'}{library};

    my $pair_list =
      [
       ['1','note::1: This is a note.'],
       ['2','note::2:intro: This is a note with a division ID.'],
      ];

    foreach my $pair (@{ $pair_list })
      {
	my $name = $pair->[0];
	my $text = $pair->[1];
	my $line = SML::Line->new(content=>$text);
	my $args = {};

	$args->{name}    = 'note';
	$args->{tag}     = $name;
	$args->{library} = $library;

	my $note = SML::Note->new(%{$args});

	$note->add_line($line);

	$toh->{'SML::Note'}{$name} = $note;
      }
  }

  return $toh;
}

######################################################################

sub _build_test_library_1 {

  return SML::Library->new(config_filename=>'library.conf');
}

######################################################################

sub _build_test_document_1 {

  my $self = shift;

  my $library  = $self->get_test_library_1;
  my $parser   = $library->get_parser;
  my $fragment = $parser->create_fragment('td-000020.txt');

  return $library->get_document('td-000020');
}

######################################################################

sub _build_test_definition_1 {

  my $self = shift;

  my $text    = 'acronym:: TLA = Three Letter Acronym';
  my $library = $self->get_test_library_1;

  my $definition = SML::Definition->new
    (
     name    => 'acronym',
     library => $library
    );

  my $line = SML::Line->new(content=>$text);

  $definition->add_line($line);

  return $definition;
}

######################################################################

sub _build_test_definition_2 {

  my $self = shift;

  my $text    = 'acronym:: FLA = Four Letter Acronym';
  my $library = $self->get_test_library_1;

  my $definition = SML::Definition->new
    (
     name    => 'acronym',
     library => $library
    );

  my $line = SML::Line->new(content=>$text);

  $definition->add_line($line);

  return $definition;
}

######################################################################

sub _build_test_definition_3 {

  my $self = shift;

  my $text    = 'acronym:: SLA = Six Letter Acronym';
  my $library = $self->get_test_library_1;

  my $definition = SML::Definition->new
    (
     name    => 'acronym',
     library => $library
    );

  my $line = SML::Line->new(content=>$text);

  $definition->add_line($line);

  return $definition;
}

######################################################################

sub _build_test_definition_4 {

  my $self = shift;

  my $text    = 'acronym:: FRD {ieee} = (IEEE) Functional Requirements Document';
  my $library = $self->get_test_library_1;

  my $definition = SML::Definition->new
    (
     name    => 'acronym',
     library => $library
    );

  my $line = SML::Line->new(content=>$text);

  $definition->add_line($line);

  return $definition;
}

######################################################################

sub _build_test_note_1 {

  my $self = shift;

  my $text = 'note::1: This is a note.';
  my $args = {};

  $args->{tag}     = '1';
  $args->{library} = $self->get_test_library_1;

  my $note = SML::Note->new(%{$args});

  my $line = SML::Line->new(content=>$text);

  $note->add_line($line);

  return $note;
}

######################################################################

sub _build_test_note_2 {

  my $self = shift;

  my $text = 'note::2:intro: This is a note with a division ID.';
  my $args = {};

  $args->{tag}     = '2';
  $args->{library} = $self->get_test_library_1;

  my $note = SML::Note->new(%{$args});

  my $line = SML::Line->new(content=>$text);

  $note->add_line($line);

  return $note;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;
