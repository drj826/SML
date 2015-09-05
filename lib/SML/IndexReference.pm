#!/usr/bin/perl

# $Id: IndexReference.pm 230 2015-03-21 17:50:52Z drj826@gmail.com $

package SML::IndexReference;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.IndexReference');

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

has 'entry' =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_entry',
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
   default => 'INDEX_REF',
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

C<SML::IndexReference> - a reference to an index entry

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [index:UAT]

  my $ref = SML::IndexReference->new
              (
                tag             => $tag,        # 'index'
                entry           => $entry,      # 'UAT'
                library         => $library,
                containing_part => $part,
              );

  my $string = $ref->get_tag;        # 'index'
  my $string = $ref->get_entry;      # 'UAT'

=head1 DESCRIPTION

Extends C<SML::String> to represent a reference to an index entry.

=head1 METHODS

=head2 get_tag

=head2 get_target_id

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
