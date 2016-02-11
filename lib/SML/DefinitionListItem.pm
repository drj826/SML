#!/usr/bin/perl

package SML::DefinitionListItem;        # ci-000432

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::ListItem';                # ci-000424

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.DefinitionListItem');

######################################################################

=head1 NAME

SML::DefinitionListItem - an item in a definition list.

=head1 SYNOPSIS

  SML::DefinitionListItem->new(library=>$library);

  $item->get_term;                       # Str
  $item->set_term($term);                # Bool
  $item->has_term;                       # Bool
  $item->get_definition;                 # Str
  $item->set_definition($definition);    # Bool
  $item->has_definition;                 # Bool
  $item->get_term_string;                # SML::String
  $item->set_term_string($string);       # Bool
  $item->has_term_string;                # Bool
  $item->get_definition_string;          # Str
  $item->set_definition_string($string); # Bool
  $item->has_definition;                 # Bool

  # methods inherited from SML::ListItem...

=head1 DESCRIPTION

An C<SML::DefinitionListItem> represents an item in a definition list.
A definition list is a list of terms with related definitions.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has term =>
  (
   isa       => 'Str',
   reader    => 'get_term',
   writer    => 'set_term',
   predicate => 'has_term',
  );

=head2 get_term

Return a scalar text value which is the term being defined.  This
value may contain SML markup.

  my $term = $item->get_term;

For example, I<TLA> is the term being defined in the following
definition list item:

  = TLA = Three Letter Acronym

=head2 set_term

Set the specified term as the term being defined in the definition
list item.

  my $result = $item->set_term($term);

=head2 has_term

Return 1 if this definition list item has a term.

  my $result = $item->has_term;

=cut

######################################################################

has definition =>
  (
   isa       => 'Str',
   reader    => 'get_definition',
   writer    => 'set_definition',
   predicate => 'has_definition',
  );

=head2 get_definition

Return a scalar text value which is the definition of the term.  This
value may contain SML markup.

  my $definition = $item->get_definition;

For example, I<Three Letter Acronym> is the definition of the term in
the following definition list item:

  = TLA = Three Letter Acronym

=head2 set_definition

Set the specified definition as the definition of the term.

  my $result = $item->set_definition($definition);

=head2 has_definition

Return 1 if this definition list item has a definition.

  my $result = $item->has_definition;

=cut

######################################################################

has term_string =>
  (
   isa       => 'SML::String',
   reader    => 'get_term_string',
   writer    => 'set_term_string',
   predicate => 'has_term_string',
  );

=head2 get_term_string

Return an C<SML::String> of the term being defined.

  my $string = $item->get_term_string;

=head2 set_term_string

Set the specified C<SML::String> as the term string.

  my $result = $item->set_term_string($string);

=head2 has_term_string

Return 1 if this definition list item has a term string.

  my $result = $item->has_term_string;

=cut

######################################################################

has definition_string =>
  (
   isa       => 'SML::String',
   reader    => 'get_definition_string',
   writer    => 'set_definition_string',
   predicate => 'has_definition_string',
  );

=head2 get_definition_string

Return an C<SML::String> which is the definition of the term.

  my $string = $item->get_definition_string;

=head2 set_definition_string

Set the specified C<SML::String> as the definition string.

  my $result = $item->set_definition_string($string);

=head2 has_definition_string

Return 1 if this definition list item has a definition string.

  my $result = $item->has_definition_string;

=cut

######################################################################

has '+name' =>
  (
   default  => 'DEFINITION_LIST_ITEM',
  );

######################################################################

# has '+leading_whitespace' =>
#   (
#    required => 0,
#   );

# Definition list items are not indented.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

# NONE

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
