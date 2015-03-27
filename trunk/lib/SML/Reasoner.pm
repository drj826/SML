#!/usr/bin/perl

# $Id$

package SML::Reasoner;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Reasoner');

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

sub infer_inverse_property {

  # If the specified element represents a property to which an inverse
  # rule applies, infer the inverse property.
  #
  # An element is a single value of a potentially multi-valued
  # property.
  #
  # Properties may have inverse (a.k.a. bi-directional) relationships
  # declared in the ontology.
  #
  # For instance imagine an entity 'problem-A' has a 'solution'
  # property with value 'solution-A'.  This means that 'problem-A' is
  # 'solved by' 'solution-A'. The inverse may be infered that entity
  # 'solution-A' 'solves' the problem 'problem-A'.

  my $self    = shift;
  my $element = shift;

  my $sml                   = SML->instance;
  my $ontology              = $sml->get_ontology;
  my $util                  = $sml->get_util;
  my $library               = $util->get_library;
  my $division              = $element->get_containing_division;
  my $division_id           = $division->get_id;
  my $division_name         = $division->get_name;
  my $element_name          = $element->get_name;
  my $element_value         = $element->get_value;
  my $inverse_division_id   = $element_value;
  my $inverse_division_name = $library->get_type($inverse_division_id);
  my $rule                  = $ontology->get_rule_for($division_name,$element_name,$inverse_division_name);
  my $inverse_rule_id       = '';

  if ( $rule )
    {
      $inverse_rule_id = $rule->get_inverse_rule_id;
    }

  else
    {
      return 0;
    }

  if ( $inverse_rule_id and $library->has_division($inverse_division_id) )
    {
      my $inverse_division      = $library->get_division($inverse_division_id);
      my $inverse_division_name = $inverse_division->get_name;
      my $inverse_rule          = $ontology->get_rule_with_id($inverse_rule_id);
      my $inverse_property_name = $inverse_rule->get_property_name;

      if ( $ontology->allows_property($inverse_division_name,$inverse_property_name ) )
	{
	  if (
	      $inverse_division->has_property($inverse_property_name)
	      and
	      $inverse_division->has_property_value($inverse_property_name,$division_id)
	     )
	    {
	      $logger->trace("..... $inverse_division_name $inverse_division_id already has $inverse_property_name $division_id");
	      return 0;
	    }

	  else
	    {
	      my $inverse_line = SML::Line->new
		(
		 content => "${inverse_property_name}:: $division_id\n",
		);

	      my $inverse_element = SML::Element->new
		(
		 name       => $inverse_property_name,
		 division   => $inverse_division,
		);

	      $inverse_element->add_line($inverse_line);

	      $inverse_element->set_containing_division($inverse_division);
	      $inverse_division->add_property_element($inverse_element);
	      $logger->trace("..... implied property: $inverse_division_id now has $inverse_property_name $division_id");
	      return 1;
	    }
	}

      else
	{
	  my $location = $element->get_location;
	  $logger->warn("NO INFERRED PROPERTY at $location: \"$division_name\" \"$inverse_property_name\"");
	}
    }

  return 1;
}

######################################################################

sub infer_status_from_outcomes {

  my $self    = shift;
  my $sml     = SML->instance;
  my $util    = $sml->get_util;
  my $library = $util->get_library;

  foreach my $entity_id (@{ $library->get_outcome_entity_id_list })
    {
      foreach my $date (@{ $library->get_outcome_date_list($entity_id) })
	{
	  my $outcome = $library->get_outcome($entity_id,$date);

	  if ( $library->has_division($entity_id) )
	    {
	      my $division = $library->get_division($entity_id);

	      if ( $division->has_property('status') )
		{
		  $division->add_property_element($outcome);
		}

	      else
		{
		  my $property = SML::Property->new(id=>$entity_id,name=>'status');
		  $division->add_property($property);
		  $division->add_property_element($outcome);
		}
	    }

	  else
	    {
	      $logger->error("CAN'T INFER STATUS FROM OUTCOMES for non-existent entity \'$entity_id\'");
	    }

	  my $outcome_status = $library->get_outcome_status($entity_id,$date);
	}
    }

  return 1;
}

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Reasoner> - a piece of software able to infer logical
consequences from a set of asserted facts, rules or axioms.

=head1 VERSION

This documentation refers to L<"SML::Reasoner"> version 2.0.0.

=head1 SYNOPSIS

  my $rsnr = SML::Reasoner->new();

=head1 DESCRIPTION

A semantic reasoner, reasoning engine, rules engine, or simply a
reasoner, is a piece of software able to infer logical consequences
from a set of asserted facts, rules or axioms. The notion of a
semantic reasoner generalizes that of an inference engine, by
providing a richer set of mechanisms to work with. The inference rules
are commonly specified by means of an ontology language, and often a
description language. Many reasoners use first-order predicate logic
to perform reasoning; inference commonly proceeds by forward chaining
and backward chaining.

=head1 METHODS

=head2 get_library

=head2 infer_inverse_property

=head2 infer_status_from_outcomes

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
