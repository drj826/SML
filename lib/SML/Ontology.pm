#!/usr/bin/perl

package SML::Ontology;                  # ci-000437

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Text::CSV;
use Cwd;
use Carp;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Ontology');

use SML::OntologyRule;

######################################################################

=head1 NAME

SML::Ontology - a formal specification of terms

=head1 SYNOPSIS

  SML::Ontology->new(library=>$library);

  $ontology->get_library;                                                           # SML::Library

  $ontology->get_allowed_property_value_list($division_name,$property_name);        # ArrayRef
  $ontology->get_allowed_property_object_name_list($division_name,$property_name);  # ArrayRef
  $ontology->value_must_be_division_id_for_property($division_name,$property_name); # Bool
  $ontology->get_rule_for($division_name,$property_name,$name_or_value);            # SML::OntologyRule
  $ontology->get_inverse_rule_for($subject_name,$predicate,$object_name);           # SML::OntologyRule
  $ontology->get_rule_with_id($rule_id);                                            # SML::OntologyRule
  $ontology->get_class_for_division_name($division_name);                           # Str
  $ontology->get_allowed_property_name_list($division_name);                        # ArrayRef
  $ontology->get_required_property_name_list($division_name);                       # ArrayRef
  $ontology->has_division_with_name($name);                                         # Bool
  $ontology->has_rule_for($division_name,$property_name,$name_or_value);            # Bool
  $ontology->has_inverse_rule_for($division_name,$property_name,$name_or_value);    # Bool
  $ontology->allows_division_name($name);                                           # Bool
  $ontology->allows_property_name($property_name,$division_name);                   # Bool
  $ontology->allows_composition($division_name_a,$division_name_b);                 # Bool
  $ontology->allows_property_value($division_name,$property_name,$value);           # Bool
  $ontology->allows_triple($subject,$predicate,$object);                            # Bool
  $ontology->property_is_universal($name);                                          # Bool
  $ontology->property_is_required($division_name,$property_name);                   # Bool
  $ontology->property_is_imply_only($division_name,$property_name);                 # Bool
  $ontology->get_property_multiplicity($division_name,$property_name);              # Str
  $ontology->get_entity_name_list;                                                  # ArrayRef
  $ontology->get_structure_name_list;                                               # ArrayRef
  $ontology->get_allowed_containee_name_list($division_name);                       # ArrayRef
  $ontology->get_rule_type_count($type);                                            # Int
  $ontology->get_rule_type_list;                                                    # ArrayRef
  $ontology->is_structure($name);                                                   # Bool
  $ontology->is_entity($name);                                                      # Bool

=head1 DESCRIPTION

An ontology is an explicit formal specification of terms that
represent the entities defined to exist in some area of interest, the
relationships that hold among them, and the formal axioms that
constrain the interpretation and well-formed use of those terms.

In SML divisions are used to represent document structures and
entities.  An SML ontology declares what structures and entities
exist, their properties, and how they relate to one another.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has library =>
  (
   is        => 'ro',
   isa       => 'SML::Library',
   reader    => 'get_library',
   required  => 1,
  );

=head2 get_library

Return the C<SML::Library> object to which the ontology belongs.

  my $library = $ontology->get_library;

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_allowed_property_value_list {

  my $self = shift;

  my $division_name = shift;
  my $property_name = shift;

  my $href = $self->_get_allowed_property_values_hash;

  return $href->{$division_name}{$property_name};
}

=head2 get_allowed_property_value_list($division_name,$property_name)

Return an ArrayRef to a list of allowed property values (as defined in
the enumerated value rules) for the specified division name and a
property name.

  my $aref = $ontology->get_allowed_property_value_list($division_name,$property_name);

For instance, the following should return a list of allowed values for
DOCUMENT state (DRAFT, REVIEW, APPROVED):

  my $aref = $ontology->get_allowed_property_value_list('DOCUMENT','state');

=cut

######################################################################

sub get_allowed_property_object_name_list {

  my $self = shift;

  my $division_name = shift;
  my $property_name = shift;

  my $href = $self->_get_property_rules_lookup_hash;

  return [ sort keys %{ $href->{$division_name}{$property_name} }];
}

=head2 get_allowed_property_object_name_list($division_name,$property_name)

Return an ArrayRef to a list of allowed property object names for the
specified division name and property name.

  my $aref = $ontology->get_allowed_property_object_name_list($division_name,$property_name);

=cut

######################################################################

