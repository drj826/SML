#!/usr/bin/perl

package SML::Index;                     # ci-000453

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Index');

######################################################################

=head1 NAME

SML::Index - an index of terms

=head1 SYNOPSIS

  SML::Index->new(library=>$library);

  $index->add_entry($entry);            # Bool
  $index->has_entry($term);             # Bool
  $index->get_entry($term);             # SML::IndexEntry
  $index->get_entry_list;               # ArrayRef
  $index->contains_entries;             # Bool
  $index->get_group_list;               # ArrayRef
  $index->get_group_entry_list($group); # ArrayRef

=head1 DESCRIPTION

A index is an alphabetized list of terms with accompanying locators to
help you find information in the text.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_entry {

  my $self  = shift;
  my $entry = shift;

  unless ( $entry )
    {
      $logger->error("CAN'T ADD ENTRY, MISSING ARGUMENT");
      return 0;
    }

  unless ( ref $entry and $entry->isa('SML::IndexEntry') )
    {
      $logger->error("CAN'T ADD ENTRY, NOT AN INDEX ENTRY \'$entry\'");
      return 0;
    }

  my $href    = $self->_get_entry_hash;
  my $term    = $entry->get_term;
  my $library = $self->_get_library;
  my $util    = $library->get_util;

  $term = $util->strip_string_markup($term);

  if ( exists $href->{$term} )
    {
      $logger->error("ENTRY ALREADY IN INDEX \'$term\'");
    }

  $href->{$term} = $entry;

  # Add this entry to the entry group hash.
  my $group      = lc(substr($term,0,1));
  my $group_hash = $self->_get_entry_group_hash;

  if ( not exists $group_hash->{$group} )
    {
      $group_hash->{$group} = [];
    }

  push(@{$group_hash->{$group}},$term);

  return 1;
}

=head2 add_entry($entry)

Add an entry (an C<SML::IndexEntry>) to the index.  Return 1 if
successful.

  my $result = $index->add_entry($index_entry);

=cut

######################################################################

sub has_entry {

  my $self = shift;
  my $term = shift;

  my $href = $self->_get_entry_hash;

  if ( exists $href->{$term} )
    {
      return 1;
    }

  return 0;
}

=head2 has_entry($term)

return 1 if the index contains an entry for the specified term.

  my $result = $index->has_entry($term);

=cut

######################################################################

sub get_entry {

  my $self = shift;
  my $term = shift;

  unless ( $self->has_entry($term) )
    {
      $logger->error("NO INDEX ENTRY: \'$term\'");

      return 0;
    }

  my $href = $self->_get_entry_hash;

  return $href->{$term};
}

=head2 get_entry($term)

Return the entry (an C<SML::IndexEntry>) for the specified term.
Throw an error if the specified term is not in the index.

  my $entry = $index->get_entry($term);

=cut

######################################################################

sub get_entry_list {

  my $self = shift;

  my $href = $self->_get_entry_hash;
  my $aref = [];

  foreach my $term ( sort keys %{ $href } )
    {
      my $entry = $href->{$term};

      push(@{$aref},$entry);
    }

  return $aref;
}

=head2 get_entry_list

Return an ArrayRef to a list of index entries alphabetized by term.

  my $aref = $index->get_entry_list;

=cut

######################################################################

sub contains_entries {

  my $self = shift;

  if ( scalar keys %{ $self->_get_entry_hash } )
    {
      return 1;
    }

  return 0;
}

=head2 contains_entries

Return 1 if the index contains any entries.

  my $result = $index->contains_entries;

=cut

######################################################################

sub get_group_list {

  my $self = shift;

  return [ sort keys %{ $self->_get_entry_group_hash } ];
}

=head2 get_group_list

Return an ArrayRef to a list of groups in the index.  Index entries
are grouped by the first character of terms.

  my $aref = $index->get_group_list;

=cut

######################################################################

sub get_group_entry_list {

  my $self  = shift;
  my $group = shift;

  my $href = $self->_get_entry_group_hash;

  if ( not exists $href->{$group} )
    {
      $logger->error("NO INDEX GROUP \'$group\'");
      return 0;
    }

  my $aref = [];

  foreach my $term (sort @{ $href->{$group} })
    {
      my $entry = $self->get_entry($term);

      push(@{$aref},$entry);
    }

  return $aref;
}

=head2 get_group_entry_list($group)

Return an ArrayRef to a list of entries belonging to the specified
group.

  my $aref = $index->get_group_entry_list($group);

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
   is       => 'ro',
   isa      => 'SML::Library',
   reader   => '_get_library',
   required => 1,
  );

# This is the library object to which the index belongs.

######################################################################

has entry_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_entry_hash',
   default => sub {{}},
  );

#   $href->{$term} = $entry;

######################################################################

has entry_group_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_entry_group_hash',
   default => sub {{}},
  );

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
