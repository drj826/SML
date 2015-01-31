#!/usr/bin/perl

# $Id$

package SML::Baretable;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Environment';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Baretable');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'BARETABLE',
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Baretable> - an environment that instructs the publishing
application to insert a baretable into the document

=head1 VERSION

This documentation refers to L<"SML::Baretable"> version 2.0.0.

=head1 SYNOPSIS

  my $bt = SML::Baretable->new();

=head1 DESCRIPTION

An SML baretable environment instructs the publishing application to
insert a baretable into the document.  Baretables are special.  They
don't have begin and end tags and they don't have a preamble.  A
baretable begins with the beginning of a table cell that isn't in a
table and ends with the beginning of a block that (1) isn't a table
cell, and (2) where column = 0 (i.e. immediately following the end of
a row).

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
