#!/usr/bin/perl

package SML::Source;                    # ci-000400

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';               # ci-000466

use namespace::autoclean;

use File::Basename;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Source');

######################################################################

=head1 NAME

SML::Source - a cite-able bibliographic source

=head1 SYNOPSIS

  SML::Source->new
    (
      name    => $name,
      id      => $id,
      library => $library,
    );

  $source->get_basename;                              # Str

  # methods inherited from SML::Structure

  NONE

  # methods inherited from SML::Division...

  $division->get_number;                              # Str
  $division->set_number;                              # Bool
  $division->get_previous_number;                     # Str
  $division->set_previous_number($number);            # Bool
  $division->get_next_number;                         # Str
  $division->set_next_number($number);                # Bool
  $division->get_containing_division;                 # SML::Division
  $division->set_containing_division($division);      # Bool
  $division->has_containing_division;                 # Bool
  $division->get_origin_line;                         # SML::Line
  $division->has_origin_line;                         # Bool
  $division->get_sha_digest;                          # Str

  $division->add_part($part);                         # Bool
  $division->add_attribute($element);                 # Bool
  $division->contains_division_with_id($id);          # Bool
  $division->contains_division_with_name($name);      # Bool
  $division->contains_element_with_name($name);       # Bool
  $division->get_list_of_divisions_with_name($name);  # ArrayRef
  $division->get_list_of_elements_with_name($name);   # ArrayRef
  $division->get_division_list;                       # ArrayRef
  $division->get_block_list;                          # ArrayRef
  $division->get_string_list;                         # ArrayRef
  $division->get_element_list;                        # ArrayRef
  $division->get_line_list;                           # ArrayRef
  $division->get_first_part;                          # SML::Part
  $division->get_first_line;                          # SML::Line
  $division->get_containing_document;                 # SML::Document
  $division->get_location;                            # Str
  $division->get_containing_section;                  # SML::Section
  $division->is_in_a($name);                          # Bool
  $division->get_content;                             # Str

  # methods inherited from SML::Part...

  $part->get_name;                                    # Str
  $part->get_library;                                 # SML::Library
  $part->get_id;                                      # Str
  $part->set_id;                                      # Bool
  $part->set_content;                                 # Bool
  $part->get_content;                                 # Str
  $part->has_content;                                 # Bool
  $part->get_container;                               # SML::Part
  $part->set_container;                               # Bool
  $part->has_container;                               # Bool
  $part->get_part_list;                               # ArrayRef
  $part->is_narrative_part;                           # Bool

  $part->init;                                        # Bool
  $part->contains_parts;                              # Bool
  $part->has_part($id);                               # Bool
  $part->get_part($id);                               # SML::Part
  $part->add_part($part);                             # Bool
  $part->get_narrative_part_list                      # ArrayRef
  $part->get_containing_document;                     # SML::Document
  $part->is_in_section;                               # Bool
  $part->get_containing_section;                      # SML::Section
  $part->render($rendition,$style);                   # Str
  $part->dump_part_structure($indent);                # Str

=head1 DESCRIPTION

An C<SML::Source> is an environment that describes a cite-able
bibliographic source.  The data fields that describe a source are
defined in the core ontology rather than hard-coded here in the class.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'SOURCE',
  );

######################################################################

# has author =>
#   (
#    is        => 'ro',
#    isa       => 'Str',
#    reader    => 'get_author',
#    # writer    => 'set_author',
#    # predicate => 'has_author',
#   );

# =head2 get_author

# The name(s) of the author(s) (in the case of more than one author,
# separated by 'and'.

#   my $author = $source->get_author;

# =cut

######################################################################

# has date =>
#   (
#    is        => 'ro',
#    isa       => 'Str',
#    reader    => 'get_date',
#    # writer    => 'set_date',
#    # predicate => 'has_date',
#   );

# =head2 get_date

# The date.

#   my $date = $source->get_date;

# =cut

######################################################################

# has address =>
#   (
#    is        => 'ro',
#    isa       => 'Str',
#    reader    => 'get_address',
#    # writer    => 'set_address',
#    # predicate => 'has_address',
#   );

# =head2 get_address

# Publisher's address (usually just the city, but can be the full
# address for lesser-known publishers).

#   my $address = $source->get_address;

# =cut

######################################################################

# has annote =>

#   (
#    is        => 'ro',
#    isa       => 'Str',
#    reader    => 'get_annote',
#    # writer    => 'set_annote',
#    # predicate => 'has_annote',
#   );

# =head2 annote

# An annotation for annotated bibliography styles (not typical).

#   my $annote = $source->get_annote;

# =cut

######################################################################

# has booktitle =>
#   (
#    is        => 'ro',
#    isa       => 'Str',
#    reader    => 'get_booktitle',
#    # writer    => 'set_booktitle',
#    # predicate => 'has_booktitle',
#   );

# =head2 get_booktitle

# The title of the book, if only part of it is being cited.

#   my $booktitle = $source->get_booktitle;

# =cut

######################################################################

# has chapter =>
#   (
#    is        => 'ro',
#    isa       => 'Str',
#    reader    => 'get_chapter',
#    # writer    => 'set_chapter',
#    # predicate => 'has_chapter',
#   );

