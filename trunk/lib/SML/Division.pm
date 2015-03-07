#!/usr/bin/perl

# $Id$

package SML::Division;

use Moose;

extends 'SML::Part';

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Division');

use lib "..";

use SML;
use SML::Property;

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+id' =>
  (
   required => 1,
  );

######################################################################

has 'number' =>
  (
   isa      => 'Str',
   reader   => 'get_number',
   writer   => 'set_number',
   default  => '',
  );

######################################################################

has 'previous_number' =>
  (
   isa      => 'Str',
   reader   => 'get_previous_number',
   writer   => 'set_previous_number',
   default  => '',
  );

######################################################################

has 'next_number' =>
  (
   isa      => 'Str',
   reader   => 'get_next_number',
   writer   => 'set_next_number',
   default  => '',
  );

######################################################################

has 'containing_division' =>
  (
   isa       => 'SML::Division',
   reader    => 'get_containing_division',
   writer    => 'set_containing_division',
   predicate => 'has_containing_division',
  );

# The division to which this one belongs; the division containing this
# one; the division of which this one is a part.

######################################################################

has 'valid_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_syntax',
   lazy      => 1,
   builder   => '_validate_syntax',
  );

######################################################################

has 'valid_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_semantics',
   lazy      => 1,
   builder   => '_validate_semantics',
  );

# division conforms with property cardinality rules
# division elements conform with infer-only rules
# division elements conform with allowed value rules
# division conforms with required property rules
# division conforms with composition rules

######################################################################

has 'valid_property_cardinality' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_property_cardinality',
   lazy      => 1,
   builder   => '_validate_property_cardinality',
  );

######################################################################

has 'valid_property_values' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_property_values',
   lazy      => 1,
   builder   => '_validate_property_values',
  );

######################################################################

has 'valid_infer_only_conformance' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_infer_only_conformance',
   lazy      => 1,
   builder   => '_validate_infer_only_conformance',
  );

######################################################################

has 'valid_required_properties' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_required_properties',
   lazy      => 1,
   builder   => '_validate_required_properties',
  );

######################################################################

has 'valid_composition' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_composition',
   lazy      => 1,
   builder   => '_validate_composition',
  );

######################################################################

has 'valid_id_uniqueness' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_id_uniqueness',
   lazy      => 1,
   builder   => '_validate_id_uniqueness',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_division {

  my $self     = shift;
  my $division = shift;

  # validate input
  if (
      not ref $division
      or
      not $division->isa('SML::Division')
     )
    {
      $logger->error("NOT A DIVISION \'$division\'");
      return 0;
    }

  my $id = $division->get_id;

  if ( exists $self->_get_division_hash->{$id} )
    {
      $logger->warn("DIVISION ALREADY EXISTS $id");
    }

  $self->_get_division_hash->{$id} = $division;

  return 1;
}

######################################################################

sub add_part {

  # A part of a division must be either a block or a division.

  my $self = shift;
  my $part = shift;

  # validate input
  if (
      ( not ref $part )
      or
      (
       not
       (
	$part->isa('SML::Block')
	or
	$part->isa('SML::Division')
       )
      )
     )
    {
      $logger->error("CAN'T ADD PART TO DIVISION \'$part\' is not a block or division");
      return 0;
    }

  $part->set_containing_division($self);

  push @{ $self->get_part_list }, $part;

  $logger->trace("add part $part");

  return 1;
}

######################################################################

sub add_property {

  my $self     = shift;
  my $property = shift;

  # validate input
  if (
      not ref $property
      or
      not $property->isa('SML::Property')
     )
    {
      $logger->error("NOT A PROPERTY \'$property\'");
      return 0;
    }

  my $name = $property->get_name;
  my $ph   = $self->_get_property_hash;

  $ph->{$name} = $property;

  return 1;
}

######################################################################

