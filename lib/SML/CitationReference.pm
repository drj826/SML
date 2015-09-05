#!/usr/bin/perl

# $Id: CitationReference.pm 277 2015-05-11 12:07:29Z drj826@gmail.com $

package SML::CitationReference;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.CitationReference');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has 'tag' =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_tag',
   required => 1,
  );

######################################################################

has 'source_id' =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_source_id',
   required => 1,
  );

######################################################################

has 'details' =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_details',
   default  => '',
  );

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'CITATION_REF',
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

C<SML::CitationReference> - a citation of a source of information

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [cite:cms15, pg 44]

  my $ref = SML::CitationReference->new
              (
                tag             => $tag,        # 'cite'
                source_id       => $source_id,  # 'cms15'
                details         => $details,    # 'pg 44'
                library         => $library,
                containing_part => $part,
              );

  my $string = $ref->get_tag;        # 'cite'
  my $id     = $ref->get_source_id;  # 'cms15'
  my $string = $ref->get_details;    # 'pg 44'

=head1 DESCRIPTION

Extends C<SML::String> to represent a citation to a C<SML::Source>.

=head1 METHODS

=head2 get_tag

=head2 get_source_id

=head2 get_details

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
