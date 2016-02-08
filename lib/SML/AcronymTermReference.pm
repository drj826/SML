#!/usr/bin/perl

package SML::AcronymTermReference;      # ci-000440

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.AcronymTermReference');

######################################################################

=head1 NAME

SML::AcronymTermReference - a reference to an acronym term

=head1 SYNOPSIS

  SML::AcronymTermReference->new
    (
      tag     => $tag,                  # Str
      acronym => $acronym,              # SML::Definition
    );

  $ref->get_tag;                        # Str
  $ref->get_namespace;                  # Str
  $ref->get_acronym;                    # SML::Definition

=head1 DESCRIPTION

SML::AcronymTermReference extends L<SML::String> to represent a
reference to an acronym term.

The acronym reference tag has the following significance:

=over 4

=item

a => If this is the first occurence render the long version otherwise
render the short version.

=item

ac => Same as 'a'

=item

acs => Render the short version of the acronym.

=item

acl => Render the long version of the acronym.

=back

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

Return a scalar text value which is the tag portion of the acronym
term reference.

  my $tag = $acronym_term_reference->get_tag;

=cut

######################################################################

has acronym =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_acronym',
   required => 1,
  );

=head2 get_acronym

Return the acronym definition (an L<SML::Definition>).

  my $acronym = $acronym_term_reference->get_acronym;

=cut

######################################################################

has namespace =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_namespace',
   default  => '',
  );

=head2 get_namespace

Return the scalar text value for the namespace.

  my $namespace = $acronym_term_reference->get_namespace;

=cut

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'ACRONYM_TERM_REF',
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
