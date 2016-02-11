#!/usr/bin/perl

package SML::CrossReference;            # ci-000443

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.CrossReference');

######################################################################

=head1 NAME

SML::CrossReference - reference another location in a library

=head1 SYNOPSIS

  SML::CrossReference->new
    (
      tag             => $tag,
      target_id       => $target_id,
      library         => $library,
      containing_part => $part,
    );

  $ref->get_tag;                        # Str
  $ref->get_target_id;                  # Str

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

SML::CrossReference Extends L<SML::String> to represent a reference to
another location in the library.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has tag =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_tag',
   required => 1,
  );

=head2 get_tag

Return a scalar text value which is the cross reference tag.

  my $tag = $cross_ref->get_tag;

For example, if the cross reference is C<[ref:fig-main-window]> then
the tag is C<ref>.

The tag value, either C<ref> or simply C<r> has no significance in the
current syntax.

=cut

######################################################################

has target_id =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_target_id',
   required => 1,
  );

=head2 get_target_id

Return a scalar text value which is the ID of the reference target.

  my $id = $cross_ref->get_target_id;

For example, if the cross reference is C<[ref:fig-main-window]> then
the target ID is C<fig-main-window>.

=cut

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'CROSS_REF',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_target_part {

  # Return the SML::Part object the target ID points to.

  my $self = shift;

  my $id       = $self->get_target_id;
  my $document = $self->get_containing_document;

  unless ( $document->has_part($id) )
    {
      $logger->error("CAN'T GET TARGET PART: $id NOT IN DOCUMENT");

      return 0;
    }

  return $document->get_part($id);
}

=head2 get_target_part

Return the part which is the target of the reference.

  my $part = $cross_ref->get_target_part.

For example if the cross reference is C<[ref:fig-main-window]> then
C<get_target_part> might return the SML::Figure object referenced.

=cut

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

=head2 get_tag

=head2 get_target_id

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
