#!/usr/bin/perl

package SML::References;                # ci-000463

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.References');

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

  my $self   = shift;
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

######################################################################

sub has_source {

  my $self = shift;
  my $id   = shift;

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

######################################################################

sub contains_entries {

  my $self = shift;

  if ( values %{ $self->_get_source_hash } )
    {
      return 1;
    }

  return 0;
}

######################################################################

sub get_source {

  my $self = shift;
  my $id   = shift;

  unless ( defined $self->_get_source_hash->{$id} )
    {
      $logger->error("CAN'T GET SOURCE \'$id\'");

      return 0;
    }

  return $self->_get_source_hash->{$id};
}

######################################################################

sub get_sources {

  my $self = shift;
  my $id   = shift;

  unless ( values %{ $self->_get_source_hash } )
    {
      $logger->error("CAN'T GET SOURCES \'$id\'");

      return 0;
    }

  return $self->_get_source_hash;
}

######################################################################

sub get_entry_count {

  # Return the number of sources in this source references list.

  my $self = shift;

  return scalar keys %{ $self->_get_source_hash }
}

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

=head1 NAME

C<SML::References> - a list of cited references.

=head1 VERSION

This documentation refers to L<"SML::References"> version 2.0.0.

=head1 SYNOPSIS

  my $refs = SML::References->new();

=head1 DESCRIPTION

A references object remembers information about referenced sources.

=head1 METHODS

=head2 add_source

=head2 has_source

=head2 get_source

=head2 get_sources

=head2 replace_division_id

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
