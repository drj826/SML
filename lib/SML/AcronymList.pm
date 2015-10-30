#!/usr/bin/perl

# $Id: AcronymList.pm 183 2015-03-08 12:54:06Z drj826@gmail.com $

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

  # validate input
  if (
      not ref $definition
      or
      not $definition->isa('SML::Definition')
     )
    {
      $logger->error("NOT A DEFINITION \'$definition\'");
      return 0;
    }

  my $term      = $definition->get_term;
  my $namespace = $definition->get_namespace || q{};
  my $ah        = $self->_get_acronym_hash;

  $ah->{$term}{$namespace} = $definition;

  return 1;
}

######################################################################

sub has_acronym {

  my $self      = shift;
  my $acronym   = shift;
  my $namespace = shift || q{};

  my $ah = $self->_get_acronym_hash;

  if ( defined $ah->{$acronym}{$namespace} )
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

  my $self      = shift;
  my $acronym   = shift;
  my $namespace = shift || q{};

  my $ah = $self->_get_acronym_hash;

  if ( defined $ah->{$acronym}{$namespace} )
    {
      return $ah->{$acronym}{$namespace};
    }

  else
    {
      $logger->warn("FAILED ACRONYM LOOKUP: \'$acronym\' \'$namespace\'");
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
      foreach my $namespace ( sort keys %{ $ah->{$acronym} } )
	{
	  push @{ $al }, $ah->{$acronym}{$namespace};
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

2.0.0

=head1 SYNOPSIS

  my $acronym_list = SML::AcronymList->new();

  my $boolean = $acronym_list->add_acronym($definition);
  my $boolean = $acronym_list->has_acronym($acronym,$namespace);
  my $acronym = $acronym_list->get_acronym($acronym,$namespace);
  my $list    = $acronym_list->get_acronym_list;  # alphabetized

=head1 DESCRIPTION

An acronym list is a list of acronyms used in a special subject,
field, or area of usage, with accompanying definitions.  The acronym
list may contain multiple alternative definitions of the same acronym
in different namespaces.

=head1 METHODS

=head2 add_acronym($definition)

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
