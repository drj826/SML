#!/usr/bin/perl

# $Id: Inline.pm 11633 2012-12-04 23:07:21Z don.johnson $

package SML::Inline;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.inline');

######################################################################
######################################################################
##
## Attributes
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

C<SML::Inline> - one or more partial lines of text.

=head1 VERSION

This documentation refers to L<"SML::Inline"> version 2.0.0.

=head1 SYNOPSIS

  my $inl = SML::Inline->new();

=head1 DESCRIPTION

An inline text element consists of one or more partial lines of
text. Inline elements may be used within paragraphs but not
vice-versa.  An inline text element may not span multiple paragraphs.

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
