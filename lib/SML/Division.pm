#!/usr/bin/perl

package SML::Division;                  # ci-000381

use Moose;

extends 'SML::Part';                    # ci-000436

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Digest::SHA qw(sha1);

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Division');

use lib "..";

######################################################################

=head1 NAME

SML::Division - a sequence of blocks

=head1 SYNOPSIS

  SML::Division->new
    (
      id      => $id,
      library => $library,
      name    => $name,
    );

  $division->get_number;                              # Str
  $division->set_number;                              # Bool
  $division->get_previous_number;                     # Str
  $division->set_previous_number($number);            # Bool
  $division->get_next_number;                         # Str
  $division->set_next_number($number);                # Bool
  $division->get_containing_division;                 # SML::Division
  $division->set_containing_division($division);      # Bool
  $division->has_containing_division;                 # Bool
  $division->get_origin_line;                         # SML::Line
  $division->has_origin_line;                         # Bool
  $division->get_sha_digest;                          # Str

  $division->add_part($part);                         # Bool
  $division->add_attribute($element);                 # Bool
  $division->contains_division_with_id($id);          # Bool
  $division->contains_division_with_name($name);      # Bool
  $division->contains_element_with_name($name);       # Bool
  $division->get_list_of_divisions_with_name($name);  # ArrayRef
  $division->get_list_of_elements_with_name($name);   # ArrayRef
  $division->get_division_list;                       # ArrayRef
  $division->get_block_list;                          # ArrayRef
  $division->get_string_list;                         # ArrayRef
  $division->get_element_list;                        # ArrayRef
  $division->get_line_list;                           # ArrayRef
  $division->get_first_part;                          # SML::Part
  $division->get_first_line;                          # SML::Line
  $division->get_containing_document;                 # SML::Document
  $division->get_location;                            # Str
  $division->get_containing_section;                  # SML::Section
  $division->is_in_a($name);                          # Bool
  $division->get_content;                             # Str

  # methods inherited from SML::Part...

  $part->get_name;                                    # Str
  $part->get_library;                                 # SML::Library
  $part->get_id;                                      # Str
  $part->set_id;                                      # Bool
  $part->set_content;                                 # Bool
  $part->get_content;                                 # Str
  $part->has_content;                                 # Bool
  $part->get_container;                               # SML::Part
  $part->set_container;                               # Bool
  $part->has_container;                               # Bool
  $part->get_part_list;                               # ArrayRef
  $part->is_narrative_part;                           # Bool

  $part->init;                                        # Bool
  $part->contains_parts;                              # Bool
  $part->has_part($id);                               # Bool
  $part->get_part($id);                               # SML::Part
  $part->add_part($part);                             # Bool
  $part->get_narrative_part_list                      # ArrayRef
  $part->get_containing_document;                     # SML::Document
  $part->is_in_section;                               # Bool
  $part->get_containing_section;                      # SML::Section
  $part->render($rendition,$style);                   # Str
  $part->dump_part_structure($indent);                # Str

=head1 DESCRIPTION

An C<SML::Division> is a contiguous sequence of C<SML::Block>s.  A
division has an unambiguous beginning and end.  Sometimes the
beginning and end are explicit and other times they are implicit.
Divisions may contain other divisions.

=head1 METHODS

=cut

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

has number =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_number',
   writer   => 'set_number',
   default  => '',
  );

=head2 get_number

Return a scalar text value which is the "number" of this division.

  my $number = $division->get_number;

This "number" is often used to uniquely identify the division in a
document presentation.  The number is generated by the parser.

Sections have numbers like "2.13.4".

Other structures like tables and figures have numbers like "3-12".
The first number (3) is the toplevel section in which the structure
appears.  The second number (12) is simply a one-up count representing
that structure (i.e. table) within the toplevel section.

Entities also have numbers like "7-95".

=head2 set_number

Set the scalar text value of the "number" of this division.

  $division->set_number($number);

=cut

######################################################################

has previous_number =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_previous_number',
   writer   => 'set_previous_number',
   default  => '',
  );

=head2 get_previous_number

Return a scalar text value which is the "number" of the previous
division in a sequence of divisions.

  my $previous = $division->get_previous_number;

For instance, if this could be the previous number of a 'SLIDE' in a
sequence of 'SLIDE's.

=head2 set_previous_number

Set the scalar text value of the number of the division previous to
this one.

  $division->set_previous_number($number);

=cut

######################################################################

has next_number =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_next_number',
   writer   => 'set_next_number',
   default  => '',
  );

=head2 get_next_number

Return a scalar text value which is the "number" of the next division
in a sequence of divisions.

  my $next = $division->get_next_number;

For instance, if this could be the number of the next 'SLIDE' in a
sequence of 'SLIDE's.

