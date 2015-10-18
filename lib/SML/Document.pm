#!/usr/bin/perl

# $Id: Document.pm 273 2015-05-11 12:05:04Z drj826@gmail.com $

package SML::Document;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Division';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Document');

use SML::Library;        # ci-000410
use SML::Glossary;

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'DOCUMENT',
  );

######################################################################

has 'glossary' =>
  (
   isa      => 'SML::Glossary',
   reader   => 'get_glossary',
   lazy     => 1,
   builder  => '_build_glossary',
  );

######################################################################

has 'acronym_list' =>
  (
   isa      => 'SML::AcronymList',
   reader   => 'get_acronym_list',
   lazy     => 1,
   builder  => '_build_acronym_list',
  );

######################################################################

has 'references' =>
  (
   isa      => 'SML::References',
   reader   => 'get_references',
   lazy     => 1,
   builder  => '_build_references',
  );

######################################################################

# has 'previous_hash' =>
#   (
#    isa       => 'HashRef',
#    reader    => 'get_previous_hash',
#    writer    => 'set_previous_hash',
#    clearer   => 'clear_previous_hash',
#    predicate => 'has_previous_hash',
#   );

######################################################################

# has 'specials' =>
#   (
#    is        => 'ro',
#    isa       => 'HashRef',
#    writer    => 'set_specials',
#    clearer   => 'clear_specials',
#    predicate => 'has_specials',
#   );

######################################################################

# has 'properties' =>
#   (
#    is        => 'ro',
#    isa       => 'HashRef',
#    default   => sub {{}},
#    writer    => 'set_properties',
#    clearer   => 'clear_properties',
#    predicate => 'has_properties',
#   );

# Allowed properties are defined in the SML ontology.  Every property
# has a name and value.  The value is an anonymous array of elements.

######################################################################

# has 'html_glossary_filename' =>
#   (
#    isa       => 'Str',
#    reader    => 'get_html_glossary_filename',
#    lazy      => 1,
#    builder   => '_build_html_glossary_filename',
#   );

######################################################################

# has 'html_acronyms_filename' =>
#   (
#    isa       => 'Str',
#    reader    => 'get_html_acronyms_filename',
#    lazy      => 1,
#    builder   => '_build_html_acronyms_filename',
#   );

######################################################################

# has 'html_sources_filename' =>
#   (
#    isa       => 'Str',
#    reader    => 'get_html_sources_filename',
#    lazy      => 1,
#    builder   => '_build_html_sources_filename',
#   );

######################################################################

has 'author' =>
  (
   isa       => 'Str',
   reader    => 'get_author',
  );

######################################################################

has 'date' =>
  (
   isa    => 'Str',
   reader => 'get_date',
  );

######################################################################

has 'revision' =>
  (
   isa    => 'Str',
   reader => 'get_revision',
  );

######################################################################

has 'subtitle',           is => 'ro', isa => 'Str';
has 'description',        is => 'ro', isa => 'Str';

has 'editor',             is => 'ro', isa => 'Str';
has 'translator',         is => 'ro', isa => 'Str';

has 'publisher',          is => 'ro', isa => 'Str';
has 'publisher_location', is => 'ro', isa => 'Str';
has 'publisher_logo',     is => 'ro', isa => 'Str';
has 'publisher_address',  is => 'ro', isa => 'Str';

has 'edition',            is => 'ro', isa => 'Str';

has 'biographical_note',  is => 'ro', isa => 'Str';
has 'copyright',          is => 'ro', isa => 'Str';
has 'full_copyright',     is => 'ro', isa => 'Str';
has 'publication_year',   is => 'ro', isa => 'Str';

has 'isbn',               is => 'ro', isa => 'Str';
has 'issn',               is => 'ro', isa => 'Str';
has 'cip_data',           is => 'ro', isa => 'Str';

has 'permissions',        is => 'ro', isa => 'Str';
has 'grants',             is => 'ro', isa => 'Str';

