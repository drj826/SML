#!/usr/bin/perl

package SML::Epigraph;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Environment';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.epigraph');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'epigraph',
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Epigraph> - an L<"SML::Environment"> that tells the publishing
application to render the content text as an epigraph.

=head1 VERSION

This documentation refers to L<"SML::Epigraph"> version 2.0.0.

=head1 SYNOPSIS

  my $epi = SML::Epigraph->new();

=head1 DESCRIPTION

An epigraph is an environment that tells the publishing application to
render the content text as an epigraph.  An epigraph is a quotation at
the beginning of a book, chapter, etc. suggesting its theme.

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
