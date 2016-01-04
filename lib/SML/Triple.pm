#!/usr/bin/perl

package SML::Triple;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Entity';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Triple');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'TRIPLE',
  );

######################################################################

has subject =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_subject',
   required => 1,
  );

######################################################################

has predicate =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_predicate',
   required => 1,
  );

######################################################################

has object =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_object',
   required => 1,
  );

######################################################################

has origin =>
  (
   is       => 'ro',
   isa      => 'SML::Element',
   reader   => 'get_origin',
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

C<SML::Triple> - a logical triple, consisting of (1) a subject,
(2) a predicate, and (3) an object.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Division

  my $triple = SML::Triple->new();

  my $subject   = $triple->get_subject;
  my $predicate = $triple->get_predicate;
  my $object    = $triple->get_object;

=head1 DESCRIPTION

A L<"SML::Triple"> is a L<"SML::Division"> that represents a
logical triple (subjetc, predicate, object triple).

=head1 METHODS

=head2 get_subject

Get the subject of the triple.

=head2 get_predicate

Get the predicate of the triple.

=head2 get_object

Get the object of the triple.

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