has 'paper_durability',   is => 'ro', isa => 'Str';

has 'dedication',         is => 'ro', isa => 'Str';
has 'epigraph',           is => 'ro', isa => 'Str';
has 'epigraph_source',    is => 'ro', isa => 'Str';

has 'doctype',            is => 'ro', isa => 'Str';
has 'fontsize',           is => 'ro', isa => 'Str';
has 'organization',       is => 'ro', isa => 'Str';
has 'version',            is => 'ro', isa => 'Str';

has 'classification',     is => 'ro', isa => 'Str';
has 'classified_by',      is => 'ro', isa => 'Str';
has 'classif_reason',     is => 'ro', isa => 'Str';
has 'declassify_on',      is => 'ro', isa => 'Str';
has 'handling_caveat',    is => 'ro', isa => 'Str';

has 'priority',           is => 'ro', isa => 'Str';
has 'status',             is => 'ro', isa => 'Str';
has 'attr',               is => 'ro', isa => 'Str';

has 'use_formal_status',  is => 'ro', isa => 'Str';

has 'effort_units',       is => 'ro', isa => 'Str';

has 'var',                is => 'ro', isa => 'Str';

has 'logo_image_left',    is => 'ro', isa => 'Str';
has 'logo_image_center',  is => 'ro', isa => 'Str';
has 'logo_image_right',   is => 'ro', isa => 'Str';

has 'header_left',        is => 'ro', isa => 'Str';
has 'header_left_odd',    is => 'ro', isa => 'Str';
has 'header_left_even',   is => 'ro', isa => 'Str';

has 'header_center',      is => 'ro', isa => 'Str';
has 'header_center_odd',  is => 'ro', isa => 'Str';
has 'header_center_even', is => 'ro', isa => 'Str';

has 'header_right',       is => 'ro', isa => 'Str';
has 'header_right_odd',   is => 'ro', isa => 'Str';
has 'header_right_even',  is => 'ro', isa => 'Str';

has 'footer_left',        is => 'ro', isa => 'Str';
has 'footer_left_odd',    is => 'ro', isa => 'Str';
has 'footer_left_even',   is => 'ro', isa => 'Str';

has 'footer_center',      is => 'ro', isa => 'Str';
has 'footer_center_odd',  is => 'ro', isa => 'Str';
has 'footer_center_even', is => 'ro', isa => 'Str';

has 'footer_right',       is => 'ro', isa => 'Str';
has 'footer_right_odd',   is => 'ro', isa => 'Str';
has 'footer_right_even',  is => 'ro', isa => 'Str';

has 'DEFAULT_RENDITION',       is => 'ro', isa => 'Str';
has 'MAX_SEC_DEPTH',           is => 'ro', isa => 'Str';
has 'MAX_ID_HIERARCHY_DEPTH',  is => 'ro', isa => 'Str';

has 'MAX_PASS_TWO_ITERATIONS', is => 'ro', isa => 'Str';
has 'pass_two_count',          is => 'ro', isa => 'Str';

has 'using_longtable',         is => 'ro', isa => 'Boolean';
has 'using_supertabular',      is => 'ro', isa => 'Boolean';

######################################################################

# has 'text_line_list' =>
#   (
#    isa    => 'ArrayRef',
#    reader => 'get_text_line_list',
#   );

######################################################################

# has 'valid' =>
#   (
#    isa       => 'Bool',
#    reader    => 'is_valid',
#    lazy      => 1,
#    builder   => '_validate_document',
#   );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_note {

  my $self = shift;
  my $note = shift;

  # validate $note is a SML::Note
  if (
      not ref $note
      or
      not $note->isa('SML::Note')
     )
    {
      $logger->error("NOT A NOTE: $note");
    }

  my $divid = q{};

  if ( $note->has_containing_division )
    {
      my $division = $note->get_containing_division;
      $divid = $division->get_id;
    }

  my $tag = $note->get_tag;

  if ( exists $self->_get_note_hash->{$divid}{$tag} )
    {
      $logger->warn("NOTE ALREADY EXISTS: \'$divid\' \'$tag\'");
    }

  $self->_get_note_hash->{$divid}{$tag} = $note;

  return 1;
}

