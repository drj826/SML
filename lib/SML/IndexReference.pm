#!/usr/bin/perl

package SML::IndexReference;            # ci-000455

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.IndexReference');

######################################################################

=head1 NAME

SML::IndexReference - a reference to an index term

=head1 SYNOPSIS

  SML::IndexReference->new
    (
      tag             => $tag,
      term            => $term,
      library         => $library,
      containing_part => $part,
    );

  $ref->get_tag;                        # Str
  $ref->get_term;                       # Str

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

An C<SML::IndexReference> extends C<SML::String> to represent a
reference to an index term.

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

Return a scalar text value which is the tag of the reference (either
'index' or just 'i').  The tag has no significance one way or the
other so I'm not sure why I provided an accessor to the tag.

  my $tag = $ref->get_tag;

=cut

######################################################################

has term =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_term',
   required => 1,
  );

=head2 get_term

Return a scalar text value which is the term of the reference.  This
is the term that should be added to the index with a locator pointing
to the location of the reference.

  my $term = $ref->get_term;

=cut

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'INDEX_REF',
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
