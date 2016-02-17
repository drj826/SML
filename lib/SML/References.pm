#!/usr/bin/perl

package SML::References;                # ci-000463

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.References');

######################################################################

=head1 NAME

SML::References - a list of source references

=head1 SYNOPSIS

  SML::References->new();

  $references->add_source($source);     # Bool
  $references->has_source($id);         # Bool
  $references->contains_entries;        # Bool
  $references->get_source($id);         # SML::Source
  $references->get_entry_count;         # Int
  $references->get_entry_list;          # ArrayRef

=head1 DESCRIPTION

An C<SML::References> object remembers information about referenced
sources.

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

sub add_source {

  my $self = shift;

  my $source = shift;

  unless ( $source )
    {
      $logger->error("CAN'T ADD SOURCE, MISSING ARGUMENT");
      return 0;
    }

  unless ( ref $source and $source->isa('SML::Source') )
    {
      $logger->error("CAN'T ADD SOURCE, NOT A SOURCE $source");
      return 0;
    }

  my $id = $source->get_id;

  my $href = $self->_get_source_hash;

  $href->{$id} = $source;

  return 1;
}

=head2 add_source

Add an C<SML::Source> to the list of references.

  my $result = $references->add_source($source);

=cut

######################################################################

sub has_source {

  my $self = shift;

  my $id = shift;

  unless ( $id )
    {
      $logger->error("CAN'T CHECK FOR SOURCE, MISSING ARGUMENT");
      return 0;
    }

  if ( defined $self->_get_source_hash->{$id} )
    {
      return 1;
    }

  return 0;
}

=head2 has_source

Return 1 if the specified source is in the list of references.

  my $result = $references->has_source($id);

=cut

######################################################################

sub contains_entries {

  my $self = shift;

  if ( values %{ $self->_get_source_hash } )
    {
      return 1;
    }

  return 0;
}

=head2 contains_entries

Return 1 if the references list contains any entries.

  my $result = $references->contains_entries;

=cut

######################################################################

sub get_source {

  my $self = shift;

  my $id = shift;

  unless ( defined $self->_get_source_hash->{$id} )
    {
      $logger->error("CAN'T GET SOURCE \'$id\'");

      return 0;
    }

  return $self->_get_source_hash->{$id};
}

=head2 get_source

Return the C<SML::Source> with the specified ID.

  my $source = $references->get_source($id);

=cut

######################################################################

# sub get_sources {

#   my $self = shift;
#   my $id   = shift;

#   unless ( values %{ $self->_get_source_hash } )
#     {
#       $logger->error("CAN'T GET SOURCES \'$id\'");

#       return 0;
#     }

#   return $self->_get_source_hash;
# }

######################################################################

sub get_entry_count {

  # Return the number of sources in this source references list.

  my $self = shift;

  return scalar keys %{ $self->_get_source_hash }
}

=head2 get_entry_count

Return an integer count of the number of entries in the references
list.

  my $count = $references->get_entry_count;

=cut

######################################################################

sub get_entry_list {

  # Return a list of sources in this source references list.

  my $self = shift;

  my $href = $self->_get_source_hash;
  my $aref = [];

  foreach my $id ( sort keys %{$href} )
    {
      push @{$aref}, $href->{$id};
    }

  return $aref;
}

=head2 get_entry_list

Return an ArrayRef to a list of entries in the references list.

  my $aref = $references->get_entry_list;

=cut

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has source_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_source_hash',
   default => sub {{}},
  );

# This hash is indexed by source ID.
#
#   $sources->{$id} = $source;

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