sub value_must_be_division_id_for_property {

  my $self = shift;

  my $division_name = shift;
  my $property_name = shift;

  my $object_name_list = $self->get_allowed_property_object_name_list($division_name,$property_name);

  if ( not scalar @{ $object_name_list } )
    {
      return 0;
    }

  foreach my $object_name (@{ $object_name_list })
    {
      if ( $object_name eq 'STRING' or $object_name eq 'BOOLEAN' )
	{
	  return 0;
	}
    }

  return 1;
}

=head2 value_must_be_division_id_for_property($division_name,$property_name)

Return 1 if the value of the specified property (division name,
property name) MUST be a division ID and not a STRING or BOOLEAN.

  my $result = $ontology->value_must_be_division_id_for_property($division_name,$property_name)

=cut

######################################################################

sub get_rule_for {

  my $self = shift;

  my $division_name = shift;
  my $property_name = shift;
  my $name_or_value = shift;

  my $prl = $self->_get_property_rules_lookup_hash;

  my $rule = $prl->{$division_name}{$property_name}{$name_or_value} || q{};

  return $rule;
}

=head2 get_rule_for($division_name,$property_name,$name_or_value)

Return the C<SML::OntologyRule> for (1) the entity named
$division_name, (2) the property named $property_name, and (3) that
has an optional inverse entity named $inverse_entity_name.

  my $rule = $ontology->get_rule_for($division_name,$property_name,$name_or_value);

=cut

######################################################################

