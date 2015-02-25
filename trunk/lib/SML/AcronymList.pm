#!/usr/bin/perl

# $Id$

package SML::AcronymList;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.AcronymList');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

# NONE.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_acronym {

  # Add a new acronym.

  my $self       = shift;
  my $definition = shift;

  if ( $definition->isa('SML::Definition') )
    {
      my $term = $definition->get_term;
      my $alt  = $definition->get_alt;
      my $ah   = $self->_get_acronym_hash;

      $ah->{$term}{$alt} = $definition;

      return 1;
    }

  else
    {
      $logger->warn("CAN'T ADD ACRONYM: \'$definition\' is not a definition");

      return 0;
    }
}

######################################################################

sub has_acronym {

  my $self    = shift;
  my $acronym = shift;
  my $alt     = shift || q{};
  my $ah      = $self->_get_acronym_hash;

  if ( defined $ah->{$acronym}{$alt} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_acronym {

  my $self    = shift;
  my $acronym = shift;
  my $alt     = shift || q{};

  my $ah = $self->_get_acronym_hash;

  if ( defined $ah->{$acronym}{$alt} )
    {
      return $ah->{$acronym}{$alt};
    }

  else
    {
      $logger->warn("FAILED ACRONYM LOOKUP: \'$acronym\' \'$alt\'");
      return 0;
    }
}

######################################################################

sub get_acronym_list {

  # Return an alphabetically sorted list of all acronyms.

  my $self = shift;

  my $ah = $self->_get_acronym_hash;
  my $al = [];                          # acronym list

  foreach my $acronym ( sort keys %{ $ah } )
    {
      foreach my $alt ( sort keys %{ $ah->{$acronym} } )
	{
	  push @{ $al }, $ah->{$acronym}{$alt};
	}
    }

  return $al;
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has 'acronym_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_acronym_hash',
   default => sub {{}},
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::AcronymList> - a list of acronyms used in a special subject,
field, or area of usage, with accompanying definitions.

=head1 VERSION

This documentation refers to L<"SML::AcronymList"> version 2.0.0.

=head1 SYNOPSIS

  my $acl = SML::AcronymList->new();

  $acl->add_acronym($definition);

  if ( $acl->has_acronym($acronym,$alternative) ) {
    my $acronym = $acl->get_acronym($acronym,$alternative);
  }

  my $alphabetized_acronym_list = $acl->get_acronym_list;

=head1 DESCRIPTION

An acronym list is a list of acronyms used in a special subject,
field, or area of usage, with accompanying definitions.  The acronym
list may contain multiple alternative definitions of the same acronym.

=head1 METHODS

=head2 add_acronym

Add an acronym definition (must be an object of type
L<"SML::Definition">).

=head2 has_acronym

Returns 1 if acronym list contains a definition for the specified
acronym/alternative pair.

=head2 get_acronym

Returns the L<"SML::Definition"> for the specified acronym/alternative
pair.

=head2 get_acronym_list

Returns an C<ArrayRef> to an alphabatized list of L<"SML::Definition">
objects in the acronym list.

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
