#!/usr/bin/perl

# $Id: IndexEntry.pm 214 2015-03-13 21:03:43Z drj826@gmail.com $

package SML::IndexEntry;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.IndexEntry');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has term =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_term',
   required => 1,
  );

######################################################################

has document =>
  (
   is        => 'ro',
   isa       => 'SML::Document',
   reader    => 'get_document',
   predicate => 'has_document',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_locator {

  # Add a locator (i.e. a division ID) where the term is discussed in
  # the document.

  my $self    = shift;
  my $locator = shift;                  # a division ID

  my $hash = $self->_get_locator_hash;

  $hash->{$locator} = 1;

  return 1;
}

######################################################################

sub add_subentry {

  # Add an index subentry to this one.

  my $self     = shift;
  my $subentry = shift;

  if (
      (not ref $subentry)
      or
      (not $subentry->isa('SML::IndexEntry'))
     )
    {
      $logger->error("NOT AN INDEX ENTRY, CAN'T USE AS SUB ENTRY \'$subentry\'");
      return 0;
    }

  my $term = $subentry->get_term;
  my $hash = $self->_get_subentry_hash;

  $hash->{$term} = $subentry;

  return 1;
}

######################################################################

sub has_subentry {

  my $self = shift;
  my $term = shift;

  my $hash = $self->_get_subentry_hash;

  if ( exists $hash->{$term} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_subentry {

  my $self = shift;
  my $term = shift;

  my $hash = $self->_get_subentry_hash;

  if ( exists $hash->{$term} )
    {
      return $hash->{$term};
    }

  else
    {
      return 0;
    }
}

######################################################################

sub add_cross_ref {

  # Add a cross reference for this index entry.

  my $self  = shift;
  my $entry = shift;                    # cross-referenced entry

  if (
      (not ref $entry)
      or
      (not $entry->isa('SML::IndexEntry'))
     )
    {
      $logger->error("NOT AN INDEX ENTRY, CAN'T CROSS REFERENCE \'$entry\'");
      return 0;
    }

  my $list = $self->_get_cross_ref_hash;

  push(@{$list},$entry);

  return 1;
}

######################################################################

sub get_locator_list {

  my $self = shift;

  my $hash = $self->_get_locator_hash;

  return keys %{ $hash };
}

######################################################################

sub get_location {

  # Return the titled division that contains the specified locator.

  my $self    = shift;
  my $locator = shift;

  if ( $self->has_document )
    {
      my $document = $self->get_document;
      my $library  = $document->get_library;
      my $division = $library->get_division($locator);

      while ( $division )
	{
	  my $division_id = $division->get_id;

	  if ( $library->has_property($division_id,'title') )
	    {
	      return $division;
	    }

	  $division = $division->get_containing_division;
	}

      $logger->error("NO TITLED DIVISION CONTAINS \'$locator\'");
      return 0;
    }

  $logger->error("INDEX ENTRY HAS NO DOCUMENT TO DETERMINE LOCATION OF $locator");
  return 0;
}

######################################################################

sub has_subentries {

  # Return 1 if this entry has any subentries.

  my $self = shift;

  my $hash = $self->_get_subentry_hash;

  if ( scalar keys %{ $hash } )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_subentry_list {

  my $self = shift;

  my $list = [];

  my $hash = $self->_get_subentry_hash;

  foreach my $subterm ( sort keys %{ $hash } )
    {
      my $subentry = $hash->{$subterm};

      push(@{$list},$subentry);
    }

  return $list;
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has locator_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_locator_hash',
   default => sub {{}},
  );

######################################################################

has subentry_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_subentry_hash',
   default => sub {{}},
  );

######################################################################

has cross_ref_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => 'get_cross_ref_hash',
   default => sub {{}},
  );

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

__END__

=head1 NAME

C<SML::IndexEntry> - a term with a set of locators where the term is
discussed in a document.

=head1 VERSION

This documentation refers to L<"SML::IndexEntry"> version 2.0.0.

=head1 SYNOPSIS

  my $entry = SML::IndexEntry->new();

=head1 DESCRIPTION

A index is a list of terms in a special subject, field, or area of
usage, with accompanying definitions.

=head1 METHODS

=head2 add_entry

Add a index entry.

=head2 has_entry

Check whether a specific index entry exists.

=head2 get_entry

Return a specific index entry.

=head2 get_entry_list

Return an alphabetically sorted list of all index entries.

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
