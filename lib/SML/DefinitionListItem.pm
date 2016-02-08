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
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default  => 'DEFINITION_LIST_ITEM',
  );

######################################################################

has '+leading_whitespace' =>
  (
   required => 0,
  );

# Definition list items are not indented.

######################################################################

has term =>
  (
   isa       => 'Str',
   reader    => 'get_term',
   writer    => 'set_term',
   predicate => 'has_term',
  );

######################################################################

has definition =>
  (
   isa       => 'Str',
   reader    => 'get_definition',
   writer    => 'set_definition',
   predicate => 'has_definition',
  );

######################################################################

has term_string =>
  (
   isa       => 'SML::String',
   reader    => 'get_term_string',
   writer    => 'set_term_string',
   predicate => 'has_term_string',
  );

######################################################################

has definition_string =>
  (
   isa       => 'SML::String',
   reader    => 'get_definition_string',
   writer    => 'set_definition_string',
   predicate => 'has_definition_string',
  );

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

=head1 NAME

C<SML::DefinitionListItem> - an item in a definition list.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::ListItem

  my $item = SML::DefinitionListItem->new
               (
                 library => $library,
               );

  my $string = $item->get_term;
  my $string = $item->get_definition;

=head1 DESCRIPTION

A definition list item is an item in a definition list.

=head1 METHODS

=head2 get_name

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
