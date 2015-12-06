#!/usr/bin/perl

# $Id: OntologyRule.pm 258 2015-04-02 13:56:17Z drj826@gmail.com $

package SML::OntologyRule;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.OntologyRule');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has 'id' =>
  (
   isa      => 'Str',
   reader   => 'get_id',
   required => 1,
  );

######################################################################

has 'ontology' =>
  (
   isa      => 'SML::Ontology',
   reader   => 'get_ontology',
   required => 1,
  );

# Ontology to which this rule belongs.

######################################################################

has 'rule_type' =>
  (
   isa      => 'Str',
   reader   => 'get_rule_type',
   required => 1,
  );

# One of:
#
#   div => division declaration rule
#   prp => property declaration rule
#   enu => enumerated value rule
#   cmp => composition rule

######################################################################

has 'entity_name' =>
  (
   isa      => 'Str',
   reader   => 'get_entity_name',
   required => 1,
  );

######################################################################

has 'property_name' =>
  (
   isa      => 'Str',
   reader   => 'get_property_name',
   required => 1,
  );

# Must be a declared property.

######################################################################

has 'value_type' =>
  (
   isa      => 'Str',
   reader   => 'get_value_type',
   required => 1,
  );

######################################################################

has 'name_or_value' =>
  (
   isa      => 'Str',
   reader   => 'get_name_or_value',
   required => 1,
  );

######################################################################

has 'inverse_rule_id' =>
  (
   isa      => 'Str',
   reader   => 'get_inverse_rule_id',
   required => 1,
  );

######################################################################

has 'cardinality' =>
  (
   isa      => 'Str',
   reader   => 'get_cardinality',
   required => 1,
  );

# 1 or many

######################################################################

has 'required' =>
  (
   isa      => 'Bool',
   reader   => 'is_required',
   required => 1,
  );

######################################################################

has 'imply_only' =>
  (
   isa      => 'Bool',
   reader   => 'is_imply_only',
   required => 1,
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
## Private Methods
##
######################################################################
######################################################################

sub BUILD {

  my $self = shift;

  my $ontology    = $self->get_ontology;
  my $library     = $ontology->get_library;
  my $syntax      = $library->get_syntax;
  my $id          = $self->get_id;
  my $rule_type   = $self->get_rule_type;
  my $entity_name = $self->get_entity_name;
  my $cardinality = $self->get_cardinality;

  unless ( $rule_type =~ /$syntax->{valid_ontology_rule_type}/xms )
    {
      $logger->warn("INVALID RULE TYPE: \'$rule_type\' in \'$id\'");
      return 0;
    }

  if (
      (
       $rule_type eq 'prp'
       or
       $rule_type eq 'enu'
       or
       $rule_type eq 'cmp'
      )
      and
      not $ontology->has_entity_with_name($entity_name)
     )
    {
      $logger->warn("INVALID ENTITY: \'$entity_name\' in \'$id\'");
      return 0;
    }

  if ( not $cardinality =~ /$syntax->{valid_cardinality_value}/xms )
    {
      $logger->warn("INVALID CARDINALITY: \"$cardinality\" in $id");
      return 0;
    }

  return 1;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::OntologyRule> - a rule that makes an assertion about
L<"SML::Entity">s and how they may relate to one another.

=head1 VERSION

This documentation refers to L<"SML::OntologyRule"> version 2.0.0.

=head1 SYNOPSIS

  my $or = SML::OntologyRule->new();

=head1 DESCRIPTION

An ontology rule asserts one of four facts: (1) the ontology contains
a named entity (class rule), (2) a named entity has a named property
of specified type and cardinality (property rule), (3) the value of a
property is allowed to be a specified value (enumerated value rule),
or (4) a named entity may contain another named entity (composition
rule).

=head1 METHODS

=head2 get_id

=head2 get_ontology

=head2 get_rule_type

=head2 get_entity_name

=head2 get_property_name

=head2 get_value_type

=head2 get_name_or_value

=head2 get_inverse_rule_id

=head2 get_cardinality

=head2 is_required

=head2 is_imply_only

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