=head2 set_next_number

Set the scalar text value of the number of the division that comes
after this one.

  $division->set_next_number($number);

=cut

######################################################################

has containing_division =>
  (
   is        => 'ro',
   isa       => 'SML::Division',
   reader    => 'get_containing_division',
   writer    => 'set_containing_division',
   predicate => 'has_containing_division',
  );

=head2 get_containing_division

Return the C<SML::Division> that contains this one. In other words,
the division to which this one belongs, or the division of which this
one is a part.

  my $container = $division->get_containing_division;

=head2 set_containing_division

Set the value of the containing division (must be an C<SML::Division>
object).

  $division->set_containing_division($container);

=head2 has_containing_division

Return 1 if this division is contained by another division.

  my $result = $division->has_containing_division;

=cut

######################################################################

has origin_line =>
  (
   is        => 'ro',
   isa       => 'SML::Line',
   reader    => 'get_origin_line',
   predicate => 'has_origin_line',
  );

=head2 get_origin_line

Return the C<SML::Line> which contains the element that caused this
division to be included.  Elements that can cause the inclusion of a
division are: (1) include, (2) plugin, and (3) script.

  my $origin = $division->get_origin_line;

=head2 has_origin_line

Return 1 if this division has an origin line and thus originated from
an include, plugin, or script element.

  my $result = $division->has_origin_line;

=cut

######################################################################

has sha_digest =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_sha_digest',
   lazy     => 1,
   builder  => '_build_sha_digest',
  );

=head2 get_sha_digest

Return a scalar text value which is the SHA1 hash of the fully
resolved manuscript of this division.  This means the division text
after all include, plugin, and script elements have been resolved.

  my $digest = $division->get_sha_digest;

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

# sub add_division {

#   my $self     = shift;
#   my $division = shift;

#   unless ( $division )
#     {
#       $logger->logcluck("CAN'T ADD DIVISION, MISSING ARGUMENT");
#       return 0;
#     }

#   unless ( ref $division and $division->isa('SML::Division') )
#     {
#       $logger->error("NOT A DIVISION \'$division\'");
#       return 0;
#     }

#   my $id = $division->get_id;

#   if ( exists $self->_get_division_hash->{$id} )
#     {
#       $logger->warn("DIVISION ALREADY EXISTS $id");
#     }

#   $self->_get_division_hash->{$id} = $division;

#   return 1;
# }

# =head2 add_division($division)

# Add a division as part of this one.  Return 1 if successful.

#   my $result = $division->add_division($other_division);

# =cut

######################################################################

sub add_part {

  my $self = shift;
  my $part = shift;

  # validate input
  unless ( ref $part and ( $part->isa('SML::Block') or $part->isa('SML::Division') ) )
    {
      $logger->error("CAN'T ADD PART TO DIVISION \'$part\' is not a block or division");
      return 0;
    }

  $part->set_containing_division($self);

  push @{ $self->get_part_list }, $part;

  $logger->trace("add part $part");

  return 1;
}

=head2 add_part($part)

Add a part to this division.  Only blocks and other divisions may be
added as parts (a string cannot be a part of a division). Return 1 if
successful.

  my $result = $division->add_part($part);

=cut

######################################################################

sub add_attribute {

  my $self = shift;

  my $attribute = shift;

  unless ( ref $attribute and $attribute->isa('SML::Element') )
    {
      $logger->error("NOT AN ELEMENT \'$attribute\'");
      return 0;
    }

  my $library    = $self->get_library;
  my $term       = $attribute->get_term;
  my $definition = $attribute->get_definition;
  my $href       = $self->_get_attribute_hash;

  if ( not exists $href->{$term} )
    {
      $href->{$term} = [];
    }

  push @{ $href->{$term} }, $definition;

  return 1;
}

=head2 add_attribute($attribute)

Add an attribute to this division.  Return 1 if successful.

  my $result = $division->add_attribute($attribute);

What's the difference between an attribute and a property?  Attributes
are not declared in the ontology and therefore cannot be validated
like properties.

=cut

######################################################################

sub contains_division_with_id {

  my $self = shift;
  my $id   = shift;

  unless ( $id )
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

      elsif ( $division->contains_division_with_id($id) )
	{
	  return 1;
	}
    }

  return 0;
}

=head2 contains_division_with_id($id)

Return 1 if the division contains a division with the specified ID.

  my $result = $division->contains_division_with_id($id);

=cut

######################################################################

