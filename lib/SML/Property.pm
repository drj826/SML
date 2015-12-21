#!/usr/bin/perl

# $Id: Property.pm 255 2015-04-01 16:07:27Z drj826@gmail.com $

package SML::Property;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Property');

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

# This is the ID of the division to which the property belongs.

######################################################################

has name =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_name',
   required => 1,
  );

######################################################################

has library =>
  (
   is       => 'ro',
   isa      => 'SML::Library',
   reader   => 'get_library',
   required => 1,
  );

######################################################################

has value_list =>
  (
   is       => 'ro',
   isa       => 'ArrayRef',
   reader    => 'get_value_list',
   default   => sub {[]},
  );

# A property may have multiple values.  Values may be added directly
# to the property's value list, or may be added as elements (which are
# parts of a division).

######################################################################

has element_list =>
  (
   is       => 'ro',
   isa       => 'ArrayRef',
   reader    => 'get_element_list',
   default   => sub {[]},
  );

# A property may have multiple values.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_value {

  my $self   = shift;
  my $value  = shift;

  push @{ $self->get_value_list }, $value;

  return 1;
}

######################################################################

sub add_element {

  my $self     = shift;
  my $element  = shift;

  push @{ $self->get_element_list }, $element;

  return 1;
}

######################################################################

sub has_value {

  my $self  = shift;
  my $value = shift;

  foreach my $element (@{ $self->get_element_list })
    {
      my $element_value = $element->get_value;

      if
	(
	 $element_value
	 and
	 $element_value eq $value
	)
	{
	  return 1;
	}
    }

  foreach my $property_value (@{ $self->get_value_list })
    {
      if ( $property_value eq $value )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub get_value {

  my $self = shift;

  my $hash    = {};                     # dedupe hash
  my $id      = $self->get_id;
  my $name    = $self->get_name;
  my $library = $self->get_library;
  my $util    = $library->get_util;
  my $options = $util->get_options;

  if ( $name eq 'status' and $options->use_formal_status )
    {
      # If 'status' is the requested property and the
      # 'use_formal_status' option is set, return the status from the
      # most recent outcome.

      my $outcomes = {};

      foreach my $element ( $self->get_element_list )
	{
	  next if not $element->get_name eq 'outcome';

	  my $date   = $element->get_date;
	  my $status = $element->get_status;

	  $outcomes->{$date} = $status;
	}

      my $dates       = [ sort by_date keys %{ $outcomes } ];
      my $most_recent = $dates->[0];

      return $outcomes->{$most_recent};
    }

  else
    {
      foreach my $element (@{ $self->get_element_list })
	{
	  $hash->{ $element->get_value } = 1;
	}

      foreach my $property_value (@{ $self->get_value_list })
	{
	  $hash->{ $property_value } = 1;
	}

      foreach my $object (@{ $library->get_object_list($id,$name) })
	{
	  $hash->{ $object } = 1;
	}
    }

  return join(', ', sort keys %{ $hash });
}

######################################################################

sub is_multi_valued {

  my $self = shift;

  my $element_count = scalar @{ $self->get_element_list };
  my $value_count   = scalar @{ $self->get_value_list };

  if ( $element_count + $value_count > 1 )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_element_count {

  my $self = shift;

  return scalar @{ $self->get_element_list };
}

######################################################################

# sub get_elements_as_enum_list {

#   my $self = shift;

#   my $library = $self->get_library;
#   my $util    = $library->get_util;

#   foreach my $element (@{ $self->get_element_list })
#     {
#       my $value = $element->get_value;

#       # is this element value actually a division ID?
#       #
#       if ( $library->has_division($value) )
# 	{
# 	  my $assoc_division = $library->get_division($value);

# 	  my $title  = $assoc_division->get_property_value('title');
# 	  my $tier   = $assoc_division->get_property_value('tier');
# 	  my $id     = $assoc_division->get_property_value('id');
# 	  my $name   = $assoc_division->get_property_value('name');
# 	  my $string = $util->wrap("- $name $id ($tier) $title");

# 	  return "$string\n\n";
# 	}

#       # or else is this element value a string?
#       #
#       elsif ( $value )
# 	{
# 	  my $string = $util->wrap("- $value");
# 	  return "$string\n\n";
# 	}

#       # or else does this element have no value?
#       #
#       else
# 	{
# 	  my $location = $element->get_location;
# 	  $logger->warn("EMPTY ELEMENT VALUE at $location");
# 	}
#     }

#   return 0;
# }

######################################################################

sub get_division {

  # Return the division to which this property belongs.  ASSUME that
  # all elements of this property come from the same division and
  # return the division of the top element on the stack.

  my $self = shift;

  if ( not $self->get_element_count )
    {
      $logger->warn("CAN'T DETERMINE DIVISION OF EMPTY PROPERTY");
      return 0;
    }

  else
    {
      my $element  = $self->get_element_list->[-1];
      my $division = $element->get_containing_division;

      if ( $division )
	{
	  return $division;
	}

      else
	{
	  $logger->warn("ELEMENT HAS NO DIVISION");
	  return 0;
	}
    }

}

######################################################################

sub by_date {

  # sort routine

  my ($a_yr,$a_mo,$a_dy,$b_yr,$b_mo,$b_dy);

  if ( $a =~ /^(\d\d\d\d)-(\d\d)-(\d\d)$/ )
    {
      $a_yr = $1;
      $a_mo = $2;
      $a_dy = $3;
    }

  else
    {
      $logger->error("INVALID DATE \'$a\'");
    }

  if ( $b =~ /^(\d\d\d\d)-(\d\d)-(\d\d)$/ )
    {
      $b_yr = $1;
      $b_mo = $2;
      $b_dy = $3;
    }

  else
    {
      $logger->error("INVALID DATE \'$b\'");
    }

  return $a_yr <=> $b_yr || $a_mo <=> $b_mo || $a_dy <=> $b_dy;

}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Property> - a characteristic attribute that describes any
division of document content.  A property is expresed as one or more
elements.

=head1 VERSION

This documentation refers to L<"SML::Property"> version 2.0.0.

=head1 SYNOPSIS

  my $prop = SML::Property->new();

=head1 DESCRIPTION

A property is a characteristic attribute that describes any division
of document content.  A property is expresed as one or more elements.

=head1 METHODS

=head2 get_id

=head2 get_name

=head2 get_element_list

=head2 add_element

=head2 has_value

=head2 get_value

=head2 is_multi_valued

=head2 get_element_count

=head2 get_elements_as_enum_list

=head2 get_division

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
