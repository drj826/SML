#!/usr/bin/perl

# $Id: Attachment.pm 77 2015-01-31 17:48:03Z drj826@gmail.com $

package SML::Attachment;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Division';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Attachment');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'ATTACHMENT',
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Attachment> - an environment that represents an element of
document structure that attaches an external file at a specific place
within an SML document.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Division

  my $attachment = SML::Attachment->new
                     (
                       id      => $id,
                       library => $library,
                     );

=head1 DESCRIPTION

An SML attachment is an environment that represents an element of
document structure that attaches an external file at a specific place
within an SML document.

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
