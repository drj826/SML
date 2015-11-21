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

has 'library' =>
  (
   isa       => 'SML::Library',
   reader    => 'get_library',
   required  => 1,
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_rules_from_file {

  my $self      = shift;
  my $file_list = shift;                # list of rules files

  if ( not ref $file_list eq 'ARRAY' )
    {
      $logger->logcluck("NOT A LIST $file_list");
      return 0;
    }

  my $result = 1;

  foreach my $filespec (@{ $file_list })
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

sub get_allowed_property_value_list {

  # Given an entity name and a property name, return a list of allowed
  # property values.

  my $self          = shift;
  my $entity_name   = shift;
  my $property_name = shift;

  return $self->_get_allowed_property_values_hash->{$entity_name}{$property_name};
}

######################################################################

sub get_entity_allowed_property_list {

  my $self        = shift;
  my $entity_name = shift;

  if ( not $entity_name )
    {
      $logger->logcluck("YOU MUST PROVIDE AN ENTITY NAME");
    }

  my $href = $self->_get_properties_by_entity_name_hash->{$entity_name};

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

# sub get_allowed_environment_list {

#   my $self = shift;

#   my $list = [];                        # allowed environments list
#   my $hash = $self->_get_rule_hash;

#   foreach my $rule ( values %{ $hash } )
#     {
#       my $entity_name = $rule->get_entity_name;
#       my $rule_type   = $rule->get_rule_type;
#       my $value_type  = $rule->get_value_type;

#       if ( $rule_type eq 'cls' and $self->allows_environment($entity_name) )
# 	{
# 	  push @{ $list }, $entity_name;
# 	}
#     }

#   my $ae = [ sort @{ $list } ];

#   return $ae;
# }

######################################################################

# sub get_entity_type {

#   my $self        = shift;
#   my $entity_name = shift;

#   if ( not defined $self->_get_types_by_entity_name_hash->{$entity_name} )
#     {
#       $logger->info("NO TYPE DEFINED: for $entity_name");
#       return 0;
#     }

#   else
#     {
#       return $self->_get_types_by_entity_name_hash->{$entity_name};
#     }
# }

######################################################################

sub get_rule_for {

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

sub get_rule_with_id {

  my $self = shift;
  my $id   = shift;

  my $hash = $self->_get_rule_hash;
  my $rule = $hash->{$id};

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

# sub get_divisions_by_name_hash {

#   my $self = shift;

#   my $dbn  = {};                        # divisions by name
#   my $hash = $self->_get_rule_hash;

#   foreach my $rule ( values %{ $hash } )
#     {
#       my $rule_type = $rule->get_rule_type;

#       if ($rule_type ne 'cls') {
# 	next;
#       }

#       my $entity_name = $rule->get_entity_name;
#       my $value_type  = $rule->get_value_type;

#       $dbn->{$entity_name} = [ $value_type ];
#     }

#   return $dbn;
# }

######################################################################

sub get_class_for_entity_name {

  my $self        = shift;
  my $entity_name = shift;

  my $tbenh = $self->_get_types_by_entity_name_hash;

  if ( exists $tbenh->{$entity_name} )
    {
      return $tbenh->{$entity_name};
    }

  else
    {
      $logger->error("THERE IS NO CLASS FOR ENTITY NAME \'$entity_name\'");
      return 0;
    }
}

######################################################################

sub get_required_property_list {

  my $self    = shift;
  my $divname = shift;

  my $rph = $self->_get_required_properties_hash;

  if ( exists $rph->{$divname} )
    {
      return [ sort keys %{ $rph->{$divname} } ]
    }

  else
    {
      return [];
    }
}

######################################################################

sub has_entity_with_name {

  # If, DURING the reading of rule files you need to know whether an
  # entity with a specified name has been defined use THIS method.
  #
  # Notice that this method loops through the rule hash to determine
  # whether the ontology defines an entity with the specified name.
  # The rule hash is built bit by bit as the rule files are read.
  # This means this method will return an answer based on the rules
  # read SO FAR.

  my $self        = shift;
  my $entity_name = shift;

  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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

sub allows_entity {

  # If, AFTER the reading of rule files you need to know whether an
  # entity with a specified name has been defined use THIS method.

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

sub allows_division {

  my $self = shift;
  my $name = shift;

  if ( exists $self->_get_types_by_entity_name_hash->{$name}
       and
       (
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::CommentDivision'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Document'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Division'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Conditional'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Demo'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Entity'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Exercise'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Quotation'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::RESOURCES'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Slide'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Library'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Assertion'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Attachment'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Audio'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Baretable'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Epigraph'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Figure'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Footer'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Header'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Keypoints'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Listing'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::PreformattedDivision'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Revisions'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Sidebar'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Source'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Table'
	or
	$self->_get_types_by_entity_name_hash->{$name} eq 'SML::Video'
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
  my $division_name = shift;
  my $property_name = shift;

  if ( not $division_name )
    {
      $logger->logcluck("YOU MUST PROVIDE AN ENTITY NAME");
    }

  if ( not $property_name )
    {
      $logger->logcluck("YOU MUST PROVIDE A PROPERTY NAME");
    }

  my $list = $self->get_entity_allowed_property_list($division_name);

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

  if ( not $self->_get_imply_only_properties_hash->{$divname}{$property_name} )
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
  my $divname       = shift;
  my $property_name = shift;

  return $self->_get_cardinality_of_properties_hash->{$divname}{$property_name};
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

sub BUILD {

  my $self = shift;

  my $library = $self->get_library;
  my $result  = 1;

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

sub _add_rule {

  my $self = shift;
  my $rule = shift;

  if ( $rule->isa('SML::OntologyRule') )
    {
      my $hash   = $self->_get_rule_hash;
      my $ruleid = $rule->get_id;

      $hash->{$ruleid} = $rule;

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
  my $hash  = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
    {
      my $rule_type = $rule->get_rule_type;

      if ($rule_type ne 'prp') {
	next;
      }

      my $rule_entity_name   = $rule->get_entity_name;
      my $rule_property_name = $rule->get_property_name;

      $pbenh->{$rule_entity_name}{$rule_property_name} = 1;

    }

  return $pbenh;
}

######################################################################

sub _build_types_by_entity_name_hash {

  my $self = shift;

  my $tbenh = {};                       # types by entity name
  my $hash  = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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

  my $ach  = {};                        # allowed compositions hash
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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

  my $rph  = {};                        # required properties hash
  my $hash = $self->_get_rule_hash;

  foreach my $rule ( values %{ $hash } )
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
