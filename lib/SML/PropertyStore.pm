#!/usr/bin/perl

package SML::PropertyStore;             # ci-000473

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Carp;                               # error reporting

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.PropertyStore');

######################################################################

=head1 NAME

SML::PropertyStore - store all properties in a library

=head1 SYNOPSIS

  SML::PropertyStore->new(library=>$library);

  $ps->add_element($division_id,$element);                                # Bool
  $ps->get_element($division_id,$property_name,$value);                   # SML::Element
  $ps->add_triple($triple);                                               # Bool
  $ps->has_triple($subject,$predicate,$object);                           # Bool
  $ps->get_triple($subject,$predicate,$object);                           # SML::Triple
  $ps->has_triple_for($subject,$predicate);                               # Bool
  $ps->get_division_id_list;                                              # ArrayRef
  $ps->add_property_value($division_id,$property_name,$value);            # Bool
  $ps->set_property_text($division_id,$property_name,$text);              # Bool
  $ps->get_property_text($division_id,$property_name);                    # Str
  $ps->get_property_string($division_id,$property_name);                  # SML::String
  $ps->get_property_string_for_value($division_id,$property_name,$value); # SML::String
  $ps->get_property_text_for_value($division_id,$property_name,$value);   # Str
  $ps->get_property_origin($division_id,$property_name);                  # Str
  $ps->get_property_value_list($division_id,$property_name);              # ArrayRef
  $ps->get_property_text_list($division_id,$property_name);               # ArrayRef
  $ps->get_property_string_list($division_id,$property_name);             # ArrayRef
  $ps->has_property($division_id,$property_name);                         # Bool
  $ps->get_property_name_list($division_id);                              # ArrayRef
  $ps->is_from_manuscript($division_id,$property_name,$value);            # Bool
  $ps->get_division_count_by_property_value($division_name,$property_name,$property_value); # Int

=head1 DESCRIPTION

An C<SML::PropertyStore> stores all properties of all divisions in a
library.  Each library has a property store. In addition to
properties, the property store keeps things related to properties:
elements, triples, and property origin information.  It also memoizes
property data in different forms: raw SML values, SML strings, and
plain text.  These different forms of property data are particularly
helpful to template designers.

The following terms have very sepcific meanings:

=over 4

=item

value => raw SML text from a manuscript

=item

string => a value turned into an C<SML::String>

=item

text => the plain text representation of a string

=item

element => an C<SML::Element>

=back

A property may have multiple values and this complicates things a
little.  For instance the 'author' property of 'DOCUMENT' may have
multiple values (multiple individual authors).

=head1 METHODS

=head2 new

Instantiate a new C<SML::PropertyStore>

  SML::PropertyStore->new(library=>$library);

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_element {

  my $self = shift;

  my $division_id = shift;              # division containing element
  my $element     = shift;              # element to add

  unless ( $division_id and $element )
    {
      $logger->error("CAN'T ADD ELEMENT, MISSING ARGUMENT(S)");
      return 0;
    }

  unless ( ref $element and $element->isa('SML::Element') )
    {
      $logger->error("CAN'T ADD ELEMENT, NOT AN ELEMENT $element");
      return 0;
    }

  # add the element to the element hash
  my $property_name = $element->get_name;
  my $value         = $element->get_value;
  my $el_href       = $self->_get_element_hash;

  if ( exists $el_href->{$division_id}{$property_name}{$value} )
    {
      # $logger->warn("ELEMENT ALREADY EXISTS $division_id $property_name $value");
    }

  else
    {
      $el_href->{$division_id}{$property_name}{$value} = $element;
    }

  $self->add_property_value($division_id,$property_name,$value);

  my $location = $element->get_location;
  my $or_href  = $self->_get_origin_hash;

  if ( exists $or_href->{$division_id}{$property_name}{$value} )
    {
      # $logger->warn("ORIGIN ALREADY EXISTS $division_id $property_name $value");
    }

  else
    {
      $or_href->{$division_id}{$property_name}{$value} = $location;
    }

  return 1;
}

=head2 add_element($division_id,$element)

Add an C<SML::Element> to the property store.  An element represents
one property value.

  my $result = $ps->add_element;

=cut

######################################################################

