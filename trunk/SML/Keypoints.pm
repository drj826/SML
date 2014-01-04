#!/usr/bin/perl

# $Id: Keypoints.pm 11633 2012-12-04 23:07:21Z don.johnson $

package SML::Keypoints;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Environment';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.keypoints');

######################################################################
######################################################################
##
## Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'keypoints',
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Keypoints> - a region that represents the key points of a
document section.

=head1 VERSION

This documentation refers to L<"SML::Keypoints"> version 2.0.0.

=head1 SYNOPSIS

  my $kyp = SML::Keypoints->new();

=head1 DESCRIPTION

An SML keypoints region represents the key points of a document
section.

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
