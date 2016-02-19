#!/usr/bin/perl

package SML::Triple;                    # ci-000469

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Entity';                  # ci-000416

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Triple');

######################################################################

=head1 NAME

SML::Triple - a subject, predicate, object triple

=head1 SYNOPSIS

  SML::Triple->new
    (
      subject   => $subject,
      predicate => $predicate,
      object    => $object,
      origin    => $origin,
    );

  $triple->get_subject;                               # Str
  $triple->get_predicate;                             # Str
  $triple->get_object;                                # Str
  $triple->get_origin;                                # Str

  # methods inherited from SML::Entity...

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

An C<SML::Triple> is an C<SML::Entity> that represents a logical
triple (subject, predicate, object triple).

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
   default => 'TRIPLE',
  );

######################################################################

has subject =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_subject',
   required => 1,
  );

=head2 get_subject

Return a scalar text value which is the subject of the triple.

  my $subject = $triple->get_subject;

=cut

######################################################################

has predicate =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_predicate',
   required => 1,
  );

=head2 get_predicate

Return a scalar text value which is the predicate of the triple.

  my $predicate = $triple->get_predicate;

=cut

######################################################################

has object =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_object',
   required => 1,
  );

=head2 get_object

Return a scalar text value which is the object of the triple.

  my $object = $triple->get_object;

=cut

######################################################################

has origin =>
  (
   is       => 'ro',
   isa      => 'SML::Element',
   reader   => 'get_origin',
   required => 1,
  );

=head2 get_origin

Return a scalar text value which is the origin of the triple.

  my $origin = $triple->get_origin;

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
