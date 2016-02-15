#!/usr/bin/perl

package SML::TestData;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Cwd;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.TestData');

use File::Slurp;

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

has triple_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_triple_test_case_list',
   lazy    => 1,
   builder => '_build_triple_test_case_list',
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

# has fragment_test_case_list =>
#   (
#    is      => 'ro',
#    isa     => 'ArrayRef',
#    reader  => 'get_fragment_test_case_list',
#    lazy    => 1,
#    builder => '_build_fragment_test_case_list',
#   );

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

######################################################################

has publisher_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_publisher_test_case_list',
   lazy    => 1,
   builder => '_build_publisher_test_case_list',
  );

######################################################################

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

######################################################################

has symbol_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_symbol_test_case_list',
   lazy    => 1,
   builder => '_build_symbol_test_case_list',
  );

######################################################################
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

has test_library_2 =>
  (
   is      => 'ro',
   isa     => 'SML::Library',
   reader  => 'get_test_library_2',
   lazy    => 1,
   builder => '_build_test_library_2',
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
      namespace => '',
      expected =>
      {
       add_entry => 1,
       has_entry => 1,
       get_entry => 'SML::Definition',
      },
     },

     {
      name => 'acronym_2',
      definition => $self->get_test_definition_4,
      acronym => 'FRD',
      namespace => 'ieee',
      expected =>
      {
       add_entry => 1,
       has_entry => 1,
       get_entry => 'SML::Definition',
      }
     },

     {
      name => 'acronym_3',
      definition => $self->get_test_definition_3,
      acronym => 'bogus',
      namespace => '',
      expected =>
      {
       add_entry => 1,
       has_entry => 0,
       get_entry => '',
      }
     },

     {
      name => 'bad_acronym_1',
      definition => 'bogus definition',
      acronym => 'bogus',
      namespace => '',
      expected =>
      {
       error =>
       {
	add_entry => 'NOT A DEFINITION',
       },
      }
     },

     {
      name => 'bad_acronym_2',
      acronym => 'bogus',
      namespace => '',
      expected =>
      {
       warning =>
       {
	get_entry => 'FAILED ACRONYM LOOKUP',
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
       get_entry => 'TLA',
       get_namespace => '',
      },
     },
    ];
}

######################################################################

sub _build_triple_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'triple_1',
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
      name => 'triple_2',
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
      document => $self->get_test_document_1,
      expected =>
      {
       contains_parts => 1,
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.1.html#SECTION.1\">Section 1</a></p>\n\n",
	},
	latex =>
	{
	 default => "Section~\\vref{introduction}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.1.xml#SECTION.1\">Section 1</a>\n\n",
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.1.html#SECTION.1\">Section 1</a></p>\n\n",
	},
	latex =>
	{
	 default => "Section~\\vref{introduction}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.1.xml#SECTION.1\">Section 1</a>\n\n",
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.2.html#SECTION.2\">Section 2</a></p>\n\n",
	},
	latex =>
	{
	 default => "Section~\\vref{system-model}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.2.html#Section.2\">Section 2</a>\n\n",
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.2.html#SECTION.2\">Section 2</a></p>\n\n",
	},
	latex =>
	{
	 default => "Section~\\vref{system-model}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.2.html#Section.2\">Section 2</a>\n\n",
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><span style=\"font-size:8pt;\"><a href=\"#footnote.introduction.1\"><sup>[1]<\/sup><\/a><\/span></p>\n\n",
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.1.html#SECTION.1\">introduction</a></p>\n\n",
	},
	latex =>
	{
	 default => "\\hyperref[introduction]{introduction}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.1.html#SECTION.1\">Section 1</a>\n\n",
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.1.html#SECTION.1\">link</a></p>\n\n",
	},
	latex =>
	{
	 default => "p. \\pageref{introduction}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.1.html#SECTION.1\">link</a>\n\n",
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.1.html#SECTION.1\">link</a></p>\n\n",
	},
	latex =>
	{
	 default => "p. \\pageref{introduction}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.1.html#SECTION.1\">link</a>\n\n",
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
	 default => "\\today\n\n",
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"images/status_yellow.png\" border=\"0\"/></p>\n\n",
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"images/status_grey.png\" border=\"0\"/></p>\n\n",
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"images/status_green.png\" border=\"0\"/></p>\n\n",
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"images/status_yellow.png\" border=\"0\"/></p>\n\n",
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"images/status_red.png\" border=\"0\"/></p>\n\n",
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
      content  => '[status:problem-20-1]',
      subclass => 'SML::Paragraph',
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><image src=\"images/status_green.png\" border=\"0\"/></p>\n\n",
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>[<a href=\"td-000020.references.html#cms15\">cms15</a>]</p>\n\n",
	},
	latex =>
	{
	 default => "\\cite{cms15}\n\n",
	},
	xml =>
	{
	 default => "[<a href=\"td-000020.references.html#cms15\">cms15</a>]\n\n",
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>[<a href=\"td-000020.references.html#cms15\">cms15, pg 44</a>]</p>\n\n",
	},
	latex =>
	{
	 default => "\\cite[pg 44]{cms15}\n\n",
	},
	xml =>
	{
	 default => "[<a href=\"td-000020.references.html#cms15\">cms15, pg 44</a>]\n\n",
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p>&lt;para style=&quot;indented&quot;&gt;</p>\n\n",
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
	 default => "\\href{mailto:joe\@example.com}{joe\@example.com}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"mailto:joe\@example.com\">joe\@example.com</a>\n\n",
	},
       },
      },
     },

     {
      name     => 'bold_1',
      content  => '!!bold text!!',
      subclass => 'SML::Paragraph',
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_bold_block',
      content  => 'This is an INVALID !!bold block',
      subclass => 'SML::Paragraph',
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_italics_block',
      content  => 'This is an INVALID ~~italics block',
      subclass => 'SML::Paragraph',
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_fixedwidth_block',
      content  => 'This is an INVALID ||fixed-width block',
      subclass => 'SML::Paragraph',
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_underline_block',
      content  => 'This is an INVALID __underline block',
      subclass => 'SML::Paragraph',
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_superscript_block',
      content  => 'This is an INVALID ^^superscript block',
      subclass => 'SML::Paragraph',
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
      expected =>
      {
       has_valid_syntax => 1,
      },
     },

     {
      name     => 'invalid_subscript_block',
      content  => 'This is an INVALID ,,subscript block',
      subclass => 'SML::Paragraph',
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
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
      document => $self->get_test_document_1,
      expected =>
      {
       has_valid_syntax => 0,
       has_valid_semantics => 1,
       valid_syntax_warning => 'INVALID SOURCE CITATION SYNTAX',
      },
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
      library => $self->get_test_library_1,
      leading_whitespace => '',
      expected =>
      {
       get_value => 'top level item',
      },
     },

     {
      name => 'indented_item',
      line => SML::Line->new(content=>'  - indented item'),
      library => $self->get_test_library_1,
      leading_whitespace => '  ',
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
      library => $self->get_test_library_1,
      expected =>
      {
       get_term => 'term 1',
       get_definition => 'definition of term 1',
      },
     },

     {
      name => 'bad_definition_list_item_1',
      line => SML::Line->new(content=>'This is not a definition list item'),
      library => $self->get_test_library_1,
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
      name => 'glossary',
      library => $self->get_test_library_1,
      expected =>
      {
       get_term => 'BPEL',
       get_namespace => '',
       get_definition => 'Business Process Execution Language',
       get_bookmark => 'bpel',
      },
     },

     {
      name => 'definition_2',
      line => SML::Line->new(content=>'glossary:: FRD {ieee} = (IEEE) Functional Requirements Document'),
      name => 'glossary',
      library => $self->get_test_library_1,
      expected =>
      {
       get_term => 'FRD',
       get_namespace => 'ieee',
       get_definition => '(IEEE) Functional Requirements Document',
       get_bookmark => 'frd:ieee',
      },
     },

     {
      name => 'bad_definition_1',
      line => SML::Line->new(content=>'This is not a definition'),
      name => 'glossary',
      library => $self->get_test_library_1,
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
      library => $self->get_test_library_1,
      divid => 'td',
      division_name => 'test-division',
      division_number => '4-4-4',
      expected =>
      {
       init       => 1,
       get_id     => 'td',
       get_name   => 'test-division',
       get_number => '4-4-4',
      }
     },

     {
      name => 'division_2',
      library => $self->get_test_library_1,
      divid => 'td-000020',
      property_name => 'title',
      expected  =>
      {
       get_first_part          => 'SML::PreformattedBlock',
       get_property            => 'SML::Property',
       get_property_value      => 'Section Structure With Regions',
       get_first_line          => '>>>DOCUMENT.td-000020',
       get_part_list           => 20,
       get_line_list           => 198,
       get_division_list       => 32,
       get_section_list        => 5,
       get_block_list          => 85,
       get_element_list        => 31,
       get_data_segment_line_list  => 12,
       get_narrative_line_list => 183,
       get_property_list       => 9,
      },
     },

     {
      name => 'division_3',
      library => $self->get_test_library_1,
      divid => 'introduction',
      property_name => 'type',
      expected =>
      {
       get_containing_division => 'SML::Document',
       get_first_part          => 'SML::Element',
       get_property            => 'SML::Property',
       get_property_value      => 'chapter',
       get_first_line          => '*.introduction Introduction',
       get_part_list           => 6,
       get_line_list           => 15,
       get_division_list       => 0,
       get_block_list          => 6,
       get_element_list        => 3,
       get_data_segment_line_list  => 2,
       get_narrative_line_list => 9,
       get_property_list       => 4,
      },
     },

     {
      name => 'division_4',
      library => $self->get_test_library_1,
      divid => 'problem-20-1',
      property_name => 'title',
      expected =>
      {
       get_containing_division => 'SML::Section',
       get_first_part          => 'SML::PreformattedBlock',
       get_property            => 'SML::Property',
       get_property_value      => 'Problem One',
       get_first_line          => '>>>problem.problem-20-1',
       get_part_list           => 11,
       get_line_list           => 42,
       get_division_list       => 10,
       get_block_list          => 19,
       get_element_list        => 5,
       get_data_segment_line_list  => 10,
       get_narrative_line_list => 28,
       get_property_list       => 6,
      },
     },

     {
      name => 'division_5',
      library => $self->get_test_library_1,
      divid => 'tab-solution-types',
      property_name => 'id',
      expected =>
      {
       get_containing_division => 'SML::Section',
       get_first_part          => 'SML::PreformattedBlock',
       get_property            => 'SML::Property',
       get_property_value      => 'tab-solution-types',
       get_first_line          => '>>>TABLE.tab-solution-types',
       get_part_list           => 11,
       get_line_list           => 30,
       get_division_list       => 12,
       get_block_list          => 15,
       get_element_list        => 1,
       get_data_segment_line_list  => 2,
       get_narrative_line_list => 24,
       get_property_list       => 2,
      },
     },

     {
      name => 'invalid_semantics_division_1',
      library => $self->get_test_library_1,
      divid => 'td-000063',
      expected =>
      {
       warning =>
       {
	is_valid => 'INVALID EXPLICIT DECLARATION OF INFER-ONLY PROPERTY',
       },
      },
     },

     {
      name => 'invalid_semantics_division_2',
      library => $self->get_test_library_1,
      divid => 'problem-1',
      expected =>
      {
       warning =>
       {
	is_valid => 'MISSING REQUIRED PROPERTY',
       },
      },
     },

     {
      name => 'invalid_semantics_division_4',
      library => $self->get_test_library_1,
      divid => 'problem-79-1',
      expected =>
      {
       warning =>
       {
	is_valid => 'INVALID PROPERTY MULTIPLICITY',
       },
      },
     },

     {
      name => 'invalid_semantics_division_5',
      library => $self->get_test_library_1,
      divid => 'problem-80-1',
      expected =>
      {
       warning =>
       {
	is_valid => 'INVALID PROPERTY VALUE',
       },
      },
     },

     {
      name => 'invalid_semantics_division_6',
      library => $self->get_test_library_1,
      divid => 'solution-81-1',
      expected =>
      {
       warning =>
       {
	is_valid => 'INVALID COMPOSITION',
       },
      },
     },
    ];
}

