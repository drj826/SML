#!/usr/bin/perl

package SML::Property;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.property');

######################################################################
######################################################################
##
## Attributes
##
######################################################################
######################################################################

has 'id' =>
  (
   isa      => 'Str',
   reader   => 'get_id',
   required => 1,
  );

# This is the ID of the division to which the property belongs.

######################################################################

has 'name' =>
  (
   isa      => 'Str',
   reader   => 'get_name',
   required => 1,
  );

######################################################################

has 'element_list' =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_element_list',
   writer    => '_set_element_list',
   clearer   => '_clear_element_list',
   predicate => '_has_element_list',
   default   => sub {[]},
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_element {

  my $self     = shift;
  my $element  = shift;
  my $el       = $self->get_element_list;

  push @{ $el }, $element;

  return 1;
}

######################################################################

sub has_value {

  my $self  = shift;
  my $value = shift;

  foreach my $element (@{ $self->get_element_list })
    {
      if ( $element->get_value eq $value )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub get_value {

  my $self    = shift;
  my $values  = [];
  my $name    = $self->get_name;
  my $sml     = SML->instance;
  my $syntax  = $sml->get_syntax;
  my $util    = $sml->get_util;
  my $options = $util->get_options;

  if (
      $name eq 'status'
      and
      $options->use_formal_status
     )
    {
      # If 'status' is the requested property and the
      # 'use_formal_status' option is set, return the status from the
      # most recent outcome.

      my $outcomes = {};

      foreach my $element ( $self->get_element_list )
	{
	  next if not $element->get_name eq 'outcome';

	  $_ = $element->get_content;

	  chomp;

	  if (/$syntax->{outcome_element}/)
	    {
	      my $date   = $1;
	      my $status = $3;

	      $outcomes->{$date} = $status;
	    }

	  else
	    {
	      my $location = $element->location;
	      $logger->error("OUTCOME SYNTAX ERROR at $location ($_)");
	    }
	}

      my $dates       = [ sort by_date keys %{ $outcomes } ];
      my $most_recent = $dates->[0];

      return $outcomes->{$most_recent};
    }

  else
    {
      foreach my $element (@{ $self->get_element_list })
	{
	  push @{ $values }, $element->get_value;
	}
    }

  return join(', ', @{ $values });

}

######################################################################

sub is_multi_valued {

  my $self          = shift;
  my $element_count = scalar @{ $self->get_element_list };

  if ( $element_count > 1 )
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

sub get_elements_as_enum_list {

  my $self    = shift;
  my $sml     = SML->instance;
  my $util    = $sml->get_util;
  my $library = $util->get_library;

  foreach my $element (@{ $self->get_element_list })
    {
      my $value = $element->get_value;

      # is this element value actually a division ID?
      #
      if ( $library->has_division($value) )
	{
	  my $assoc_division = $library->get_division($value);

	  my $title  = $assoc_division->get_property_value('title');
	  my $tier   = $assoc_division->get_property_value('tier');
	  my $id     = $assoc_division->get_property_value('id');
	  my $name   = $assoc_division->get_property_value('name');
	  my $string = $util->wrap("- $name $id ($tier) $title");

	  return "$string\n\n";
	}

      # or else is this element value a string?
      #
      elsif ( $value )
	{
	  my $string = $util->wrap("- $value");
	  return "$string\n\n";
	}

      # or else does this element have no value?
      #
      else
	{
	  my $location = $element->get_location;
	  $logger->warn("EMPTY ELEMENT VALUE at $location");
	}
    }

  return 0;
}

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
