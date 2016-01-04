#!/usr/bin/perl

package SML::EnumeratedList;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.EnumeratedList');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'ENUMERATED_LIST',
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
# items in the list.  It is significant because if the indent of one
# list item is greater than the indent of the previous list item it
# indicates the start of a sub-list.

######################################################################

has ident =>
  (
   is        => 'ro',
   isa       => 'Int',
   reader    => 'get_indent',
   builder   => '_build_indent',
   lazy      => 1,
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

# none.

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

# none.

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

=head1 NAME

C<SML::EnumeratedList> - an environment that instructs the publishing
application to insert a list into the document.

=head1 VERSION

This documentation refers to L<"SML::EnumeratedList"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::Division

  my $list = SML::EnumeratedList->new(id=>$id,library=>$library);

=head1 DESCRIPTION

An SML list environment instructs the publishing application to
insert a list into the document.

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
