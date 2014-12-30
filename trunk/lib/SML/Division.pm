#!/usr/bin/perl

package SML::Division;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.division');

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

has 'id' =>
  (
   isa      => 'Str',
   reader   => 'get_id',
   writer   => 'set_id',
   required => 1,
  );

######################################################################

has 'id_path' =>
  (
   isa      => 'Str',
   reader   => 'get_id_path',
   lazy     => 1,
   builder  => '_build_id_path',
  );

######################################################################

has 'name' =>
  (
   isa      => 'Str',
   reader   => 'get_name',
   required => 1,
  );

######################################################################

# has 'type' =>
#   (
#    isa      => 'Str',
#    reader   => 'get_type',
#    default  => 'division',
#   );

######################################################################

has 'number' =>
  (
   isa      => 'Str',
   reader   => 'get_number',
   writer   => 'set_number',
  );

######################################################################

has 'containing_division' =>
  (
   isa       => 'SML::Division',
   reader    => 'get_containing_division',
   writer    => 'set_containing_division',
   clearer   => 'clear_containing_division',
   predicate => 'has_containing_division',
  );

# The division to which this one belongs; the division containing this
# one; the division of which this one is a part.

######################################################################

has 'part_list' =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_part_list',
   writer    => '_set_part_list',
   clearer   => '_clear_part_list',
   predicate => '_has_part_list',
   default   => sub {[]},
  );

# The sequential array of divisions and blocks within this one.

######################################################################

# has 'environment_list' =>
#   (
#    isa       => 'ArrayRef',
#    reader    => 'get_environment_list',
#    writer    => 'set_environment_list',
#    clearer   => 'clear_environment_list',
#    predicate => 'has_environment_list',
#   );

# This is a sequential array of all environments in the division.
#
# An environment is a division that describes the intended format,
# structure, or content of the contained blocks of text.  Environments
# are composed of a preamble followed by an optional environment
# narrative.  Environments may not be nested. Environments may not
# contain regions.  Environments commonly have titles, IDs, and
# descriptions. Common environments include tables, figures, listings,
# and attachments.
#
#     my $el = $self->get_environment_list;

######################################################################

# has 'region_list' =>
#   (
#    isa       => 'ArrayRef',
#    reader    => 'get_region_list',
#    writer    => 'set_region_list',
#    clearer   => 'clear_region_list',
#    predicate => 'has_region_list',
#   );

# This is a sequential array of all regions in the division.
#
# A region is a division that describes the intended content of the
# text.  Regions consist of a preamble followed by an optional region
# narrative. Regions may contain environments. Some regions represent
# entitys (problems, solutions, tests, results, tasks, and
# roles). Other common regions include demo, exercise, keypoints,
# quotation, and slide.
#
#   my $rl = $self->get_region_list;

######################################################################

has 'division_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_division_hash',
   writer    => 'set_division_hash',
   clearer   => 'clear_division_hash',
   predicate => 'has_division_hash',
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
   reader    => 'get_property_hash',
   writer    => 'set_property_hash',
   clearer   => 'clear_property_hash',
   predicate => 'has_property_hash',
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
   reader    => 'get_attribute_hash',
   writer    => 'set_attribute_hash',
   clearer   => 'clear_attribute_hash',
   predicate => 'has_attribute_hash',
   default   => sub {{}},
  );

######################################################################

# has 'html' =>
#   (
#    isa     => 'Str',
#    reader  => 'get_html',
#    writer  => 'set_html',
#    default => q{},
#   );

######################################################################

has 'valid_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_syntax',
   lazy      => 1,
   builder   => 'validate_syntax',
  );

######################################################################

has 'valid_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_semantics',
   lazy      => 1,
   builder   => 'validate_semantics',
  );

# division conforms with property cardinality rules
# division elements conform with infer-only rules
# division elements conform with allowed value rules
# division conforms with required property rules
# division conforms with composition rules

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub init {

  my $self = shift;

  $self->_clear_part_list;
  $self->_set_part_list([]);

  return 1;
}

######################################################################

sub add_division {

  my $self     = shift;
  my $division = shift;
  my $id       = $division->get_id;

  if ( exists $self->get_division_hash->{$id} )
    {
      $logger->warn("DIVISION ALREADY EXISTS $id");
    }

  $self->get_division_hash->{$id} = $division;

  return 1;
}

