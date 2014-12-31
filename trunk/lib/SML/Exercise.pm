#!/usr/bin/perl

package SML::Exercise;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Region';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Exercise');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'exercise',
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Exercise> - a region that represents an exercise a student
might work though to better understand concepts described in the text.

=head1 VERSION

This documentation refers to L<"SML::Exercise"> version 2.0.0.

=head1 SYNOPSIS

  my $exr = SML::Exercise->new();

=head1 DESCRIPTION

An exercise is a region that represents an exercise a student might
work though to better understand concepts described in the text.

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
