#!/usr/bin/perl

package SML::Outcome;                   # ci-000459

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Element';                 # ci-000386

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Outcome');

######################################################################

=head1 NAME

SML::Outcome - the result of an audit, test or review

=head1 SYNOPSIS

  SML::Outcome->new(name=>$name,library=>$library);

  $outcome->get_date;                       # Str
  $outcome->set_date($date);                # Bool
  $outcome->has_date;                       # Bool
  $outcome->get_entity_id;                  # Str
  $outcome->set_entity_id($entity_id);      # Bool
  $outcome->has_entity_id;                  # Bool
  $outcome->get_status;                     # Str
  $outcome->set_status($status);            # Bool
  $outcome->has_status;                     # Bool
  $outcome->get_description;                # Str
  $outcome->set_description($description);  # Bool
  $outcome->has_description;                # Bool

=head1 DESCRIPTION

An C<SML::Outcome> is an C<SML::Element> that represents the outcome
of an audit, test or review.  It includes a date, a status, and a
description.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has date =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_date',
   writer    => 'set_date',
   predicate => 'has_date',
  );

=head2 get_date

Return a scalar text value which is the date of the outcome
(yyyy-mm-dd).

  my $date = $outcome->get_date;

=head2 set_date

Set the date of the outcome (yyyy-mm-dd).

  $outcome->set_date($date);

=head2 has_date

Return 1 if this outcome has a date.

  my $result = $outcome->has_date;

=cut

######################################################################

has entity_id =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_entity_id',
   writer    => 'set_entity_id',
   predicate => 'has_entity_id',
  );

=head2 get_entity_id

Return a scalar text value which is the entity_id against which this
outcome was determined.

  my $entity_id = $outcome->get_entity_id;

=head2 set_entity_id

Set the entity_id of the outcome.

  $outcome->set_entity_id($entity_id);

=head2 has_entity_id

Return 1 if this outcome has a entity_id.

  my $result = $outcome->has_entity_id;

=cut

######################################################################

has status =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_status',
   writer    => 'set_status',
   predicate => 'has_status',
  );

=head2 get_status

Return a scalar text value which is the status of the outcome (green,
yellow, red, or grey).

  my $status = $outcome->get_status;

=head2 set_status

Set the status of the outcome (green, yellow, red, or grey).

  $outcome->set_status($status);

=head2 has_status

Return 1 if this outcome has a status.

  my $result = $outcome->has_status;

=cut

######################################################################

has description =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_description',
   writer    => 'set_description',
   predicate => 'has_description',
  );

=head2 get_description

Return a scalar text value which is the description of the outcome.

  my $description = $outcome->get_description;

=head2 set_description

Set the description of the outcome.

  $outcome->set_description($description);

=head2 has_description

Return 1 if this outcome has a description.

  my $result = $outcome->has_description;

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

# NONE

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
