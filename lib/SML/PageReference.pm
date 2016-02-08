#!/usr/bin/perl

package SML::PageReference;             # ci-000460

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.PageReference');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has tag =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_tag',
   required => 1,
  );

######################################################################

has target_id =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_target_id',
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
   default => 'PAGE_REF',
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

# NONE

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::PageReference> - a reference to an ID that renders the page
number on which that document part is presented.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [pg:introduction]

  my $ref = SML::PageReference->new
              (
                tag             => $tag,        # 'pg'
                target_id       => $target_id,  # 'introduction'
                library         => $library,
                containing_part => $part,
              );

  my $string = $ref->get_tag;        # 'pg'
  my $id     = $ref->get_target_id;  # 'introduction'

=head1 DESCRIPTION

Extends C<SML::String> to represent a reference to an ID of a part of
the document which renders the page number on which that part is
presented.  the document.

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