sub get_inverse_rule_for {

  my $self = shift;

  my $subject_name = shift;             # rq-002
  my $predicate    = shift;             # is_part_of
  my $object_name  = shift;             # rq-001

  unless ( $subject_name and $predicate and $object_name )
    {
      $logger->error("CAN'T GET INVERSE RULE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $rule = $self->get_rule_for($subject_name,$predicate,$object_name);

  my $inverse_rule_id = $rule->get_inverse_rule_id;

  return $self->get_rule_with_id($inverse_rule_id);
}

=head2 get_inverse_rule_for($subject_name,$predicate,$object_name)

Return the C<SML::OntologyRule> which is the inverse rule for the
specified subject, predicate and object.

  my $rule = $ontology->get_inverse_rule_for($subject_name,$predicate,$object_name);

=cut

######################################################################

sub get_rule_with_id {

  my $self = shift;

  my $rule_id = shift;

  unless ( $rule_id )
    {
      $logger->error("CAN'T GET RULE WITH ID, MISSING ARGUMENT");
      return 0;
    }

  my $href = $self->_get_rule_hash;
  my $rule = $href->{$rule_id};

  if ( defined $rule )
    {
      return $rule;
    }

  else
    {
      $logger->error("CAN'T GET RULE \'$rule_id\'");
      return 0;
    }
}

=head2 get_rule_with_id($rule_id)

Return the C<SML::OntologyRule> with the specified rule ID.

  my $rule = $ontology->get_rule_with_id($rule_id);

=cut

######################################################################

sub get_class_for_division_name {

  my $self = shift;

  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T GET CLASS FOR DIVISION NAME, MISSING ARGUMENT");
      return 0;
    }

  my $href = $self->_get_types_by_division_name_hash;

  unless ( exists $href->{$name} )
    {
      $logger->error("THERE IS NO CLASS FOR DIVISION NAME \'$name\'");
      return 0;
    }

  return $href->{$name};
}

=head2 get_class_for_division_name($division_name)

Return a scalar text value which is the class for the specified
division name.

  my $class = $ontology->get_class_for_division_name($division_name);

For instance:

  $ontology->get_class_for_division_name('DOCUMENT'); # SML::Document

=cut

######################################################################

sub get_allowed_property_name_list {

  my $self = shift;

  my $division_name = shift;

  if ( not $division_name )
    {
      $logger->logcluck("CAN'T GET ALLOWED PROPERTY NAME LIST, MISSING ARGUMENT");
      return 0;
    }

  my $href = $self->_get_properties_by_division_name_hash->{$division_name};

  if ( not defined $href )
    {
      return [];
    }

  if ( not scalar keys %{ $href } )
    {
      return [];
    }

  return [ sort keys %{ $href } ];
}

=head2 get_allowed_property_name_list($division_name)

Return an ArrayRef to a list of property names allowed for the
specified division name.

  my $aref = $ontology->get_allowed_property_name_list($division_name);

=cut

######################################################################

sub get_required_property_name_list {

  my $self = shift;

  my $division_name = shift;

  unless ( $division_name )
    {
      $logger->error("CAN'T GET REQUIRED PROPERTY NAME LIST, MISSING ARGUMENT");
      return 0;
    }

  my $href = $self->_get_required_properties_hash;

  unless ( exists $href->{$division_name} )
    {
      return [];
    }

  return [ sort keys %{ $href->{$division_name} } ]
}

=head2 get_required_property_name_list($division_name)

Return an ArrayRef to a list of property names required for the
specified division name.

  my $aref = $ontology->get_required_property_name_list($division_name);

=cut

######################################################################

sub has_division_with_name {

  my $self = shift;

  my $name = shift;

  my $href = $self->_get_rule_hash;

  foreach my $rule ( values %{ $href } )
    {
      my $division_name = $rule->get_division_name;

      if ( $division_name eq $name )
	{
	  return 1;
	}
    }

  return 0;
}

=head2 has_division_with_name($name)

Return 1 if the ontology defines a division with the specified name.

  my $result = $ontology->has_division_with_name($name);

ONLY USE THIS METHOD DURING THE READING OF RULE FILES.

Notice that this method loops through the rule hash to determine
whether the ontology defines an division with the specified name.
The rule hash is built bit by bit as the rule files are read.
This means this method will return an answer based on the rules
read SO FAR.

=cut

######################################################################

sub has_rule_for {

  my $self = shift;

  my $division_name = shift;
  my $property_name = shift;
  my $name_or_value = shift;

  my $prlh = $self->_get_property_rules_lookup_hash;

  if ( exists $prlh->{$division_name}{$property_name}{$name_or_value} )
    {
      return 1;
    }

  return 0;
}

=head2 has_rule_for($division_name,$property_name,$name_or_value)

Return 1 if the ontology has a rule for the specified division name,
property name, and object name or value.

  my $result = $ontology->has_rule_for($division_name,$property_name,$name_or_value);

=cut

######################################################################

sub has_inverse_rule_for {

  my $self = shift;

  my $division_name = shift;
  my $property_name = shift;
  my $name_or_value = shift;

  my $prlh = $self->_get_property_rules_lookup_hash;

  my $rule = $prlh->{$division_name}{$property_name}{$name_or_value};

  if ( $rule->get_inverse_rule_id )
    {
      return 1;
    }

  return 0;
}

=head2 has_inverse_rule_for($division_name,$property_name,$name_or_value)

Return 1 if the ontology has an inverse rule for the specified
division name, property name, and object name or value.

  my $result = $ontology->has_inverse_rule_for($division_name,$property_name,$name_or_value);

=cut

######################################################################

sub allows_division_name {

  my $self = shift;

  my $name = shift;

  my $href = $self->_get_types_by_division_name_hash;

  if ( exists $href->{$name} )
    {
      return 1;
    }

  return 0;
}

=head2 allows_division_name($name)

Return 1 if the ontology allows the specified division name.

  my $result = $ontology->allows_division_name($name);

ONLY USE AFTER the reading of rule files you need to know whether an
entity with a specified name has been defined use THIS method.

=cut

######################################################################

sub allows_property_name {

  my $self = shift;

  my $property_name = shift;
  my $division_name = shift;

  unless ( $property_name and $division_name )
    {
      $logger->logcluck("CAN'T CHECK IF ONTOLOGY ALLOWS PROPERTY NAME, MISSING ARGUMENT(S)");
      return 0;
    }

  my $aref = $self->get_allowed_property_name_list($division_name);

  if ( not $aref )
    {
      return 0;
    }

  foreach my $name (@{ $aref })
    {
      if ( $name eq $property_name )
	{
	  return 1;
	}
    }

  my $universal_list = $self->get_allowed_property_name_list('UNIVERSAL');

  foreach my $name (@{ $universal_list })
    {
      if ( $name eq $property_name )
	{
	  return 1;
	}
    }

  return 0;
}

=head2 allows_property_name($property_name,$division_name)

Return 1 if the ontology allows the specified property name within the
specified division.

  my $result = $ontology_allows_property_name($property_name,$division_name);

=cut

######################################################################

sub allows_composition {

  my $self = shift;

  my $division_name_a = shift;
  my $division_name_b = shift;

  my $href = $self->_get_allowed_compositions_hash;

  if ( defined $href->{$division_name_a}{$division_name_b} )
    {
      return 1;
    }

  return 0;
}

=head2 allows_composition($division_name_a,$division_name_b)

Return 1 if division name A is allowed to be within division name B.

  my $result = $ontology->allows_composition($division_name_a,$division_name_b);

=cut

######################################################################

sub allows_property_value {

  my $self = shift;

  my $division_name = shift;
  my $property_name = shift;
  my $value         = shift;

  my $href = $self->_get_allowed_property_values_hash;

  # allowed property value list
  my $apv_list = $href->{$division_name}{$property_name};

  if (
      ( not defined $apv_list )
      or
      ( defined $apv_list and not scalar @{ $apv_list } )
     )
    {
      return 1;
    }

  foreach my $allowed_value ( @{ $apv_list } )
    {
      if ( $allowed_value eq $value )
	{
	  return 1;
	}
    }

  return 0;
}

=head2 allows_property_value($division_name,$property_name,$value)

Return 1 if the ontology allows the specified value for the specified
property in the specified division.

  my $result = $ontology->allows_property_value($division_name,$property_name,$value);

=cut

######################################################################

sub allows_triple {

  my $self = shift;

  my $subject   = shift;                # rq-002
  my $predicate = shift;                # is_part_of
  my $object    = shift;                # rq-001

  unless ( $subject and $predicate and $object )
    {
      $logger->error("CAN'T CHECK IF ONTOLOGY ALLOWS TRIPLE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $library      = $self->get_library;
  my $subject_name = $library->get_division_name_for_id($subject);
  my $object_name  = $library->get_division_name_for_id($object);

  if ( $self->has_rule_for($subject_name,$predicate,$object_name) )
    {
      return 1;
    }

  return 0;
}

=head2 allows_triple($subject,$predicate,$object)

Return 1 if the ontology allows the specified subject, predicate,
object triple.

  my $result = $ontology->allows_triple($subject,$predicate,$object);

=cut

######################################################################

sub property_is_universal {

  my $self = shift;

  my $name = shift;

  my $href = $self->_get_property_rules_lookup_hash;

  if ( exists $href->{'UNIVERSAL'}{$name} )
    {
      return 1;
    }

  return 0;
}

=head2 property_is_universal($name)

Return 1 if the named property is universal.  That means an element
representing the property may appear anywhere in the text not just in
specified divisions.

  my $result = $ontology->property_is_universal($name);

=cut

######################################################################

sub property_is_required {

  my $self = shift;

  my $division_name = shift;
  my $property_name = shift;

  my $href = $self->_get_required_properties_hash;

  if ( exists $href->{$division_name}{$property_name} )
    {
      return 1;
    }

  return 0;
}

=head2 property_is_required($division_name,$property_name)

Return 1 if the specified property is required within the specified
division.

  my $result = $ontology->property_is_required($division_name,$property_name);

=cut

######################################################################

sub property_is_imply_only {

  my $self = shift;

  my $division_name = shift;
  my $property_name = shift;

  my $href = $self->_get_imply_only_properties_hash;

  unless ( $href->{$division_name}{$property_name} )
    {
      return 0;
    }

  return 1;
}

=head2 property_is_imply_only($division_name,$property_name)

Return 1 if the specified property is "imply only" within the
specified division.

  my $result = $ontology->property_is_imply_only($division_name,$property_name);

This means that an element explicitly declaring this property CANNOT
appear in the manuscript.  The property may only be "implied"
(inferred) by the reasoner.

To prevent conflicts, each inversable property should be declared in
the ontology such that only one may be explicit.

Consider, for instance, the properties used to form a hierarchy of
entities: 'is_part_of' and 'has_part'.  These two properties are
inverse of one another.  If A 'is_part_of' B then it follows that B
'has_part' A.

A problem arises if you allow explicit declaration of both
'is_part_of' and 'has_part' in your manuscripts: you can create
conflicts.  You might say B 'is_part_of' A but also that C 'has_part'
A.  This can't happen in a hierarchy (not directly).

Setting an "imply only" condition prevents this problem.

=cut

######################################################################

sub get_property_multiplicity {

  my $self = shift;

  my $division_name = shift;
  my $property_name = shift;

  my $href = $self->_get_multiplicity_of_properties_hash;

  if ( exists $href->{$division_name}{$property_name} )
    {
      return $href->{$division_name}{$property_name};
    }

  return 0;
}

=head2 get_property_multiplicity($division_name,$property_name)

Return the declared multiplicity of the specified property in the
specified division.

  my $multiplicity = $ontology->get_property_multiplicity($division_name,$property_name);

Multiplicity tells you the minimum and maximum allowed number of
members in a set.  In SML it is the number of values a property is
allowed to have and may be either '1' or 'many'.

=cut

######################################################################

sub get_entity_name_list {

  my $self = shift;

  my $aref  = [];
  my $tbenh = $self->_get_types_by_division_name_hash;

  foreach my $name ( sort keys %{ $tbenh } )
    {
      my $value = $tbenh->{$name};

      if ( $value eq 'SML::Entity' )
	{
	  push(@{$aref},$name);
	}
    }

  return $aref;
}

=head2 get_entity_name_list

Return an ArrayRef to a list of entity names declared by the ontology.

  my $aref = $ontology->get_entity_name_list;

=cut

######################################################################

sub get_structure_name_list {

  my $self = shift;

  my $aref  = [];
  my $tbenh = $self->_get_types_by_division_name_hash;

  foreach my $name ( sort keys %{ $tbenh } )
    {
      my $value = $tbenh->{$name};

      if ( $value ne 'SML::Entity' )
	{
	  push(@{$aref},$name);
	}
    }

  return $aref;
}

=head2 get_structure_name_list

Return an ArrayRef to a list of structure names declared by the
ontology.  If a division is not an entity it is a structure.

  my $aref = $ontology->get_structure_name_list;

=cut

######################################################################

sub get_allowed_containee_name_list {

  my $self = shift;

  my $division_name = shift;

  my $href = $self->_get_allowed_compositions_hash;

  my $result_hash = {};

  foreach my $containee_name ( keys %{ $href } )
    {
      foreach my $container_name ( keys %{ $href->{$containee_name} } )
	{
	  if ( $container_name eq $division_name )
	    {
	      $result_hash->{$containee_name} = 1;
	    }
	}
    }

  return [ sort keys %{ $result_hash } ];
}

=head2 get_allowed_containee_name_list($division_name)

Return an ArrayRef to a list of division names allowed to exist within
the specified one.

  my $aref = $ontology->get_allowed_containee_name_list($division_name);

=cut

######################################################################

sub get_rule_type_count {

  my $self = shift;

  my $type = shift;

  unless ( $type )
    {
      $logger->error("CAN'T GET RULE TYPE COUNT, MISSING ARGUMENT(S)");
      return 0;
    }

  my $count     = 0;
  my $rule_hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $rule_hash } )
    {
      my $rule_type = $rule->get_rule_type;

      if ( $rule_type eq $type )
	{
	  ++ $count;
	}
    }

  return $count;
}

=head2 get_rule_type_count($type)

Return a scalar integer value for the number of rules of the specified
type.

  my $count = $ontology->get_rule_type_count($type);

=cut

######################################################################

sub get_rule_type_list {

  my $self = shift;

  my $rule_hash = $self->_get_rule_hash;

  my $result_hash = {};

  foreach my $rule ( values %{ $rule_hash } )
    {
      my $rule_type = $rule->get_rule_type;

      $result_hash->{$rule_type} = 1;
    }

  return [ sort keys %{ $result_hash } ];
}

=head2 get_rule_type_list

Return an ArrayRef to the list of rules in the ontology

  my $aref = $ontology->get_rule_type_list;

=cut

######################################################################

sub is_structure {

  my $self = shift;

  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T CHECK IF NAME IS A STRUCTURE, MISSING ARGUMENT");
      return 0;
    }

  my $href = $self->_get_types_by_division_name_hash;

  my $class = $href->{$name};

  unless ( $class )
    {
      $logger->error("THIS SHOULD NEVER HAPPEN $name");
      return 0;
    }

  if ( $class eq 'SML::Entity' )
    {
      return 0;
    }

  return 1;
}

