#!/usr/bin/perl

# $Id: Environment.pm 192 2015-03-08 13:45:00Z drj826@gmail.com $

package SML::Environment;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Division';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Environment');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

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

C<SML::Environment> - a division that describes the intended format,
structure, or content of the contained blocks of text.

=head1 VERSION

This documentation refers to L<"SML::Environment"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::Division

  my $env = SML::Environment->new();

=head1 DESCRIPTION

An environment is a division that describes the intended format,
structure, or content of the contained blocks of text.  Environments
are composed of a preamble followed by an optional environment
narrative.  Environments may not be nested. Environments may not
contain regions.  Environments commonly have titles, IDs, and
descriptions. Common environments include tables, figures, listings,
and attachments. Contrast with region

=head1 METHODS

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
