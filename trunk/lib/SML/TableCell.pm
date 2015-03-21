#!/usr/bin/perl

# $Id$

package SML::TableCell;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Division';

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
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub as_text {

  my $self = shift;

  return 1;
}

######################################################################

sub as_latex {

  my $self = shift;

  return 1;
}

######################################################################

sub as_csv {

  my $self = shift;

  return 1;
}

######################################################################

sub as_xml {

  my $self = shift;

  return 1;
}

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
