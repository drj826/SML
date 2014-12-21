#!/usr/bin/perl

# $Id: Syntax.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 4;
use Test::Perl::Critic (-severity => 4);

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
  );

# can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed attributes?
#---------------------------------------------------------------------

my @attributes =
  (
   'start_document',
   'end_document',
   'comment_line',
   'comment_marker',
   'start_conditional',
   'end_conditional',
   'end_table_row',
   'start_region',
   'end_region',
   'start_environment',
   'end_environmnent',
   'start_section',
   'list_item',
   'bull_list_item',
   'enum_list_item',
   'def_list_item',
   'paragraph_text',
   'indented_text',
   'blank_line',
   'non_blank_line',
   'table_cell',
   'bold',
   'italics',
   'fixedwidth',
   'underline',
   'superscript',
   'subscript',
   'start_element',
   'title_element',
   'id_element',
   'author_element',
   'date_element',
   'revision_element',
   'document_file_element',
   'fragment_file_element',
   'entity_file_element',
   'reference_file_element',
   'script_file_element',
   'insert_element',
   'insert_ins_element',
   'insert_gen_element',
   'insert_string',
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
   'variable_ref',
   'variable_element',
   'acronym_element',
   'file_element',
   'image_element',
   'note_element',
   'lookup_ref',
   'gloss_term_ref',
   'begin_gloss_term_ref',
   'gloss_def_ref',
   'begin_gloss_def_ref',
   'begin_acronym_term_ref',
   'acronym_term_ref',
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
   'version_ref',
   'revision_ref',
   'date_ref',
   'status_ref',
   'citation_ref',
   'begin_citation_ref',
   'file_ref',
   'path_ref',
   'user_entered_text',
   'command_ref',
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
   'open_dblquote_symbol',
   'close_dblquote_symbol',
   'open_sglquote_symbol',
   'close_sglquote_symbol',
   'section_symbol',
   'emdash_symbol',
   'inline_tag',
   'valid_inline_tags',
   'literal',
   'xml_tag',
   'email_addr',
   'valid_date',
   'valid_status',
   'valid_description',
   'valid_ontology_rule_type',
   'valid_cardinality_value',
   'key_value_pair',
  );

can_ok( $obj, @attributes );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
  );

# can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
