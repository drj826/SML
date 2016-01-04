#!/usr/bin/perl

package SML::FootnoteReference;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.FootnoteReference');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has section_id =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_section_id',
   required => 1,
  );

######################################################################

has number =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_number',
   required => 1,
  );

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'FOOTNOTE_REF',
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

C<SML::FootnoteReference> - a reference to a footnote

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [f:ch2:3]

  my $ref = SML::FootnoteReference->new
              (
                section_id      => $section_id, # 'ch2'
                number          => $number,     # '3'
                library         => $library,
                containing_part => $part,
              );

  my $id  = $ref->get_section_id;      # 'ch2'
  my $num = $ref->get_number;          # '3'

=head1 DESCRIPTION

Extends C<SML::String> to represent a reference to a footnote.

=head1 METHODS

=head2 get_section_id

=head2 get_number

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
