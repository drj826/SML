#!/usr/bin/perl

package SML::Definition;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Element';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.definition');

######################################################################
######################################################################
##
## Attributes
##
######################################################################
######################################################################

# has 'alt' =>
#   (
#    isa    => 'Str',
#    reader => 'get_alt',
#   );

# This is an alternative namespace for this term.  Since terms may
# have different meaning based on their context, this is a mechanism
# for indicating context.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_term {

  my $self   = shift;
  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  $_ = $self->get_content;

  chomp;

  if ( /$syntax->{definition_element}/xms )
    {
      return $2;
    }

  else
    {
      $logger->error("DEFINITION SYNTAX ERROR term not found");
      return q{};
    }
}

######################################################################

sub get_alt {

  my $self   = shift;
  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  $_ = $self->get_content;

  chomp;

  if ( /$syntax->{definition_element}/xms )
    {
      return $4 || q{};
    }

  else
    {
      $logger->error("DEFINITION SYNTAX ERROR");
      return q{};
    }
}

######################################################################

sub get_value {

  my $self   = shift;
  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  $_ = $self->get_content;

  chomp;

  if ( /$syntax->{definition_element}/xms )
    {
      return $5;
    }

  else
    {
      $logger->error("DEFINITION SYNTAX ERROR value not found");
      return q{};
    }
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Definition> - an element that defines an term/alt/definition
triple.

=head1 VERSION

This documentation refers to L<"SML::Definition"> version 2.0.0.

=head1 SYNOPSIS

  my $def = SML::Definition->new();

=head1 DESCRIPTION

A definition is an element that defines an term/alt/definition triple.

=head1 METHODS

=head2 get_term

=head2 get_alt

=head2 get_value

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
