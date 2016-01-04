#!/usr/bin/perl

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

has library =>
  (
   is        => 'ro',
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

sub infer_inverse_triple {

  my $self   = shift;
  my $triple = shift;

  unless ( ref $triple and $triple->isa('SML::Triple') )
    {
      $logger->error("CAN'T INFER INVERSE TRIPLE.  \'$triple\' IS NOT A TRIPLE");
      return 0;
    }

  my $library      = $self->get_library;
  my $ontology     = $library->get_ontology;
  my $subject      = $triple->get_subject;
  my $predicate    = $triple->get_predicate;
  my $object       = $triple->get_object;
  my $subject_name = $library->get_division_name_for_id($subject);
  my $object_name  = $library->get_division_name_for_id($object);

  unless ( $ontology->has_inverse_rule_for($subject_name,$predicate,$object_name) )
    {
      return 0;
    }

  my $inverse_rule      = $ontology->get_inverse_rule_for($subject_name,$predicate,$object_name);
  my $inverse_predicate = $inverse_rule->get_property_name;

  my $inverse_triple = SML::Triple->new
    (
     subject   => $object,
     predicate => $inverse_predicate,
     object    => $subject,
     library   => $library,
     origin    => $triple->get_origin,
    );

  $logger->info("inferred inverse triple $object $inverse_predicate $subject");

  return $inverse_triple;
}

######################################################################

sub infer_status_from_outcome {

  my $self    = shift;
  my $outcome = shift;

  my $library     = $self->get_library;
  my $entity_id   = $outcome->get_entity_id;
  my $status      = $outcome->get_status;
  my $date        = $outcome->get_date;
  my $description = $outcome->get_description;

  unless ( $library->has_division_id($entity_id) )
    {
      $logger->error("CAN'T INFER STATUS FROM OUTCOMES for non-existent entity \'$entity_id\'");
      next;
    }

  $logger->trace("inferred status $status from outcome for $entity_id");
  $library->set_property_value($entity_id,'status',$status);

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

C<SML::Reasoner> - object able to infer logical consequences from a
set of asserted facts, rules or axioms

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  my $reasoner = SML::Reasoner->new(library=>$library);

  my $library  = $reasoner->get_libary;
  my $property = $reasoner->infer_inverse_property($element);
  my $boolean  = $reasoner->infer_status_from_outcomes;

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
