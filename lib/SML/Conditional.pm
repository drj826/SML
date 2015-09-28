#!/usr/bin/perl

# $Id: Conditional.pm 198 2015-03-09 21:42:49Z drj826@gmail.com $

package SML::Conditional;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Division';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Conditional');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'CONDITIONAL',
  );

######################################################################

has 'token' =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_token',
   required => 1,
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Conditional> - a L<"SML::Division"> that represents content
that may or may not be included in the published document depending on
whether a flag is set.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Division

  my $conditional = SML::Conditional->new
                      (
                        id      => $id,
                        token   => $token,
                        library => $library,
                      );

=head1 DESCRIPTION

A conditional division represents content that may or may not be
included in the published document depending on whether a flag is
set. Conditionals may NOT be nested.

Example:

  ???version-2

  This text is only included in the document if 'version-2' is defined
  using a 'define' element.

  ???version-2

=head1 METHODS

=head2 get_name

=head2 get_type

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