=head2 is_structure($name)

Return 1 if the specified name is the name of a document structure
division.

  my $result = $ontology->is_structure($name);

=cut

######################################################################

sub is_entity {

  my $self = shift;

  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T CHECK IF NAME IS AN ENTITY, MISSING ARGUMENT");
      return 0;
    }

  if ( $self->is_structure($name) )
    {
      return 0;
    }

  return 1;
}

=head2 is_entity($name)

Return 1 if the specified name is the name of a document entity
division.

  my $result = $ontology->is_entity($name);

=cut

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has rule_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_rule_hash',
   default   => sub {{}},
  );

# $href->{$rule_id} = $ontology_rule;

######################################################################

has types_by_division_name_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_types_by_division_name_hash',
   lazy      => 1,
   builder   => '_build_types_by_division_name_hash',
  );

# $href->{$division_name} = $value_type;

######################################################################

has properties_by_division_name_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_properties_by_division_name_hash',
   lazy      => 1,
   builder   => '_build_properties_by_division_name_hash',
  );

# $href->{$division_name}{$property_name} = 1;

######################################################################

has property_rules_lookup_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_property_rules_lookup_hash',
   lazy      => 1,
   builder   => '_build_property_rules_lookup_hash',
  );

# $href->{$division_name}{$property_name}{$name_or_value} = $ontology_rule;

