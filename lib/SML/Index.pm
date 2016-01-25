#!/usr/bin/perl

package SML::Index;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Index');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has library =>
  (
   is       => 'ro',
   isa      => 'SML::Library',
   reader   => 'get_library',
   required => 1,
  );

# This is the library object to which the index belongs.

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

  unless ( ref $entry and $entry->isa('SML::IndexEntry') )
    {
      $logger->error("CAN'T ADD ENTRY, NOT AN INDEX ENTRY \'$entry\'");
      return 0;
    }

  my $hash = $self->_get_entry_hash;
  my $term = $entry->get_term;

  $logger->debug("add_entry $term");

  my $library = $self->get_library;
  my $util    = $library->get_util;

  $term = $util->strip_string_markup($term);

  if ( exists $hash->{$term} )
    {
      $logger->error("ENTRY ALREADY IN INDEX \'$term\'");
    }

  $hash->{$term} = $entry;

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

######################################################################

sub has_entry {

  my $self = shift;
  my $term = shift;

  my $hash = $self->_get_entry_hash;

  if ( exists $hash->{$term} )
    {
      return 1;
    }

  return 0;
}

######################################################################

sub get_entry {

  my $self = shift;
  my $term = shift;

  unless ( $self->has_entry($term) )
    {
      $logger->error("NO INDEX ENTRY: \'$term\'");

      return 0;
    }

  my $hash = $self->_get_entry_hash;

  return $hash->{$term};
}

######################################################################

sub get_entry_list {

  my $self = shift;

  my $hash = $self->_get_entry_hash;
  my $list = [];

  foreach my $term ( sort keys %{ $hash } )
    {
      my $entry = $hash->{$term};

      push(@{$list},$entry);
    }

  return $list;
}

######################################################################

sub contains_entries {

  # Return 1 if the index has any entries.

  my $self = shift;

  if ( scalar keys %{ $self->_get_entry_hash } )
    {
      return 1;
    }

  return 0;
}

######################################################################

sub get_group_list {

  my $self = shift;

  return [ sort keys %{ $self->_get_entry_group_hash } ];
}

######################################################################

sub get_group_entry_list {

  # Return a list of entries belonging to a specified group.

  my $self  = shift;
  my $group = shift;

  my $hash = $self->_get_entry_group_hash;

  if ( not exists $hash->{$group} )
    {
      $logger->error("NO INDEX GROUP \'$group\'");
      return 0;
    }

  my $list = [];

  foreach my $term (sort @{ $hash->{$group} })
    {
      my $entry = $self->get_entry($term);

      push(@{$list},$entry);
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

has entry_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_entry_hash',
   default => sub {{}},
  );

#   $hash->{$term} = $entry;

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

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Index> - a list of terms in a special subject, field, or
area of usage, with accompanying definitions.

=head1 VERSION

This documentation refers to L<"SML::Index"> version 2.0.0.

=head1 SYNOPSIS

  my $gloss = SML::Index->new( library => $library );

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
