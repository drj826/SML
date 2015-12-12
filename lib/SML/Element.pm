#!/usr/bin/perl

# $Id: Element.pm 255 2015-04-01 16:07:27Z drj826@gmail.com $

package SML::Element;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Block';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Element');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   required => 1,
  );

######################################################################

has value =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_value',
   writer    => 'set_value',
   predicate => 'has_value',
  );

# This is the value of the element.  The value may contain SML markup.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _type_of {

  # Return the TYPE of the element value (object name, STRING, or
  # BOOLEAN)

  my $self  = shift;
  my $value = shift;

  my $library = $self->get_library;
  my $util    = $library->get_util;
  my $name    = q{};

  if ( $library->has_division_id($value) )
    {
      my $object = $library->get_division($value);
      return $object->get_name;
    }

  elsif ( $value eq '0' or $value eq '1' )
    {
      return 'BOOLEAN';
    }

  else
    {
      return 'STRING';
    }
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Element> - a block containing a name/value pair expressing a
piece of structured information (descriptive markup) or instructing
the publishing application to take some action (procedural markup).

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Block

  my $element = SML::Element->new
                  (
                    name    => $name,
                    library => $library,
                  );

  my $string  = $element->get_value;
  my $boolean = $element->validate_element_allowed;
  my $boolean = $element->validate_outcome_semantics;
  my $boolean = $element->validate_footnote_syntax;

=head1 DESCRIPTION

An element is a block containing a name/value pair expressing a piece
of structured information (descriptive markup) or instructing the
publishing application to take some action (procedural markup).
Elements are usually defined within DATA SEGMENT divisions but there
are several 'universal' elements that may be used in NARRATIVE
SEGMENTS as well.

=head1 METHODS

=head2 get_value

=head2 validate_element_allowed

=head2 validate_outcome_semantics

=head2 validate_footnote_syntax

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
