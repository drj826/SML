#!/usr/bin/perl

package SML::BulletList;                # ci-000441

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';               # ci-000466

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.BulletList');

######################################################################

=head1 NAME

SML::BulletList - a list of bullet items

=head1 SYNOPSIS

  SML::BulletList->new(id=>$id,library=>$library);

  $bullet_list->get_leading_whitespace;
  $bullet_list->get_indent;

=head1 DESCRIPTION

SML::BulletList is an L<SML::Structure> that contains bullet items.
Lists can be nested through indentation.  The top level list must have
no indentation.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has leading_whitespace =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_leading_whitespace',
   required  => 1,
  );

=head2 get_leading_whitespace

Return a scalar value string of whitespace characters. The leading
whitespace is the whitespace at the beginning of the items in the
list.  It is significant because if the indent of one list item is
greater than the indent of the previous list item it indicates the
start of a sub-list.

  my $whitespace = $bullet_list->get_leading_whitespace;

=cut

######################################################################

has indent =>
  (
   is        => 'ro',
   isa       => 'Int',
   reader    => 'get_indent',
   builder   => '_build_indent',
   lazy      => 1,
  );

=head2 get_indent

Return an integer value that represents the indentation level of the
bullet list.

  my $indent = $bullet_list->get_indent;

=cut

######################################################################

has '+name' =>
  (
   default => 'BULLET_LIST',
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

sub _build_indent {

  my $self = shift;

  my $leading_whitespace = $self->get_leading_whitespace;

  return length($leading_whitespace);
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012,2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