sub contains_division_with_name {

  my $self = shift;
  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T DETERMINE IF DIVISION CONTAINS ANOTHER, MISSING ARGUMENTS");
      return 0;
    }

  my $library  = $self->get_library;
  my $ontology = $library->get_ontology;

  unless ( $ontology->allows_division_name($name) )
    {
      $logger->error("CAN'T DETERMINE IF DIVISION CONTAINS ANOTHER, \'$name\' NOT ALLOWED");
      return 0;
    }

  foreach my $part (@{ $self->get_division_list })
    {
      my $part_name = $part->get_name;

      if ( $part_name eq $name )
	{
	  return 1;
	}
    }

  return 0;
}

=head2 contains_division_with_name($name)

Return 1 if this division contains one or more divisions with the
specified name.

  my $result = $division->contains_division_with_name($name);

For instance, if you wanted to know if this division contains any
tables:

  if ( $division->contains_division_with_name('TABLE') )
    {
      # do something...
    }

=cut

######################################################################

sub contains_element_with_name {

  my $self = shift;
  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T DETERMINE IF DIVISION CONTAINS ELEMENT, MISSING ARGUMENTS");
      return 0;
    }

  foreach my $element (@{ $self->get_element_list })
    {
      my $element_name = $element->get_name;

      if ( $element_name eq $name )
	{
	  return 1;
	}
    }

  return 0;
}

=head2 contains_element_with_name($name)

Return 1 if this division contains one or more elements with the
specified name.

  my $result = $division->contains_element_with_name($name);

For instance, if you wanted to know if this division contains any
images:

  if ( $division->contains_element_with_name('image') )
    {
      # do something...
    }

=cut

######################################################################

sub get_list_of_divisions_with_name {

  my $self = shift;
  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T GET LIST OF DIVISIONS WITH NAME, MISSING ARGUMENTS");
      return 0;
    }

  my $aref = [];

  foreach my $part (@{ $self->get_division_list })
    {
      my $part_name = $part->get_name;

      if ( $part_name eq $name )
	{
	  push @{ $aref }, $part;
	}
    }

  return $aref;
}

=head2 get_list_of_divisions_with_name($name)

Return an ArrayRef to a list of division objects (within this one)
with the specified name.

  my $aref = $division->get_list_of_divisions_with_name($name);

For instance, return a list of sections within this division:

  my $aref = $division->get_list_of_divisions_with_name('SECTION');

=cut

######################################################################

sub get_list_of_elements_with_name {

  my $self = shift;
  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T GET LIST OF ELEMENTS WITH NAME, MISSING ARGUMENTS");
      return 0;
    }

  my $aref = [];

  foreach my $element (@{ $self->get_element_list })
    {
      my $element_name = $element->get_name;

      if ( $element_name eq $name )
	{
	  push @{ $aref }, $element;
	}
    }

  return $aref;
}

=head2 get_list_of_elements_with_name($name)

Return an ArrayRef to a list of element objects (within this division)
with the specified name.

  my $aref = $division->get_list_of_elements_with_name($name);

For instance, return a list of image elements within this division.

  my $aref = $division->get_list_of_elements_with_name('image');

=cut

######################################################################

sub get_division_list {

  my $self = shift;

  my $aref = [];                        # division list

  no warnings 'recursion';

  foreach my $part (@{ $self->get_part_list })
    {
      if ( $part->isa('SML::Division') )
	{
	  push @{ $aref }, $part;
	  push @{ $aref }, @{ $part->get_division_list };
	}
    }

  return $aref;
}

=head2 get_division_list

Return an ArrayRef to an ordered list of divisions within this one.
Recurse to provide a complete ordered sequence of divisions, depth
first.

  my $aref = $division->get_division_list;

=cut

######################################################################

sub get_block_list {

  my $self = shift;

  my $aref = [];                        # block list

  no warnings 'recursion';

  foreach my $part (@{ $self->get_part_list })
    {
      if ( $part->isa('SML::Block' ) )
	{
	  push @{ $aref }, $part;
	}

      elsif ( $part->isa('SML::Division') )
	{
	  push @{ $aref }, @{ $part->get_block_list };
	}

      else
	{
	  $logger->error("THIS SHOULD NEVER HAPPEN");
	}
    }

  return $aref;
}

=head2 get_block_list

Return an ArrayRef to an ordered list of blocks within this division.
Recurse to provide a complete ordered sequence of blocks, depth first.

  my $aref = $division->get_block_list;

=cut

######################################################################

sub get_string_list {

  my $self = shift;

  my $aref = [];                        # string list

  no warnings 'recursion';

  foreach my $block (@{ $self->get_block_list })
    {
      $self->_add_parts_to_list($block,$aref);
    }

  return $aref;
}

=head2 get_string_list

Return an ArrayRef to an ordered list of strings within this division.
Recurse to provide a complete ordered sequence of strings, depth
first.

  my $aref = $division->get_string_list;

