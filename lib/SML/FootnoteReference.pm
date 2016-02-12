#!/usr/bin/perl

package SML::FootnoteReference;         # ci-000448

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.FootnoteReference');

######################################################################

=head1 NAME

SML::FootnoteReference - a reference to a footnote

=head1 SYNOPSIS

  SML::FootnoteReference->new
    (
      section_id      => $section_id,
      number          => $number,
      library         => $library,
      containing_part => $part,
    );

  $ref->get_section_id;                 # Str
  $ref->get_number;                     # Str

  # methods inherited from SML::String...

  $string->get_remaining;               # Str
  $string->set_remaining;               # Bool
  $string->get_containing_division;     # SML::Division
  $string->get_containing_block;        # SML::Block
  $string->get_plain_text;              # Str

  $string->get_location;                # Str

  # methods inherited from SML::Part...

  $part->get_name;                      # Str
  $part->get_library;                   # SML::Library
  $part->get_id;                        # Str
  $part->set_id;                        # Bool
  $part->set_content;                   # Bool
  $part->get_content;                   # Str
  $part->has_content;                   # Bool
  $part->get_container;                 # SML::Part
  $part->set_container;                 # Bool
  $part->has_container;                 # Bool
  $part->get_part_list;                 # ArrayRef
  $part->is_narrative_part;             # Bool

  $part->init;                          # Bool
  $part->contains_parts;                # Bool
  $part->has_part($id);                 # Bool
  $part->get_part($id);                 # SML::Part
  $part->add_part($part);               # Bool
  $part->get_narrative_part_list        # ArrayRef
  $part->get_containing_document;       # SML::Document
  $part->is_in_section;                 # Bool
  $part->get_containing_section;        # SML::Section
  $part->render($rendition,$style);     # Str
  $part->dump_part_structure($indent);  # Str

=head1 DESCRIPTION

A C<SML::FootnoteReference> extends C<SML::String> to represent a
reference to a footnote.

=head1 METHODS

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has section_id =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_section_id',
   required => 1,
  );

=head2 get_section_id

Return a scalar text value which is the ID of the section containing
the referenced footnote.

  my $section_id = $ref->get_section_id;

=cut

######################################################################

has number =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_number',
   required => 1,
  );

=head2 get_number

Return a scalar text value which is the number of the referenced
footnote.  The number doesn't have to be a number.  It could be a
letter or even multiple characters.

  my $number = $ref->get_number;

=cut

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'FOOTNOTE_REF',
  );

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

# NONE

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
