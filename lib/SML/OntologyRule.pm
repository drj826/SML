#!/usr/bin/perl

package SML::OntologyRule;              # ci-000458

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.OntologyRule');

######################################################################

=head1 NAME

SML::OntologyRule - an ontology rule

=head1 SYNOPSIS

  SML::OntologyRule->new
    (
      id              => $id,
      ontology        => $ontology,
      rule_type       => $rule_type,
      division_name   => $division_name,
      property_name   => $property_name,
      value_type      => $value_type,
      name_or_value   => $name_or_value,
      inverse_rule_id => $inverse_rule_id,
      multiplicity    => $multiplicity,
      required        => $required,
      imply_only      => $imply_only,
    );

  $rule->get_id;                        # Str
  $rule->get_ontology;                  # SML::Ontology
  $rule->get_rule_type;                 # Str (div, prp, enu, cmp, or def)
  $rule->get_division_name;             # Str
  $rule->get_property_name;             # Str
  $rule->get_value_type;                # Str
  $rule->get_name_or_value;             # Str
  $rule->get_inverse_rule_id;           # Str
  $rule->get_multiplicity;              # Str
  $rule->is_required;                   # Bool
  $rule->is_imply_only;                 # Bool

=head1 DESCRIPTION

An ontology rule declares a fact about the ontology.  An ontology is
composed of a collection of ontology rules.  Document semantics are
validated against the set of ontology rules.

There are five types of ontology rules, each asserts its own type of
fact:

=over 4

=item

div => A "division declaration rule" declares that a division with the
specified name exists in the ontology.  For instance:

  person      <-- division exists

=item

prp = A "property declaration rule" declares that divisions with a
certain name I<may> have a property by the specified name.

  person      <-- division name
  hair color  <-- named property exists

=item

enu = An "enumeration declaration rule" declares that the value of a
named property belonging to a named division may have the specified
value.  For instance:

  person      <-- division name
  hair color  <-- named property
  blonde      <-- allowed value

=item

cmp = A "composition declaration rule" declares that one type of
division may be part of another type of division.  For instance:

  person      <-- division named 'B' may be part of 'A'
  family      <-- division named 'A' may have parts which are 'B'

=item

def = A "default value declaration rule" declares a default property
value.  For instance:

  DOCUMENT    <-- division name
  state       <-- property name
  DRAFT       <-- default value

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

has id =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_id',
   required => 1,
  );

=head2 get_id

Return a scalar text value which is the unique identifier of this
ontology rule.

  my $rule_id = $rule->get_id;

=cut

######################################################################

has ontology =>
  (
   is       => 'ro',
   isa      => 'SML::Ontology',
   reader   => 'get_ontology',
   required => 1,
  );

=head2 get_ontology

Return the C<SML::Ontology> to which this rule belongs.

  my $ontology = $rule->get_ontology;

=cut

######################################################################

has rule_type =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_rule_type',
   required => 1,
  );

=head2 get_rule_type

Return a scalar array value which is the type of the rule.

  my $rule_type = $rule->get_type.

One of:

  div => division declaration rule
  prp => property declaration rule
  enu => enumeration declaration rule
  cmp => composition declaration rule
  def => default value declaration rule

=cut

######################################################################

has division_name =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_division_name',
   required => 1,
  );

=head2 get_division_name

Return a scalar text value which is the division name addressed by
this rule.

  my $division_name = $rule->get_division_name;

=cut

######################################################################

has property_name =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_property_name',
   required => 1,
  );

=head2 get_property_name

return a scalar text value which is the property name addressed by
this rule.

  my $property_name = $rule->get_property_name;

=cut

######################################################################

has value_type =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_value_type',
   required => 1,
  );

=head2 get_value_type

Return a scalar text value which is the value type (more properly the
object type) declared by this rule.

  my $type = $rule->get_value_type;

=cut

######################################################################

has name_or_value =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_name_or_value',
   required => 1,
  );

=head2 get_name_or_value

Return a scalar text value which is the name or value of the object
type declared by this rule.

  my $name_or_value = $rule->get_name_or_value;

=cut

######################################################################

has inverse_rule_id =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_inverse_rule_id',
   required => 1,
  );

=head2 get_inverse_rule_id

Return the scalar text value which is the ID of the ontology rule
which is the inverse of this one.

  my $rule_id = $rule->get_inverse_rule_id;

=cut

######################################################################

has multiplicity =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_multiplicity',
   required => 1,
  );

=head2 get_multiplicity

Return the scalar text value that represents the maximum allowed
multiplicity declared by this rule ('1' or 'many').

  my $multiplicity = $rule->get_multiplicity;

=cut

######################################################################

has required =>
  (
   is       => 'ro',
   isa      => 'Bool',
   reader   => 'is_required',
   required => 1,
  );

=head2 is_required

Return 1 if this rule represents a required property.

  my $required = $rule->is_required;

=cut

######################################################################

has imply_only =>
  (
   is       => 'ro',
   isa      => 'Bool',
   reader   => 'is_imply_only',
   required => 1,
  );

=head2 is_imply_only

Return 1 if this rule represents an "imply only" property.

  my $imply_only = $rule->is_imply_only;

=cut

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

sub BUILD {

  my $self = shift;

  my $ontology      = $self->get_ontology;
  my $library       = $ontology->get_library;
  my $syntax        = $library->get_syntax;
  my $id            = $self->get_id;
  my $rule_type     = $self->get_rule_type;
  my $division_name = $self->get_division_name;
  my $multiplicity  = $self->get_multiplicity;

  # validate rule type
  unless ( $rule_type =~ /$syntax->{valid_ontology_rule_type}/xms )
    {
      $logger->warn("INVALID RULE TYPE \'$rule_type\' in \'$id\'");
      return 0;
    }

  # validate division name
  if (
      $rule_type eq 'prp'
      or
      $rule_type eq 'enu'
      or
      $rule_type eq 'cmp'
      or
      $rule_type eq 'def'
     )
    {
      unless ( $ontology->has_division_with_name($division_name) )
	{
	  $logger->warn("INVALID DIVISION IN ONTOLOGY RULE \'$division_name\' in \'$id\'");
	  return 0;
	}
    }

  # validate multiplicity value
  unless ( $multiplicity =~ /$syntax->{valid_multiplicity_value}/xms )
    {
      $logger->warn("INVALID MULTIPLICITY: \"$multiplicity\" in $id");
      return 0;
    }

  return 1;
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
