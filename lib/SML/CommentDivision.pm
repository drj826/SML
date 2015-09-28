#!/usr/bin/perl

# $Id: CommentDivision.pm 234 2015-03-23 20:20:45Z drj826@gmail.com $

package SML::CommentDivision;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Division';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.CommentDivision');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'COMMENT_DIVISION',
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::CommentDivision> - a preformatted division of text that is not
rendered in published output.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Division

  my $division = SML::CommentDivision->new
                   (
                     id      => $id,
                     library => $library,
                   );

=head1 DESCRIPTION

A comment division is a preformatted division of text that is not
rendered in published output.

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
