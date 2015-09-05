#!/usr/bin/perl

# $Id: StatusReference.pm 230 2015-03-21 17:50:52Z drj826@gmail.com $

package SML::StatusReference;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.StatusReference');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has 'entity_id' =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_entity_id',
   required => 1,
  );

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'STATUS_REF',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

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

C<SML::StatusReference> - either a color or a reference to an entity
ID that renders the current status color of the entity (red, yellow,
green, or grey)

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [status:rq-000001]

  my $ref = SML::StatusReference->new
              (
                entity_id       => $entity_id,  # 'rq-000001'
                library         => $library,
                containing_part => $part,
              );

  my $id = $ref->get_entity_id;  # 'rq-000001'

=head1 DESCRIPTION

Extends C<SML::String> to represent either a status color (red,
yellow, green or grey) or a reference to an ID that renders the
current status color of the entity.

=head1 METHODS

=head2 get_entity_id

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
