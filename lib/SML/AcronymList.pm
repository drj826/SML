#!/usr/bin/perl

package SML::AcronymList;               # ci-000439

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.AcronymList');

######################################################################

=head1 NAME

SML::AcronymList - a list of acronyms

=head1 SYNOPSIS

  SML::AcronymList->new();

  $acronym_list->add_entry($definition);          # Bool
  $acronym_list->has_entry($acronym,$namespace);  # Bool
  $acronym_list->get_entry($acronym,$namespace);  # SML::Definition
  $acronym_list->get_entry_list;                  # ArrayRef

=head1 DESCRIPTION

An acronym list is a list of acronym definitions (L<SML::Definition>
objects) used in a special subject, field, or area of usage.  The
acronym list may contain multiple alternative definitions of the same
acronym in different namespaces.

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

sub add_entry {

  my $self       = shift;
  my $definition = shift;

  # validate input
  unless ( ref $definition and $definition->isa('SML::Definition') )
    {
      $logger->error("NOT A DEFINITION \'$definition\'");
      return 0;
    }

  my $href      = $self->_get_entry_hash;
  my $term      = $definition->get_term;
  my $namespace = $definition->get_namespace || q{};

  $href->{$term}{$namespace} = $definition;

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

=head2 add_entry

Add a new entry (an L<SML::Definition>) to the acronym list.  Return 1
if successful.

  my $result = $acronym_list->add_entry($definition);

=cut

######################################################################

sub has_entry {

  my $self      = shift;
  my $acronym   = shift;
  my $namespace = shift || q{};

  unless ( $acronym )
    {
      $logger->error("CAN'T CHECK FOR ENTRY, MISSING ARGUMENTS");
      return 0;
    }

  my $href = $self->_get_entry_hash;

  if ( defined $href->{$acronym}{$namespace} )
    {
      return 1;
    }

  return 0;
}

=head2 has_entry

Return 1 if the acronym list has the specified acronym in the
specified (optional) namespace.

  my $result = $acronym_list->has_entry($acronym,$namespace);

=cut

######################################################################

sub get_entry {

  my $self      = shift;
  my $acronym   = shift;
  my $namespace = shift || q{};

  my $href = $self->_get_entry_hash;

  unless ( defined $href->{$acronym}{$namespace} )
    {
      $logger->warn("FAILED ACRONYM LOOKUP $acronym {$namespace}");
      return 0;
    }

  return $href->{$acronym}{$namespace};
}

=head2 get_entry

Return the acronym list entry (an L<SML::Definition>) for the
specified acronym and namespace.

  my $definition = $acronym_list->get_entry($acronym,$namespace);

=cut

######################################################################

sub get_entry_list {

  my $self = shift;

  my $href = $self->_get_entry_hash;
  my $aref = [];                        # acronym list

  foreach my $acronym ( sort keys %{ $href } )
    {
      foreach my $namespace ( sort keys %{ $href->{$acronym} } )
	{
	  push @{ $aref }, $href->{$acronym}{$namespace};
	}
    }

  return $aref;
}

=head2 get_entry_list

Return an ArrayRef to an alphabetically sorted list of all acronyms.

 my $list = $acronym_list->get_entry_list;

=cut

######################################################################

sub get_entry_count {

  # Return a count of the number of entries in the glossary.

  my $self = shift;

  return scalar @{ $self->get_entry_list };
}

=head2 get_entry_count

Return an integer count of the number of entries in the acronym list.

  my $count = $acronym_list->get_entry_count;

=cut

######################################################################

sub contains_entries {

  my $self = shift;

  if ( scalar keys %{ $self->_get_entry_hash } > 0 )
    {
      return 1;
    }

  return 0;
}

=head2 contains_entries

Return 1 if the acronym list contains any entries.

  my $result = $acronym_list->contains_entries;

=cut

######################################################################

sub get_group_list {

  my $self = shift;

  return [ sort keys %{ $self->_get_entry_group_hash } ];
}

=head2 get_group_list

Return an ArrayRef to a list of groups in the acronym list.  The
acronym list is organized into groups of entries.  Each group is
identified by the first character of an acronym.  This means the
acronym list is typically grouped by letter of the alphabet.

  my $aref = $acronym_list->get_group_list;

=cut

######################################################################

sub get_group_entry_list {

  my $self  = shift;
  my $group = shift;

  my $group_hash = $self->_get_entry_group_hash;

  if ( not exists $group_hash->{$group} )
    {
      $logger->error("NO ACRONYM LIST GROUP \'$group\'");
      return 0;
    }

  my $entry_hash = $self->_get_entry_hash;

  my $href = {};

  foreach my $term (sort @{ $group_hash->{$group} })
    {
      foreach my $namespace ( sort keys %{ $entry_hash->{$term} } )
	{
	  my $entry = $self->get_entry($term,$namespace);

	  $href->{"$term.$namespace"} = $entry;
	}
    }

  my $aref = [];

  foreach my $term_namespace ( sort keys %{$href} )
    {
      my $entry = $href->{$term_namespace};

      push(@{$aref},$entry);
    }

  return $aref;
}

=head2 get_group_entry_list

Return an ArrayRef to a list of entries belonging to the specified
group.

  my $aref = $acronym_list->get_group_entry_list($group);

=cut

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
