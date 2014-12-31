#!/usr/bin/perl

package SML::Demo;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Region';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Demo');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'demo',
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Demo> - a region that represents a demonstration that an
instructor might give during a classroom presentation.

=head1 VERSION

This documentation refers to L<"SML::Demo"> version 2.0.0.

=head1 SYNOPSIS

  my $demo = SML::Demo->new();

=head1 DESCRIPTION

An SML demo is a region that represents a demonstration that an
instructor might give during a classroom presentation. Demos are
expressed as regions to they may contain environments like tables and
figures.

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
