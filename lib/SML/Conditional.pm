#!/usr/bin/perl

package SML::Conditional;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Division';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.conditional');

######################################################################
######################################################################
##
## Attributes
##
######################################################################
######################################################################

has 'token' =>
  (
   is       => 'ro',
   isa      => 'Str',
   required => 1,
  );

######################################################################

# has '+type' =>
#   (
#    default => 'division',
#   );

######################################################################

has '+name' =>
  (
   default => 'CONDITIONAL',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_token {
  my $self = shift;
  return $self->token;
}

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

This documentation refers to L<"SML::Conditional"> version 2.0.0.

=head1 SYNOPSIS

  my $cnd = SML::Conditional->new();

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
