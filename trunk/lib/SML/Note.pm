#!/usr/bin/perl

# $Id$

package SML::Note;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Element';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Note');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

# Lower case name is OK since this is an element.

has '+name' =>
  (
   default => 'note',
  );

######################################################################

has 'tag' =>
  (
   isa      => 'Str',
   reader   => 'get_tag',
   required => 1,
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

C<SML::Note> - an element that notates document content such as a
footnote or an end note.

=head1 VERSION

This documentation refers to L<"SML::Note"> version 2.0.0.

=head1 SYNOPSIS

  my $note = SML::Note->new();

=head1 DESCRIPTION

An L<"SML::Note"> is an L<"SML::Element"> that notates document
content such as a footnote or an end note.

=head1 METHODS

=head2 get_tag

A tag is a string that uniquely identifies a note within the section
in which it occurs.  It is typically a single character such as a
number or letter.

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
