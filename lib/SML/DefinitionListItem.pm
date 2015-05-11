#!/usr/bin/perl

# $Id$

package SML::DefinitionListItem;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::ListItem';

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

has 'term' =>
  (
   isa      => 'SML::String',
   reader   => 'get_term',
   lazy     => 1,
   builder  => '_build_term',
  );

######################################################################

has 'definition' =>
  (
   isa      => 'SML::String',
   reader   => 'get_definition',
   lazy     => 1,
   builder  => '_build_definition',
  );

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

sub _build_term {

  # Return the term being defined by the definition list item.

  my $self = shift;

  my $sml     = SML->instance;
  my $syntax  = $sml->get_syntax;
  my $text    = $self->get_content || q{};
  my $library = $self->get_library;

  $text =~ s/[\r\n]*$//;                # chomp

  if ( $text =~ /$syntax->{'def_list_item'}/xms )
    {
      my $term   = $1;                  # see SML::Syntax
      my $string = SML::String->new
	(
	 content => $term,
	 library => $library,
	);

      $self->add_part($string);

      return $string;
    }

  else
    {
      $logger->error("DEFINITION LIST ITEM SYNTAX ERROR no term found");
      return q{};
    }
};

######################################################################

sub _build_definition {

  # Return the definition of the term being defined by the definition
  # list item.

  my $self = shift;

  my $sml     = SML->instance;
  my $syntax  = $sml->get_syntax;
  my $text    = $self->get_content || q{};
  my $library = $self->get_library;

  $text =~ s/[\r\n]*$//;                # chomp

  if ( $text =~ /$syntax->{'def_list_item'}/xms )
    {
      my $definition = $2;              # see SML::Syntax
      my $string     = SML::String->new
	(
	 content => $definition,
	 library => $library,
	);

      $self->add_part($string);

      return $string;
    }

  else
    {
      $logger->error("DEFINITION LIST ITEM SYNTAX ERROR no definition found");
      return q{};
    }
};

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::DefinitionListItem> - an item in a definition list.

=head1 VERSION

This documentation refers to L<"SML::DefinitionListItem"> version
2.0.0.

=head1 SYNOPSIS

  my $dle = SML::DefinitionListItem->new();

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