# =head2 chapter

# The chapter number.

#   my $chapter = $source->get_chapter;

# =cut

######################################################################

# has crossref =>
#   (
#    is        => 'ro',
#    isa       => 'Str',
#    reader    => 'get_crossref',
#    # writer    => 'set_crossref',
#    # predicate => 'has_crossref',
#   );

# =head2 crossref

# The key of the cross-referenced entry.

#   my $crossref = $source->get_crossref;

# =cut

######################################################################

# has edition =>
#   (
#    is        => 'ro',
#    isa       => 'Str',
#    reader    => 'get_edition',
#    # writer    => 'set_edition',
#    # predicate => 'has_edition',
#   );

# =head2 get_edition

# The edition of a book, long form (such as "First" or "Second").

#   my $edition = $source->get_edition;

# =cut

######################################################################

# has editor =>
#   (
#    is        => 'ro',
#    isa       => 'Str',
#    reader    => 'get_editor',
#    # writer    => 'set_editor',
#    # predicate => 'has_editor',
#   );

# =head2 get_editor

# The name(s) of the editor(s).

#   my $editor = $source->get_editor;

# =cut

######################################################################

# has howpublished =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_howpublished',
#   );

# =head2 get_howpublished

# How it was published, if the publishing method is nonstandard.

#   my $howpublished = $source->get_howpublished;

# =cut

######################################################################

# has institution =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_institution',
#   );

# =head2 get_institution

# The institution that was involved in the publishing, but not
# necessarily the publisher.

#   my $institution = $source->get_institution;

# =cut

######################################################################

# has journal =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_journal',
#   );

# =head2 get_journal

# The journal or magazine the work was published in.

#   my $journal = $source->get_journal;

# =cut

######################################################################

# has key =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_key',
#   );

# =head2 get_key

# A hidden field used for specifying or overriding the alphabetical
# order of entries (when the "author" and "editor" fields are
# missing). Note that this is very different from the key that is used
# to cite or cross-reference the entry.

#   my $key = $source->get_key;

# =cut

######################################################################

# has month =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_month',
#   );

# =head2 get_month

# The month of publication (or, if unpublished, the month of creation).

#   my $month = $source->get_month;

# =cut

######################################################################

# has note =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_note',
#   );

# =head2 get_note

# Miscellaneous extra information.

#   my $note = $source->get_note;

# =cut

######################################################################

# has organization =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_organization',
#   );

# =head2 get_organization

# The conference sponsor.

#   my $organization = $source->get_organization;

# =cut

######################################################################

# has pages =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_pages',
#   );

# =head2 get_pages

# Page numbers, separated either by commas or double-hyphens.

#   my $pages = $source->get_pages;

# =cut

######################################################################

# has publisher =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_publisher',
#   );

# =head2 get_publisher

# The publisher's name.

#   my $publisher = $source->get_publisher;

# =cut

######################################################################

# has school =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_school',
#   );

# =head2 get_school

# The school where the thesis was written.

#   my $school = $source->get_school;

# =cut

######################################################################

# has series =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_series',
#   );

# =head2 get_series

# The series of books the book was published in (e.g. "The Hardy Boys"
# or "Lecture Notes in Computer Science")

#   my $series = $source->get_series;

# =cut

######################################################################

# has source =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_source',
#   );

######################################################################

# has subtitle =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_subtitle',
#   );

######################################################################

# has source_type =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_source_type',
#   );

# =head2 source_type

# The field overriding the default type of publication (e.g. "Research
# Note" for techreport, "{PhD} dissertation" for phdthesis, "Section"
# for inbook/incollection)

#   my $source_type = $source->get_source_type;

# =cut

######################################################################

# has volume =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_volume',
#   );

# =head2 get_volume

# The volume of a journal or multi-volume book.

#   my $volume = $source->get_volume;

# =cut

######################################################################

# has year =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_year',
#   );

# =head2 get_year

# The year of publication (or, if unpublished, the year of creation)

#   my $year = $source->get_year.

# =cut

######################################################################

# has appearance =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_appearance',
#   );

######################################################################

# has color =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_color',
#   );

######################################################################

# has icon =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_icon',
#   );

######################################################################

# has mimetype =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_mimetype',
#   );

######################################################################

# has file =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_file',
#   );

######################################################################

# has number =>
#   (
#    is     => 'ro',
#    isa    => 'Str',
#    reader => 'get_number',
#   );

# =head2 get_number

# The "(issue) number" of a journal, magazine, or tech-report, if
# applicable. (Most publications have a "volume", but no "number"
# field.)

#   my $number = $source->get_number;

# =cut

######################################################################

has basename =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_basename',
   builder => '_build_basename',
   lazy    => 1,
  );

=head2 get_basename

Return a scalar text value which is the base filename for the value of
the "file" property.

  my $basename = $source->get_basename;

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _build_basename {

  my $self = shift;

  my $library = $self->get_library;
  my $id      = $self->get_id;
  my $ps      = $library->get_property_store;

  if ( $ps->has_property($id,'file') )
    {
      my $filespec = $ps->get_property_text($id,'file');

      return basename($filespec);
    }

  else
    {
      return 0;
    }
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012-2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