######################################################################

has allowed_property_values_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_allowed_property_values_hash',
   lazy      => 1,
   builder   => '_build_allowed_property_values_hash',
  );

# $href->{$division_name}{$property_name} = $value_list

######################################################################

has allowed_compositions_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_allowed_compositions_hash',
   lazy      => 1,
   builder   => '_build_allowed_compositions_hash',
  );

# $href->{$containee_name}{$container_name} = 1;

######################################################################

has imply_only_properties_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_imply_only_properties_hash',
   lazy      => 1,
   builder   => '_build_imply_only_properties_hash',
  );

# $href->{$division_name}{$property_name} = 1;

######################################################################

has multiplicity_of_properties_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_multiplicity_of_properties_hash',
   lazy      => 1,
   builder   => '_build_multiplicity_of_properties_hash',
  );

# $href->{$division_name}{$property_name} = $multiplicity;

######################################################################

has required_properties_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_required_properties_hash',
   lazy      => 1,
   builder   => '_build_required_properties_hash',
  );

# $href->{$division_name}{$property_name} = 1;

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub BUILD {

  my $self = shift;

  my $library = $self->get_library;
  my $result  = 1;

  $self->_build_builtin_rules;

  foreach my $filespec (@{ $library->get_ontology_rule_filespec_list })
    {
      my $outcome = $self->_read_rule_file($filespec);

      if ( $outcome == 0 )
	{
	  $result = 0;
	}
    }

  return $result;
}

