#!/usr/bin/perl

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

sub add_entry {

  # Add a new entry to the acronym list.

  my $self       = shift;
  my $definition = shift;

  # validate input
  unless ( ref $definition and $definition->isa('SML::Definition') )
    {
      $logger->error("NOT A DEFINITION \'$definition\'");
      return 0;
    }

  my $hash      = $self->_get_entry_hash;
  my $term      = $definition->get_term;
  my $namespace = $definition->get_namespace || q{};

  $hash->{$term}{$namespace} = $definition;

  # Add this entry to the entry group hash.
  my $group      = lc(substr($term,0,1));
  my $group_hash = $self->_get_entry_group_hash;

  if ( not exists $group_hash->{$group} )
    {
      $group_hash->{$group} = [];
    }

  push(@{$group_hash->{$group}},$term);

  return 1;
}

######################################################################

sub has_entry {

  # Return 1 if the acronym list has the specified acronym in the
  # specified (optional) namespace.

  my $self      = shift;
  my $acronym   = shift;
  my $namespace = shift || q{};

  unless ( $acronym )
    {
      $logger->error("CAN'T CHECK FOR ENTRY, MISSING ARGUMENTS");
      return 0;
    }

  my $hash = $self->_get_entry_hash;

  if ( defined $hash->{$acronym}{$namespace} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_entry {

  my $self      = shift;
  my $acronym   = shift;
  my $namespace = shift || q{};

  my $hash = $self->_get_entry_hash;

  if ( defined $hash->{$acronym}{$namespace} )
    {
      return $hash->{$acronym}{$namespace};
    }

  else
    {
      $logger->warn("FAILED ACRONYM LOOKUP $acronym {$namespace}");
      return 0;
    }
}

######################################################################

sub get_entry_list {

  # Return an alphabetically sorted list of all acronyms.

  my $self = shift;

  my $hash = $self->_get_entry_hash;
  my $list = [];                        # acronym list

  foreach my $acronym ( sort keys %{ $hash } )
    {
      foreach my $namespace ( sort keys %{ $hash->{$acronym} } )
	{
	  push @{ $list }, $hash->{$acronym}{$namespace};
	}
    }

  return $list;
}

######################################################################

sub get_entry_count {

  # Return a count of the number of entries in the glossary.

  my $self = shift;

  return scalar @{ $self->get_entry_list };
}

######################################################################

sub contains_entries {

  my $self = shift;

  if ( scalar keys %{ $self->_get_entry_hash } > 0 )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_group_list {

  my $self = shift;

  return [ sort keys %{ $self->_get_entry_group_hash } ];
}

######################################################################

sub get_group_entry_list {

  # Return a list of entries belonging to a specified group.

  my $self  = shift;
  my $group = shift;

  my $group_hash = $self->_get_entry_group_hash;

  if ( not exists $group_hash->{$group} )
    {
      $logger->error("NO ACRONYM LIST GROUP \'$group\'");
      return 0;
    }

  my $entry_hash = $self->_get_entry_hash;

  my $hash = {};

  foreach my $term (sort @{ $group_hash->{$group} })
    {
      foreach my $namespace ( sort keys %{ $entry_hash->{$term} } )
	{
	  my $entry = $self->get_entry($term,$namespace);

	  $hash->{"$term.$namespace"} = $entry;
	}
    }

  my $list = [];

  foreach my $term_namespace ( sort keys %{$hash} )
    {
      my $entry = $hash->{$term_namespace};

      push(@{$list},$entry);
    }

  return $list;
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has entry_hash =>
  (
   isa     => 'HashRef',
   reader  => '_get_entry_hash',
   default => sub {{}},
  );

######################################################################

has entry_group_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_entry_group_hash',
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

  my $boolean = $acronym_list->add_entry($definition);
  my $boolean = $acronym_list->has_entry($acronym,$namespace);
  my $acronym = $acronym_list->get_entry($acronym,$namespace);
  my $list    = $acronym_list->get_entry_list;  # alphabetized

=head1 DESCRIPTION

An acronym list is a list of acronyms used in a special subject,
field, or area of usage, with accompanying definitions.  The acronym
list may contain multiple alternative definitions of the same acronym
in different namespaces.

=head1 METHODS

=head2 add_entry($definition)

Add an acronym definition (must be an object of type
L<"SML::Definition">).

=head2 has_entry

Returns 1 if acronym list contains a definition for the specified
acronym/alternative pair.

=head2 get_entry

Returns the L<"SML::Definition"> for the specified acronym/alternative
pair.

=head2 get_entry_list

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
