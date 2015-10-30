#!/usr/bin/perl

# $Id: Outcome.pm 236 2015-03-23 20:22:31Z drj826@gmail.com $

package SML::Outcome;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Element';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Outcome');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has 'date' =>
  (
   isa       => 'Str',
   reader    => 'get_date',
   writer    => 'set_date',
   predicate => 'has_date',
  );

######################################################################

has 'entity_id' =>
  (
   isa       => 'Str',
   reader    => 'get_entity_id',
   writer    => 'set_entity_id',
   predicate => 'has_entity_id',
  );

######################################################################

has 'status' =>
  (
   isa       => 'Str',
   reader    => 'get_status',
   writer    => 'set_status',
   predicate => 'has_status',
  );

######################################################################

has 'description' =>
  (
   isa       => 'Str',
   reader    => 'get_description',
   writer    => 'set_description',
   predicate => 'has_description',
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

C<SML::Outcome> - an element that represents the outcome of an audit
or review.  It includes a date, a status and a description.

=head1 VERSION

This documentation refers to L<"SML::Outcome"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::Element

  my $outcome = SML::Outcome->new(name=>$name,library=>$library);

=head1 DESCRIPTION

An L<"SML::Outcome"> is an L<"SML::Element"> that represents the
outcome of an audit or review.  It includes a date, a status, and a
description.

=head1 METHODS

=head2 get_tag

A tag is a string that uniquely identifies a outcome within the section
in which it occurs.  It is typically a single character such as a
number or letter.

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
