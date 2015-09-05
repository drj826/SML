#!/usr/bin/perl

# $Id: LiteralString.pm 77 2015-01-31 17:48:03Z drj826@gmail.com $

package SML::LiteralString;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.LiteralString');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'LITERAL_STRING',
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

C<SML::LiteralString> - a string of literal characters

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: {lit:[c]}

  my $ref = SML::LiteralString->new
              (
                content         => $content,  # '[c]'
                library         => $library,
                containing_part => $part,
              );

  my $string = $ref->get_content;    # '[c]'

=head1 DESCRIPTION

Extends C<SML::String> to represent a literal sequence of characters.

=head1 METHODS

=head2 get_content

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