######################################################################

sub add_part {

  # A part is either a block or a division.

  my $self = shift;
  my $part = shift;
  my $type = ref $part;

  if (
      not
      (
       $type
       or
       $part->isa('SML::Block')
       or
       $part->isa('SML::Division')
      )
     )
    {
      $logger->error("CAN'T ADD PART \'$part\' is not a block or division");
      return 0;
    }

  $part->set_containing_division( $self );

  push @{ $self->get_part_list }, $part;

  $logger->trace("add part $type");

  return 1;
}

######################################################################

sub add_property {

  my $self     = shift;
  my $property = shift;
  my $name     = $property->get_name;

  $self->get_property_hash->{$name} = $property;

  return 1;
}

######################################################################

sub add_property_element {

  my $self    = shift;
  my $element = shift;

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
  # Attributes are not declared in the ontology and therefore cannot
  # be validated like properties.

  my $self       = shift;
  my $element    = shift;
  my $sml        = SML->instance;
  my $syntax     = $sml->get_syntax;
  my $attributes = $self->get_attribute_hash;
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

  if ( defined $self->get_division_hash->{$id} )
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

  if ( exists $self->get_property_hash->{$name} )
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

  if ( exists $self->get_attribute_hash->{$attribute} )
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

  my $self      = shift;
  my $list = [];

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

sub get_section_list {

  # Return an ordered list of sections within this division.

  my $self = shift;
  my $list = [];

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

  my $self   = shift;
  my $list = [];

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

  my $self     = shift;
  my $list = [];

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

  my $self  = shift;
  my $list = [];

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

  my $self        = shift;
  my $list       = [];
  my $sml         = SML->instance;
  my $syntax      = $sml->get_syntax;
  my $ontology    = $sml->get_ontology;
  my $in_preamble = 1;
  my $i           = 0;
  my $lastblock   = scalar @{ $self->get_block_list };
  my $divname     = $self->get_name;

  foreach my $block (@{ $self->get_block_list })
    {
      $_ = $block->get_content;

      chomp;
      ++ $i;

      next if $i == 1;
      last if $i == $lastblock;

      if (
	  $in_preamble
	  and
	  /$syntax->{start_element}/xms
	  and
	  $ontology->allows_property($divname,$1)
	 )
	{
	  foreach my $line (@{ $block->get_line_list })
	    {
	      push @{ $list }, $line
	    }
	}

      elsif ( _line_ends_preamble($_) )
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

  my $self        = shift;
  my $list       = [];
  my $sml         = SML->instance;
  my $syntax      = $sml->get_syntax;
  my $ontology    = $sml->get_ontology;
  my $in_preamble = 1;
  my $i           = 0;
  my $lastblock   = scalar @{ $self->get_block_list };
  my $divname     = $self->get_name;

  foreach my $block (@{ $self->get_block_list })
    {
      $_ = $block->get_content;

      chomp;
      ++ $i;

      next if $i == 1;
      last if $i == $lastblock;

      if (
	  $in_preamble
	  and
	  /$syntax->{start_element}/xms
	  and
	  $ontology->allows_property($divname,$1)
	 )
	{
	  next;
	}

      elsif ( _line_ends_preamble($_) )
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
  my $list = [];

  foreach my $name ( sort keys %{ $self->get_property_hash } )
    {
      push @{ $list }, $self->get_property_hash->{$name};
    }

  return $list;
}

######################################################################

sub get_property {

  my $self = shift;
  my $name = shift;

  if ( $self->has_property($name) )
    {
      return $self->get_property_hash->{$name};
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

  my $self     = shift;
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

  my $self  = shift;
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

  my $self     = shift;
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

  my $self     = shift;
  my $type     = shift;
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

sub as_sml {

  my $self = shift;
  my $text = q{};

  foreach my $block (@{ $self->get_block_list })
    {
      $text .= $block->as_sml;
    }

  return $text;
}

######################################################################

sub as_text {

  my $self       = shift;
  my $sml        = SML->instance;
  my $syntax     = $sml->get_syntax;
  my $lines      = $self->get_line_list;
  my $text       = q{};
  my $in_comment = 0;

 LINE:
  foreach my $line (@{ $lines }) {

    $_ = $line->get_content;

      #---------------------------------------------------------------
      # Ignore comments
      #
      if ( /$syntax->{comment_marker}/xms ) {
	if ( $in_comment ) {
	  $in_comment = 0;
	} else {
	  $in_comment = 1;
	}
	next LINE;
      } elsif ( $in_comment ) {
	next LINE;
      } elsif ( /$syntax->{comment_line}/xms ) {
	next LINE;
      }

    $text .= $_;
  }

  return $text;
}

######################################################################

sub as_html {

  my $self = shift;
  my $html = q{};

  $html .= $self->start_html;

  foreach my $part (@{ $self->get_part_list })
    {
      $html .= $part->as_html;
    }

  $html .= $self->end_html;

  return $html;
}

######################################################################

sub start_html {

  my $self = shift;
  my $name = $self->get_name;
  my $id   = $self->get_id || 'unknown';
  my $html = q{};

  $html .= "\n<!-- start $name $id -->\n";

  return $html;

}

######################################################################

sub end_html {

  my $self = shift;
  my $name = $self->get_name;
  my $id   = $self->get_id || 'unknown';
  my $html = q{};

  $html .= "\n<!-- end $name $id -->\n";

  return $html;

}

######################################################################

sub validate {

  my $self  = shift;
  my $valid = 1;

  if ( not $self->has_valid_syntax )
    {
      $valid = 0;
    }

  if ( not $self->has_valid_semantics )
    {
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub validate_syntax {

  my $self     = shift;
  my $valid    = 1;
  my $blocks   = $self->get_block_list;
  my $elements = $self->get_element_list;

  if ( not $self->validate_id_uniqueness )
    {
      $valid = 0;
    }

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

sub validate_semantics {

  my $self     = shift;
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

  if ( not $self->validate_property_cardinality )
    {
      $valid = 0;
    }

  if ( not $self->validate_property_values )
    {
      $valid = 0;
    }

  if ( not $self->validate_infer_only_conformance )
    {
      $valid = 0;
    }

  if ( not $self->validate_required_properties )
    {
      $valid = 0;
    }

  if ( not $self->validate_composition )
    {
      $valid = 0;
    }

  if ( not $self->validate_id_uniqueness )
    {
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub validate_property_cardinality {

  my $self     = shift;
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
      my $list          = $property->get_element_list;

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
	  my $count = scalar @{ $list };
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

sub validate_property_values {

  my $self     = shift;
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

sub validate_infer_only_conformance {

  my $self     = shift;
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

sub validate_required_properties {

  my $self     = shift;
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

sub validate_composition {

  # 1. Validate conformance with division composition rules.
  #
  #    If this division is contained by another division, validate
  #    that a composition rule allows this relationship.

  my $self      = shift;
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
	  $self->set_valid(0);

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

sub validate_id_uniqueness {

  my $self   = shift;
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
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _line_ends_preamble {

  $_ = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  if (
         /$syntax->{start_region}/xms
      or /$syntax->{start_environment}/xms
      or /$syntax->{start_section}/xms
      or /$syntax->{generate_element}/xms
      or /$syntax->{insert_element}/xms
      or /$syntax->{template_element}/
      or /$syntax->{include_element}/xms
      or /$syntax->{script_element}/xms
      or /$syntax->{outcome_element}/xms
      or /$syntax->{review_element}/xms
      or /$syntax->{index_element}/xms
      or /$syntax->{glossary_element}/xms
      or /$syntax->{list_item}/xms
      or /$syntax->{paragraph_text}/xms
      or /$syntax->{indented_text}/xms
      or /$syntax->{table_cell}/xms
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

sub _build_id_path {

  my $self          = shift;
  my $container_ids = [];
  my $id            = $self->get_id;
  my $container     = $self->get_containing_division;

  push @{ $container_ids }, $id;

  while ( ref $container )
    {
      my $container_id = $container->get_id;
      push @{ $container_ids }, $container_id;

      $container = $container->get_containing_division;
    }

  my $id_path = join('.', reverse @{ $container_ids });

  return $id_path;
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

=head2 get_division_hash

Get a hash, indexed by division ID, of all divisions contained by this
division.

=head2 get_property_hash

Get a hash, indexed by property name, of all property values of this
division.

=head2 get_attribute_hash

Get a hash, indexed by attribute name, of all attribute values of this
division.

=head2 get_html

Get a string which is the HTML rendition of this division.

=head2 is_valid

Get a boolean value that represents whether this division is valid.

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
