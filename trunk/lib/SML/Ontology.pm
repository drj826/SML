#!/usr/bin/perl

# $Id$

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

use SML;
use SML::OntologyRule;

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_rules_from_file {

  my $self          = shift;
  my $rule_filename = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  #-------------------------------------------------------------------
  # rule file not readable?
  #
  if ( not -r "$rule_filename" )
    {
      my $dir = getcwd;
      $logger->logdie("$rule_filename not readable from $dir");
    }

  #-------------------------------------------------------------------
  # Read ontology configuration file
  #
  my $line_list = [];

  open my $fh, '<', $rule_filename or croak("Couldn't open $rule_filename");
  @{ $line_list } = <$fh>;
  close $fh;

  foreach my $text (@{ $line_list })
    {
      $text =~ s/[\r\n]*$//;            # chomp;

      if ( $text =~ /$syntax->{comment_line}/ )
	{
	  next;
	}

      if ( $text =~ /$syntax->{blank_line}/ )
	{
	  next;
	}

      my $sml             = SML->instance;
      my $util            = $sml->get_util;
      my $csv             = Text::CSV->new();
      my $status          = $csv->parse($text);
      my $field           = [ $csv->fields() ];

      my $rule_id         = $util->trim_whitespace( $field->[0] );
      my $rule_type       = $util->trim_whitespace( $field->[1] );
      my $entity_name     = $util->trim_whitespace( $field->[2] );
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
	 entity_name     => $entity_name,
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

sub get_allowed_property_value_list {

  # Given an entity name and a property name, return a list of allowed
  # property values.

  my $self          = shift;
  my $entity_name   = shift;
  my $property_name = shift;

  return $self->_get_allowed_property_values_hash->{$entity_name}{$property_name};
}

######################################################################

sub contains_entity_named {

  my $self        = shift;
  my $entity_name = shift;

  foreach my $rule ( values %{ $self->_get_rule_hash } )
    {
      my $name = $rule->get_entity_name;

      if ( $name eq $entity_name )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub allowed_properties {

  my $self        = shift;
  my $entity_name = shift;

  my $list = $self->_get_properties_by_entity_name_hash->{$entity_name};

  if ( not defined $list or not scalar @{ $list } )
    {
      $logger->warn("NO PROPERTIES DEFINED for $entity_name");
    }

  return $list;
}

######################################################################

sub allowed_environments {

  my $self = shift;

  my $list = [];                        # allowed environments list

  foreach my $rule ( values %{ $self->_get_rule_hash } )
    {
      my $entity_name = $rule->get_entity_name;
      my $rule_type   = $rule->get_rule_type;
      my $value_type  = $rule->get_value_type;

      if ( $rule_type eq 'cls' and $self->allows_environment($entity_name) )
	{
	  push @{ $list }, $entity_name;
	}
    }

  my $ae = [ sort @{ $list } ];

  return $ae;
}

######################################################################

sub type_of {

  my $self        = shift;
  my $entity_name = shift;

  if ( not defined $self->_get_types_by_entity_name_hash->{$entity_name} )
    {
      $logger->info("NO TYPE DEFINED: for $entity_name");
      return 0;
    }

  else
    {
      return $self->_get_types_by_entity_name_hash->{$entity_name};
    }
}

######################################################################

sub has_entity {

  my $self        = shift;
  my $entity_name = shift;

  if ( exists $self->_get_types_by_entity_name_hash->{$entity_name} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub allows_region {

  my $self        = shift;
  my $entity_name = shift;

  if ( exists $self->_get_types_by_entity_name_hash->{$entity_name}
       and
       (
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Region'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Demo'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Entity'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Exercise'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Quotation'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::RESOURCES'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Slide'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Library'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Document'
       )
     )

    {
      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub allows_environment {

  my $self        = shift;
  my $entity_name = shift;

  if ( exists $self->_get_types_by_entity_name_hash->{$entity_name}
       and
       (
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Environment'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Assertion'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Attachment'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Audio'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Baretable'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Epigraph'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Figure'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Footer'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Header'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Keypoints'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Listing'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::PreformattedDivision'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Revisions'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Sidebar'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Source'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Table'
	or
	$self->_get_types_by_entity_name_hash->{$entity_name} eq 'SML::Video'
       )
     )

    {
      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub allows_property {

  my $self          = shift;
  my $entity_name   = shift;
  my $property_name = shift;

  if ( not $self->allowed_properties($entity_name) )
    {
      return 0;
    }

  foreach my $name (@{ $self->allowed_properties($entity_name) })
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

  my $self   = shift;
  my $name_a = shift;
  my $name_b = shift;

  if ( defined $self->_get_allowed_compositions_hash->{$name_a}{$name_b} )
    {
      return 1;
    }

  else
    {
      return 0;
    }

}

######################################################################

sub rule_for {

  # Return the rule for (1) the entity named $entity_name, (2) the
  # property named $property_name, and (3) that has an optional
  # inverse entity named $inverse_entity_name.

  my $self          = shift;
  my $entity_name   = shift;
  my $property_name = shift;
  my $name_or_value = shift;

  my $prl = $self->_get_property_rules_lookup_hash;

  my $rule = $prl->{$entity_name}{$property_name}{$name_or_value} || q{};

  return $rule;
}

######################################################################

sub rule_with_id {

  my $self = shift;
  my $id   = shift;

  my $rule = $self->_get_rule_hash->{$id};

  if ( defined $rule )
    {
      return $rule;
    }

  else
    {
      $logger->error("CAN'T GET RULE \'$id\'");
      return 0;
    }
}

######################################################################

sub property_is_universal {

  my $self          = shift;
  my $property_name = shift;

  my $lookup = $self->_get_property_rules_lookup_hash;

  if ( exists $lookup->{'UNIVERSAL'}{$property_name} )
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
  my $divname       = shift;
  my $property_name = shift;

  return $self->_get_imply_only_properties_hash->{$divname}{$property_name};
}

######################################################################

sub property_allows_cardinality {

  my $self          = shift;
  my $divname       = shift;
  my $property_name = shift;

  return $self->_get_cardinality_of_properties_hash->{$divname}{$property_name};
}

######################################################################

sub divisions_by_name {

  my $self = shift;

  my $dbn  = {};                        # divisions by name

  foreach my $rule ( values %{ $self->_get_rule_hash } )
    {
      my $rule_type = $rule->get_rule_type;

      if ($rule_type ne 'cls') {
	next;
      }

      my $entity_name = $rule->get_entity_name;
      my $value_type  = $rule->get_value_type;

      $dbn->{$entity_name} = [ $value_type ];
    }

  return $dbn;
}

######################################################################

sub allows_property_value {

  my $self          = shift;
  my $entity_name   = shift;
  my $property_name = shift;
  my $value         = shift;

  my $apv = $self->_get_allowed_property_values_hash->{$entity_name}{$property_name};

  if (
      ( not defined $apv )
      or
      ( defined $apv and not scalar @{ $apv } )
     )
    {
      return 1;
    }

  foreach my $allowed_value ( @{ $apv } )
    {
      if ( $value eq $allowed_value )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub class_for_entity_name {

  my $self        = shift;
  my $entity_name = shift;

  return $self->_get_types_by_entity_name_hash->{$entity_name};
}

######################################################################

sub get_required_property_list {

  my $self    = shift;
  my $divname = shift;

  return [ keys %{ $self->_get_required_properties_hash->{$divname} } ];
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has 'rule_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_rule_hash',
   writer    => '_set_rule_hash',
   clearer   => '_clear_rule_hash',
   predicate => '_has_rule_hash',
   default   => sub {{}},
  );

######################################################################

has 'types_by_entity_name_hash' =>
  (
   isa      => 'HashRef',
   reader   => '_get_types_by_entity_name_hash',
   lazy     => 1,
   builder  => '_build_types_by_entity_name_hash',
  );

######################################################################

has 'properties_by_entity_name_hash' =>
  (
   isa      => 'HashRef',
   reader   => '_get_properties_by_entity_name_hash',
   lazy     => 1,
   builder  => '_build_properties_by_entity_name_hash',
  );

######################################################################

has 'property_rules_lookup_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_property_rules_lookup_hash',
   lazy    => 1,
   builder => '_build_property_rules_lookup_hash',
  );

######################################################################

has 'allowed_property_values_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_allowed_property_values_hash',
   lazy    => 1,
   builder => '_build_allowed_property_values_hash',
  );

######################################################################

has 'allowed_compositions_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_allowed_compositions_hash',
   lazy    => 1,
   builder => '_build_allowed_compositions_hash',
  );

######################################################################

has 'imply_only_properties_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_imply_only_properties_hash',
   lazy    => 1,
   builder => '_build_imply_only_properties_hash',
  );

######################################################################

has 'cardinality_of_properties_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_cardinality_of_properties_hash',
   lazy    => 1,
   builder => '_build_cardinality_of_properties_hash',
  );

######################################################################

has 'required_properties_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_required_properties_hash',
   lazy    => 1,
   builder => '_build_required_properties_hash',
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _add_rule {

  my $self = shift;
  my $rule = shift;

  if ( $rule->isa('SML::OntologyRule') )
    {
      my $rules  = $self->_get_rule_hash;
      my $ruleid = $rule->get_id;
      $rules->{$ruleid} = $rule;
      return 1;
    }

  else
    {
      $logger->error("CAN'T ADD RULE \'$rule\' is not a SML::OntologyRule");
      return 0;
    }

}

######################################################################

sub _build_properties_by_entity_name_hash {

  my $self = shift;

  my $pbenh = {};                       # properties by entity name

  foreach my $rule ( values %{ $self->_get_rule_hash } )
    {
      my $rule_type = $rule->get_rule_type;

      if ($rule_type ne 'prp') {
	next;
      }

      my $rule_entity_name   = $rule->get_entity_name;
      my $rule_property_name = $rule->get_property_name;

      if ( not defined $pbenh->{$rule_entity_name} )
	{
	  $pbenh->{$rule_entity_name} = [];
	}

      push @{ $pbenh->{$rule_entity_name} }, $rule_property_name;
    }

  return $pbenh;
}

######################################################################

sub _build_types_by_entity_name_hash {

  my $self = shift;

  my $tbenh = {};                       # types by entity name

  foreach my $rule ( values %{ $self->_get_rule_hash } )
    {
      my $rule_type = $rule->get_rule_type;

      if ($rule_type ne 'cls') {
	next;
      }

      my $entity_name = $rule->get_entity_name;

      $tbenh->{$entity_name} = $rule->get_value_type;
    }

  return $tbenh;
}

######################################################################

sub _build_property_rules_lookup_hash {

  my $self = shift;

  my $prlh = {};                        # property rules lookup

  foreach my $rule ( values %{ $self->_get_rule_hash } )
    {
      my $rule_type = $rule->get_rule_type;

      if ($rule_type ne 'prp') {
	next;
      }

      my $entity_name   = $rule->get_entity_name   || q{};
      my $property_name = $rule->get_property_name || q{};
      my $name_or_value = $rule->get_name_or_value || q{};

      $prlh->{$entity_name}{$property_name}{$name_or_value} = $rule;
    }

  return $prlh;
}

######################################################################

sub _build_allowed_property_values_hash {

  my $self = shift;

  my $apvh = {};                        # allowed property values hash

  foreach my $rule ( values %{ $self->_get_rule_hash } )
    {
      my $rule_type = $rule->get_rule_type;

      if ($rule_type ne 'enu') {
	next;
      }

      my $entity_name   = $rule->get_entity_name;
      my $property_name = $rule->get_property_name;
      my $value         = $rule->get_name_or_value;

      if ( not defined $apvh->{$entity_name} )
	{
	  $apvh->{$entity_name}{$property_name} = [];
	}

      push @{ $apvh->{$entity_name}{$property_name} }, $value;
    }

  return $apvh;
}

######################################################################

sub _build_allowed_compositions_hash {

  my $self = shift;

  my $ach = {};                         # allowed compositions hash

  foreach my $rule ( values %{ $self->_get_rule_hash } )
    {
      my $rule_type = $rule->get_rule_type;

      if ($rule_type ne 'cmp') {
	next;
      }

      my $container_name = $rule->get_entity_name;
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

  foreach my $rule ( values %{ $self->_get_rule_hash } )
    {
      if ($rule->get_rule_type ne 'prp') {
	next;
      }

      if ( $rule->is_imply_only )
	{
	  my $entity_name   = $rule->get_entity_name;
	  my $property_name = $rule->get_property_name;

	  $ioph->{$entity_name}{$property_name} = 1;
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

  foreach my $rule ( values %{ $self->_get_rule_hash } )
    {
      if ($rule->get_rule_type ne 'prp') {
	next;
      }

      my $entity_name   = $rule->get_entity_name;
      my $property_name = $rule->get_property_name;
      my $cardinality   = $rule->get_cardinality;

      $coph->{$entity_name}{$property_name} = $cardinality;

    }

  return $coph;
}

######################################################################

sub _build_required_properties_hash {

  # Return a hash of required properties indexed by division name.

  my $self = shift;

  my $rph = {};                         # required properties hash

  foreach my $rule ( values %{ $self->_get_rule_hash } )
    {
      if ($rule->get_rule_type ne 'prp') {
	next;
      }

      if ( $rule->is_required )
	{
	  my $entity_name   = $rule->get_entity_name;
	  my $property_name = $rule->get_property_name;

	  $rph->{$entity_name}{$property_name} = 1;
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