sub get_element {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;
  my $value         = shift;

  unless ( $division_id and $property_name and $value )
    {
      $logger->error("CAN'T GET ELEMENT, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_element_hash;

  unless ( exists $href->{$division_id}{$property_name}{$value} )
    {
      $logger->error("CAN'T GET ELEMENT, DOESN'T EXIST $division_id $property_name $value");
      return 0;
    }

  return $href->{$division_id}{$property_name}{$value};
}

=head2 get_element($division_id,$property_name,$value)

Return the C<SML::Element> for the spcified division ID, property
name, and raw value.

  my $element = $ps->get_element($division_id,$property_name,$value);

=cut

######################################################################

sub add_triple {

  my $self = shift;

  my $triple = shift;

  unless ( $triple )
    {
      $logger->error("CAN'T ADD TRIPLE, MISSING ARGUMENT");
      return 0;
    }

  unless ( ref $triple and $triple->isa('SML::Triple') )
    {
      $logger->error("CAN'T ADD TRIPLE, NOT A TRIPLE $triple");
      return 0;
    }

  my $subject   = $triple->get_subject;
  my $predicate = $triple->get_predicate;
  my $object    = $triple->get_object;

  my $href = $self->_get_triple_hash;

  if ( exists $href->{$subject}{$predicate}{$object} )
    {
      $logger->warn("TRIPLE ALREADY EXISTS $subject $predicate $object");
      return 0;
    }

  $href->{$subject}{$predicate}{$object} = $triple;

  my $pr_href = $self->_get_property_hash;

  $pr_href->{$subject}{$predicate}{$object} = 1;

  return 1;
}

=head2 add_triple($triple)

Add a triple to the property store.

  my $result = $ps->add_triple($triple);

=cut

######################################################################

sub has_triple {

  my $self = shift;

  my $subject   = shift;
  my $predicate = shift;
  my $object    = shift;

  unless ( $subject and $predicate and $object )
    {
      $logger->error("CAN'T CHECK IF PROPERTY STORE HAS TRIPLE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_triple_hash;

  if ( exists $href->{$subject}{$predicate}{$object} )
    {
      return 1;
    }

  return 0;
}

=head2 has_triple($subject,$predicate,$object)

Return 1 if the property store has a triple for the specified subject,
predicate, and object.

  my $result = $ps->has_triple($subject,$predicate,$object);

=cut

######################################################################

sub get_triple {

  my $self = shift;

  my $subject   = shift;
  my $predicate = shift;
  my $object    = shift;

  unless ( $subject and $predicate and $object )
    {
      $logger->error("CAN'T GET TRIPLE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_triple_hash;

  unless ( exists $href->{$subject}{$predicate}{$object} )
    {
      $logger->error("CAN'T GET TRIPLE, DOESN'T EXIST $subject $predicate $object");
      return 0;
    }

  return $href->{$subject}{$predicate}{$object};
}

=head2 get_triple($subject,$predicate,$object)

Return the C<SML::Triple> for the specified subject, predicate, and
object.

  my $triple = $ps->get_triple($subject,$predicate,$object);

=cut

######################################################################

sub has_triple_for {

  # Return 1 if the property store has a triple for the specified
  # subject and predicate.

  my $self = shift;

  my $subject   = shift;
  my $predicate = shift;

  unless ( $subject and $predicate )
    {
      $logger->error("CAN'T CHECK FOR TRIPLE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_triple_hash;

  if ( exists $href->{$subject}{$predicate} )
    {
      return 1;
    }

  return 0;
}

=head2 has_triple_for($subject,$predicate)

Return 1 if the property store has a triple for the specified subject
and predicate.

  my $result = $ps->has_triple_for($subject,$predicate);

=cut

######################################################################

sub get_division_id_list {

  my $self = shift;

  my $href = $self->_get_property_hash;

  return [ keys %{$href} ];
}

=head2 get_division_id_list

Return a list of division IDs known to the property store.

  my $aref = $ps->get_division_id_list;

=cut

######################################################################

sub add_property_value {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;
  my $value         = shift;

  unless ( $division_id and $property_name and defined $value )
    {
      $logger->error("CAN'T ADD PROPERTY VALUE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_property_hash;

  $href->{$division_id}{$property_name}{$value} = 1;

  return 1;
}

=head2 add_property_value

Add a property value to the property store.

  my $result = $ps->add_property_value($division_id,$property_name,$value);

=cut

######################################################################

sub set_property_text {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;
  my $text          = shift;

  unless ( $division_id and $property_name and $text )
    {
      $logger->error("CAN'T ADD PROPERTY VALUE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_property_hash;

  $href->{$division_id}{$property_name}{$text} = 1;

  my $pt_href = $self->_get_property_text_hash;

  $pt_href->{$division_id}{$property_name} = $text;

  my $ptl_href = $self->_get_property_text_list_hash;

  $ptl_href->{$division_id}{$property_name} = [ $text ];

  return 1;
}

=head2 set_property_text($division_id,$property_name,$text)

Set the text value for the specified property.

  my $result = $ps->set_property_text($division_id,$property_name,$text);

=cut

######################################################################

sub get_property_text {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->logcluck("CAN'T GET PROPERTY TEXT, MISSING ARGUMENT(S)");
      return 0;
    }

  my $library       = $self->_get_library;
  my $ontology      = $library->get_ontology;
  my $division_name = $library->get_division_name_for_id($division_id);
  my $href          = $self->_get_property_text_hash;

  if ( exists $href->{$division_id}{$property_name} )
    {
      return $href->{$division_id}{$property_name};
    }

  elsif ( $ontology->has_default_property_value($division_name,$property_name) )
    {
      my $text = $ontology->get_default_property_value($division_name,$property_name);

      $self->add_property_value($division_id,$property_name,$text);
    }

  my $pr_href = $self->_get_property_hash;

  unless ( exists $pr_href->{$division_id}{$property_name} )
    {
      $logger->error("CAN'T GET PROPERTY TEXT, NO PROPERTY $division_id $property_name");
      return 0;
    }

  my $string = $self->get_property_string($division_id,$property_name);
  my $text   = $string->get_plain_text;

  $href->{$division_id}{$property_name} = $text;

  return $text;
}

=head2 get_property_text($division_id,$property_name)

Return a scalar text value which is the plain text rendition of a
property value.

  my $text = $ps->get_property_text($division_id,$property_name);

=cut

######################################################################

sub get_property_string {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->logcluck("CAN'T GET PROPERTY STRING, MISSING ARGUMENT(S)");
      return 0;
    }

  my $library       = $self->_get_library;
  my $ontology      = $library->get_ontology;
  my $division_name = $library->get_division_name_for_id($division_id);
  my $href          = $self->_get_property_string_hash;

  if ( exists $href->{$division_id}{$property_name} )
    {
      return $href->{$division_id}{$property_name};
    }

  elsif ( $ontology->has_default_property_value($division_name,$property_name) )
    {
      my $text = $ontology->get_default_property_value($division_name,$property_name);

      $self->add_property_value($division_id,$property_name,$text);
    }

  my $pr_href = $self->_get_property_hash;

  unless ( exists $pr_href->{$division_id}{$property_name} )
    {
      $logger->error("CAN'T GET PROPERTY STRING, NO PROPERTY $division_id $property_name");
      return 0;
    }

  $logger->debug("get_property_string: $division_id, $property_name");

  my $value_list = [ keys %{ $pr_href->{$division_id}{$property_name} } ];

  # DEBUGGING...
  foreach my $value (@{ $value_list })
    {
      $logger->debug("  value: $value");
    }

  my $util       = $library->get_util;
  my $text       = $util->commify_series(@{$value_list});
  my $parser     = $library->get_parser;
  my $division   = $library->get_division($division_id);
  my $string     = $parser->create_string($text,$division);

  $href->{$division_id}{$property_name} = $string;

  return $string;
}

=head2 get_property_string($division_id,$property_name)

Return an C<SML::String> rendition of a property value.

  my $string = $ps->get_property_string($division_id,$property_name);

=cut

######################################################################

sub get_property_string_for_value {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;
  my $value         = shift;

  unless ( $division_id and $property_name and $value )
    {
      $logger->logcluck("CAN'T GET PROPERTY STRING BY VALUE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_property_string_by_value_hash;

  if ( exists $href->{$division_id}{$property_name}{$value} )
    {
      return $href->{$division_id}{$property_name}{$value};
    }

  my $element    = $self->get_element($division_id,$property_name,$value);
  my $library    = $self->_get_library;
  my $util       = $library->get_util;
  my $parser     = $library->get_parser;
  my $division   = $library->get_division($division_id);
  my $string     = $parser->create_string($value,$division);

  $href->{$division_id}{$property_name}{$value} = $string;

  return $string;
}

=head2 get_property_string_for_value($division_id,$property_name,$value)

Return an C<SML::String> for a single value of a (potentially
multivalued) property.

  my $string = $ps->get_property_string_for_value($division_id,$property_name,$value);

=cut

######################################################################

sub get_property_text_for_value {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;
  my $value         = shift;

  unless ( $division_id and $property_name and $value )
    {
      $logger->logcluck("CAN'T GET PROPERTY TEXT BY VALUE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_property_text_by_value_hash;

  if ( exists $href->{$division_id}{$property_name}{$value} )
    {
      return $href->{$division_id}{$property_name}{$value};
    }

  my $string = $self->get_property_string_for_value($division_id,$property_name,$value);
  my $text   = $string->get_plain_text;

  $href->{$division_id}{$property_name}{$value} = $text;

  return $text;
}

=head2 get_property_text_for_value($division_id,$property_name,$value)

Return a scalar text value for a single value of a (potentially
multivalued) property.

  my $text = $ps->get_property_text_for_value($division_id,$property_name,$value);

=cut

######################################################################

sub get_property_origin {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->error("CAN'T GET PROPERTY ORIGIN, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_origin_hash;

  unless ( exists $href->{$division_id}{$property_name} )
    {
      $logger->errror("CAN'T GET PROPERTY ORIGIN, NO ORIGIN DATA");
      return 0;
    }

  my $origin_list = [];
  my $value_list  = [ keys %{ $href->{$division_id}{$property_name} } ];

  foreach my $value (@{ $value_list })
    {
      my $origin = $href->{$division_id}{$property_name}{$value};

      push @{$origin_list}, $origin;
    }

  my $library = $self->_get_library;
  my $util    = $library->get_util;

  return $util->commify_series(@{$origin_list});
}

=head2 get_property_origin($division_id,$property_name)

Return a scalar text value which represents the location of the
origin(s) of the specified property.

  my $origin = $ps->get_property_origin($division_id,$property_name);

=cut

######################################################################

sub get_property_value_list {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->logcluck("CAN'T GET PROPERTY VALUE LIST, MISSING ARGUMENT(S)");
      return 0;
    }

  my $pr_href = $self->_get_property_hash;

  unless ( exists $pr_href->{$division_id}{$property_name} )
    {
      $logger->error("CAN'T GET PROPERTY VALUE LIST, NO PROPERTY $division_id $property_name");
      return 0;
    }

  return [ keys %{ $pr_href->{$division_id}{$property_name} } ];
}

=head2 get_property_value_list($division_id,$property_name)

Return an ArrayRef to a list of raw SML values for the specified property.

  my $aref = $ps->get_property_value_list($division_id,$property_name);

=cut

######################################################################

sub get_property_text_list {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->logcluck("CAN'T GET PROPERTY TEXT LIST, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_property_text_list_hash;

  if ( exists $href->{$division_id}{$property_name} )
    {
      return $href->{$division_id}{$property_name};
    }

  my $pr_href = $self->_get_property_hash;

  unless ( exists $pr_href->{$division_id}{$property_name} )
    {
      $logger->error("CAN'T GET PROPERTY TEXT LIST, NO PROPERTY $division_id $property_name");
      return 0;
    }

  my $string_list = $self->get_property_string_list($division_id,$property_name);
  my $text_list   = [];

  foreach my $string (@{ $string_list })
    {
      my $text = $string->get_plain_text;

      push @{$text_list}, $text
    }

  $href->{$division_id}{$property_name} = $text_list;

  return $text_list;
}

=head2 get_property_text_list($division_id,$property_name)

Return an ArrayRef to a list of plain text values for the specified
property.

  my $aref = $ps->get_property_text_list($division_id,$property_name);

=cut

######################################################################

sub get_property_string_list {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->error("CAN'T GET PROPERTY STRING LIST, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_property_string_list_hash;

  if ( exists $href->{$division_id}{$property_name} )
    {
      return $href->{$division_id}{$property_name};
    }

  my $pr_href = $self->_get_property_hash;

  unless ( exists $pr_href->{$division_id}{$property_name} )
    {
      $logger->error("CAN'T GET PROPERTY STRING, NO PROPERTY $division_id $property_name");
      return 0;
    }

  my $value_list  = [ keys %{ $pr_href->{$division_id}{$property_name} } ];
  my $library     = $self->_get_library;
  my $util        = $library->get_util;
  my $parser      = $library->get_parser;
  my $string_list = [];
  my $division    = $library->get_division($division_id);

  foreach my $value (@{ $value_list })
    {
      my $string = $parser->create_string($value,$division);

      push @{$string_list}, $string
    }

  $href->{$division_id}{$property_name} = $string_list;

  return $string_list;
}

=head2 get_property_string_list($division_id,$property_name)

Return an ArrayRef to a list of C<SML::String> values for the
specified property.

  my $aref = $ps->get_property_string_list($division_id,$property_name);

=cut

######################################################################

sub has_property {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->error("CAN'T CHECK FOR PROPERTY TEXT, MISSING ARGUMENT(S)");
      return 0;
    }

  my $pr_href = $self->_get_property_hash;

  if ( exists $pr_href->{$division_id}{$property_name} )
    {
      return 1;
    }

  return 0;
}

=head2 has_property

Return 1 if the property store has the specified property.

  my $result = $ps->has_property($division_id,$property_name);

=cut

######################################################################

sub get_property_name_list {

  # Return a list of existing property names for the specified
  # division_id.

  my $self = shift;

  my $division_id = shift;

  unless ( $division_id )
    {
      $logger->error("CAN'T GET PROPERTY NAME LIST, MISSING ARGUMENT");
      return 0;
    }

  my $pr_href = $self->_get_property_hash;

  unless ( exists $pr_href->{$division_id} )
    {
      $logger->error("CAN'T GET PROPERTY NAME LIST FOR $division_id, NO SUCH DIVISION");
      return 0;
    }

  return [ keys %{ $pr_href->{$division_id} } ];
}

=head2 get_property_name_list($division_id)

Return an ArrayRef to a list of property names for the specified
division.

  my $aref = $ps->get_property_name_list($division_id);

=cut

######################################################################

sub is_from_manuscript {

  # The specified value is declared in the manuscript if it exists in
  # the element hash.

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;
  my $value         = shift;

  unless ( $division_id and $property_name and $value )
    {
      $logger->error("CAN'T CHECK IF VALUE IS FROM MANUSCRIPT, MISSING ARGUMENT(S)");
      $logger->error("  division_id:   $division_id");
      $logger->error("  property_name: $property_name");
      $logger->error("  value:         $value");
      return 0;
    }

  my $href = $self->_get_element_hash;

  if ( exists $href->{$division_id}{$property_name}{$value} )
    {
      return 1;
    }

  return 0;
}

=head2 is_from_manuscript($division_id,$property_name,$value)

Return 1 if the specified property value originates from manuscript
text (as opposed to being inferred by the reasoner or generated by a
plugin). This is used to validate infer-only conformance.  If a
property value is infer-only then it may NOT be explicitly declared in
a manuscript.

  my $result = $ps->is_from_manuscript($division_id,$property_name,$value);

=cut

######################################################################

sub get_division_count_by_property_value {

  my $self = shift;

  my $division_name  = shift;
  my $property_name  = shift;
  my $property_value = shift;

  my $library  = $self->_get_library;
  my $ontology = $library->get_ontology;

  unless
    (
     defined $division_name
     and
     defined $property_name
     and
     defined $property_value
    )
    {
      $logger->error("CAN'T GET DIVISION COUNT BY PROPERTY VALUE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $count = 0;

  my $href = $self->_get_property_hash;

  foreach my $id ( keys %{ $href } )
    {
      my $name = $library->get_division_name_for_id($id);

      if ( $name eq $division_name )
	{
	  # fill in default value if necessary
	  if
	    (
	     $ontology->has_default_property_value($division_name,$property_name)
	     and
	     not exists $href->{$id}{$property_name}
	    )
	    {
	      my $default_value = $ontology->get_default_property_value($division_name,$property_name);

	      $self->add_property_value($id,$property_name,$default_value);
	    }

	  foreach my $pname ( keys %{ $href->{$id} } )
	    {
	      if ( $pname eq $property_name )
		{
		  foreach my $pvalue ( keys %{ $href->{$id}{$pname} } )
		    {
		      if ( $pvalue eq $property_value )
			{
			  ++ $count;
			}
		    }
		}
	    }
	}
    }

  return $count;
}

=head2 get_division_count_by_property_value($division_name,$property_name,$property_value)

Return an integer count of the number of divisions in the library that
have the specified property name and value.

  my $count = $ps->get_division_count_by_property_value($division_name,$property_name,$property_value)

For example imagine you want to know how many 'requirement' entities
in a library have a status value of green:

  my $count = $ps->get_division_count_by_property_value('requirement','status','green');

=cut

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has library =>
  (
   is       => 'ro',
   isa      => 'SML::Library',
   reader   => '_get_library',
   required => 1,
  );

######################################################################

has element_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_element_hash',
   default => sub {{}},
  );

# $href->{$division_id}{$property_name}{$value} = $element;

######################################################################

has property_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_property_hash',
   default => sub {{}},
  );

# $href->{$division_id}{$property_name}{$value} = 1;

######################################################################

has triple_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_triple_hash',
   default => sub {{}},
  );

# $href->{$division_id}{$property_name}{$value} = triple;

######################################################################

has origin_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_origin_hash',
   default => sub {{}},
  );

# $href->{$division_id}{$property_name}{$value} = $origin;

######################################################################

has property_text_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_property_text_hash',
   default => sub {{}},
  );

# This is a 2-dimensional hash of scalars.  Each scalar is a
# concatenation of (potentially) multiple values for a property.
#
#   $href->{$division_id}{$property_name} = $scalar;
#
# For instance, if a DOCUMENT division with ID 'my-doc' has three
# authors:
#
#   >>>DOCUMENT.my-doc
#
#   author:: Mickey
#
#   author:: Donald
#
#   author:: Goofy
#
#   <<<DOCUMENT
#
# Then one hash entry would be:
#
#   $href->{'my-doc'}{'author'} = "Mickey, Donald, and Goofy";

######################################################################

has property_text_by_value_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_property_text_by_value_hash',
   default => sub {{}},
  );

######################################################################

has property_string_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_property_string_hash',
   default => sub {{}},
  );

# $href->{$division_id}{$property_name} = $string;

######################################################################

has property_string_by_value_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_property_string_by_value_hash',
   default => sub {{}},
  );

######################################################################

has property_text_list_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_property_text_list_hash',
   default => sub {{}},
  );

# This is a 2-dimensional hash of arrays.  Each array may contain the
# multiple values of a property identified by a division ID and
# property name:
#
#   $href->{$division_id}{$property_name} = [$value1,$value2,$value3];
#
# For instance, if a DOCUMENT division with ID 'my-doc' has three
# authors:
#
#   >>>DOCUMENT.my-doc
#
#   author:: Mickey
#
#   author:: Donald
#
#   author:: Goofy
#
#   <<<DOCUMENT
#
# Then one hash entry would be:
#
#   $href->{'my-doc'}{'author'} = ['Mickey','Donald','Goofy'];

######################################################################

has property_string_list_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_property_string_list_hash',
   default => sub {{}},
  );

# $href->{$division_id}{$property_name} = $string_list;

######################################################################

has property_origin_list_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_property_origin_list_hash',
   default => sub {{}},
  );

# $href->{$division_id}{$property_name} = $origin_list;

######################################################################

has property_is_from_manuscript_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_property_is_from_manuscript_hash',
   default => sub {{}},
  );

# This is a 3-dimensional hash of boolean values that remembers
# whether each property value came from the manuscript as opposed to
# being inferred by the reasoner or set by a plugin.  This is used to
# validate infer-only conformance.  If a property value is infer-only
# then it may NOT be explicitly declared in the manuscript.
#
#   $href->{$division_id}{$property_name}{$property_value} = 1;

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _set_property_text {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;
  my $text          = shift;

  unless ( $division_id and $property_name and $text )
    {
      $logger->error("CAN'T SET PROPERTY TEXT, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_property_text_hash;

  $href->{$division_id}{$property_name} = $text;

  return 1;
}

######################################################################

sub _set_property_string {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;
  my $string        = shift;

  unless ( $division_id and $property_name and $string )
    {
      $logger->error("CAN'T SET PROPERTY STRING, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_property_string_hash;

  $href->{$division_id}{$property_name} = $string;

  return 1;
}

######################################################################

sub _set_property_origin {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;
  my $origin        = shift;

  unless ( $division_id and $property_name and $origin )
    {
      $logger->error("CAN'T SET PROPERTY ORIGIN, MISSING ARGUMENT(S)");
      return 0;
    }

  my $href = $self->_get_origin_hash;

  $href->{$division_id}{$property_name} = $origin;

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
