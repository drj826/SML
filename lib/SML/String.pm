#!/usr/bin/perl

package SML::String;                    # ci-000438

use Moose;

extends 'SML::Part';                    # ci-000436

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.String');

######################################################################

=head1 NAME

SML::String - a sequence of characters

=head1 SYNOPSIS

  SML::String->new
    (
      name            => $name,
      content         => $content,
      library         => $library,
      containing_part => $part,
    );

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

An C<SML::String> is an C<SML::Part> of a document that is a sequence
of characters.

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
   default  => 'STRING',
  );

######################################################################

has '+content' =>
  (
   required  => 1,
  );

######################################################################

has remaining =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_remaining',
   writer  => 'set_remaining',
   default => q{},
  );

=head2 get_remaining

This is a scalar text value of the text remaining to be parsed into
string objects.  It is used by the parser to track progress in parsing
the content of the string.

  my $remaining = $string->get_remaining;

=head2 set_remaining($text)

Set the text remaining to be parsed into string objects.

  $string->set_remaining($text)

=cut

######################################################################

has containing_division =>
  (
   is       => 'ro',
   isa      => 'SML::Division',
   reader   => 'get_containing_division',
   lazy     => 1,
   builder  => '_build_containing_division',
  );

=head2 get_containing_division

Return the C<SML::Division> that contains this string.

  my $division = $string->get_containing_division;

=cut

######################################################################

has containing_block =>
  (
   is       => 'ro',
   isa      => 'SML::Block',
   reader   => 'get_containing_block',
   builder  => '_build_containing_block',
   lazy     => 1,
  );

=head2 get_containing_block

Return the C<SML::Block> that contains this string.

  my $block = $string->get_containing_block;

=cut

######################################################################

has plain_text =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_plain_text',
   builder => '_build_plain_text',
   lazy    => 1,
  );

=head2 get_plain_text

Return a plain text rendition of this string.

  my $text = $string->get_plain_text;

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_location {

  my $self = shift;

  if ( $self->get_containing_block )
    {
      my $block = $self->get_containing_block;
      return $block->get_location;
    }

  return 'unknown';
}

=head2 get_location

Return a scalar text value that represents the location of this string
in the manuscript text.

  my $location = $string->get_location;

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

sub BUILD {

  my $self = shift;

  if ( $self->has_content )
    {
      $self->set_remaining( $self->get_content );
    }

  return 1;
}

######################################################################

sub _build_containing_division {

  my $self = shift;

  my $block = $self->get_containing_block;

  return $block->get_containing_division;
}

######################################################################

sub _build_containing_block {

  my $self = shift;

  if ( not $self->has_container )
    {
      $logger->error("STRING HAS NO CONTAINER \'$self\'");
      return 0;
    }

  my $container = $self->get_container;

  if ( $container->isa('SML::Block') )
    {
      return $container;
    }

  while ( $container->has_container )
    {
      $container = $container->get_container;

      if ( $container->isa('SML::Block') )
	{
	  return $container;
	}
    }

  $logger->error("THIS SHOULD NEVER HAPPEN");
  return 0;
}

######################################################################

sub _build_plain_text {

  my $self = shift;

  if ( $self->contains_parts )
    {
      my $aref = [];

      foreach my $part (@{ $self->get_part_list })
	{
	  push @{$aref}, $part->get_plain_text;
	}

      return join(' ', @{$aref});
    }

  else
    {
      return $self->get_content;
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
