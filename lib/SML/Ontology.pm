#!/usr/bin/perl

# $Id: Ontology.pm 258 2015-04-02 13:56:17Z drj826@gmail.com $

package SML::Ontology;

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

# This is the library object to which the ontology belongs.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_allowed_property_value_list {

  # Return a list of allowed property values (as defined in the
  # enumerated value rules) for the specified division name and a
  # property name.  For instance, return a list of allowed values for
  # DOCUMENT state (DRAFT, REVIEW, APPROVED).

  my $self          = shift;
  my $division_name = shift;
  my $property_name = shift;

  my $hash = $self->_get_allowed_property_values_hash;

  return $hash->{$division_name}{$property_name};
}

######################################################################

sub get_allowed_property_object_name_list {

  # Return a list of allowed property object names for the specified
  # division name and property name.

  my $self          = shift;
  my $division_name = shift;
  my $property_name = shift;

  my $hash = $self->_get_property_rules_lookup_hash;

  return [ sort keys %{ $hash->{$division_name}{$property_name} }];
}

######################################################################

sub value_must_be_division_id_for_property {

  # Return 1 if the value of the specified property (division name,
  # property name) MUST be a division ID (not a STRING or BOOLEAN).

  my $self          = shift;
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

######################################################################

sub get_rule_for {

  # Return the rule for (1) the entity named $division_name, (2) the
  # property named $property_name, and (3) that has an optional
  # inverse entity named $inverse_entity_name.

  my $self          = shift;
  my $division_name = shift;
  my $property_name = shift;
  my $name_or_value = shift;

  my $prl = $self->_get_property_rules_lookup_hash;

  my $rule = $prl->{$division_name}{$property_name}{$name_or_value} || q{};

  return $rule;
}

######################################################################

sub get_inverse_rule_for {

  my $self         = shift;
  my $subject_name = shift;             # rq-002
  my $predicate    = shift;             # is_part_of
  my $object_name  = shift;             # rq-001

  unless ( $subject_name and $predicate and $object_name )
    {
      $logger->error("CAN'T GET INVERSE RULE FOR $subject_name $predicate $object_name");
      return 0;
    }

  my $rule = $self->get_rule_for($subject_name,$predicate,$object_name);

  my $inverse_rule_id = $rule->get_inverse_rule_id;

  return $self->get_rule_with_id($inverse_rule_id);
}

######################################################################

sub get_rule_with_id {

  my $self    = shift;
  my $rule_id = shift;

  unless ( $rule_id )
    {
      $logger->error("CAN'T GET RULE WITH ID, MISSING ARGUMENT");
      return 0;
    }

  my $hash = $self->_get_rule_hash;
  my $rule = $hash->{$rule_id};

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

######################################################################

sub get_class_for_division_name {

  my $self = shift;
  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T GET CLASS FOR DIVISION NAME, MISSING ARGUMENT");
      return 0;
    }

  my $hash = $self->_get_types_by_division_name_hash;

  unless ( exists $hash->{$name} )
    {
      $logger->error("THERE IS NO CLASS FOR DIVISION NAME \'$name\'");
      return 0;
    }

  return $hash->{$name};
}

######################################################################

sub get_list_of_allowed_property_names_for_division_name {

  my $self = shift;
  my $name = shift;

  if ( not $name )
    {
      $logger->logcluck("CAN'T GET LIST OF ALLOWED PROPERTY NAMES FOR DIVISION NAME, MISSING ARGUMENT");
      return 0;
    }

  my $href = $self->_get_properties_by_division_name_hash->{$name};

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

######################################################################

sub get_list_of_required_property_names_for_division_name {

  my $self          = shift;
  my $division_name = shift;

  unless ( $division_name )
    {
      $logger->error("CAN'T GET LIST OF REQUIRED PROPERTY NAMES FOR DIVISION NAME, MISSING ARGUMENT");
      return 0;
    }

  my $hash = $self->_get_required_properties_hash;

  if ( exists $hash->{$division_name} )
    {
      return [ sort keys %{ $hash->{$division_name} } ]
    }

  else
    {
      return [];
    }
}

######################################################################

sub has_division_with_name {

  # If, DURING the reading of rule files you need to know whether an
  # division with a specified name has been defined use THIS method.
  #
  # Notice that this method loops through the rule hash to determine
  # whether the ontology defines an division with the specified name.
  # The rule hash is built bit by bit as the rule files are read.
  # This means this method will return an answer based on the rules
  # read SO FAR.

  my $self = shift;
  my $name = shift;

  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
    {
      my $division_name = $rule->get_division_name;

      if ( $division_name eq $name )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub has_rule_for {

  # Return 1 if the ontology has a rule for the specified division
  # name, property name, and object name or value.

  my $self          = shift;
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

######################################################################

sub has_inverse_rule_for {

  # Return 1 if the ontology has an inverse rule for the specified
  # division name and property name.

  my $self          = shift;
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

######################################################################

sub allows_division_name {

  # Return 1 if the ontology allows the specified division name.
  #
  # ONLY USE AFTER the reading of rule files you need to know whether
  # an entity with a specified name has been defined use THIS method.

  my $self = shift;
  my $name = shift;

  my $hash = $self->_get_types_by_division_name_hash;

  if ( exists $hash->{$name} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub allows_property_name_in_division_name {

  my $self          = shift;
  my $property_name = shift;
  my $division_name = shift;

  if ( not $division_name )
    {
      $logger->logcluck("YOU MUST PROVIDE AN ENTITY NAME");
    }

  if ( not $property_name )
    {
      $logger->logcluck("YOU MUST PROVIDE A PROPERTY NAME");
    }

  my $list = $self->get_list_of_allowed_property_names_for_division_name($division_name);

  if ( not $list )
    {
      return 0;
    }

  foreach my $name (@{ $list })
    {
      if ( $name eq $property_name )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub allows_composition {

  # Return 1 if division A is allowed within division B.

  my $self            = shift;
  my $division_name_a = shift;
  my $division_name_b = shift;

  my $hash = $self->_get_allowed_compositions_hash;

  if ( defined $hash->{$division_name_a}{$division_name_b} )
    {
      return 1;
    }

  else
    {
      return 0;
    }

}

######################################################################

sub allows_property_value {

  my $self          = shift;
  my $division_name = shift;
  my $property_name = shift;
  my $value         = shift;

  my $hash = $self->_get_allowed_property_values_hash;

  # allowed property value list
  my $apv_list = $hash->{$division_name}{$property_name};

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

######################################################################

sub allows_triple {

  my $self      = shift;
  my $subject   = shift;                # rq-002
  my $predicate = shift;                # is_part_of
  my $object    = shift;                # rq-001

  unless ( $subject and $predicate and $object )
    {
      $logger->error("CAN'T CHECK IF ONTOLOGY ALLOWS TRIPLE $subject $predicate $object");
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

######################################################################

sub property_is_universal {

  # Return 1 if the specified property name is universal.  That means
  # it can appear anywhere in the text and is not restricted to
  # certain divisions.

  my $self = shift;
  my $name = shift;

  my $hash = $self->_get_property_rules_lookup_hash;

  if ( exists $hash->{'UNIVERSAL'}{$name} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub property_is_required {

  # Return 1 if the specified property is required for the specified
  # division.

  my $self          = shift;
  my $division_name = shift;
  my $property_name = shift;

  my $hash = $self->_get_required_properties_hash;

  if ( exists $hash->{$division_name}{$property_name} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub property_is_imply_only {

  my $self          = shift;
  my $division_name = shift;
  my $property_name = shift;

  my $hash = $self->_get_imply_only_properties_hash;

  unless ( $hash->{$division_name}{$property_name} )
    {
      return 0;
    }

  return 1;
}

######################################################################

sub property_allows_cardinality {

  # Return the allowed cardinality of the specified division and
  # property.

  my $self          = shift;
  my $division_name = shift;
  my $property_name = shift;

  my $hash = $self->_get_cardinality_of_properties_hash;

  if ( exists $hash->{$division_name}{$property_name} )
    {
      return $hash->{$division_name}{$property_name};
    }

  return 0;
}

######################################################################

sub get_entity_name_list {

  # Return a list of division names that have a value type of
  # SML::Entity.

  my $self = shift;

  my $list  = [];
  my $tbenh = $self->_get_types_by_division_name_hash;

  foreach my $name ( sort keys %{ $tbenh } )
    {
      my $value = $tbenh->{$name};

      if ( $value eq 'SML::Entity' )
	{
	  push(@{$list},$name);
	}
    }

  return $list;
}

######################################################################

sub get_structure_name_list {

  # Return a list of division names that DON'T have a value type of
  # SML::Entity.

  my $self = shift;

  my $list  = [];
  my $tbenh = $self->_get_types_by_division_name_hash;

  # !!! BUG HERE !!!
  #
  # This should check for values equal to SML::Structure rather than
  # values NOT equal to SML::Entity (but SML::Structure doesn't exist
  # yet).

  foreach my $name ( sort keys %{ $tbenh } )
    {
      my $value = $tbenh->{$name};

      if ( $value ne 'SML::Entity' )
	{
	  push(@{$list},$name);
	}
    }

  return $list;
}

######################################################################

sub get_allowed_containee_name_list {

  # Return a list of divisions allowed within the specified one.

  my $self          = shift;
  my $division_name = shift;

  my $hash = $self->_get_allowed_compositions_hash;

  my $result_hash = {};

  foreach my $containee_name ( keys %{ $hash } )
    {
      foreach my $container_name ( keys %{ $hash->{$containee_name} } )
	{
	  if ( $container_name eq $division_name )
	    {
	      $result_hash->{$containee_name} = 1;
	    }
	}
    }

  return [ sort keys %{ $result_hash } ];
}

######################################################################

sub get_rule_type_count {

  my $self = shift;
  my $type = shift;

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

######################################################################

sub is_structure {

  # Return 1 if the specified name is the name of a structure
  # division.  All divisions are structure divisions except for
  # entities.

  my $self = shift;
  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T CHECK IF NAME IS A STRUCTURE, MISSING ARGUMENT");
      return 0;
    }

  my $hash = $self->_get_types_by_division_name_hash;

  my $class = $hash->{$name};

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

######################################################################

sub is_entity {

  # Return 1 if the specified name is the name of an entity division.
  # All divisions are structure divisions except for entities.

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

# $hash->{$rule_id} = $ontology_rule;

######################################################################

has types_by_division_name_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_types_by_division_name_hash',
   lazy      => 1,
   builder   => '_build_types_by_division_name_hash',
  );

# $hash->{$division_name} = $value_type;

######################################################################

has properties_by_division_name_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_properties_by_division_name_hash',
   lazy      => 1,
   builder   => '_build_properties_by_division_name_hash',
  );

# $hash->{$division_name}{$property_name} = 1;

######################################################################

has property_rules_lookup_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_property_rules_lookup_hash',
   lazy      => 1,
   builder   => '_build_property_rules_lookup_hash',
  );

# $hash->{$division_name}{$property_name}{$name_or_value} = $ontology_rule;

######################################################################

has allowed_property_values_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_allowed_property_values_hash',
   lazy      => 1,
   builder   => '_build_allowed_property_values_hash',
  );

# $hash->{$division_name}{$property_name} = $value_list

######################################################################

has allowed_compositions_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_allowed_compositions_hash',
   lazy      => 1,
   builder   => '_build_allowed_compositions_hash',
  );

# $hash->{$containee_name}{$container_name} = 1;

######################################################################

has imply_only_properties_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_imply_only_properties_hash',
   lazy      => 1,
   builder   => '_build_imply_only_properties_hash',
  );

# $hash->{$division_name}{$property_name} = 1;

######################################################################

has cardinality_of_properties_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_cardinality_of_properties_hash',
   lazy      => 1,
   builder   => '_build_cardinality_of_properties_hash',
  );

# $hash->{$division_name}{$property_name} = $cardinality;

######################################################################

has required_properties_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_required_properties_hash',
   lazy      => 1,
   builder   => '_build_required_properties_hash',
  );

# $hash->{$division_name}{$property_name} = 1;

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
     ['SML010', 'prp', 'PROPERTY_DECLARATION',    'cardinality',     'Str'          , 'STRING','',  1,   1 ,''],
     ['SML011', 'prp', 'PROPERTY_DECLARATION',    'required',        'Str'          , 'STRING','',  1,   1 ,''],
     ['SML011', 'prp', 'PROPERTY_DECLARATION',    'description',     'Str'          , 'STRING','',  1,   0 ,''],

     ['SML012', 'div', 'COMPOSITION_DECLARATION', 'exists',          'SML::Division', '',      '',  1,   '',''],
     ['SML013', 'prp', 'COMPOSITION_DECLARATION', 'division',        'Str'          , 'STRING','',  1,   1 ,''],
     ['SML014', 'prp', 'COMPOSITION_DECLARATION', 'containee_class', 'Str'          , 'STRING','',  1,   1 ,''],
     ['SML015', 'prp', 'COMPOSITION_DECLARATION', 'containee_name',  'Str'          , 'STRING','',  1,   1 ,''],
     ['SML016', 'prp', 'COMPOSITION_DECLARATION', 'cardinality',     'Str'          , 'STRING','',  1,   1 ,''],
     ['SML017', 'prp', 'COMPOSITION_DECLARATION', 'description',     'Str'          , 'STRING','',  1,   0 ,''],
     ['SML018', 'enu', 'COMPOSITION_DECLARATION', 'cardinality',     'Str'          , '1',     '',  1,   1 ,''],
     ['SML019', 'enu', 'COMPOSITION_DECLARATION', 'cardinality',     'Str'          , 'many',  '',  1,   1 ,''],

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
      my $cardinality     = $rule->[7];
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
	 cardinality     => $cardinality,
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
      my $cardinality     = $util->trim_whitespace( $field->[7] );
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
	 cardinality     => $cardinality,
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

  my $hash    = $self->_get_rule_hash;
  my $rule_id = $rule->get_id;

  $hash->{$rule_id} = $rule;

  return 1;
}

######################################################################

sub _build_properties_by_division_name_hash {

  my $self = shift;

  my $pbenh = {};                       # properties by entity name
  my $hash  = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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
  my $hash  = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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

sub _build_cardinality_of_properties_hash {

  # Return a hash of 'cardinality of' properties indexed by division
  # name and property.

  my $self = shift;

  my $coph = {};                        # cardinality of properties
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
    {
      my $rule_type = $rule->get_rule_type;

      unless ($rule_type eq 'prp')
	{
	  next;
	}

      my $division_name = $rule->get_division_name;
      my $property_name = $rule->get_property_name;
      my $cardinality   = $rule->get_cardinality;

      $coph->{$division_name}{$property_name} = $cardinality;

    }

  return $coph;
}

######################################################################

sub _build_required_properties_hash {

  # Return a hash of required properties indexed by division name.

  my $self = shift;

  my $rph  = {};                        # required properties hash
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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

=head1 NAME

C<SML::Ontology> - an explicit formal specification of terms that
represent the entities defined to exist in some area of interest, the
relationships that hold among them, and the formal axioms that
constrain the interpretation and well-formed use of those terms.

=head1 VERSION

This documentation refers to L<"SML::Ontology"> version 2.0.0.

=head1 SYNOPSIS

  my $ont = SML::Ontology->new();

=head1 DESCRIPTION

An ontology is an explicit formal specification of terms that
represent the entities defined to exist in some area of interest, the
relationships that hold among them, and the formal axioms that
constrain the interpretation and well-formed use of those terms.

=head1 METHODS

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
