#!/usr/bin/perl

# $Id: ListItem.pm 230 2015-03-21 17:50:52Z drj826@gmail.com $

package SML::ListItem;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Block';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.ListItem');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'LIST_ITEM',
  );

######################################################################

has leading_whitespace =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_leading_whitespace',
   required  => 1,
  );

# The leading_whitespace is the whitespace at the beginning of the
# list item.  It is significant because if the indent of one list item
# is greater than the indent of the previous list item it indicates
# the start of a sub-list.

######################################################################

has value =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_value',
   writer    => 'set_value',
   predicate => 'has_value',
  );

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

C<SML::Listitem> - a block of text that represents one item in a
sequence or hierarchy of items.

=head1 VERSION

This documentation refers to L<"SML::Listitem"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::Block

  my $item = SML::Listitem->new();

=head1 DESCRIPTION

An listitem is a block of text that represents one item in a sequence
or hierarchy of items.

=head1 METHODS

=head2 get_name

=head2 get_type

=head2 get_value

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