######################################################################

sub _build_builtin_rules {

  my $self = shift;

  my $builtin_rules =
    [
     # rule ID   type   division name              property           object type      name/val inv crd  rq im
     ['SML001', 'div', 'DIVISION_DECLARATION',    'exists',          'SML::Division', ''      ,'',  1,  '', ''],
     ['SML002', 'prp', 'DIVISION_DECLARATION',    'has_division',    'Str'          , 'STRING','',  1,   1 ,''],
     ['SML003', 'prp', 'DIVISION_DECLARATION',    'class',           'Str'          , 'STRING','',  1,   1 ,''],
     ['SML004', 'prp', 'DIVISION_DECLARATION',    'description',     'Str'          , 'STRING','',  1,   0 ,''],

     ['SML005', 'div', 'PROPERTY_DECLARATION',    'exists',          'SML::Division', '',      '',  1,   '',''],
     ['SML006', 'prp', 'PROPERTY_DECLARATION',    'division',        'Str'          , 'STRING','',  1,   1 ,''],
     ['SML007', 'prp', 'PROPERTY_DECLARATION',    'has_property',    'Str'          , 'STRING','',  1,   1 ,''],
     ['SML008', 'prp', 'PROPERTY_DECLARATION',    'object_type',     'Str'          , 'STRING','',  1,   1 ,''],
     ['SML009', 'prp', 'PROPERTY_DECLARATION',    'object_name',     'Str'          , 'STRING','',  1,   1 ,''],
     ['SML010', 'prp', 'PROPERTY_DECLARATION',    'multiplicity',    'Str'          , 'STRING','',  1,   1 ,''],
     ['SML011', 'prp', 'PROPERTY_DECLARATION',    'required',        'Str'          , 'STRING','',  1,   1 ,''],
     ['SML011', 'prp', 'PROPERTY_DECLARATION',    'description',     'Str'          , 'STRING','',  1,   0 ,''],

     ['SML012', 'div', 'COMPOSITION_DECLARATION', 'exists',          'SML::Division', '',      '',  1,   '',''],
     ['SML013', 'prp', 'COMPOSITION_DECLARATION', 'division',        'Str'          , 'STRING','',  1,   1 ,''],
     ['SML014', 'prp', 'COMPOSITION_DECLARATION', 'containee_class', 'Str'          , 'STRING','',  1,   1 ,''],
     ['SML015', 'prp', 'COMPOSITION_DECLARATION', 'containee_name',  'Str'          , 'STRING','',  1,   1 ,''],
     ['SML016', 'prp', 'COMPOSITION_DECLARATION', 'multiplicity',    'Str'          , 'STRING','',  1,   1 ,''],
     ['SML017', 'prp', 'COMPOSITION_DECLARATION', 'description',     'Str'          , 'STRING','',  1,   0 ,''],
     ['SML018', 'enu', 'COMPOSITION_DECLARATION', 'multiplicity',    'Str'          , '1',     '',  1,   1 ,''],
     ['SML019', 'enu', 'COMPOSITION_DECLARATION', 'multiplicity',    'Str'          , 'many',  '',  1,   1 ,''],

     ['SML020', 'div', 'ENUMERATION_DECLARATION', 'exists',          'SML::Division', '',      '',  1,   '',''],
     ['SML021', 'prp', 'ENUMERATION_DECLARATION', 'division',        'Str'          , 'STRING','',  1,   1 ,''],
     ['SML022', 'prp', 'ENUMERATION_DECLARATION', 'property',        'Str'          , 'STRING','',  1,   1 ,''],
     ['SML023', 'prp', 'ENUMERATION_DECLARATION', 'allowed_value',   'Str'          , 'STRING','',  1,   1 ,''],
     ['SML024', 'prp', 'ENUMERATION_DECLARATION', 'description',     'Str'          , 'STRING','',  1,   0 ,''],
    ];

  foreach my $rule (@{ $builtin_rules })
    {
      my $rule_id         = $rule->[0];
      my $rule_type       = $rule->[1];
      my $division_name   = $rule->[2];
      my $property_name   = $rule->[3];
      my $value_type      = $rule->[4];
      my $name_or_value   = $rule->[5];
      my $inverse_rule_id = $rule->[6];
      my $multiplicity    = $rule->[7];
      my $required        = $rule->[8];
      my $imply_only      = $rule->[9];

      my $ontology_rule = SML::OntologyRule->new
	(
	 ontology        => $self,
	 id              => $rule_id,
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

      $self->_add_rule($ontology_rule);
    }

  return 1;
}

######################################################################

sub _read_rule_file {

  my $self     = shift;
  my $filespec = shift;                 # rule file filespec

  if ( not -r "$filespec" )
    {
      my $dir = getcwd;
      $logger->logdie("$filespec not readable from $dir");
      return 0;
    }

  my $library   = $self->get_library;
  my $syntax    = $library->get_syntax;
  my $util      = $library->get_util;
  my $line_list = [];

  open my $fh, '<', $filespec or croak("Couldn't open $filespec");
  @{ $line_list } = <$fh>;
  close $fh;

  foreach my $line (@{ $line_list })
    {
      $line =~ s/[\r\n]*$//;            # chomp;

      if ( $line =~ /$syntax->{comment_line}/ )
	{
	  next;
	}

      if ( $line =~ /$syntax->{blank_line}/ )
	{
	  next;
	}

      my $csv             = Text::CSV->new();
      my $status          = $csv->parse($line);
      my $field           = [ $csv->fields() ];

      my $rule_id         = $util->trim_whitespace( $field->[0] );
      my $rule_type       = $util->trim_whitespace( $field->[1] );
      my $division_name   = $util->trim_whitespace( $field->[2] );
      my $property_name   = $util->trim_whitespace( $field->[3] );
      my $value_type      = $util->trim_whitespace( $field->[4] );
      my $name_or_value   = $util->trim_whitespace( $field->[5] );
      my $inverse_rule_id = $util->trim_whitespace( $field->[6] );
      my $multiplicity    = $util->trim_whitespace( $field->[7] );
      my $required        = $util->trim_whitespace( $field->[8] );
      my $imply_only      = $util->trim_whitespace( $field->[9] );

      my $rule = SML::OntologyRule->new
	(
	 ontology        => $self,
	 id              => $rule_id,
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

      $self->_add_rule($rule);
    }

  return 1;
}

######################################################################

sub _add_rule {

  my $self = shift;
  my $rule = shift;

  unless ( $rule->isa('SML::OntologyRule') )
    {
      $logger->error("CAN'T ADD RULE \'$rule\' is not a SML::OntologyRule");
      return 0;
    }

  my $href    = $self->_get_rule_hash;
  my $rule_id = $rule->get_id;

  $href->{$rule_id} = $rule;

  return 1;
}

######################################################################

sub _build_properties_by_division_name_hash {

  my $self = shift;

  my $pbenh = {};                       # properties by entity name
  my $href  = $self->_get_rule_hash;

  foreach my $rule ( values %{ $href } )
    {
      my $rule_type = $rule->get_rule_type;

      unless ($rule_type eq 'prp')
	{
	  next;
	}

      my $rule_division_name = $rule->get_division_name;
      my $rule_property_name = $rule->get_property_name;

      $pbenh->{$rule_division_name}{$rule_property_name} = 1;

    }

  return $pbenh;
}

######################################################################

sub _build_types_by_division_name_hash {

  my $self = shift;

  my $tbenh = {};                       # types by entity name
  my $href  = $self->_get_rule_hash;

  foreach my $rule ( values %{ $href } )
    {
      my $rule_type = $rule->get_rule_type;

      unless ($rule_type eq 'div')
	{
	  next;
	}

      my $division_name = $rule->get_division_name;
      my $value_type    = $rule->get_value_type;

      $tbenh->{$division_name} = $value_type;
    }

  return $tbenh;
}

######################################################################

sub _build_property_rules_lookup_hash {

  my $self = shift;

  my $prlh = {};                        # property rules lookup
  my $href = $self->_get_rule_hash;

  foreach my $rule ( values %{ $href } )
    {
      my $rule_type = $rule->get_rule_type;

      unless ($rule_type eq 'prp')
	{
	  next;
	}

      my $division_name = $rule->get_division_name   || q{};
      my $property_name = $rule->get_property_name || q{};
      my $name_or_value = $rule->get_name_or_value || q{};

      $prlh->{$division_name}{$property_name}{$name_or_value} = $rule;
    }

  return $prlh;
}

######################################################################

sub _build_allowed_property_values_hash {

  my $self = shift;

  my $apvh = {};                        # allowed property values hash
  my $href = $self->_get_rule_hash;

  foreach my $rule ( values %{ $href } )
    {
      my $rule_type = $rule->get_rule_type;

      unless ($rule_type eq 'enu')
	{
	  next;
	}

      my $division_name = $rule->get_division_name;
      my $property_name = $rule->get_property_name;
      my $value         = $rule->get_name_or_value;

      # !!! BUG HERE !!!
      #
      # The hash values should not be lists.  This should be a
      # 3-dimensional hash.  The third dimension should be the allowed
      # property value and the hash value should be a boolean (1);

      if ( not defined $apvh->{$division_name} )
	{
	  $apvh->{$division_name}{$property_name} = [];
	}

      push @{ $apvh->{$division_name}{$property_name} }, $value;
    }

  return $apvh;
}

######################################################################

sub _build_allowed_compositions_hash {

  my $self = shift;

  my $ach  = {};                        # allowed compositions hash
  my $href = $self->_get_rule_hash;

  foreach my $rule ( values %{ $href } )
    {
      my $rule_type = $rule->get_rule_type;

      unless ($rule_type eq 'cmp')
	{
	  next;
	}

      my $container_name = $rule->get_division_name;
      my $containee_name = $rule->get_name_or_value;

      $ach->{$containee_name}{$container_name} = 1;
    }

  return $ach;

}

######################################################################

sub _build_imply_only_properties_hash {

  # Return a hash of 'imply only' properties indexed by division name.

  my $self = shift;

  my $ioph = {};                        # imply only properties
  my $href = $self->_get_rule_hash;

  foreach my $rule ( values %{ $href } )
    {
      my $rule_type = $rule->get_rule_type;

      unless ($rule_type eq 'prp')
	{
	  next;
	}

      if ( $rule->is_imply_only )
	{
	  my $division_name = $rule->get_division_name;
	  my $property_name = $rule->get_property_name;

	  $ioph->{$division_name}{$property_name} = 1;
	}
    }

  return $ioph;
}

######################################################################

sub _build_multiplicity_of_properties_hash {

  # Return a hash of 'multiplicity of' properties indexed by division
  # name and property.

  my $self = shift;

  my $coph = {};                        # multiplicity of properties
  my $href = $self->_get_rule_hash;

  foreach my $rule ( values %{ $href } )
    {
      my $rule_type = $rule->get_rule_type;

      unless ($rule_type eq 'prp')
	{
	  next;
	}

      my $division_name = $rule->get_division_name;
      my $property_name = $rule->get_property_name;
      my $multiplicity  = $rule->get_multiplicity;

      $coph->{$division_name}{$property_name} = $multiplicity;

    }

  return $coph;
}

######################################################################

sub _build_required_properties_hash {

  # Return a hash of required properties indexed by division name.

  my $self = shift;

  my $rph  = {};                        # required properties hash
  my $href = $self->_get_rule_hash;

  foreach my $rule ( values %{ $href } )
    {
      my $rule_type = $rule->get_rule_type;

      unless ($rule_type eq 'prp')
	{
	  next;
	}

      if ( $rule->is_required )
	{
	  my $division_name = $rule->get_division_name;
	  my $property_name = $rule->get_property_name;

	  $rph->{$division_name}{$property_name} = 1;
	}
    }

  return $rph;
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
