#!/usr/bin/perl

package SML::PathReference;             # ci-000461

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.PathReference');

######################################################################

=head1 NAME

SML::PathReference - a reference to a file path

=head1 SYNOPSIS

  SML::PathReference->new
    (
      pathspec        => $pathspec,
      library         => $library,
      containing_part => $part,
    );

  $ref->get_pathspec;                   # Str

=head1 DESCRIPTION

An C<SML::PathReference> extends C<SML::String> to represent a file
path specification.

=head1 METHODS

=cut

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

=head2 get_pathspec

Return a scalar text value which is the path specification.

  my $path = $ref->get_pathspec

=cut

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

# NONE

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

# NONE

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012-2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
