#!/usr/bin/perl

package SML::IDReference;               # ci-000451

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.IDReference');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
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
   default => 'ID_REF',
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

sub _build_plain_text {

  my $self = shift;

  return $self->get_target_id;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::IDReference> - a reference to an ID in the document

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [id:introduction]

  my $ref = SML::IDReference->new
              (
                target_id       => $target_id,  # 'introduction'
                library         => $library,
                containing_part => $part,
              );

  my $id = $ref->get_target_id;    # 'introduction'

=head1 DESCRIPTION

Extends C<SML::String> to represent a reference to an ID of some other
part of the document.

=head1 METHODS

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
