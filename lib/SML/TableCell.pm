#!/usr/bin/perl

package SML::TableCell;                 # ci-000428

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';               # ci-000466

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.TableCell');

######################################################################

=head1 NAME

SML::TableCell - a single table cell

=head1 SYNOPSIS

  SML::TableCell->new
    (
      id               => $id,
      library          => $library,
      emphasis         => $emphasis,
      background_color => $background_color,
      justification    => $justification,
      fontsize         => $fontsize,
    );

  $cell->get_emphasis,                  # Str
  $cell->has_emphasis,                  # Bool
  $cell->get_justification,             # Str
  $cell->has_justification,             # Bool
  $cell->get_background_color,          # Str
  $cell->has_background_color,          # Bool
  $cell->get_fontsize,                  # Str
  $cell->has_fontsize,                  # Bool

  # methods inherited from SML::Structure...

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

An C<SML::TableCell> extends C<SML::Structure> to represent a single
table cell.

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
   default => 'TABLE_CELL',
  );

######################################################################

has emphasis =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_emphasis',
   predicate => 'has_emphasis',
  );

=head2 get_emphasis

Return a scalar text value that, if present indicates the table cell
should be emphasized.  User's may chose to emphasize column header
cells or certain row cells.

  my $emphasis = $cell->get_emphasis;

=head2 has_emphasis

Return 1 if the table cell has an 'emphasis' value.

  my $result = $cell->has_emphasis;

=cut

######################################################################

has justification =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_justification',
   predicate => 'has_justification',
  );

=head2 get_justification

Return a scalar text value which is the horizontal justification of
the table cell content (left, center, or right).

  my $justification = $cell->get_justification.

=head2 has_justification

Return 1 if a value is defined for justification.

  my $result = $cell->has_justification;

=cut

######################################################################

has background_color =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_background_color',
   predicate => 'has_background_color',
  );

=head2 get_background_color

Return a scalar text value which is the background color of the table
cell.

  my $background_color = $cell->get_background_color.

=head2 has_background_color

Return 1 if a value is defined for background color.

  my $result = $cell->has_background_color;

=cut

######################################################################

has fontsize =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_fontsize',
   predicate => 'has_fontsize',
  );

=head2 get_fontsize

Return a scalar text value which is the fontsize of the table cell
text.

  my $fontsize = $cell->get_fontsize.

=head2 has_fontsize

Return 1 if a value is defined for fontsize.

  my $result = $cell->has_fontsize;

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
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