sub add_property_element {

  my $self    = shift;
  my $element = shift;

  # validate input
  if (
      not ref $element
      or
      not $element->isa('SML::Element')
     )
    {
      $logger->error("NOT AN ELEMENT \'$element\'");
      return 0;
    }

  my $name = $element->get_name;

  if ( not $name )
    {
      $logger->error("NO ELEMENT NAME for \'$element\'");
    }

  my $div = $element->get_containing_division;

  if ( not $div )
    {
      my $content = $element->get_content;
      $logger->error("NO CONTAINING DIVISION for \'$element\' containing \'$content\'");
    }

  my $divid   = $div->get_id;
  my $divname = $div->get_name;

  if ( $logger->is_trace() )
    {
      my $value = $element->get_value;

      $logger->trace("add_property_element \'$divname\' \'$name\' = \'$value\'");
    }

  if ( $self->has_property($name) )
    {
      my $property = $self->get_property($name);
      $property->add_element($element);
    }

  else
    {
      my $property = SML::Property->new(id=>$divid,name=>$name);
      $property->add_element($element);
      $self->add_property($property);
    }

  return 1;
}

######################################################################

sub add_attribute {

  # What's the difference between attributes and properties?
  #
  # Attributes are not declared in the ontology and therefore cannot
  # be validated like properties.

  my $self    = shift;
  my $element = shift;

  # validate input
  if (
      not ref $element
      or
      not $element->isa('SML::Element')
     )
    {
      $logger->error("NOT AN ELEMENT \'$element\'");
      return 0;
    }

  my $sml        = SML->instance;
  my $syntax     = $sml->get_syntax;
  my $attributes = $self->_get_attribute_hash;
  my $value      = $element->get_value;

  if ( $value =~ /$syntax->{key_value_pair}/xms )
    {
      my $key = $1;
      my $val = $2;

      if ( not exists $attributes->{$key} )
	{
	  $attributes->{$key} = [];
	}

      push @{ $attributes->{$key} }, $val;

      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub contains_division {

  # Return 1 if the document contains a division with the specified ID.

  my $self = shift;
  my $id   = shift;

  # validate input
  if ( not $id )
    {
      $logger->error("YOU MUST SPECIFY AN ID");
      return 0;
    }

  if ( defined $self->_get_division_hash->{$id} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_property {

  my $self = shift;
  my $name = shift;

  # validate input
  if ( not $name )
    {
      $logger->error("YOU MUST SPECIFY A NAME");
      return 0;
    }

  if ( exists $self->_get_property_hash->{$name} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_property_value {

  # Return 1 if the division already has the specified property
  # name/value pair.

  my $self  = shift;
  my $name  = shift;
  my $value = shift;

  # validate input
  if ( not $name or not $value )
    {
      $logger->error("YOU MUST SPECIFY NAME AND VALUE");
      return 0;
    }

  if ( $self->has_property($name) )
    {
      my $property = $self->get_property($name);
      if ( $property->has_value($value) )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub has_attribute {

  my $self      = shift;
  my $attribute = shift;

  # validate input
  if ( not $attribute )
    {
      $logger->error("YOU MUST SPECIFY ATTRIBUTE");
      return 0;
    }

  if ( exists $self->_get_attribute_hash->{$attribute} )
    {
      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub get_division_list {

  # Return an ordered list of divisions within this one.

  my $self = shift;

  my $list = [];                        # division list

  no warnings 'recursion';

  foreach my $part (@{ $self->get_part_list })
    {
      if ( $part->isa('SML::Block') )
	{
	  next;
	}

      elsif ( $part->isa('SML::Division') )
	{
	  push @{ $list }, $part;
	  push @{ $list }, @{ $part->get_division_list };
	}

      else
	{
	  $logger->error("THIS SHOULD NEVER HAPPEN");
	}
    }

  return $list;
}

######################################################################

sub has_sections {

  # Return 1 if this division contains one or more sections.

  my $self = shift;

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Section') )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub get_section_list {

  # Return an ordered list of sections within this division.

  my $self = shift;

  my $list = [];                        # section list

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Section') )
	{
	  push @{ $list }, $part;
	}
    }

  return $list;
}

######################################################################

sub get_block_list {

  # Return an ordered list of blocks within this division.

  my $self = shift;

  my $list = [];                        # block list

  no warnings 'recursion';

  foreach my $part (@{ $self->get_part_list })
    {
      if ( $part->isa('SML::Block' ) )
	{
	  push @{ $list }, $part;
	}

      elsif ( $part->isa('SML::Division') )
	{
	  push @{ $list }, @{ $part->get_block_list };
	}

      else
	{
	  $logger->error("THIS SHOULD NEVER HAPPEN");
	}
    }

  return $list;
}

######################################################################

sub get_element_list {

  # Return an ordered list of elements within this division.

  my $self = shift;

  my $list = [];                        # element list

  foreach my $block (@{ $self->get_block_list })
    {
      if ( $block->isa('SML::Element') )
	{
	  push @{ $list }, $block;
	}

    }

  return $list;
}

######################################################################

sub get_line_list {

  my $self = shift;

  my $list = [];                        # line list

  no warnings 'recursion';

  foreach my $part (@{ $self->get_part_list })
    {
      push @{ $list }, @{ $part->get_line_list };
    }

  return $list;
}

######################################################################

sub get_preamble_line_list {

  # Return an ArrayRef of preamble lines.

  # !!! BUG HERE !!!
  #
  # Extracting the preamble lines should be a parser function and not
  # a division function.

  my $self = shift;

  my $list        = [];                 # preamble line list
  my $sml         = SML->instance;
  my $syntax      = $sml->get_syntax;
  my $ontology    = $sml->get_ontology;
  my $in_preamble = 1;
  my $i           = 0;
  my $lastblock   = scalar @{ $self->get_block_list };
  my $divname     = $self->get_name;

  foreach my $block (@{ $self->get_block_list })
    {
      my $text = $block->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      ++ $i;

      next if $i == 1;
      last if $i == $lastblock;

      if (
	  $in_preamble
	  and
	  $text =~ /$syntax->{start_element}/xms
	  and
	  $ontology->allows_property($divname,$1)
	 )
	{
	  foreach my $line (@{ $block->get_line_list })
	    {
	      push @{ $list }, $line
	    }
	}

      elsif ( _line_ends_preamble($text) )
	{
	  return $list;
	}

      else
	{
	  foreach my $line (@{ $block->get_line_list })
	    {
	      push @{ $list }, $line
	    }
	}
    }

  return $list;
}

######################################################################

sub get_narrative_line_list {

  # Return an ArrayRef of narrative lines.

  # !!! BUG HERE !!!
  #
  # Extracting the narrative lines should be a parser function and not
  # a division function.

  my $self = shift;

  my $list        = [];                 # narrative line list
  my $sml         = SML->instance;
  my $syntax      = $sml->get_syntax;
  my $ontology    = $sml->get_ontology;
  my $in_preamble = 1;
  my $i           = 0;
  my $lastblock   = scalar @{ $self->get_block_list };
  my $divname     = $self->get_name;

  foreach my $block (@{ $self->get_block_list })
    {
      my $text = $block->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      ++ $i;

      next if $i == 1;
      last if $i == $lastblock;

      if (
	  $in_preamble
	  and
	  $text =~ /$syntax->{start_element}/xms
	  and
	  $ontology->allows_property($divname,$1)
	 )
	{
	  next;
	}

      elsif ( _line_ends_preamble($text) )
	{
	  $in_preamble = 0;
	  foreach my $line (@{ $block->get_line_list })
	    {
	      push @{ $list }, $line
	    }
	}

      elsif ( $in_preamble )
	{
	  next;
	}

      else
	{
	  foreach my $line (@{ $block->get_line_list })
	    {
	      push @{ $list }, $line
	    }
	}
    }

  return $list;
}

######################################################################

sub get_first_part {

  my $self = shift;

  if ( defined $self->get_part_list->[0] )
    {
      return $self->get_part_list->[0];
    }

  else
    {
      $logger->error("CAN'T GET FIRST PART of division");
      return 0;
    }
}

######################################################################

sub get_first_line {

  my $self = shift;

  my $first_part = $self->get_first_part;
  my $first_line = $first_part->get_first_line;

  return $first_line;
}

######################################################################

sub get_property_list {

  my $self = shift;

  my $list = [];                        # property list

  foreach my $name ( sort keys %{ $self->_get_property_hash } )
    {
      push @{ $list }, $self->_get_property_hash->{$name};
    }

  return $list;
}

######################################################################

sub get_property {

  my $self = shift;
  my $name = shift;

  if ( $self->has_property($name) )
    {
      return $self->_get_property_hash->{$name};
    }

  else
    {
      my $id = $self->get_id;
      $logger->error("CAN'T GET PROPERTY \'$id\' has no \'$name\' property");
      return 0;
    }
}

######################################################################

sub get_property_value {

  my $self = shift;
  my $name = shift;

  if ( $self->has_property($name) )
    {
      my $property = $self->get_property($name);
      my $value    = $property->get_value;

      return $value;
    }

  else
    {
      return q{};
    }
}

######################################################################

sub get_containing_document {

  # Return the document to which this division belongs (or undef).

  my $self = shift;

  my $division = $self;

  while ( ref $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Document') )
	{
	  return $division;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  # $logger->error("CAN'T GET DOCUMENT");
  return 0;
}

######################################################################

sub get_location {

  # Return the location (filepec + line number) of the beginning of
  # this division.

  my $self = shift;

  my $block = $self->get_block_list->[0];

  if ( $block )
    {
      return $block->get_location;
    }

  else
    {
      return 'UNKNOWN';
    }
}

######################################################################

sub get_section {

  # Return the section containing this division.  If not in a section,
  # return undef.

  my $self = shift;

  my $division = $self;

  while ( $division )
    {
      if ( $division->isa('SML::Section') )
	{
	  return $division;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  # $logger->error("CAN'T GET SECTION");
  return 0;
}

######################################################################

sub is_in_a {

  # Return 1 if this division is in a division of "type" (even if it
  # is buried several divisions deep).  Don't use this method to find
  # out whether a block is in a SML::Fragment division.

  my $self = shift;
  my $type = shift;

  my $division = $self;

  while ( ref $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa($type) )
	{
	  return 1;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub validate {

  my $self = shift;

  my $valid = 1;

  if ( not $self->has_valid_syntax )
    {
      $valid = 0;
    }

  if ( not $self->has_valid_semantics )
    {
      $valid = 0;
    }

  if ($valid)
    {
      $logger->info("valid");
    }

  else
    {
      $logger->warn("NOT VALID");
    }

  return $valid;
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has 'division_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_division_hash',
   default   => sub {{}},
  );

# This datastructure contains division objects (contained by this one)
# indexed by division ID.
#
#   $dh->{$divid} = $division;

######################################################################

has 'property_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_property_hash',
   default   => sub {{}},
  );

# This datastructure contains property values indexed by name. Allowed
# properties are defined in the SML ontology.  Every property has a
# name and value.  The value is an SML::Property object.
#
#   $ph->{$property_name} = $property;

######################################################################

has 'attribute_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_attribute_hash',
   default   => sub {{}},
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _line_ends_preamble {

  my $text = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  if (
         $text =~ /$syntax->{start_region}/xms
      or $text =~ /$syntax->{start_environment}/xms
      or $text =~ /$syntax->{start_section}/xms
      or $text =~ /$syntax->{generate_element}/xms
      or $text =~ /$syntax->{insert_element}/xms
      or $text =~ /$syntax->{template_element}/
      or $text =~ /$syntax->{include_element}/xms
      or $text =~ /$syntax->{script_element}/xms
      or $text =~ /$syntax->{outcome_element}/xms
      or $text =~ /$syntax->{review_element}/xms
      or $text =~ /$syntax->{index_element}/xms
      or $text =~ /$syntax->{glossary_element}/xms
      or $text =~ /$syntax->{list_item}/xms
      or $text =~ /$syntax->{paragraph_text}/xms
      or $text =~ /$syntax->{indented_text}/xms
      or $text =~ /$syntax->{table_cell}/xms
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

sub _validate_syntax {

  my $self = shift;

  my $valid    = 1;
  my $blocks   = $self->get_block_list;
  my $elements = $self->get_element_list;

  foreach my $block (@{ $blocks })
    {
      if ( not $block->has_valid_syntax ) {
	$valid = 0
      }
    }

  foreach my $element (@{ $elements })
    {
      if ( not $element->has_valid_syntax ) {
	$valid = 0;
      }
    }

  return $valid;
}

######################################################################

sub _validate_semantics {

  my $self = shift;

  my $valid    = 1;
  my $blocks   = $self->get_block_list;
  my $elements = $self->get_element_list;

  foreach my $block (@{ $blocks })
    {
      if ( not $block->has_valid_semantics ) {
	$valid = 0
      }
    }

  foreach my $element (@{ $elements })
    {
      if ( not $element->has_valid_semantics ) {
	$valid = 0;
      }
    }

  if ( not $self->has_valid_property_cardinality )
    {
      $valid = 0;
    }

  if ( not $self->has_valid_property_values )
    {
      $valid = 0;
    }

  if ( not $self->has_valid_infer_only_conformance )
    {
      $valid = 0;
    }

  if ( not $self->has_valid_required_properties )
    {
      $valid = 0;
    }

  if ( not $self->has_valid_composition )
    {
      $valid = 0;
    }

  if ( not $self->has_valid_id_uniqueness )
    {
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_property_cardinality {

  my $self = shift;

  my $valid    = 1;
  # my $divtype  = $self->get_type;
  my $divname  = $self->get_name;
  my $divid    = $self->get_id;
  my $sml      = SML->instance;
  my $ontology = $sml->get_ontology;

  foreach my $property (@{ $self->get_property_list })
    {
      my $property_name = $property->get_name;
      my $cardinality   = $ontology->property_allows_cardinality($divname,$property_name);

      # Validate property cardinality
      if ( $ontology->property_is_universal($property_name) )
	{
	  # OK, all universal properties have cardinality = many
	}

      elsif ( not defined $cardinality )
	{
	  my $location = $self->get_location;
	  $logger->error("This should never happen");
	  $logger->error("NO CARDINALITY at $location: for $divname $property_name");
	  $valid = 0;
	}

      else
	{
	  my $list = $property->get_element_list;
	  my $count = scalar(@{ $list });
	  if ( $cardinality eq '1' and $count > 1 )
	    {
	      my $location = $self->get_location;
	      $logger->warn("INVALID PROPERTY CARDINALITY at $location: $divname allows only 1 $property_name");
	      $valid = 0;
	    }
	}
    }

  return $valid;
}

######################################################################

sub _validate_property_values {

  my $self = shift;

  my $valid    = 1;
  my $seen     = {};
  # my $divtype  = $self->get_type;
  my $divname  = $self->get_name;
  my $divid    = $self->get_id;
  my $sml      = SML->instance;
  my $ontology = $sml->get_ontology;

  foreach my $property (@{ $self->get_property_list })
    {
      my $property_name = $property->get_name;

      $seen->{$property_name} = 1;

      my $imply_only  = $ontology->property_is_imply_only($divname,$property_name);
      my $list        = $property->get_element_list;
      my $cardinality = $ontology->property_allows_cardinality($divname,$property_name);

      foreach my $element (@{ $list })
	{
	  my $value      = $element->get_value;
	  my $first_line = $element->get_first_line;

	  next if not defined $first_line;

	  my $file = $first_line->get_file;

	  next if not defined $file;

	  next if $file->get_filespec eq 'empty_file';

	  # validate property value is allowed
	  if ( not $ontology->allows_property_value($divname,$property_name,$value) )
	    {
	      my $location = $element->get_location;
	      my $allowed_property_values = $ontology->get_allowed_property_values($divname,$property_name);
	      my $valid_property_values = join(', ', @{ $allowed_property_values });
	      $logger->warn("INVALID PROPERTY VALUE \'$value\' at $location: $divname $property_name must be one of: $valid_property_values");
	      $valid = 0;
	    }

	}

    }

  return $valid;
}

######################################################################

sub _validate_infer_only_conformance {

  my $self = shift;

  my $valid    = 1;
  my $seen     = {};
  # my $divtype  = $self->get_type;
  my $divname  = $self->get_name;
  my $divid    = $self->get_id;
  my $sml      = SML->instance;
  my $ontology = $sml->get_ontology;

  foreach my $property (@{ $self->get_property_list })
    {
      my $property_name = $property->get_name;

      $seen->{$property_name} = 1;

      my $imply_only  = $ontology->property_is_imply_only($divname,$property_name);
      my $list        = $property->get_element_list;
      my $cardinality = $ontology->property_allows_cardinality($divname,$property_name);

      foreach my $element (@{ $list })
	{
	  my $value      = $element->get_value;
	  my $first_line = $element->get_first_line;

	  next if not defined $first_line;

	  my $file = $first_line->get_file;

	  next if not defined $file;

	  next if $file->get_filespec eq 'empty_file';

	  # Validate infer-only conformance
	  if ( $imply_only )
	    {
	      my $location   = $element->get_location;
	      $logger->warn("INVALID EXPLICIT DECLARATION OF INFER-ONLY PROPERTY \'$property_name\' at $location: $divname $divid");
	      $valid = 0;
	    }

	}

    }

  return $valid;
}

######################################################################

sub _validate_required_properties {

  my $self = shift;

  my $valid    = 1;
  my $seen     = {};
  my $divname  = $self->get_name;
  my $divid    = $self->get_id;
  my $sml      = SML->instance;
  my $ontology = $sml->get_ontology;

  foreach my $property (@{ $self->get_property_list })
    {
      my $property_name = $property->get_name;

      $seen->{$property_name} = 1;
    }

  # Validate that all required properties are declared
  foreach my $required ( keys %{ $ontology->get_required_properties_hash->{$divname} } )
    {
      if ( not $seen->{$required} )
	{
	  my $location = $self->get_location;
	  $logger->warn("MISSING REQUIRED PROPERTY at $location: $divname $divid requires \'$required\' ");
	  $valid = 0;
	}
    }

  return $valid;
}

######################################################################

sub _validate_composition {

  # Validate conformance with division composition rules. If this
  # division is contained by another division, validate that a
  # composition rule allows this relationship.
  #
  # This means check wether THIS division is allowed to be inside the
  # one that contains it.

  my $self = shift;

  my $valid     = 1;
  my $container = $self->get_containing_division;
  my $sml       = SML->instance;
  my $ontology  = $sml->get_ontology;

  if ( $container )
    {
      my $name           = $self->get_name;
      my $container_name = $container->get_name;

      if ( $ontology->allows_composition($name,$container_name) )
	{
	  return 1;
	}

      else
	{
	  my $location   = $self->get_location;
	  my $first_line = $self->get_first_line;

	  # $self->set_valid(0);

	  if (
	      ref $first_line
	      and
	      ref $first_line->get_included_from_line
	     )
	    {
	      my $include_location = $first_line->get_included_from_line->get_location;
	      $logger->warn("INVALID COMPOSITION at $location: $name in $container_name (included at $include_location)");
	    }

	  else
	    {
	      $logger->warn("INVALID COMPOSITION at $location: $name in $container_name");
	    }

	  return 0;
	}
    }

  return $valid;
}

######################################################################

sub _validate_id_uniqueness {

  my $self = shift;

  my $valid  = 1;
  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $seen   = {};

  foreach my $element (@{ $self->get_element_list })
    {
      if ($element->get_name ne 'id')
	{
	  next;
	}

      my $id       = $element->get_value;
      my $location = $element->get_location;

      if ( not exists $seen->{$id} )
	{
	  $seen->{$id} = $element;
	}

      else
	{
	  my $current_line  = $element->get_first_line;
	  my $previous      = $seen->{$id};
	  my $previous_line = $previous->get_first_line;

	  if (
	      defined $current_line->get_included_from_line
	      and
	      defined $previous_line->get_included_from_line
	     )
	    {
	      my $current_location  = $current_line->get_location;
	      my $previous_location = $previous_line->get_location;
	      my $included_location = $previous_line->get_included_from_line->get_location;

	      $logger->warn("INVALID NON-UNIQUE ID at $location: \"$id\" (included at $current_location) previously defined at $previous_location (included at $included_location)");
	      $valid = 0;
	    }

	  elsif ( defined $previous_line->get_included_from_line )
	    {
	      my $previous_location = $previous_line->get_location;
	      my $included_location = $previous_line->get_included_from_line->get_location;

	      $logger->warn("INVALID NON-UNIQUE ID at $location: \"$id\" previously defined at $previous_location (included at $included_location)");
	      $valid = 0;
	    }

	  else
	    {
	      my $previous_location = $previous_line->get_location;

	      $logger->warn("INVALID NON-UNIQUE ID at $location: \"$id\" previously defined at $previous_location");
	      $valid = 0;
	    }
	}
    }

  return $valid;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Division> - a contiguous sequence of L<"SML::Block">s.

=head1 VERSION

This documentation refers to L<"SML::Division"> version 2.0.0.

=head1 SYNOPSIS

  my $division = SML::Division->new();

=head1 DESCRIPTION

A L<"SML::Division"> is a contiguous sequence of L<"SML::Block">s.  A
division has an unambiguous beginning and end.  Sometimes the
beginning and end are explicit and other times they are implicit.
Divisions may contain other divisions.

=head1 METHODS

=head2 get_name

=head2 get_id

=head2 get_type

=head2 get_number

=head2 get_division

Get the division to which this one belongs.

=head2 get_part_list

=head2 get_environment_list

Get a sequential list of environments contained in this division.

=head2 get_region_list

Get a sequential list of regions contained in this division.

=head2 get_html

Get a string which is the HTML rendition of this division.

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
