#!/usr/bin/perl

# $Id$

package SML::Entity;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Region';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Entity');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

# has '+type' =>
#   (
#    default => 'region',
#   );

######################################################################

has 'basename' =>
  (
   isa       => 'Str',
   reader    => 'get_basename',
   writer    => 'set_basename',
   clearer   => 'clear_basename',
   predicate => 'has_basename',
  );

# This is the base filename.  It is the same as the basename of the
# primary SML entity file.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub validate {

  my $self  = shift;
  my $valid = 1;

  foreach my $block (@{ $self->get_block_list })
    {
      if ( not $block->validate_syntax ) {
	$self->set_valid(0);
	$valid = 0;
      }
    }

  foreach my $element (@{ $self->get_element_list })
    {
      if ( not $element->validate_syntax ) {
	$self->set_valid(0);
	$valid = 0;
      }

      if ( not $element->validate_resource_availability ) {
	$self->set_valid(0);
	$valid = 0;
      }
    }

  foreach my $division (@{ $self->get_division_list })
    {
      if ( not $division->validate_semantics ) {
	$self->set_valid(0);
	$valid = 0;
      }

      if ( not $division->validate_composition ) {
	$self->set_valid(0);
	$valid = 0;
      }
    }

  if ( $self->is_valid )
    {
      $logger->info('the entity is valid');
    }

  else
    {
      $logger->warn('THE ENTITY IS NOT VALID');
    }

  return $valid;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Entity> - a region that represents content with semantic
meaning.

=head1 VERSION

This documentation refers to L<"SML::Entity"> version 2.0.0.

=head1 SYNOPSIS

  my $ent = SML::Entity->new();

=head1 DESCRIPTION

An SML entity is a region that represents content with semantic
meaning.  Entities are often somehow related to other entities. Common
entities include problems, solutions, tests, results, tasks, and
roles.

=head1 METHODS

=head2 get_name

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
