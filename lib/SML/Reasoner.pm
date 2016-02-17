#!/usr/bin/perl

package SML::Reasoner;                  # ci-000380

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Reasoner');

######################################################################

=head1 NAME

SML::Reasoner - simple inference engine

=head1 SYNOPSIS

  SML::Reasoner->new(library=>$library);

  $reasoner->infer_inverse_triple($triple);       # SML::Triple
  $reasoner->infer_status_from_outcome($outcome); # Bool

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

sub infer_inverse_triple {

  my $self = shift;

  my $triple = shift;                   # SML::Triple

  unless ( ref $triple and $triple->isa('SML::Triple') )
    {
      $logger->error("CAN'T INFER INVERSE TRIPLE.  \'$triple\' IS NOT A TRIPLE");
      return 0;
    }

  my $subject      = $triple->get_subject;
  my $predicate    = $triple->get_predicate;
  my $object       = $triple->get_object;

  my $library      = $self->_get_library;
  my $ontology     = $library->get_ontology;
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

=head2 infer_inverse_triple($triple)

Return an C<SML::Triple> which is the inverse of the one specified.

  my $inverse_triple = $reasoner->infer_inverse_triple($triple);

A triple consists of a subject, predicate, and object.  The inverse of
a triple is one in which the object of the original is the subject of
the inverse, the subject of the original is the object of the inverse,
and the predicate is modified to make sense.

These two triples are inverse of one another:

  A: solution 001 solves requirement 002

  B: requirement 002 is solved by solution 001

  A subject:   solution 001
  A predicate: solves
  A object:    requirement 002

  B subject:   requirement 002
  B predicate: is solved by
  B object:    solution 001

=cut

######################################################################

sub infer_status_from_outcome {

  my $self = shift;

  my $outcome = shift;

  my $library     = $self->_get_library;
  my $ps          = $library->get_property_store;
  my $entity_id   = $outcome->get_entity_id;
  my $status      = $outcome->get_status;
  my $date        = $outcome->get_date;
  my $description = $outcome->get_description;

  unless ( $library->has_division_id($entity_id) )
    {
      $logger->error("CAN'T INFER STATUS FROM OUTCOMES for non-existent entity \'$entity_id\'");
      return 0;
    }

  $logger->trace("inferred status $status from outcome for $entity_id");

  $ps->set_property_text($entity_id,'status',$status);

  return 1;
}

=head2 infer_status_from_outcome($outcome)

Infer the status of an entity by the outcome of an audit or
test. Return 1 if successful.

  my $result = $reasoner->infer_status_from_outcome($outcome);

Really there's no inference going on here.  This is just setting the
value of the entity status to whatever the outcome determined it to
be.

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
   is        => 'ro',
   isa       => 'SML::Library',
   reader    => '_get_library',
   required  => 1,
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

# NONE

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
