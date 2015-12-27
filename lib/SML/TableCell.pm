#!/usr/bin/perl

# $Id: TableCell.pm 230 2015-03-21 17:50:52Z drj826@gmail.com $

package SML::TableCell;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.TableCell');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'TABLE_CELL',
  );

######################################################################

has emphasis =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_emphasis',
   predicate => 'has_emphasis',
  );

# If present, this 'emphasis' indicator means the author wants to
# emphasize the content of this table cell.

######################################################################

has justification =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_justification',
   predicate => 'has_justification',
  );

######################################################################

has background_color =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_background_color',
   predicate => 'has_background_color',
  );

######################################################################

has fontsize =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_fontsize',
   predicate => 'has_fontsize',
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

C<SML::TableCell> - an environment that instructs the publishing
application to insert a table cell into the document.

=head1 VERSION

This documentation refers to L<"SML::TableCell"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::Division

  my $tblcell = SML::TableCell->new();

=head1 DESCRIPTION

An SML table cell environment instructs the publishing application to
insert a table cell into the document.

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
