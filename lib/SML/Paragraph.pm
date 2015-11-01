#!/usr/bin/perl

# $Id: Paragraph.pm 185 2015-03-08 12:57:49Z drj826@gmail.com $

package SML::Paragraph;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Block';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Paragraph');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'PARAGRAPH',
  );

######################################################################

has value =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_value',
   writer    => 'set_value',
   predicate => 'has_value',
  );

# This is the raw text of the paragraph.  This can be different than
# 'content' because when the paragraph is the first block of a table
# cell the leading markup must be stripped.

######################################################################

has value_string =>
  (
   is        => 'ro',
   isa       => 'SML::String',
   reader    => 'get_value_string',
   writer    => 'set_value_string',
   predicate => 'has_value_string',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Paragraph> - a block of text that represents one item in a
sequence or hierarchy of items.

=head1 VERSION

This documentation refers to L<"SML::Paragraph"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::Block

  my $para = SML::Paragraph->new();

=head1 DESCRIPTION

An paragraph is a block of text that represents one item in a sequence
or hierarchy of items.

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
