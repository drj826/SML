#!/usr/bin/perl

package SML::Listing;                   # ci-000397

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';               # ci-000466

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Listing');

######################################################################

=head1 NAME

SML::Listing - a test listing

=head1 SYNOPSIS

  SML::Listing->new();

  $listing->get_content;                              # Str

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
  OVERRIDDEN: $division->get_content;                 # Str

  # methods inherited from SML::Part...

  $part->get_name;                                    # Str
  $part->get_library;                                 # SML::Library
  $part->get_id;                                      # Str
  $part->set_id;                                      # Bool
  $part->set_content;                                 # Bool
  OVERRIDDEN: $part->get_content;                     # Str
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

An SML listing is a document structure that presents a text listing.
Listed text often has a special syntax as with code or marked up text.

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
   default => 'LISTING',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_content {

  my $self = shift;

  my $library = $self->get_library;
  my $id      = $self->get_id;
  my $ps      = $library->get_property_store;

  if ( $ps->has_property($id,'file') )
    {
      my $filespec = $ps->get_property_text($id,'file');

      my $file = SML::File->new
	(
	 filespec => $filespec,
	 library  => $library,
	);

      return $file->get_text;
    }

  else
    {
      my $text = q{};

      foreach my $part (@{ $self->get_narrative_part_list })
	{
	  my $name = $part->get_name;

	  next if $name eq 'BEGIN_DIVISION';
	  next if $name eq 'END_DIVISION';

	  $text .= $part->get_content;
	}

      return $text;
    }

  return 0;
}

=head2 get_content

Return a scalar text value of the plain text content of the listing.

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
