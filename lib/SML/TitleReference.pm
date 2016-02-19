#!/usr/bin/perl

package SML::TitleReference;            # ci-000468

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.TitleReference');

######################################################################

=head1 NAME

SML::TitleReference - a reference to the title of a division

=head1 SYNOPSIS

  SML::TitleReference->new
    (
      tag             => $tag,
      target_id       => $target_id,
      library         => $library,
      containing_part => $part,
    );

  $ref->get_tag;                        # Str
  $ref->get_target_id;                  # Str

=head1 DESCRIPTION

An C<SML::TitleReference> extends C<SML::String> to represent a
reference to the title of a division in the library.

=head1 METHODS

=cut

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

=head2 get_tag

Return a scalar text value which is the tag of the element (not
significant).

  my $tag = $ref->get_tag;

=cut

######################################################################

has target_id =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_target_id',
   required => 1,
  );

=head2 get_target_id

Return a scalar text value which is the ID of the referenced division.

  my $target_id = $ref->get_target_id;

=cut

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'TITLE_REF',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_target_part {

  # Return the SML::Part object the target ID points to.

  my $self = shift;

  my $id       = $self->get_target_id;
  my $document = $self->get_containing_document;

  unless ( $document->has_part($id) )
    {
      $logger->error("CAN'T GET TARGET PART: $id NOT IN DOCUMENT");
      return 0;
    }

  return $document->get_part($id);
}

=head2 get_target_part

Return the referenced C<SML::Part>.

  my $part = $ref->get_target_part;

=cut

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

sub _build_plain_text {

  my $self = shift;

  my $target_id = $self->get_target_id;
  my $library   = $self->get_library;
  my $ps        = $library->get_property_store;

  return $ps->get_property_text($target_id,'title');
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012-2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
