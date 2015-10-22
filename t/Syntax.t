#!/usr/bin/perl

# $Id: Syntax.t 264 2015-05-11 11:56:25Z drj826@gmail.com $

use lib "../lib";
use Test::More tests => 3;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Syntax;
  use_ok( 'SML::Syntax' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Syntax->new;
isa_ok( $obj, 'SML::Syntax' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # comment markup
   'comment_line',

   # table markup
   'end_table_row',
   'table_cell',

   # section markup
   'start_section',

   # block markup
   'paragraph_text',
   'indented_text',
   'list_item',
   'bull_list_item',
   'enum_list_item',
   'def_list_item',

   # string markup
   'bold',
   'bold_string',
   'italics',
   'italics_string',
   'fixedwidth',
   'fixedwidth_string',
   'underline',
   'underline_string',
   'superscript',
   'superscript_string',
   'subscript',
   'subscript_string',
   'sglquote_string',
   'dblquote_string',

   # element markup
   'title_element',
   'insert_element',
   'insert_ins_element',
   'insert_gen_element',
   'template_element',
   'generate_element',
   'include_element',
   'csvfile_element',
   'script_element',
   'outcome_element',
   'review_element',
   'index_element',
   'definition_element',
   'glossary_element',
   'variable_element',
   'acronym_element',
   'file_element',
   'image_element',
   'note_element',

   # string references
   'variable_ref',
   'lookup_ref',
   'gloss_term_ref',
   'begin_gloss_term_ref',
   'gloss_def_ref',
   'begin_gloss_def_ref',
   'acronym_term_ref',
   'begin_acronym_term_ref',
   'cross_ref',
   'begin_cross_ref',
   'id_ref',
   'begin_id_ref',
   'page_ref',
   'begin_page_ref',
   'url_ref',
   'footnote_ref',
   'index_ref',
   'thepage_ref',
   'pagecount_ref',
   'thesection_ref',
   'theversion_ref',
   'therevision_ref',
   'thedate_ref',
   'status_ref',
   'citation_ref',
   'begin_citation_ref',
   'file_ref',
   'path_ref',
   'command_ref',
   'email_addr',

   # symbol markup
   'linebreak_symbol',
   'pagebreak_symbol',
   'clearpage_symbol',
   'take_note_symbol',
   'smiley_symbol',
   'frowny_symbol',
   'keystroke_symbol',
   'left_arrow_symbol',
   'right_arrow_symbol',
   'latex_symbol',
   'tex_symbol',
   'copyright_symbol',
   'trademark_symbol',
   'reg_trademark_symbol',
   # 'open_dblquote_symbol',
   # 'close_dblquote_symbol',
   # 'open_sglquote_symbol',
   # 'close_sglquote_symbol',
   'section_symbol',
   'emdash_symbol',

   # special strings
   'user_entered_text',

   # other markup
   'blank_line',
   'non_blank_line',
   'inline_tag',
   'literal',
   'xml_tag',

   # validation regular expressions
   'valid_inline_tags',
   'valid_date',
   'valid_status',
   'valid_description',
   'valid_ontology_rule_type',
   'valid_cardinality_value',
   'key_value_pair',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
