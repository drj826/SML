#!/usr/bin/perl

# $Id: Formattable.pm 11633 2012-12-04 23:07:21Z don.johnson $

package SML::Formattable;

use Moose::Role;

requires 'render';
requires 'get_content';
requires 'get_containing_document';

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Formattable');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub render {

  my $self      = shift;
  my $rendition = shift || 'html';
  my $style     = shift || 'default';

  my $text = $self->get_content;

  # escape literal XML tags
  $text = $self->_render_literal_xml_tags($text,$rendition,$style);

  # render references
  $text = $self->_render_internal_references($text,$rendition,$style);
  $text = $self->_render_url_references($text,$rendition,$style);
  $text = $self->_render_footnote_references($text,$rendition,$style);
  $text = $self->_render_glossary_references($text,$rendition,$style);
  $text = $self->_render_acronym_references($text,$rendition,$style);
  $text = $self->_render_index_references($text,$rendition,$style);
  $text = $self->_render_id_references($text,$rendition,$style);
  $text = $self->_render_thepage_references($text,$rendition,$style);
  $text = $self->_render_page_references($text,$rendition,$style);
  $text = $self->_render_version_references($text,$rendition,$style);
  $text = $self->_render_revision_references($text,$rendition,$style);
  $text = $self->_render_date_references($text,$rendition,$style);
  $text = $self->_render_status_references($text,$rendition,$style);
  $text = $self->_render_citation_references($text,$rendition,$style);

  # render special symbols and characters
  $text = $self->_render_take_note_symbols($text,$rendition,$style);
  $text = $self->_render_smiley_symbols($text,$rendition,$style);
  $text = $self->_render_frowny_symbols($text,$rendition,$style);
  $text = $self->_render_keystroke_symbols($text,$rendition,$style);
  $text = $self->_render_left_arrow_symbols($text,$rendition,$style);
  $text = $self->_render_right_arrow_symbols($text,$rendition,$style);
  $text = $self->_render_latex_symbols($text,$rendition,$style);
  $text = $self->_render_tex_symbols($text,$rendition,$style);
  $text = $self->_render_copyright_symbols($text,$rendition,$style);
  $text = $self->_render_trademark_symbols($text,$rendition,$style);
  $text = $self->_render_reg_trademark_symbols($text,$rendition,$style);
  $text = $self->_render_open_double_quote($text,$rendition,$style);
  $text = $self->_render_close_double_quote($text,$rendition,$style);
  $text = $self->_render_open_single_quote($text,$rendition,$style);
  $text = $self->_render_close_single_quote($text,$rendition,$style);
  $text = $self->_render_section_symbols($text,$rendition,$style);
  $text = $self->_render_emdash($text,$rendition,$style);

  # render spanned content
  $text = $self->_render_underlined_text($text,$rendition,$style);
  $text = $self->_render_superscripted_text($text,$rendition,$style);
  $text = $self->_render_subscripted_text($text,$rendition,$style);
  $text = $self->_render_italicized_text($text,$rendition,$style);
  $text = $self->_render_bold_text($text,$rendition,$style);
  $text = $self->_render_fixed_width_text($text,$rendition,$style);
  $text = $self->_render_file_references($text,$rendition,$style);
  $text = $self->_render_path_references($text,$rendition,$style);
  $text = $self->_render_user_entered_text($text,$rendition,$style);
  $text = $self->_render_commands($text,$rendition,$style);
  $text = $self->_render_email_addresses($text,$rendition,$style);

  return $text;
}

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

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;