######################################################################

sub _build_document_test_case_list {

  my $self = shift;

  return
    [
     {
      # Simple Document With One Paragraph
      name     => 'td-000001',
      testfile => 'td-000001.txt',
      docid    => 'td-000001',
      library  => $self->get_test_library_1,
      expected =>
      {
       dump_part_structure => slurp('expected/part-structure/td-000001.txt'),
       get_glossary => 'SML::Glossary',
       is_valid => 1,
       render =>
       {
	sml =>
	{
	 default => slurp('expected/sml/default/td-000001.txt'),
	},
       },
      },
     },

     {
      # Comment Division
      name     => 'td-000002',
      testfile => 'td-000002.txt',
      docid    => 'td-000002',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000002.txt'),
       render =>
       {
	sml =>
	{
	 default => slurp('expected/sml/default/td-000002.txt'),
	},
       },
      },
     },

     {
      # Comment Line
      name     => 'td-000003',
      testfile => 'td-000003.txt',
      docid    => 'td-000003',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000003.txt'),
       render =>
       {
	sml =>
	{
	 default => slurp('expected/sml/default/td-000003.txt'),
	},
       },
      },
     },

     {
      # Conditional Divisions
      name     => 'td-000004',
      testfile => 'td-000004.txt',
      docid    => 'td-000004',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000004.txt'),
       render =>
       {
	sml =>
	{
	 default => slurp('expected/sml/default/td-000004.txt'),
	},
       },
      },
     },

     {
      # Problem Region
      name     => 'td-000005',
      testfile => 'td-000005.txt',
      docid    => 'td-000005',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000005.txt'),
       render =>
       {
	sml =>
	{
	 default => slurp('expected/sml/default/td-000005.txt'),
	},
       },
      },
     },

     {
      # Listing Environment
      name     => 'td-000006',
      testfile => 'td-000006.txt',
      docid    => 'td-000006',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000006.txt'),
       render =>
       {
	sml =>
	{
	 default => slurp('expected/sml/default/td-000006.txt'),
	},
       },
      },
     },

     {
      # Lists
      name     => 'td-000007',
      testfile => 'td-000007.txt',
      docid    => 'td-000007',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000007.txt'),
       render =>
       {
	sml =>
	{
	 default => slurp('expected/sml/default/td-000007.txt'),
	},
       },
      },
     },

     # {
     #  # Generate Content
     #  name     => 'td-000008',
     #  testfile => 'td-000008.txt',
     #  docid    => 'td-000008',
     #  library  => $self->get_test_library_1,
     #  expected =>
     #  {
     #   is_valid => 1,
     #   dump_part_structure => slurp('expected/part-structure/td-000008.txt'),
     #  },
     # },

     {
      # Insert Content
      name     => 'td-000009',
      testfile => 'td-000009.txt',
      docid    => 'td-000009',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000009.txt'),
      },
     },

     {
      # Script Content
      name     => 'td-000010',
      testfile => 'td-000010.txt',
      docid    => 'td-000010',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000010.txt'),
      },
     },

     {
      # Image Element
      name     => 'td-000011',
      testfile => 'td-000011.txt',
      docid    => 'td-000011',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000011.txt'),
      },
     },

     {
      # Footnote Element
      name     => 'td-000012',
      testfile => 'td-000012.txt',
      docid    => 'td-000012',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000012.txt'),
       render =>
       {
	sml =>
	{
	 default => slurp('expected/sml/default/td-000012.txt'),
	},
       },
      },
     },

     {
      # Glossary Element
      name     => 'td-000013',
      testfile => 'td-000013.txt',
      docid    => 'td-000013',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000013.txt'),
      },
     },

     {
      # Var Element
      name     => 'td-000014',
      testfile => 'td-000014.txt',
      docid    => 'td-000014',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000014.txt'),
      },
     },

     {
      # Acronym Element
      name     => 'td-000015',
      testfile => 'td-000015.txt',
      docid    => 'td-000015',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000015.txt'),
      },
     },

     {
      # Index Element
      name     => 'td-000016',
      testfile => 'td-000016.txt',
      docid    => 'td-000016',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000016.txt'),
      },
     },

     {
      # Very Long Multi-Line Title
      name     => 'td-000017',
      testfile => 'td-000017.txt',
      docid    => 'td-000017',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       dump_part_structure => slurp('expected/part-structure/td-000017.txt'),
      },
     },

     {
      # Include File As A Section (Asterisk Argument Method)
      name     => 'td-000018',
      testfile => 'td-000018.txt',
      docid    => 'td-000018',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # Include File As A Section (Leading Asterisk Method)
      name     => 'td-000019',
      testfile => 'td-000019.txt',
      docid    => 'td-000019',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # Section Structure With Regions
      name     => 'td-000020',
      testfile => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # Include Raw Content
      name     => 'td-000021',
      testfile => 'td-000021.txt',
      docid    => 'td-000021',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # Include A Problem Region
      name     => 'td-000023',
      testfile => 'td-000023.txt',
      docid    => 'td-000023',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # Substitute Variables
      name     => 'td-000025',
      testfile => 'td-000025.txt',
      docid    => 'td-000025',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # Valid Glossary Term Reference
      name     => 'td-000026',
      testfile => 'td-000026.txt',
      docid    => 'td-000026',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID Glossary Term Reference
      name     => 'td-000027',
      testfile => 'td-000027.txt',
      docid    => 'td-000027',
      library  => $self->get_test_library_1,
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
      # Valid Source Citation
      name     => 'td-000028',
      testfile => 'td-000028.txt',
      docid    => 'td-000028',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID SOURCE CITATION, NOT A SOURCE DIVISION
      name     => 'td-000029',
      testfile => 'td-000029.txt',
      docid    => 'td-000029',
      library  => $self->get_test_library_1,
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
      # INVALID BEGIN REGION (DEMO inside LISTING)
      name     => 'td-000030',
      testfile => 'td-000030.txt',
      docid    => 'td-000030',
      library  => $self->get_test_library_1,
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

     # {
     #  # UNDEFINED REGION
     #  name     => 'td-000031',
     #  testfile => 'td-000031.txt',
     #  docid    => 'td-000031',
     #  library  => $self->get_test_library_2,
     #  expected =>
     #  {
     #   fatal =>
     #   {
     # 	is_valid =>
     # 	[
     # 	 ['sml.Parser' => 'UNDEFINED REGION'],
     # 	],
     #   }
     #  },
     # },

     {
      # Valid Cross Reference
      name     => 'td-000032',
      testfile => 'td-000032.txt',
      docid    => 'td-000032',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID CROSS REFERENCE
      name     => 'td-000033',
      testfile => 'td-000033.txt',
      docid    => 'td-000033',
      library  => $self->get_test_library_1,
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
      # Valid ID Reference
      name     => 'td-000034',
      testfile => 'td-000034.txt',
      docid    => 'td-000034',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID ID REFERENCE
      name     => 'td-000035',
      testfile => 'td-000035.txt',
      docid    => 'td-000035',
      library  => $self->get_test_library_1,
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
      # Valid Page Reference
      name     => 'td-000036',
      testfile => 'td-000036.txt',
      docid    => 'td-000036',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID PAGE REFERENCE
      name     => 'td-000037',
      testfile => 'td-000037.txt',
      docid    => 'td-000037',
      library  => $self->get_test_library_1,
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
      # Valid Bold Markup
      name     => 'td-000038',
      testfile => 'td-000038.txt',
      docid    => 'td-000038',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID BOLD MARKUP
      name     => 'td-000039',
      testfile => 'td-000039.txt',
      docid    => 'td-000039',
      library  => $self->get_test_library_1,
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
      # Valid Italics Markup
      name     => 'td-000040',
      testfile => 'td-000040.txt',
      docid    => 'td-000040',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID ITALICS MARKUP
      name     => 'td-000041',
      testfile => 'td-000041.txt',
      docid    => 'td-000041',
      library  => $self->get_test_library_1,
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
      # Valid Fixed-Width Markup
      name     => 'td-000042',
      testfile => 'td-000042.txt',
      docid    => 'td-000042',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID FIXED-WIDTH MARKUP
      name     => 'td-000043',
      testfile => 'td-000043.txt',
      docid    => 'td-000043',
      library  => $self->get_test_library_1,
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
      # Valid Underline Markup
      name     => 'td-000044',
      testfile => 'td-000044.txt',
      docid    => 'td-000044',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID UNDERLINE MARKUP
      name     => 'td-000045',
      testfile => 'td-000045.txt',
      docid    => 'td-000045',
      library  => $self->get_test_library_1,
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
      # Valid Superscript Markup
      name     => 'td-000046',
      testfile => 'td-000046.txt',
      docid    => 'td-000046',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID SUPERSCRIPT MARKUP
      name     => 'td-000047',
      testfile => 'td-000047.txt',
      docid    => 'td-000047',
      library  => $self->get_test_library_1,
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
      # Valid Subscript Markup
      name     => 'td-000048',
      testfile => 'td-000048.txt',
      docid    => 'td-000048',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID SUBSCRIPT MARKUP
      name     => 'td-000049',
      testfile => 'td-000049.txt',
      docid    => 'td-000049',
      library  => $self->get_test_library_1,
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
      # INVALID GLOSSARY TERM SYNTAX
      name     => 'td-000050',
      testfile => 'td-000050.txt',
      docid    => 'td-000050',
      library  => $self->get_test_library_1,
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
      # DEFINITION NOT IN GLOSSARY
      name     => 'td-000051',
      testfile => 'td-000051.txt',
      docid    => 'td-000051',
      library  => $self->get_test_library_1,
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
      # INVALID GLOSSARY DEFINITION REF SYNTAX
      name     => 'td-000052',
      testfile => 'td-000052.txt',
      docid    => 'td-000052',
      library  => $self->get_test_library_1,
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
      # ACRONYM NOT IN ACRONYM LIST
      name     => 'td-000053',
      testfile => 'td-000053.txt',
      docid    => 'td-000053',
      library  => $self->get_test_library_1,
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
      # INVALID ACRONYM REFERENCE SYNTAX
      name     => 'td-000054',
      testfile => 'td-000054.txt',
      docid    => 'td-000054',
      library  => $self->get_test_library_1,
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
      # INVALID SOURCE CITATION
      name     => 'td-000055',
      testfile => 'td-000055.txt',
      docid    => 'td-000055',
      library  => $self->get_test_library_1,
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
      # INVALID SOURCE CITATION SYNTAX
      name     => 'td-000056',
      testfile => 'td-000056.txt',
      docid    => 'td-000056',
      library  => $self->get_test_library_1,
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
      # INVALID CROSS REFERENCE SYNTAX
      name     => 'td-000057',
      testfile => 'td-000057.txt',
      docid    => 'td-000057',
      library  => $self->get_test_library_1,
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
      # INVALID ID REFERENCE SYNTAX
      name     => 'td-000058',
      testfile => 'td-000058.txt',
      docid    => 'td-000058',
      library  => $self->get_test_library_1,
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
      # INVALID PAGE REFERENCE SYNTAX
      name     => 'td-000059',
      testfile => 'td-000059.txt',
      docid    => 'td-000059',
      library  => $self->get_test_library_1,
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
      # Resolve Template
      name     => 'td-000060',
      testfile => 'td-000060.txt',
      docid    => 'td-000060',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # Include File Default Method
      name     => 'td-000061',
      testfile => 'td-000061.txt',
      docid    => 'td-000061',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
       render =>
       {
	sml =>
	{
	 default => slurp('expected/sml/default/td-000061.txt'),
	},
       },
      },
     },

     {
      # INVALID EXPLICIT DECLARATION OF INFER-ONLY PROPERTY
      name     => 'td-000063',
      testfile => 'td-000063.txt',
      docid    => 'td-000063',
      library  => $self->get_test_library_1,
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
      # MISSING REQUIRED PROPERTY
      name     => 'td-000064',
      testfile => 'td-000064.txt',
      docid    => 'td-000064',
      library  => $self->get_test_library_1,
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
      # Valid File Element
      name     => 'td-000065',
      testfile => 'td-000065.txt',
      docid    => 'td-000065',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # FILE NOT FOUND
      name     => 'td-000066',
      testfile => 'td-000066.txt',
      docid    => 'td-000066',
      library  => $self->get_test_library_1,
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
      # Valid Image File Element
      name     => 'td-000067',
      testfile => 'td-000067.txt',
      docid    => 'td-000067',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # FILE NOT FOUND
      name     => 'td-000068',
      testfile => 'td-000068.txt',
      docid    => 'td-000068',
      library  => $self->get_test_library_1,
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
      # Block Content
      name     => 'td-000069',
      testfile => 'td-000069.txt',
      docid    => 'td-000069',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     # {
     #  # INVALID NON-UNIQUE ID
     #  name     => 'td-000070',
     #  testfile => 'td-000070.txt',
     #  docid    => 'td-000070',
     #  library  => $self->get_test_library_2,
     #  expected =>
     #  {
     #   is_valid => 0,
     #   warning =>
     #   {
     # 	is_valid =>
     # 	[
     # 	 ['sml.Division' => 'INVALID NON-UNIQUE ID'],
     # 	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
     # 	],
     #   },
     #  },
     # },

     {
      # Baretable
      name     => 'td-000071',
      testfile => 'td-000071.txt',
      docid    => 'td-000071',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # Block Unit Test Data
      name     => 'td-000072',
      testfile => 'td-000072.txt',
      docid    => 'td-000072',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # Include From Different Directory
      name     => 'td-000073',
      testfile => 'td-000073.txt',
      docid    => 'td-000073',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # Glossary Term Reference Containing Newline
      name     => 'td-000077',
      testfile => 'td-000077.txt',
      docid    => 'td-000077',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # Title Containing[linebreak]A Line Break
      name     => 'td-000078',
      testfile => 'td-000078.txt',
      docid    => 'td-000078',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 1,
      },
     },

     {
      # INVALID PROPERTY MULTIPLICITY
      name     => 'td-000079',
      testfile => 'td-000079.txt',
      docid    => 'td-000079',
      library  => $self->get_test_library_1,
      expected =>
      {
       is_valid => 0,
       warning =>
       {
	is_valid =>
	[
	 ['sml.Division' => 'INVALID PROPERTY MULTIPLICITY'],
	 ['sml.Document' => 'THE DOCUMENT IS NOT VALID'],
	],
       },
      },
     },

     {
      # INVALID PROPERTY VALUE
      name     => 'td-000080',
      testfile => 'td-000080.txt',
      docid    => 'td-000080',
      library  => $self->get_test_library_1,
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
      # INVALID COMPOSITION
      name     => 'td-000081',
      testfile => 'td-000081.txt',
      docid    => 'td-000081',
      library  => $self->get_test_library_1,
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
      # Definition List Test
      name     => 'td-000082',
      testfile => 'td-000082.txt',
      docid    => 'td-000082',
      library  => $self->get_test_library_1,
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
      leading_whitespace => '',
      expected =>
      {
       get_value => 'top level item',
      },
     },

     {
      name => 'indented_item',
      text => '  + indented item',
      library => $self->get_test_library_1,
      leading_whitespace => '  ',
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
      filespec => 'test-library-1/td-000001.txt',
      library => $self->get_test_library_1,
      expected =>
      {
       get_sha_digest => '43244a80ba1df20d038733bd23a83b5b7b9b11e5',
       get_md5_digest => '515ffddd5578369af2caabf2a3f35a2c',
       is_valid => 1,
      },
     },

     {
      name     => 'bad_file_1',
      filespec => 'library/testdata/bogus.txt',
      library => $self->get_test_library_1,
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

# sub _build_fragment_test_case_list {

#   my $self = shift;

#   return
#     [
#      {
#       name => 'fragment_1',
#       filespec => 'library/testdata/td-000074.txt',
#       divid => 'my-problem',
#       library => $self->get_test_library_1,
#       expected =>
#       {
#        extract_division_lines => 19,
#       },
#      },

#      {
#       name => 'fragment_2',
#       filespec => 'library/testdata/td-000074.txt',
#       divid => 'tab-solution-types',
#       library => $self->get_test_library_1,
#       expected =>
#       {
#        extract_division_lines => 29,
#       },
#      },

#      {
#       name => 'fragment_3',
#       filespec => 'library/testdata/td-000074.txt',
#       divid => 'introduction',
#       library => $self->get_test_library_1,
#       expected =>
#       {
#        extract_division_lines => 16,
#       },
#      },
#     ];
# }

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
       '../library/ontology_rules_sml.conf',
       '../library/ontology_rules_lib.conf',
      ],
      division_name => 'problem',
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
       get_allowed_property_name_list =>
       [
	'allocation',
	'assignee',
	'assignment',
	'associated',
	'attr',
	'author',
	'changed_by',
	'has_part',
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
	'is_part_of',
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
	'TRIPLE',
	'ATTACHMENT',
	'AUDIO',
	'BARE_TABLE',
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
       get_required_property_name_list =>
       [
	'description',
	'id',
	'title',
	'type',
       ],
       has_division_with_name => 1,
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
      division_name => 'bogus',
      property_name => 'bogus',
      property_value => 'bogus',
      environment_name => 'bogus',
      division_a => 'TABLE',
      division_b => 'TABLE',
      expected =>
      {
       has_division_with_name => 0,
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
      division_name => 'problem',
      property_name => 'status',
      property_value => 'pink',
      expected =>
      {
       allows_property_value => 0,
       property_is_universal => 0,
       property_is_imply_only => 0,
       get_property_multiplicity => 1,
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
      division_name => 'problem',
      property_name => 'has_part',
      expected =>
      {
       property_is_imply_only => 1,
       get_property_multiplicity => 'many',
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
      name     => 'simple_document',
      divid    => 'td-000001',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_comment_division',
      divid    => 'td-000002',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_comment_line',
      divid    => 'td-000003',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_conditional_division',
      divid    => 'td-000004',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_problem_division',
      divid    => 'td-000005',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_listing_division',
      divid    => 'td-000006',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_lists',
      divid    => 'td-000007',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     # {
     #  name     => 'document_containing_generate_element',
     #  divid    => 'td-000008',
     #  library  => $self->get_test_library_1,
     #  expected =>
     #  {
     #   parse => 'SML::Document',
     #  },
     # },

     {
      name     => 'document_containing_insert_element',
      divid    => 'td-000009',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_script_element',
      divid    => 'td-000010',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_image_element',
      divid    => 'td-000011',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_footnote_element',
      divid    => 'td-000012',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_glossary_element',
      divid    => 'td-000013',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_var_element',
      divid    => 'td-000014',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_acronym_element',
      divid    => 'td-000015',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_index_element',
      divid    => 'td-000016',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_index_element',
      divid    => 'td-000017',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_included_section_style_1',
      divid    => 'td-000018',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_included_section_style_2',
      divid    => 'td-000019',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_sections_and_divisions',
      divid    => 'td-000020',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_raw_include_element',
      divid    => 'td-000021',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'problem_division',
      divid    => 'rq-000003',
      library  => $self->get_test_library_1,
      args =>
      {
       id => 'rq-000003',
      },
      expected =>
      {
       parse => 'SML::Entity',
      }
     },

     {
      name     => 'document_containing_included_entity',
      divid    => 'td-000023',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     # {
     #  name     => 'raw_single_paragraph',
     #  divid    => 'td-000024',
     #  library  => $self->get_test_library_1,
     #  expected =>
     #  {
     #   parse => 'SML::Division',
     #  },
     # },

     {
      name     => 'document_containing_variable_substitutions',
      divid    => 'td-000025',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_glossary_term_reference_1',
      divid    => 'td-000026',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_source_citation',
      divid    => 'td-000028',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_source_citation',
      divid    => 'td-000029',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_cross_reference',
      divid    => 'td-000032',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_cross_reference',
      divid    => 'td-000033',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_id_reference',
      divid    => 'td-000034',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_id_reference',
      divid    => 'td-000035',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_page_reference',
      divid    => 'td-000036',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_page_reference',
      divid    => 'td-000037',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_bold_markup',
      divid    => 'td-000038',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_bold_markup',
      divid    => 'td-000039',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_italics_markup',
      divid    => 'td-000040',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_italics_markup',
      divid    => 'td-000041',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_fixedwidth_markup',
      divid    => 'td-000042',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_fixedwidth_markup',
      divid    => 'td-000043',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_underline_markup',
      divid    => 'td-000044',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_underline_markup',
      divid    => 'td-000045',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_superscript_markup',
      divid    => 'td-000046',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_superscript_markup',
      divid    => 'td-000047',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_subscript_markup',
      divid    => 'td-000048',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_subscript_markup',
      divid    => 'td-000049',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_glossary_term_syntax',
      divid    => 'td-000050',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_glossary_definition_reference',
      divid    => 'td-000051',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_glossary_definition_reference_syntax',
      divid    => 'td-000052',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_acronym_reference',
      divid    => 'td-000053',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_acronym_reference_syntax',
      divid    => 'td-000054',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_source_citation',
      divid    => 'td-000055',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_source_citation_syntax',
      divid    => 'td-000056',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_cross_reference_syntax',
      divid    => 'td-000057',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_id_reference_syntax',
      divid    => 'td-000058',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_invalid_page_reference_syntax',
      divid    => 'td-000059',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_template',
      divid    => 'td-000060',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_default_includes',
      divid    => 'td-000061',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     # {
     #  name     => 'raw_division_containing_source_references',
     #  divid    => 'td-000062',
     #  library  => $self->get_test_library_1,
     #  expected =>
     #  {
     #   parse => 'SML::Division',
     #  },
     # },

     {
      name     => 'document_containing_invalid_explicit_declaration_of_infer_only_property',
      divid    => 'td-000063',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_entity_with_missing_required_property',
      divid    => 'td-000064',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_file_element',
      divid    => 'td-000065',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_reference_to_missing_file',
      divid    => 'td-000066',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_image_element',
      divid    => 'td-000067',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_reference_to_missing_image_file',
      divid    => 'td-000068',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_block_content',
      divid    => 'td-000069',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_baretable',
      divid    => 'td-000071',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_many_block_and_string_samples',
      divid    => 'td-000072',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_include_from_subdir',
      divid    => 'td-000073',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     # {
     #  name     => 'raw_division_containing_divisions_for_extraction',
     #  divid    => 'td-000074',
     #  library  => $self->get_test_library_1,
     #  expected =>
     #  {
     #   parse => 'SML::Division',
     #  },
     # },

     {
      name     => 'listing_division',
      divid    => 'td-000075',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Listing',
      }
     },

     {
      name     => 'section',
      divid    => 'td-000076',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Section',
      }
     },

     {
      name     => 'document_containing_glossary_term_reference_2',
      divid    => 'td-000077',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
      },
     },

     {
      name     => 'document_containing_title_with_linebreak',
      divid    => 'td-000078',
      library  => $self->get_test_library_1,
      expected =>
      {
       parse => 'SML::Document',
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
      document => $self->get_test_document_1,
      expected =>
      {
       has_part => 1,
       get_part => 'SML::Section',
      },
     },

     {
      name     => 'part_test_2',
      part_id  => 'problem-20-1',
      document => $self->get_test_document_1,
      expected =>
      {
       has_part => 1,
       get_part => 'SML::Entity',
      },
     },

     {
      name     => 'part_test_3',
      part_id  => 'bogus_id',
      document => $self->get_test_document_1,
      expected =>
      {
       has_part => 0,
      },
     },

     {
      name     => 'plain_string_1',
      text     => 'This is a plain string.',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => 'This is a plain string.',
	},
       },
      },
     },

     #-----------------------------------------------------------------
     # SPECIAL STRINGS
     #-----------------------------------------------------------------

     {
      name     => 'user_entered_text_1',
      text     => '[enter:your age]',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '[enter:your age]',
	},
       },
      },
     },

     {
      name     => 'user_entered_text_2',
      text     => '[en:your age]',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '[en:your age]',
	},
       },
      },
     },

     {
      name     => 'literal_1',
      text     => '{lit:[c]}',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '{lit:[c]}',
	},
       },
      },
     },

     {
      name     => 'cross_reference_1',
      content  => '[ref:introduction]',
      subclass => 'SML::Paragraph',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      library  => $self->get_test_library_1,
      document => $self->get_test_document_1,
      expected =>
      {
       render =>
       {
	html =>
	{
	 default => "<p><a href=\"td-000020.1.html#SECTION.1\">Section 1</a></p>\n\n",
	},
	latex =>
	{
	 default => "Section~\\vref{introduction}\n\n",
	},
	xml =>
	{
	 default => "<a href=\"td-000020.1.xml#SECTION.1\">Section 1</a>\n\n",
	},
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

    ];
}

######################################################################

sub _build_publisher_test_case_list {

  my $self = shift;

  return
    [
     {
      name => 'document_1',
      object => $self->get_test_document_1,
      library => $self->get_test_library_1,
      expected =>
      {
       publish =>
       {
	html =>
	{
	 default => 1,
	},
       },
      },
     },
    ];
}

######################################################################

sub _build_string_test_case_list {

  my $self = shift;

  return
    [
     #-----------------------------------------------------------------
     # NON-REFERENCE STRINGS
     #-----------------------------------------------------------------

     {
      name => 'plain_string_1',
      text => q{This is a plain string.},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'string',
       get_content => 'This is a plain string.',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => 'This is a plain string.',
	},
	html =>
	{
	 default => 'This is a plain string.',
	},
	latex =>
	{
	 default => 'This is a plain string.',
	},
       },
      },
     },

     {
      name => 'bold_string_1',
      text => q{!!this is bold!!},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'bold_string',
       get_content => 'this is bold',
       contains_parts => 1,
       render =>
       {
	sml =>
	{
	 default => '!!this is bold!!',
	},
	html =>
	{
	 default => '<b>this is bold</b>',
	},
	latex =>
	{
	 default => '\textbf{this is bold}',
	},
       },
      },
     },

     {
      name => 'italics_string_1',
      text => q{~~this is italics~~},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'italics_string',
       get_content => 'this is italics',
       contains_parts => 1,
       render =>
       {
	sml =>
	{
	 default => '~~this is italics~~',
	},
	html =>
	{
	 default => '<i>this is italics</i>',
	},
	latex =>
	{
	 default => '\textit{this is italics}',
	},
       },
      },
     },

     {
      name => 'fixedwidth_string_1',
      text => q{||this is fixed width||},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'fixedwidth_string',
       get_content => 'this is fixed width',
       contains_parts => 1,
       render =>
       {
	sml =>
	{
	 default => '||this is fixed width||',
	},
	html =>
	{
	 default => '<tt>this is fixed width</tt>',
	},
	latex =>
	{
	 default => '\texttt{this is fixed width}',
	},
       },
      },
     },

     {
      name => 'underline_string_1',
      text => q{__this is underlined__},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'underline_string',
       get_content => 'this is underlined',
       contains_parts => 1,
       render =>
       {
	sml =>
	{
	 default => '__this is underlined__',
	},
	html =>
	{
	 default => '<u>this is underlined</u>',
	},
	latex =>
	{
	 default => '\underline{this is underlined}',
	},
       },
      },
     },

     {
      name => 'superscript_string_1',
      text => q{^^this is superscripted^^},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'superscript_string',
       get_content => 'this is superscripted',
       contains_parts => 1,
       render =>
       {
	sml =>
	{
	 default => '^^this is superscripted^^',
	},
	html =>
	{
	 default => '<sup>this is superscripted</sup>',
	},
	latex =>
	{
	 default => '\textsuperscript{this is superscripted}',
	},
       },
      },
     },

     {
      name => 'subscript_string_1',
      text => q{,,this is subscripted,,},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'subscript_string',
       get_content => 'this is subscripted',
       contains_parts => 1,
       render =>
       {
	sml =>
	{
	 default => ',,this is subscripted,,',
	},
	html =>
	{
	 default => '<sub>this is subscripted</sub>',
	},
	latex =>
	{
	 default => '\subscript{this is subscripted}',
	},
       },
      },
     },

     {
      name     => 'keystroke_symbol_1',
      text     => q{[[Enter]]},
      library  => $self->get_test_library_1,
      expected =>
      {
       get_name => 'keystroke_symbol',
       get_content => 'Enter',
       contains_parts => 1,
       render =>
       {
	sml =>
	{
	 default => '[[Enter]]',
	},
	html =>
	{
	 default => "<span class=\"keystroke\">Enter</span>",
	},
	latex =>
	{
	 default => "\\keystroke{Enter}",
	},
	xml =>
	{
	 default => "<span class=\"keystroke\">Enter</span>",
	},
       },
      },
     },

     {
      name     => 'keystroke_symbol_2',
      text     => q{[[Ctrl]]-[[Alt]]-[[Del]]},
      library  => $self->get_test_library_1,
      expected =>
      {
       get_name => 'string',
       get_content => '[[Ctrl]]-[[Alt]]-[[Del]]',
       contains_parts => 5,
       render =>
       {
	sml =>
	{
	 default => '[[Ctrl]]-[[Alt]]-[[Del]]',
	},
	html =>
	{
	 default => "<span class=\"keystroke\">Ctrl</span>-<span class=\"keystroke\">Alt</span>-<span class=\"keystroke\">Del</span>",
	},
	latex =>
	{
	 default => "\\keystroke{Ctrl}-\\keystroke{Alt}-\\keystroke{Del}",
	},
	xml =>
	{
	 default => "<span class=\"keystroke\">Ctrl</span>-<span class=\"keystroke\">Alt</span>-<span class=\"keystroke\">Del</span>",
	},
       },
      },
     },

     {
      name => 'user_entered_text_1',
      text => q{[enter:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'USER_ENTERED_TEXT',
       get_content => 'bogus',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[enter:bogus]',
	},
	html =>
	{
	 default => '<b><tt>bogus</tt></b>',
	},
	latex =>
	{
	 default => '\\textbf{\\texttt{bogus}}',
	},
       },
      },
     },

     {
      name => 'user_entered_text_2',
      text => q{[en:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'USER_ENTERED_TEXT',
       get_content => 'bogus',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[en:bogus]',
	},
	html =>
	{
	 default => '<b><tt>bogus</tt></b>',
	},
	latex =>
	{
	 default => '\textbf{\texttt{bogus}}',
	},
       },
      },
     },

     {
      name => 'bold_inside_italics_1',
      text => q{~~this is !!bold!! inside italics~~},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'italics_string',
       get_content => 'this is !!bold!! inside italics',
       contains_parts => 3,
       render =>
       {
	sml =>
	{
	 default => '~~this is !!bold!! inside italics~~',
	},
	html =>
	{
	 default => '<i>this is <b>bold</b> inside italics</i>',
	},
	latex =>
	{
	 default => '\textit{this is \textbf{bold} inside italics}',
	},
       },
      },
     },

     {
      name => 'italics_inside_bold_1',
      text => q{!!this is ~~italics~~ inside bold!!},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'bold_string',
       get_content => 'this is ~~italics~~ inside bold',
       contains_parts => 3,
       render =>
       {
	sml =>
	{
	 default => '!!this is ~~italics~~ inside bold!!',
	},
	html =>
	{
	 default => '<b>this is <i>italics</i> inside bold</b>',
	},
	latex =>
	{
	 default => '\textbf{this is \textit{italics} inside bold}',
	},
       },
      },
     },

     {
      name => 'string_with_italics_and_bold_1',
      text => q{this string has ~~italics~~ and !!bold!!},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'string',
       get_content => 'this string has ~~italics~~ and !!bold!!',
       contains_parts => 4,
       render =>
       {
	sml =>
	{
	 default => 'this string has ~~italics~~ and !!bold!!',
	},
	html =>
	{
	 default => 'this string has <i>italics</i> and <b>bold</b>',
	},
	latex =>
	{
	 default => 'this string has \textit{italics} and \textbf{bold}',
	},
       },
      },
     },

     {
      name => 'sglquote_string_1',
      text => q{`this is a single quoted string'},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'sglquote_string',
       get_content => q{this is a single quoted string},
       contains_parts => 1,
       render =>
       {
	sml =>
	{
	 default => q{`this is a single quoted string'},
	},
	html =>
	{
	 default => q{&#8216;this is a single quoted string&#8217;},
	},
	latex =>
	{
	 default => q{`this is a single quoted string'},
	},
       },
      },
     },

     #-----------------------------------------------------------------
     # EXTERNAL REFERENCE STRINGS (not validated)
     #-----------------------------------------------------------------

     {
      name => 'file_reference_1',
      text => q{[file:bogus.txt]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'FILE_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[file:bogus.txt]',
	},
	html =>
	{
	 default => '<tt>bogus.txt</tt>',
	},
	latex =>
	{
	 default => '\path{bogus.txt}',
	},
       },
      },
     },

     {
      name => 'path_reference_1',
      text => q{[path:path/to/bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'PATH_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[path:path/to/bogus]',
	},
	html =>
	{
	 default => '<tt>path/to/bogus</tt>',
	},
	latex =>
	{
	 default => '\path{path/to/bogus}',
	},
       },
      },
     },

     {
      name => 'url_reference_1',
      text => q{[url:http://www.google.com/]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'URL_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[url:http://www.google.com/]',
	},
	html =>
	{
	 default => '<a href="http://www.google.com/">http://www.google.com/</a>',
	},
	latex =>
	{
	 default => '\urlstyle{sf}\url{http://www.google.com/}',
	},
       },
      },
     },

     {
      name => 'url_reference_2',
      text => q{[url:http://www.google.com/|google]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'URL_REF',
       get_content => 'google',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[url:http://www.google.com/|google]',
	},
	html =>
	{
	 default => '<a href="http://www.google.com/">google</a>',
	},
	latex =>
	{
	 default => '\urlstyle{sf}\href{http://www.google.com/}{google}',
	},
       },
      },
     },

     {
      name => 'command_reference_1',
      text => q{[cmd:ls -al | grep bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'COMMAND_REF',
       get_content => 'ls -al | grep bogus',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[cmd:ls -al | grep bogus]',
	},
	html =>
	{
	 default => '<tt>ls -al | grep bogus</tt>',
	},
	latex =>
	{
	 default => '\path{ls -al | grep bogus}',
	},
       },
      },
     },

     {
      name => 'email_address_1',
      text => q{[email:help@example.com]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'EMAIL_ADDR',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[email:help@example.com]',
	},
	html =>
	{
	 default => '<a href="mailto:help@example.com">help@example.com</a>',
	},
	latex =>
	{
	 default => '\href{mailto:help@example.com}{help@example.com}',
	},
       },
      },
     },

     {
      name => 'email_address_2',
      text => q{[email:john.smith@example.com|John Smith]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'EMAIL_ADDR',
       get_content => 'John Smith',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[email:john.smith@example.com|John Smith]',
	},
	html =>
	{
	 default => '<a href="mailto:john.smith@example.com">John Smith</a>',
	},
	latex =>
	{
	 default => '\href{mailto:john.smith@example.com}{John Smith}',
	},
       },
      },
     },

     #-----------------------------------------------------------------
     # INTERNAL REFERENCE STRINGS (validated)
     #-----------------------------------------------------------------

     {
      name => 'cross_reference_1',
      text => q{[r:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'CROSS_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[r:bogus]',
	},
       },
      },
     },

     {
      name => 'cross_reference_2',
      text => q{[ref:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'CROSS_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[ref:bogus]',
	},
       },
      },
     },

     {
      name => 'id_reference_2',
      text => q{[id:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'ID_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[id:bogus]',
	},
       },
      },
     },

     {
      name => 'page_reference_1',
      text => q{[page:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'PAGE_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[page:bogus]',
	},
       },
      },
     },

     {
      name => 'page_reference_2',
      text => q{[pg:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'PAGE_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[pg:bogus]',
	},
       },
      },
     },

     {
      name => 'footnote_reference_1',
      text => q{[f:introduction:1]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'FOOTNOTE_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[f:introduction:1]',
	},
       },
      },
     },

     {
      name => 'index_reference_1',
      text => q{[index:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'INDEX_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[index:bogus]',
	},
       },
      },
     },

     {
      name => 'index_reference_2',
      text => q{[i:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'INDEX_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[i:bogus]',
	},
       },
      },
     },

     {
      name => 'variable_reference_1',
      text => q{[var:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'VARIABLE_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[var:bogus]',
	},
       },
      },
     },

     {
      name => 'glossary_term_reference_1',
      text => q{[g:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'GLOSS_TERM_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[g:bogus]',
	},
       },
      },
     },

     {
      name => 'glossary_term_reference_2',
      text => q{[G:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'GLOSS_TERM_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[G:bogus]',
	},
       },
      },
     },

     {
      name => 'glossary_term_reference_3',
      text => q{[gls:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'GLOSS_TERM_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[gls:bogus]',
	},
       },
      },
     },

     {
      name => 'glossary_term_reference_4',
      text => q{[Gls:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'GLOSS_TERM_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[Gls:bogus]',
	},
       },
      },
     },

     {
      name => 'glossary_definition_reference_1',
      text => q{[def:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'GLOSS_DEF_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[def:bogus]',
	},
       },
      },
     },

     {
      name => 'acronym_term_reference_1',
      text => q{[a:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'ACRONYM_TERM_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[a:bogus]',
	},
       },
      },
     },

     {
      name => 'acronym_term_reference_2',
      text => q{[ac:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'ACRONYM_TERM_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[ac:bogus]',
	},
       },
      },
     },

     {
      name => 'acronym_term_reference_3',
      text => q{[acs:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'ACRONYM_TERM_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[acs:bogus]',
	},
       },
      },
     },

     {
      name => 'acronym_term_reference_4',
      text => q{[acl:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'ACRONYM_TERM_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[acl:bogus]',
	},
       },
      },
     },

     {
      name => 'theversion_symbol_1',
      text => q{[theversion]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'theversion_ref',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[theversion]',
	},
       },
      },
     },

     {
      name => 'therevision_symbol_1',
      text => q{[therevision]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'therevision_ref',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[therevision]',
	},
       },
      },
     },

     {
      name => 'status_reference_1',
      text => q{[status:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'STATUS_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[status:bogus]',
	},
       },
      },
     },

     {
      name => 'citation_reference_1',
      text => q{[cite:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'CITATION_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[cite:bogus]',
	},
       },
      },
     },

     {
      name => 'citation_reference_2',
      text => q{[c:bogus]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'CITATION_REF',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[c:bogus]',
	},
       },
      },
     },

     #-----------------------------------------------------------------
     # REPLACEMENT STRINGS
     #-----------------------------------------------------------------

     {
      name => 'thepage_replacement_string_1',
      text => q{[thepage]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'thepage_ref',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[thepage]',
	},
	html =>
	{
	 default => '',
	},
	latex =>
	{
	 default => '\thepage',
	},
       },
      },
     },

     {
      name => 'thedate_replacement_string_1',
      text => q{[thedate]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'thedate_ref',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[thedate]',
	},
	html =>
	{
	 default => '', # <-- !!! BUG HERE !!!
	},
	latex =>
	{
	 default => '\today',
	},
       },
      },
     },

     {
      name => 'pagecount_replacement_string_1',
      text => q{[pagecount]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'pagecount_ref',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[pagecount]',
	},
	html =>
	{
	 default => '',
	},
	latex =>
	{
	 default => '\pageref{LastPage}',
	},
       },
      },
     },

     {
      name => 'thesection_replacement_string_1',
      text => q{[thesection]},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'thesection_ref',
       get_content => '',
       contains_parts => 0,
       render =>
       {
	sml =>
	{
	 default => '[thesection]',
	},
	html =>
	{
	 default => '',
	},
	latex =>
	{
	 default => '\thesection',
	},
       },
      },
     },

     #-----------------------------------------------------------------
     # COMPLEX STRINGS
     #-----------------------------------------------------------------

     {
      name => 'complex_string_1',
      text => q{Prefix `single' and ``double.''},
      library => $self->get_test_library_1,
      expected =>
      {
       get_name => 'string',
       get_content => q{Prefix `single' and ``double.''},
       contains_parts => 4,
       render =>
       {
	sml =>
	{
	 default => q{Prefix `single' and ``double.''},
	},
	html =>
	{
	 default => q{Prefix &#8216;single&#8217; and &#8220;double.&#8221;},
	},
	latex =>
	{
	 default => q{Prefix `single' and ``double.''},
	},
       },
      },
     },

    ];
}

######################################################################

sub _build_symbol_test_case_list {

  my $self = shift;

  return
    [
     {
      name     => 'linebreak_symbol_1',
      text     => '[linebreak]',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '[linebreak]',
	},
	html =>
	{
	 default => '<br/>',
	},
	latex =>
	{
	 default => '\linebreak',
	},
       },
      },
     },

     {
      name     => 'pagebreak_symbol_1',
      text     => '[pagebreak]',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '[pagebreak]',
	},
	html =>
	{
	 default => '',
	},
	latex =>
	{
	 default => '\pagebreak',
	},
       },
      },
     },

     {
      name     => 'clearpage_symbol_1',
      text     => '[clearpage]',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '[clearpage]',
	},
	html =>
	{
	 default => '',
	},
	latex =>
	{
	 default => '\clearpage',
	},
       },
      },
     },

     {
      name     => 'take_note_symbol_1',
      text     => '[take_note]',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '[take_note]',
	},
	html =>
	{
	 default => "<b>(take note!)</b>",
	},
	latex =>
	{
	 default => "\\marginpar{\\Huge\\Writinghand}",
	},
	xml =>
	{
	 default => "<b>(take note!)</b>",
	},
       },
      },
     },

     {
      name     => 'smiley_symbol_1',
      text     => ':-)',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => ':-)',
	},
	html =>
	{
	 default => "&#9786;",
	},
	latex =>
	{
	 default => "\\large\\Smiley",
	},
	xml =>
	{
	 default => "&#9786;",
	},
       },
      },
     },

     {
      name     => 'frowny_symbol_1',
      text     => ':-(',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => ':-(',
	},
	html =>
	{
	 default => "&#9785;",
	},
	latex =>
	{
	 default => "\\large\\Frowny",
	},
	xml =>
	{
	 default => "&#9785;",
	},
       },
      },
     },

     {
      name     => 'left_arrow_symbol_1',
      text     => '<-',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '<-',
	},
	html =>
	{
	 default => "&#8592;",
	},
	latex =>
	{
	 default => "\$\\leftarrow\$",
	},
	xml =>
	{
	 default => "&#8592;",
	},
       },
      },
     },

     {
      name     => 'right_arrow_symbol_1',
      text     => '->',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '->',
	},
	html =>
	{
	 default => "&#8594;",
	},
	latex =>
	{
	 default => "\$\\rightarrow\$",
	},
	xml =>
	{
	 default => "&#8594;",
	},
       },
      },
     },

     {
      name     => 'latex_symbol_1',
      text     => 'LaTeX',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => 'LaTeX',
	},
	html =>
	{
	 default => "L<sup>a</sup>T<sub>e</sub>X",
	},
	latex =>
	{
	 default => "\\LaTeX{}",
	},
	xml =>
	{
	 default => "LaTeX",
	},
       },
      },
     },

     {
      name     => 'tex_symbol_1',
      text     => 'TeX',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => 'TeX',
	},
	html =>
	{
	 default => "T<sub>e</sub>X",
	},
	latex =>
	{
	 default => "\\TeX{}",
	},
	xml =>
	{
	 default => "TeX",
	},
       },
      },
     },

     {
      name     => 'copyright_symbol_1',
      text     => '[c]',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '[c]',
	},
	html =>
	{
	 default => "&copy;",
	},
	latex =>
	{
	 default => "\\tiny\$^{\\copyright}\$\\normalsize",
	},
	xml =>
	{
	 default => "&copy;",
	},
       },
      },
     },

     {
      name     => 'trademark_symbol_1',
      text     => '[tm]',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '[tm]',
	},
	html =>
	{
	 default => "&trade;",
	},
	latex =>
	{
	 default => "\\tiny\$^{\\texttrademark}\$\\normalsize",
	},
	xml =>
	{
	 default => "&trade;",
	},
       },
      },
     },

     {
      name     => 'reg_trademark_symbol_1',
      text     => '[rtm]',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '[rtm]',
	},
	html =>
	{
	 default => "&reg;",
	},
	latex =>
	{
	 default => "\\tiny\$^{\\textregistered}\$\\normalsize",
	},
	xml =>
	{
	 default => "&reg;",
	},
       },
      },
     },

     # {
     #  name     => 'open_dblquote_symbol_1',
     #  text     => '``',
     #  library  => $self->get_test_library_1,
     #  expected =>
     #  {
     #   render =>
     #   {
     # 	sml =>
     # 	{
     # 	 default => '``',
     # 	},
     # 	html =>
     # 	{
     # 	 default => "&#8220;",
     # 	},
     # 	latex =>
     # 	{
     # 	 default => "\`\`",
     # 	},
     # 	xml =>
     # 	{
     # 	 default => "&#8220;",
     # 	},
     #   },
     #  },
     # },

     # {
     #  name     => 'close_dblquote_symbol_1',
     #  text     => '\'\'',
     #  library  => $self->get_test_library_1,
     #  expected =>
     #  {
     #   render =>
     #   {
     # 	sml =>
     # 	{
     # 	 default => '\'\'',
     # 	},
     # 	html =>
     # 	{
     # 	 default => "&#8221;",
     # 	},
     # 	latex =>
     # 	{
     # 	 default => "\'\'",
     # 	},
     # 	xml =>
     # 	{
     # 	 default => "&#8221;",
     # 	},
     #   },
     #  },
     # },

     # {
     #  name     => 'open_sglquote_symbol_1',
     #  text     => '`',
     #  library  => $self->get_test_library_1,
     #  expected =>
     #  {
     #   render =>
     #   {
     # 	sml =>
     # 	{
     # 	 default => '`',
     # 	},
     # 	html =>
     # 	{
     # 	 default => "&#8216;",
     # 	},
     # 	latex =>
     # 	{
     # 	 default => "\`",
     # 	},
     # 	xml =>
     # 	{
     # 	 default => "&#8216;",
     # 	},
     #   },
     #  },
     # },

     # {
     #  name     => 'close_sglquote_symbol_1',
     #  text     => '\'',
     #  library  => $self->get_test_library_1,
     #  expected =>
     #  {
     #   render =>
     #   {
     # 	sml =>
     # 	{
     # 	 default => '\'',
     # 	},
     # 	html =>
     # 	{
     # 	 default => "&#8217;",
     # 	},
     # 	latex =>
     # 	{
     # 	 default => "\'",
     # 	},
     # 	xml =>
     # 	{
     # 	 default => "&#8217;",
     # 	},
     #   },
     #  },
     # },

     {
      name     => 'section_symbol_1',
      text     => '[section]',
      library  => $self->get_test_library_1,
      expected =>
      {
       render =>
       {
	sml =>
	{
	 default => '[section]',
	},
	html =>
	{
	 default => "&sect;",
	},
	latex =>
	{
	 default => "{\\S}",
	},
	xml =>
	{
	 default => "&sect;",
	},
       },
      },
     },

     # {
     #  name     => 'emdash_symbol_1',
     #  text     => '--',
     #  library  => $self->get_test_library_1,
     #  expected =>
     #  {
     #   render =>
     #   {
     # 	sml =>
     # 	{
     # 	 default => '--',
     # 	},
     # 	html =>
     # 	{
     # 	 default => "&mdash;",
     # 	},
     # 	latex =>
     # 	{
     # 	 default => "--",
     # 	},
     # 	xml =>
     # 	{
     # 	 default => "&mdash;",
     # 	},
     #   },
     #  },
     # },

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
    # my $fragment = $parser->create_fragment('td-000020.txt');
    my $document = $library->get_division('td-000020');

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

  return SML::Library->new
    (
     config_filename=>'test-library-1.conf',
    );
}

######################################################################

sub _build_test_library_2 {

  return SML::Library->new
    (
     config_filename=>'test-library-2.conf',
    );
}

######################################################################

sub _build_test_document_1 {

  my $self = shift;

  my $library = $self->get_test_library_1;

  return $library->get_division('td-000020');
}

######################################################################

sub _build_test_definition_1 {

  my $self = shift;

  my $library = $self->get_test_library_1;

  my $definition = SML::Definition->new
    (
     name       => 'acronym',
     library    => $library,
     term       => 'TLA',
     definition => 'Three Letter Acronym',
    );

  my $parser = $library->get_parser;
  $parser->_parse_block($definition);

  return $definition;
}

######################################################################

sub _build_test_definition_2 {

  my $self = shift;

  my $library = $self->get_test_library_1;

  my $definition = SML::Definition->new
    (
     name       => 'acronym',
     library    => $library,
     term       => 'FLA',
     definition => 'Four Letter Acronym',
    );

  my $parser = $library->get_parser;
  $parser->_parse_block($definition);

  return $definition;
}

######################################################################

sub _build_test_definition_3 {

  my $self = shift;

  my $library = $self->get_test_library_1;

  my $definition = SML::Definition->new
    (
     name       => 'acronym',
     library    => $library,
     term       => 'SLA',
     definition => 'Six Letter Acronym',
    );

  my $parser = $library->get_parser;
  $parser->_parse_block($definition);

  return $definition;
}

######################################################################

sub _build_test_definition_4 {

  my $self = shift;

  my $library = $self->get_test_library_1;

  my $definition = SML::Definition->new
    (
     name       => 'acronym',
     library    => $library,
     term       => 'FRD',
     namespace  => 'ieee',
     definition => '(IEEE) Functional Requirements Document',
    );

  my $parser = $library->get_parser;
  $parser->_parse_block($definition);

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

sub slurp {

  my $filespec = shift;

  my $content = q{};

  if ( -f "../library/testdata/$filespec" )
    {
      $content = read_file("../library/testdata/$filespec");
    }

  elsif ( -f "library/testdata/$filespec" )
    {
      $content = read_file("library/testdata/$filespec");
    }

  else
    {
      $logger->warn("CAN'T FIND $filespec");
    }

  return $content;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::TestData> - unit test cases and test data

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  my $td = SML::TestData->new();

  my $tcl = $td->get_acronym_list_test_case_list;
  my $tcl = $td->get_acronym_term_reference_test_case_list;
  my $tcl = $td->get_triple_test_case_list;
  my $tcl = $td->get_block_test_case_list;
  my $tcl = $td->get_bullet_list_item_test_case_list;
  my $tcl = $td->get_cross_reference_test_case_list;
  my $tcl = $td->get_definition_list_item_test_case_list;
  my $tcl = $td->get_definition_test_case_list;
  my $tcl = $td->get_division_test_case_list;
  my $tcl = $td->get_document_test_case_list;
  my $tcl = $td->get_element_test_case_list;
  my $tcl = $td->get_enumerated_list_item_test_case_list;
  my $tcl = $td->get_file_test_case_list;
  my $tcl = $td->get_formatter_test_case_list;
  my $tcl = $td->get_library_test_case_list;
  my $tcl = $td->get_ontology_test_case_list;
  my $tcl = $td->get_parser_test_case_list;
  my $tcl = $td->get_part_test_case_list;
  my $tcl = $td->get_string_test_case_list;
  my $tcl = $td->get_symbol_test_case_list;
  my $tcl = $td->get_test_data_test_case_list;

  my $library    = $td->get_test_library_1;
  my $document   = $td->get_test_document_1;
  my $definition = $td->get_test_definition_1;
  my $definition = $td->get_test_definition_2;
  my $definition = $td->get_test_definition_3;
  my $definition = $td->get_test_definition_4;
  my $note       = $td->get_test_note_1;

=head1 DESCRIPTION

A class that contains and provides test cases and test data.

=head1 METHODS

=head2 get_acronym_list_test_case_list

=head2 get_acronym_term_reference_test_case_list

=head2 get_triple_test_case_list

=head2 get_block_test_case_list

=head2 get_bullet_list_item_test_case_list

=head2 get_cross_reference_test_case_list

=head2 get_definition_list_item_test_case_list

=head2 get_definition_test_case_list

=head2 get_division_test_case_list

=head2 get_document_test_case_list

=head2 get_element_test_case_list

=head2 get_enumerated_list_item_test_case_list

=head2 get_file_test_case_list

=head2 get_formatter_test_case_list

=head2 get_library_test_case_list

=head2 get_ontology_test_case_list

=head2 get_parser_test_case_list

=head2 get_part_test_case_list

=head2 get_string_test_case_list

=head2 get_symbol_test_case_list

=head2 get_test_data_test_case_list

=head2 get_test_library_1

=head2 get_test_document_1

=head2 get_test_definition_1

=head2 get_test_definition_2

=head2 get_test_definition_3

=head2 get_test_definition_4

=head2 get_test_note_1

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012,2013 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
