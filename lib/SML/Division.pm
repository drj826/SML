#!/usr/bin/perl

# $Id: Division.pm 274 2015-05-11 12:05:43Z drj826@gmail.com $

package SML::Division;

use Moose;

extends 'SML::Part';

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Division');

use lib "..";

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

has 'origin_line' =>
  (
   isa       => 'SML::Line',
   reader    => 'get_origin_line',
   predicate => 'has_origin_line',
  );

# If this division was included via the `include' mechanism, this is
# the SML::Line object that included the division.

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

  my $library    = $self->get_library;
  my $ah         = $self->_get_attribute_hash;
  my $term       = $element->get_term;
  my $definition = $element->get_definition;

  if ( not exists $ah->{$term} )
    {
      $ah->{$term} = [];
    }

  push @{ $ah->{$term} }, $definition;

  return 1;
}

######################################################################

sub add_image {

  my $self  = shift;
  my $image = shift;

  my $image_list = $self->get_image_list;

  push(@{ $image_list },$image);

  return 1;
}

######################################################################

sub contains_division {

  # Return 1 if the division contains a division with the specified ID.

  my $self = shift;
  my $id   = shift;

  # validate input
  if ( not $id )
    {
      $logger->error("YOU MUST SPECIFY AN ID");
      return 0;
    }

  foreach my $division (@{ $self->get_division_list })
    {
      if ( $division->get_id eq $id )
	{
	  return 1;
	}

      elsif ( $division->contains_division($id) )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

# sub has_property {

#   my $self = shift;
#   my $name = shift;

#   unless ( $name )
#     {
#       $logger->error("CAN'T CHECK IF DIVISION HAS PROPERTY, YOU MUST SPECIFY A NAME");
#       return 0;
#     }

#   my $library = $self->get_library;
#   my $id      = $self->get_id;

#   if ( $library->has_property($id,$name) )
#     {
#       return 1;
#     }

#   return 0;
# }

######################################################################

# sub has_property_value {

#   # Return 1 if the division already has the specified property
#   # name/value pair.

#   my $self  = shift;
#   my $name  = shift;
#   my $value = shift;

#   unless ( $name and $value )
#     {
#       $logger->error("CAN'T CHECK IF DIVISION HAS PROPERTY VALUE, YOU MUST SPECIFY NAME AND VALUE");
#       return 0;
#     }

#   my $library = $self->get_library;
#   my $id      = $self->get_id;

#   if ( $library->has_property_value($id,$name,$value) )
#     {
#       return 1;
#     }

#   return 0;
# }

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
      if ( $part->isa('SML::Division') )
	{
	  push @{ $list }, $part;
	  push @{ $list }, @{ $part->get_division_list };
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

sub has_tables {

  # Return 1 if this division contains one or more tables.

  my $self = shift;

  foreach my $division (@{ $self->get_division_list })
    {
      if ( $division->isa('SML::Table') )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub has_figures {

  # Return 1 if this division contains one or more figures.

  my $self = shift;

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Figure') )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub has_images {

  # Return 1 if this division (or any the divisions it contains) has
  # an image element.

  my $self = shift;

  foreach my $element (@{ $self->get_element_list })
    {
      my $name = $element->get_name;

      if ( $name eq 'image' )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub get_image_list {

  my $self = shift;

  my $list = [];

  foreach my $element (@{ $self->get_element_list })
    {
      if ( $element->isa('SML::Image') )
	{
	  push(@{$list},$element);
	}
    }

  return $list;
}

######################################################################

sub has_files {

  # Return 1 if this division (or any the divisions it contains) has
  # an file element.

  my $self = shift;

  foreach my $element (@{ $self->get_element_list })
    {
      my $name = $element->get_name;

      if ( $name eq 'file' )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub get_file_list {

  my $self = shift;

  my $list = [];

  foreach my $element (@{ $self->get_element_list })
    {
      my $name = $element->get_name;

      if ( $name eq 'file' )
	{
	  push(@{$list},$element);
	}
    }

  return $list;
}

######################################################################

sub has_attachments {

  # Return 1 if this division contains one or more attachments.

  my $self = shift;

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Attachment') )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub has_listings {

  # Return 1 if this division contains one or more listings.

  my $self = shift;

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Listing') )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub has_demos {

  # Return 1 if this division contains one or more demos.

  my $self = shift;

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Demo') )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub has_exercises {

  # Return 1 if this division contains one or more exercises.

  my $self = shift;

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Exercise') )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub has_slides {

  # Return 1 if this division contains one or more slides.

  my $self = shift;

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Slide') )
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

sub get_figure_list {

  # Return an ordered list of figures within this division.

  my $self = shift;

  my $list = [];                        # figure list

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Figure') )
	{
	  push @{ $list }, $part;
	}
    }

  return $list;
}

######################################################################

sub get_table_list {

  # Return an ordered list of tables within this division.

  my $self = shift;

  my $list = [];                        # table list

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Table') )
	{
	  push @{ $list }, $part;
	}
    }

  return $list;
}

######################################################################

sub get_listing_list {

  # Return an ordered list of listings within this division.

  my $self = shift;

  my $list = [];                        # listing list

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Listing') )
	{
	  push @{ $list }, $part;
	}
    }

  return $list;
}

######################################################################

sub get_demo_list {

  # Return an ordered list of demos within this division.

  my $self = shift;

  my $list = [];                        # demo list

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Demo') )
	{
	  push @{ $list }, $part;
	}
    }

  return $list;
}

######################################################################

sub get_exercise_list {

  # Return an ordered list of exercises within this division.

  my $self = shift;

  my $list = [];                        # exercise list

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Exercise') )
	{
	  push @{ $list }, $part;
	}
    }

  return $list;
}

######################################################################

sub get_slide_list {

  # Return an ordered list of slides within this division.

  my $self = shift;

  my $list = [];                        # slide list

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Slide') )
	{
	  push @{ $list }, $part;
	}
    }

  return $list;
}

######################################################################

sub get_attachment_list {

  # Return an ordered list of attachments within this division.

  my $self = shift;

  my $list = [];                        # attachment list

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Attachment') )
	{
	  push @{ $list }, $part;
	}
    }

  return $list;
}

######################################################################

sub get_source_list {

  # Return a list of sources within this division ordered by source
  # ID.

  my $self = shift;

  my $hash = {};                        # source hash

  foreach my $part (@{ $self->get_division_list })
    {
      if ( $part->isa('SML::Source') )
	{
	  my $source = $part;
	  my $id     = $source->get_id;

	  $hash->{$id} = $source;
	}
    }

  my $list = [];

  foreach my $id ( sort keys %{ $hash } )
    {
      my $source = $hash->{$id};

      push(@{$list},$source);
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

sub get_data_segment_line_list {

  # Return an ArrayRef of DATA SEGMENT lines.

  # !!! BUG HERE !!!
  #
  # Extracting the DATA SEGMENT lines should be a parser function and
  # not a division function.

  my $self = shift;

  my $list        = [];                 # DATA SEGMENT line list
  my $library     = $self->get_library;
  my $syntax      = $library->get_syntax;
  my $ontology    = $library->get_ontology;
  my $in_data_segment = 1;
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
	  $in_data_segment
	  and
	  $text =~ /$syntax->{element}/xms
	  and
	  $ontology->allows_property($divname,$1)
	 )
	{
	  foreach my $line (@{ $block->get_line_list })
	    {
	      push @{ $list }, $line
	    }
	}

      elsif ( $self->_line_ends_data_segment($text) )
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
  my $library     = $self->get_library;
  my $syntax      = $library->get_syntax;
  my $ontology    = $library->get_ontology;
  my $in_data_segment = 1;
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
	  $in_data_segment
	  and
	  $text =~ /$syntax->{element}/xms
	  and
	  $ontology->allows_property($divname,$1)
	 )
	{
	  next;
	}

      elsif ( $self->_line_ends_data_segment($text) )
	{
	  $in_data_segment = 0;
	  foreach my $line (@{ $block->get_line_list })
	    {
	      push @{ $list }, $line
	    }
	}

      elsif ( $in_data_segment )
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

  my $part_list = $self->get_part_list;

  if ( $self->contains_parts )
    {
      return $self->get_part_list->[0];
    }

  else
    {
      $logger->error("CAN'T GET FIRST PART, DIVISION HAS NO PARTS");
      return 0;
    }
}

######################################################################

sub get_first_line {

  my $self = shift;

  if ( $self->contains_parts )
    {
      my $first_part = $self->get_first_part;

      return $first_part->get_first_line;
    }

  else
    {
      $logger->error("CAN'T GET FISRT LINE, DIVISION HAS NO PARTS");
      return 0;
    }
}

######################################################################

# sub get_property_list {

#   my $self = shift;

#   my $list = [];                        # property list

#   foreach my $name ( sort keys %{ $self->_get_property_hash } )
#     {
#       push @{ $list }, $self->_get_property_hash->{$name};
#     }

#   return $list;
# }

######################################################################

# sub get_property {

#   my $self = shift;
#   my $name = shift;

#   unless ( $name )
#     {
#       $logger->error("CAN'T GET PROPERTY, YOU MUST SPECIFY A NAME");
#       return 0;
#     }

#   if ( $self->has_property($name) )
#     {
#       return $self->_get_property_hash->{$name};
#     }

#   else
#     {
#       my $id = $self->get_id;
#       $logger->error("CAN'T GET PROPERTY \'$id\' has no \'$name\' property");
#       return 0;
#     }
# }

######################################################################

# sub get_property_value {

#   my $self = shift;
#   my $name = shift;

#   if ( $self->has_property($name) )
#     {
#       my $property = $self->get_property($name);
#       my $value    = $property->get_value;

#       return $value;
#     }

#   else
#     {
#       # my $id = $self->get_id;
#       # $logger->error("CAN'T GET PROPERTY VALUE \'$id\' has no \'$name\' property");
#       return q{};
#     }
# }

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

  while ( ref $division )
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

sub get_content {

  my $self = shift;

  my $content = q{};

  foreach my $block (@{ $self->get_block_list })
    {
      $content .= $block->get_content . "\n\n";
    }

  return $content;
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

# has 'property_hash' =>
#   (
#    isa       => 'HashRef',
#    reader    => '_get_property_hash',
#    default   => sub {{}},
#   );

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

sub BUILD {

  my $self = shift;

  my $id      = $self->get_id;
  my $library = $self->get_library;

  if ( $id )
    {
      my $id_element = SML::Element->new
	(
	 name    => 'id',
	 library => $self->get_library,
	 value   => $id,
	);

      $library->add_property_value($id,'id',$id,$id_element);
    }

  return 1;
}

######################################################################

sub _line_ends_data_segment {

  my $self = shift;
  my $text = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;

  if (
         $text =~ /$syntax->{segment_separator}/xms
      or $text =~ /$syntax->{start_division}/xms
      or $text =~ /$syntax->{start_section}/xms
      or $text =~ /$syntax->{generate_element}/xms
      or $text =~ /$syntax->{insert_element}/xms
      or $text =~ /$syntax->{template_element}/xms
      or $text =~ /$syntax->{include_element}/xms
      or $text =~ /$syntax->{script_element}/xms
      or $text =~ /$syntax->{outcome_element}/xms
      or $text =~ /$syntax->{review_element}/xms
      or $text =~ /$syntax->{index_element}/xms
      or $text =~ /$syntax->{glossary_element}/xms
      or $text =~ /$syntax->{list_item}/xms
      or
      (
       $text =~ /$syntax->{paragraph_text}/xms
       and
       not $text =~ /$syntax->{element}/xms
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

# sub _validate_division {

#   my $self = shift;

#   my $valid = 1;
#   my $id    = $self->get_id;

#   $logger->debug("validate division $id");

#   $valid = 0 if not $self->has_valid_id_uniqueness;

#   foreach my $block (@{ $self->get_block_list })
#     {
#       $valid = 0 if not $block->has_valid_syntax;
#       $valid = 0 if not $block->has_valid_semantics;
#     }

#   foreach my $element (@{ $self->get_element_list })
#     {
#       $valid = 0 if not $element->has_valid_syntax;
#       $valid = 0 if not $element->has_valid_semantics;
#     }

#   foreach my $division (@{ $self->get_division_list })
#     {
#       $valid = 0 if not $division->has_valid_syntax;
#       $valid = 0 if not $division->has_valid_semantics;
#     }

#   if ( $valid )
#     {
#       $logger->info("the division is valid \'$id\'");
#     }

#   else
#     {
#       $logger->warn("THE DIVISION IS NOT VALID \'$id\'");
#     }

#   return $valid;
# }

######################################################################

# sub _validate_syntax {

#   my $self = shift;

#   my $valid    = 1;
#   my $blocks   = $self->get_block_list;
#   my $elements = $self->get_element_list;

#   foreach my $block (@{ $blocks })
#     {
#       $valid = 0 if not $block->has_valid_syntax;
#     }

#   foreach my $element (@{ $elements })
#     {
#       $valid = 0 if not $element->has_valid_syntax;
#     }

#   return $valid;
# }

######################################################################

# sub _validate_semantics {

#   my $self = shift;

#   my $valid    = 1;
#   my $blocks   = $self->get_block_list;
#   my $elements = $self->get_element_list;

#   foreach my $block (@{ $blocks })
#     {
#       $valid = 0 if not $block->has_valid_semantics;
#     }

#   foreach my $element (@{ $elements })
#     {
#       $valid = 0 if not $element->has_valid_semantics;
#     }

#   $valid = 0 if not $self->has_valid_property_cardinality;
#   $valid = 0 if not $self->has_valid_property_values;
#   $valid = 0 if not $self->has_valid_infer_only_conformance;
#   $valid = 0 if not $self->has_valid_required_properties;
#   $valid = 0 if not $self->has_valid_composition;
#   $valid = 0 if not $self->has_valid_id_uniqueness;

#   return $valid;
# }

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Division> - a L<"SML::Part"> which is a contiguous sequence of
L<"SML::Block">s.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Part

  my $division = SML::Division->new
                   (
                     id      => $id,
                     library => $library,
                     name    => $name,
                   );

  my $string   = $division->get_number;
  my $boolean  = $division->set_number;
  my $string   = $division->get_previous_number;
  my $boolean  = $division->set_previous_number($number);
  my $string   = $division->get_next_number;
  my $boolean  = $division->set_next_number($number);
  my $division = $division->get_containing_division;
  my $boolean  = $division->set_containing_division($division);
  my $boolean  = $division->has_containing_division;
  my $boolean  = $division->has_valid_syntax;
  my $boolean  = $division->has_valid_semantics;
  my $boolean  = $division->has_valid_property_cardinality;
  my $boolean  = $division->has_valid_property_values;
  my $boolean  = $division->has_valid_infer_only_conformance;
  my $boolean  = $division->has_valid_required_properties;
  my $boolean  = $division->has_valid_composition;
  my $boolean  = $division->has_valid_id_uniqueness;

  my $boolean  = $division->add_division($division);
  my $boolean  = $division->add_part($part);
  my $boolean  = $division->add_property($property);
  my $boolean  = $division->add_attribute($element);
  my $boolean  = $division->contains_division($id);
  my $boolean  = $division->has_property($property_name);
  my $boolean  = $division->has_property_value($property_name,$value);
  my $boolean  = $division->has_attribute($attribute_name);
  my $list     = $division->get_division_list;
  my $boolean  = $division->has_sections;
  my $boolean  = $division->has_tables;
  my $boolean  = $division->has_figures;
  my $boolean  = $division->has_attachments;
  my $boolean  = $division->has_listings;
  my $list     = $division->get_section_list;
  my $list     = $division->get_block_list;
  my $list     = $division->get_element_list;
  my $list     = $division->get_line_list;
  my $list     = $division->get_data_segment_line_list;
  my $list     = $division->get_narrative_line_list;
  my $part     = $division->get_first_part;
  my $line     = $division->get_first_line;
  my $document = $division->get_containing_document;
  my $string   = $division->get_location;
  my $section  = $division->get_section;
  my $boolean  = $division->is_in_a($division_type);
  my $boolean  = $division->validate;

=head1 DESCRIPTION

A L<"SML::Division"> is a contiguous sequence of L<"SML::Block">s.  A
division has an unambiguous beginning and end.  Sometimes the
beginning and end are explicit and other times they are implicit.
Divisions may contain other divisions.

=head1 METHODS

=head2 get_number

=head2 set_number

=head2 get_previous_number

=head2 set_previous_number($number)

=head2 get_next_number

=head2 set_next_number($number)

=head2 get_containing_division

=head2 set_containing_division($division)

=head2 has_containing_division

=head2 has_valid_syntax

=head2 has_valid_semantics

=head2 has_valid_property_cardinality

=head2 has_valid_property_values

=head2 has_valid_infer_only_conformance

=head2 has_valid_required_properties

=head2 has_valid_composition

=head2 has_valid_id_uniqueness

=head2 add_division($division)

=head2 add_part($part)

=head2 add_property($property)

=head2 add_property_element($element)

=head2 add_attribute($element)

=head2 contains_division($id)

=head2 has_attribute($attribute_name)

=head2 get_division_list

=head2 has_sections

=head2 get_section_list

=head2 get_block_list

=head2 get_element_list

=head2 get_line_list

=head2 get_data_segment_line_list

=head2 get_narrative_line_list

=head2 get_first_part

=head2 get_first_line

=head2 get_containing_document

=head2 get_location

=head2 get_section

=head2 is_in_a($division_type)

=head2 validate

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
