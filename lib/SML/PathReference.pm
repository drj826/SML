#!/usr/bin/perl

# $Id: PathReference.pm 230 2015-03-21 17:50:52Z drj826@gmail.com $

package SML::PathReference;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.PathReference');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has pathspec =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_pathspec',
   required => 1,
  );

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'PATH_REF',
  );

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
## Private Attributes
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

C<SML::PathReference> - a reference to a file path

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [path:/etc/init]

  my $ref = SML::PathReference->new
              (
                pathspec        => $pathspec,   # '/etc/init'
                library         => $library,
                containing_part => $part,
              );

  my $string = $ref->get_pathspec;   # '/etc/init'

=head1 DESCRIPTION

Extends C<SML::String> to represent a file path specification.

=head1 METHODS

=head2 get_pathspec

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
