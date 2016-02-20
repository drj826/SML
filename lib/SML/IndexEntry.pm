#!/usr/bin/perl

package SML::IndexEntry;                # ci-000454

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.IndexEntry');

######################################################################

=head1 NAME

SML::IndexEntry - an index term with a set of locators

=head1 SYNOPSIS

  SML::IndexEntry->new(term=>$term);

  $entry->get_term;                     # Str
  $entry->get_term_string;              # SML::String
  $entry->set_term_string($string);     # Bool
  $entry->get_document;                 # SML::Document
  $entry->has_document;                 # Bool

  $entry->add_locator($locator);        # Bool
  $entry->add_subentry($subentry);      # Bool
  $entry->has_subentry($term);          # Bool
  $entry->get_subentry($term);          # SML::IndexEntry
  $entry->add_cross_ref($other_entry);  # Bool
  $entry->get_locator_list;             # ArrayRef
  $entry->get_location($locator);       # SML::Division
  $entry->has_subentries;               # Bool
  $entry->get_subentry_list;            # ArrayRef

=head1 DESCRIPTION

A index is a list of terms in a special subject, field, or area of
usage, with accompanying definitions.

=head1 METHODS

=cut

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

=head2 get_term

Return a scalar text value which is the term of this index entry.

  my $term = $entry->get_term;

=cut

######################################################################

has term_string =>
  (
   is       => 'ro',
   isa      => 'SML::String',
   reader   => 'get_term_string',
   writer   => 'set_term_string',
  );

=head2 get_term_string

Return an C<SML::String> representation of the index term.

  my $string = $entry->get_term_string;

=head2 set_term_string($string)

Set the term string (must be an C<SML::String> object).

  $entry->set_term_string($string);

=cut

######################################################################

has document =>
  (
   is        => 'ro',
   isa       => 'SML::Document',
   reader    => 'get_document',
   predicate => 'has_document',
  );

=head2 get_document

Return the C<SML::Document> object containing this index entry.

  my $document = $entry->get_document;

=head2 has_document

Return 1 if this index entry has a document which contains it.  (If
this index entry belongs to a library index it won't have an
associated document.)

  my $result = $entry->has_document;

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_locator {

  my $self    = shift;
  my $locator = shift;                  # a division ID

  unless ( $locator )
    {
      $logger->error("CAN'T ADD LOCATOR, MISSING ARGUMENT");
      return 0;
    }

  my $href = $self->_get_locator_hash;

  $href->{$locator} = 1;

  return 1;
}

=head2 add_locator($locator)

Add a locator to this index entry.  A locator is a division ID
identifying a division relevant to the index term. Return 1 if
successful.

  my $result = $entry->add_locator($locator);

=cut

######################################################################

sub add_subentry {

  my $self     = shift;
  my $subentry = shift;

  unless ( $subentry )
    {
      $logger->error("CAN'T ADD SUBENTRY, MISSING ARGUMENT");
      return 0;
    }

  unless ( ref $subentry and $subentry->isa('SML::IndexEntry') )
    {
      $logger->error("NOT AN INDEX ENTRY, CAN'T USE AS SUB ENTRY \'$subentry\'");
      return 0;
    }

  my $term     = $subentry->get_term;
  my $document = $self->get_document;
  my $library  = $document->get_library;
  my $util     = $library->get_util;

  $term = $util->strip_string_markup($term);

  my $href = $self->_get_subentry_hash;

  $href->{$term} = $subentry;

  return 1;
}

=head2 add_subentry($subentry)

Add a subentry (an C<SML::IndexEntry>) to the index entry.  Return 1
if successful. Indexes are allowed to have 3 levels of entries: (1)
entry, (2) subentry, (3) subsubentry.

  my $result = $entry->add_subentry($subentry);

=cut

######################################################################

sub has_subentry {

  my $self = shift;
  my $term = shift;

  my $href = $self->_get_subentry_hash;

  if ( exists $href->{$term} )
    {
      return 1;
    }

  return 0;
}

=head2 has_subentry($term)

Return 1 if the index entry has a subentry for the specified term.

  my $result = $entry->has_subentry($term);

=cut

######################################################################

sub get_subentry {

  my $self = shift;
  my $term = shift;

  my $href = $self->_get_subentry_hash;

  unless ( exists $href->{$term} )
    {
      $logger->error("CAN'T GET SUBENTRY, NO SUBENTRY FOR TERM $term");
      return 0;
    }

  return $href->{$term};
}

=head2 get_subentry($term)

Return the subentry (an C<SML::IndexEntry>) for the specified term.
Throw and error if the entry has no subentry for the specified term.

  my $result = $entry->has_subentry($term);

=cut

######################################################################

sub add_cross_ref {

  # Add a cross reference for this index entry.

  my $self  = shift;
  my $other_entry = shift;                    # cross-referenced entry

  unless ( ref $other_entry and $other_entry->isa('SML::IndexEntry') )
    {
      $logger->error("NOT AN INDEX ENTRY, CAN'T CROSS REFERENCE \'$other_entry\'");
      return 0;
    }

  my $term = $other_entry->get_term;

  my $href = $self->_get_cross_ref_hash;

  $href->{$term} = $other_entry;

  return 1;
}

=head2 add_cross_ref

Add a cross reference between the entry and another entry.  Return 1
if successful.

  my $result = $entry->add_cross_ref($other_entry);

=cut

######################################################################

sub get_locator_list {

  my $self = shift;

  my $href = $self->_get_locator_hash;

  return keys %{ $href };
}

=head2 get_locator_list

Return an ArrayRef to a list of locators (i.e. division IDs) for this
entry.

  my $aref = $entry->get_locator_list;

=cut

######################################################################

sub get_location {

  my $self    = shift;
  my $locator = shift;

  if ( $self->has_document )
    {
      my $document = $self->get_document;
      my $library  = $document->get_library;
      my $division = $library->get_division($locator);
      my $ps       = $library->get_property_store;

      while ( $division )
	{
	  my $division_id = $division->get_id;

	  if ( $ps->has_property($division_id,'title') )
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

=head2 get_location($locator)

Return the titled division (an C<SML::Division>) that contains the
specified locator.

  my $division = $entry->get_location($locator);

=cut

######################################################################

sub has_subentries {

  # Return 1 if this entry has any subentries.

  my $self = shift;

  my $href = $self->_get_subentry_hash;

  if ( scalar keys %{ $href } )
    {
      return 1;
    }

  return 0;
}

=head2 has_subentries

Return 1 if the entry has any subentries.

  my $result = $entry->has_subentries;

=cut

######################################################################

sub get_subentry_list {

  my $self = shift;

  my $aref = [];

  my $href = $self->_get_subentry_hash;

  foreach my $subterm ( sort keys %{ $href } )
    {
      my $subentry = $href->{$subterm};

      push @{$aref}, $subentry;
    }

  return $aref;
}

=head2 get_subentry_list

Return an ArrayRef to a list of subentries alphabetized by subentry
term.

  my $aref = $entry->get_subentry_list;

=cut

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has library =>
  (
   is        => 'ro',
   isa       => 'SML::Library',
   reader    => '_get_library',
   required  => 1,
  );

# This is the library to which this index entry belongs.

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

# $href->{$subterm} = $subentry

######################################################################

has cross_ref_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_cross_ref_hash',
   default => sub {{}},
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub BUILD {

  my $self = shift;

  my $library = $self->_get_library;
  my $parser  = $library->get_parser;
  my $term    = $self->get_term;
  my $string  = $parser->create_string($term);

  $self->set_term_string($string);

  return 1;
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