######################################################################

sub add_index_term {

  my $self  = shift;
  my $term  = shift;
  my $divid = shift;

  if ( exists $self->_get_index_hash->{$term} )
    {
      my $index = $self->_get_index_hash->{$term};
      $index->{ $divid } = 1;
    }

  else
    {
      $self->_get_index_hash->{$term} = { $divid => 1 };
    }

  return 1;
}

######################################################################

sub has_note {

  my $self  = shift;
  my $divid = shift;
  my $tag   = shift;

  my $nh = $self->_get_note_hash;

  if ( exists $nh->{$divid}{$tag} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_index_term {

  my $self  = shift;
  my $term  = shift;

  if ( exists $self->_get_index_hash->{$term} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_glossary_term {

  my $self = shift;
  my $term = shift;
  my $alt  = shift || q{};

  if ( defined $self->get_glossary->{$term}{$alt} )
    {
      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub has_acronym {

  my $self = shift;
  my $term = shift;
  my $alt  = shift || q{};

  if ( defined $self->acronyms->{$term}{$alt} )
    {
      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub has_source {

  my $self = shift;
  my $id   = shift;

  if ( defined $self->_get_source_hash->{$id} )
    {
      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub get_acronym_definition {

  my $self    = shift;
  my $acronym = shift;
  my $alt     = shift || q{};

  my $acronyms = $self->acronyms;

  return $acronyms->{$acronym}{$alt};
}

######################################################################

sub get_note {

  my $self  = shift;
  my $divid = shift;
  my $tag   = shift;

  my $nh = $self->_get_note_hash;

  return $nh->{$divid}{$tag};
}

######################################################################

sub get_index_term {

  my $self  = shift;
  my $term  = shift;

  if ( exists $self->_get_index_hash->{$term} )
    {
      return $self->_get_index_hash->{$term};
    }

  else
    {
      # $logger->error("CAN'T GET INDEX TERM");
      return 0;
    }
}

######################################################################

sub replace_division_id {

  # THIS IS A HACK.  I should change the syntax of the division start
  # markup to include the ID so this isn't necessary.  That way the
  # document can remember the correct division ID at the start of the
  # division.

  my $self     = shift;
  my $division = shift;
  my $id       = shift;

  foreach my $stored_id (keys %{ $self->_get_division_hash })
    {
      my $stored_division = $self->_get_division_hash->{$stored_id};
      if ( $stored_division == $division )
	{
	  delete $self->_get_division_hash->{$stored_id};
	  $self->_get_division_hash->{$id} = $division;
	}
    }

  return 1;
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has 'note_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_note_hash',
   default   => sub {{}},
  );

# This data structure contains note text indexed by division ID and
# note tag.

#   my $note = $nh->{section-2}{a};

######################################################################

has 'index_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_index_hash',
   default   => sub {{}},
  );

# Index term data structure.  This is a hash of all index terms.  The
# hash keys are the indexed terms.  The hash values are anonymous
# hashes in which the key is the division ID in which the term
# appears, and the value is simply a boolean.
#
#   $index_ds->{$term} = { $divid_1 => 1, $divid_2 => 1, ... };

######################################################################

has 'table_data_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_table_data_hash',
   default   => sub {{}},
  );

######################################################################

has 'baretable_data_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_baretable_data_hash',
   default   => sub {{}},
  );

######################################################################

has 'source_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_source_hash',
   writer    => '_set_source_hash',
   clearer   => '_clear_source_hash',
   predicate => '_has_source_hash',
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

# sub _validate_document {

#   my $self = shift;

#   my $valid = 1;
#   my $id    = $self->get_id;

#   $logger->debug("validate document $id");

#   $valid = 0 if not $self->has_valid_id_uniqueness;

#   foreach my $block (@{ $self->get_block_list })
#     {
#       $valid = 0 if not $block->has_valid_syntax;
#       $valid = 0 if not $block->has_valid_semantics;
#     }

#   foreach my $element (@{ $self->get_element_list })
#     {
#       $valid = 0 if not $element->has_valid_syntax;
#       $valid = 0 if not $element->has_valid_semantics;
#     }

#   foreach my $division (@{ $self->get_division_list })
#     {
#       next if $division->get_name eq 'document';

#       $valid = 0 if not $division->has_valid_semantics;
#     }

#   if ( $valid )
#     {
#       $logger->info("the document is valid \'$id\'");
#     }

#   else
#     {
#       $logger->warn("THE DOCUMENT IS NOT VALID \'$id\'");
#     }

#   return $valid;
# }

######################################################################

sub _build_glossary {
  my $self = shift;
  return SML::Glossary->new;
}

######################################################################

sub _build_acronym_list {
  my $self = shift;
  return SML::AcronymList->new;
}

######################################################################

sub _build_references {
  my $self = shift;
  return SML::References->new;
}

######################################################################

sub _build_html_glossary_filename {

  my $self  = shift;
  my $docid = $self->get_id;

  return $docid . ".glossary.html";
}

######################################################################

sub _build_html_acronyms_filename {

  my $self  = shift;
  my $docid = $self->get_id;

  return $docid . ".acronyms.html";
}

######################################################################

sub _build_html_sources_filename {

  my $self  = shift;
  my $docid = $self->get_id;

  return $docid . ".source.html";
}

######################################################################

sub _render_html_navigation_pane {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_title_page {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_table_of_contents {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_revisions {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_recent_updates {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_slides {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_sidebars {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_quotations {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_demonstrations {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_exercises {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_listings {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_to_do_items {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_tables {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_figures {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_attachments {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_footnotes {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_glossary {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_acronyms {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_changelog {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_references {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_index {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_document_section {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_copyright_page {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Document> - a written work about a topic

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Division

  my $document = SML::Document->new
                   (
                     id      => $id,
                     library => $library,
                   );

  my $glossary     = $document->get_glossary;
  my $acronym_list = $document->get_acronym_list;
  my $references   = $document->get_references;
  my $string       = $document->get_author;
  my $string       = $document->get_date;
  my $string       = $document->get_revision;
  my $boolean      = $document->is_valid;

  my $boolean      = $document->add_note($note);
  my $boolean      = $document->add_index_term($term,$division_id);
  my $boolean      = $document->has_note($division_id,$tag);
  my $boolean      = $document->has_index_term($term);
  my $boolean      = $document->has_glossary_term($term,$alt);
  my $boolean      = $document->has_acronym($term,$alt);
  my $boolean      = $document->has_source($id);
  my $definition   = $document->get_acronym_definition($acronym,$alt);
  my $note         = $document->get_note($division_id,$tag);
  my $term         = $document->get_index_term($term);
  my $boolean      = $document->replace_division_id($division,$id);

=head1 DESCRIPTION

A document is a written work about a topic.  Documents have types:
book, report, or article. An SML document is composed of a DATA
SEGMENT followed by a NARRATIVE SEGMENT.

=head1 METHODS

=head2 get_glossary

=head2 get_acronym_list

=head2 get_references

=head2 get_author

=head2 get_date

=head2 get_revision

=head2 is_valid

=head2 add_note($note)

=head2 add_index_term($term,$division_id)

=head2 has_note($division_id,$tag)

=head2 has_index_term($term)

=head2 has_glossary_term($term,$alt)

=head2 has_acronym($term,$alt)

=head2 has_source($id)

=head2 get_acronym_definition($acronym,$alt)

=head2 get_note($division_id,$tag)

=head2 get_index_term($term)

=head2 replace_division_id($division,$id)

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