=cut

######################################################################

sub get_element_list {

  my $self = shift;

  my $aref = [];                        # element list

  foreach my $block (@{ $self->get_block_list })
    {
      if ( $block->isa('SML::Element') )
	{
	  push @{ $aref }, $block;
	}

    }

  return $aref;
}

=head2 get_element_list

Return an ArrayRef to an ordered list of elements within this
division.  Recurse to provide a complete ordered sequence of elements,
depth first.

  my $aref = $division->get_element_list;

=cut

######################################################################

sub get_line_list {

  my $self = shift;

  my $aref = [];                        # line list

  no warnings 'recursion';

  foreach my $part (@{ $self->get_part_list })
    {
      push @{ $aref }, @{ $part->get_line_list };
    }

  return $aref;
}

=head2 get_line_list

Return an ArrayRef to an ordered list of lines within this division.
Recurse to provide a complete ordered sequence of lines, depth first.

  my $aref = $division->get_line_list;

=cut

######################################################################

sub get_first_part {

  my $self = shift;

  my $part_list = $self->get_part_list;

  unless ( $self->contains_parts )
    {
      $logger->error("CAN'T GET FIRST PART, DIVISION HAS NO PARTS");
      return 0;
    }

  return $self->get_part_list->[0];
}

=head2 get_first_part

Return the first C<SML::Part> in this division.

  my $part = $division->get_first_part;

=cut

######################################################################

sub get_first_line {

  my $self = shift;

  unless ( $self->contains_parts )
    {
      $logger->error("CAN'T GET FISRT LINE, DIVISION HAS NO PARTS");
      return 0;
    }

  my $first_part = $self->get_first_part;

  return $first_part->get_first_line;
}

=head2 get_first_line

Return the first C<SML::Line> in this division.

  my $line = $division->get_first_line;

=cut

######################################################################

sub get_containing_document {

  # Return the document to which this division belongs (or undef).

  my $self = shift;

  my $division = $self;

  while ( ref $division )
    {
      my $name = $division->get_name;

      if ( $name eq 'DOCUMENT' )
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

=head2 get_containing_document

Return the C<SML::Document> containing this division.

  my $document = $division->get_containing_document;

=cut

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

  return 'UNKNOWN';
}

=head2 get_location

Return a scalar text value which is the location of the first line of
this division.

  my $location = $division->get_location;

=cut

######################################################################

sub get_containing_section {

  my $self = shift;

  my $division = $self;

  while ( $division )
    {
      my $name = $division->get_name;

      if ( $name eq 'SECTION' )
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

=head2 get_containing_section

Return the C<SML::Section> containing this division.  If not in a
section, return 0.

  my $section = $division->get_containing_section;

=cut

######################################################################

sub is_in_a {

  my $self = shift;
  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T CHECK IF DIVISION IS IN ANOTHER, MISSING ARGUMENT");
      return 0;
    }

  my $division = $self;

  while ( ref $division and $division->isa('SML::Division') )
    {
      my $division_name = $division->get_name;

      if ( $division_name eq $name )
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

=head2 is_in_a($name)

Return 1 if this division is in a division of "name" (even if it is
buried several divisions deep).

  my $result = $division->is_in_a($name);

=cut

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

=head2 get_content

Return a scalar text value of the SML text of this division.

  my $text = $division->get_content;

=cut

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has division_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_division_hash',
   default   => sub {{}},
  );

# This datastructure contains division objects (contained by this one)
# indexed by division ID.
#
#   $dh->{$divid} = $division;

######################################################################

has attribute_hash =>
  (
   is        => 'ro',
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

  my $id = $self->get_id;

  if ( $id )
    {
      my $library = $self->get_library;
      my $ps      = $library->get_property_store;

      $ps->add_property_value($id,'id',$id);
    }

  return 1;
}

######################################################################

sub _build_sha_digest {

  my $self = shift;

  my $sha  = Digest::SHA->new;
  my $data = $self->get_content;

  $sha->add($data);

  return $sha->hexdigest;
}

######################################################################

sub _add_parts_to_list {

  my $self = shift;
  my $part = shift;
  my $aref = shift;

  unless ( defined $part and defined $aref )
    {
      $logger->error("CAN'T ADD PARTS TO LIST, MISSING ARGUMENTS");
      return 0;
    }

  unless ( $part->isa('SML::Part') )
    {
      $logger->error("CAN'T ADD PARTS TO LIST, PART IS NOT A PART $part");
      return 0;
    }

  foreach my $subpart (@{ $part->get_part_list })
    {
      push @{$aref}, $subpart;

      if ( $subpart->contains_parts )
	{
	  $self->_add_parts_to_list($subpart,$aref);
	}
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
