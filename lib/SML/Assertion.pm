#!/usr/bin/perl

# $Id: Assertion.pm 194 2015-03-08 13:46:17Z drj826@gmail.com $

package SML::Assertion;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Environment';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Assertion');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'ASSERTION',
  );

######################################################################

has 'subject' =>
  (
   isa      => 'Str',
   reader   => 'get_subject',
   required => 1,
  );

######################################################################

has 'predicate' =>
  (
   isa      => 'Str',
   reader   => 'get_predicate',
   required => 1,
  );

######################################################################

has 'object' =>
  (
   isa      => 'Str',
   reader   => 'get_object',
   required => 1,
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Assertion> - a logical assertion, consisting of (1) a subject,
(2) a predicate, and (3) an object.

=head1 VERSION

This documentation refers to L<"SML::Assertion"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::Environment

  my $assertion = SML::Assertion->new();

  my $subject   = $assertion->get_subject;
  my $predicate = $assertion->get_predicate;
  my $object    = $assertion->get_object;

=head1 DESCRIPTION

A L<"SML::Assertion"> is a L<"SML::Environment"> that represents a
logical assertion (subjetc, predicate, object triple).

=head1 METHODS

=head2 get_subject

Get the subject of the assertion.

=head2 get_predicate

Get the predicate of the assertion.

=head2 get_object

Get the object of the assertion.

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
