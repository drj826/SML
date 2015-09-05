#!/usr/bin/perl

# $Id: References.pm 77 2015-01-31 17:48:03Z drj826@gmail.com $

package SML::References;

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

has 'source_hash' =>
  (
   isa     => 'HashRef',
   reader  => 'get_source_hash',
   default => sub {{}},
  );

# This hash is indexed by source ID.
#
#   $sources->{$id} = $source;

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
  my $id     = $source->get_id;

  $self->get_source_hash->{$id} = $source;

  return 1;
}

######################################################################

sub has_source {

  my $self = shift;
  my $id   = shift;

  if ( defined $self->get_source_hash->{$id} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_sources {

  my $self = shift;
  my $id   = shift;

  if ( values %{ $self->get_source_hash } )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_source {

  my $self = shift;
  my $id   = shift;

  if ( defined $self->get_source_hash->{$id} )
    {
      return $self->get_source_hash->{$id};
    }

  else
    {
      $logger->error("CAN'T GET SOURCE \'$id\'");
      return 0;
    }
}

######################################################################

sub get_sources {

  my $self = shift;
  my $id   = shift;

  if ( values %{ $self->get_source_hash } )
    {
      return $self->get_source_hash;
    }

  else
    {
      $logger->error("CAN'T GET SOURCES \'$id\'");
      return 0;
    }
}

######################################################################

sub replace_division_id {

  # This is a hack.  I should change the syntax of the source start
  # markup to include the ID so this isn't necessary.  That way the
  # library can remember the correct ID at the start of the source.

  my $self   = shift;
  my $source = shift;
  my $id     = shift;

  foreach my $stored_id (keys %{ $self->get_source_hash })
    {
      my $stored_source = $self->get_source_hash->{$stored_id};
      if ( $stored_source == $source )
	{
	  delete $self->get_source_hash->{$stored_id};
	  $self->get_source_hash->{$id} = $source;
	}
    }

  return 1;
}

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

=head2 get_source_hash

=head2 add_source

=head2 has_source

=head2 has_sources

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
