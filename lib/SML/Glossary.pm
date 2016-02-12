#!/usr/bin/perl

package SML::Glossary;                  # ci-000435

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Glossary');

######################################################################

=head1 NAME

SML::Glossary - a list of terms and their definitions

=head1 SYNOPSIS

  SML::Glossary->new();

  $glossary->add_entry($definition);        # Bool
  $glossary->has_entry($term,$namespace);   # Bool
  $glossary->get_entry($term,$namespace);   # Bool
  $glossary->get_entry_list;                # ArrayRef
  $glossary->get_entry_count;               # Int
  $glossary->contains_entries;              # Bool
  $glossary->get_group_list;                # ArrayRef
  $glossary->get_group_entry_list($group);  # ArrayRef

=head1 DESCRIPTION

A glossary is a list of terms in a special subject, field, or area of
usage, with accompanying definitions.

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


  unless ( ref $definition and $definition->isa('SML::Definition') )
    {
      $logger->error("CAN'T ADD GLOSSARY ENTRY: \'$definition\' is not a definition");
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

=head2 add_entry($definition)

Add the specified entry (an C<SML::Definition>) to the glossary.
Return 1 if successful.

  my $result = $glossary->add_entry($definition);

=cut

######################################################################

sub has_entry {

  my $self      = shift;
  my $term      = shift;
  my $namespace = shift || q{};

  my $eh = $self->_get_entry_hash;

  if ( exists $eh->{$term}{$namespace} )
    {
      return 1;
    }

  return 0;
}

=head2 has_entry($term,$namespace)

Return 1 if the glossary contains an entry for the specified term and
namespace.

  my $result = $glossary->has_entry($term,$namespace);

=cut

######################################################################

sub get_entry {

  my $self      = shift;
  my $term      = shift;
  my $namespace = shift || q{};

  if ( $self->has_entry($term,$namespace) )
    {
      my $eh = $self->_get_entry_hash;

      return $eh->{$term}{$namespace};
    }

  else
    {
      $logger->error("CAN'T GET GLOSSARY ENTRY: $term {$namespace}");
      return 0;
    }
}

=head2 get_entry($term,$namespace)

Return the C<SML::Definition> for the specified term and namespace.
Throw an error if there is no definition for the specified term and
namespace.

  my $entry = $glossary->get_entry($term,$namespace);

=cut

######################################################################

sub get_entry_list {

  my $self = shift;

  my $aref = [];
  my $eh   = $self->_get_entry_hash;

  foreach my $term ( sort keys %{ $eh } )
    {
      foreach my $namespace ( sort keys %{ $eh->{$term} } )
	{
	  push @{ $aref }, $eh->{$term}{$namespace};
	}
    }

  return $aref;
}

=head2 get_entry_list

Return an ArrayRef to an alphabetized list of glossary entries.

  my $aref = $glossary->get_entry_list;

=cut

######################################################################

sub get_entry_count {

  # Return a count of the number of entries in the glossary.

  my $self = shift;

  return scalar @{ $self->get_entry_list };
}

=head2 get_entry_count

Return an integrer value of the number of entries in the glossary.

  my $count = $glossary->get_entry_count;

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

Return 1 if the glossary contains any entries.

  my $result = $glossary->contains_entries;

=cut

######################################################################

sub get_group_list {

  my $self = shift;

  return [ sort keys %{ $self->_get_entry_group_hash } ];
}

=head2 get_group_list

Return an ArrayRef to an alphabetized list of glossary entry groups.
Entries are grouped by the first character of the defined term so
basically the groups will be letters of the alphabet.

  my $aref = $glossary->get_group_list;

=cut

######################################################################

sub get_group_entry_list {

  # Return a list of entries belonging to a specified group.

  my $self  = shift;
  my $group = shift;

  my $group_hash = $self->_get_entry_group_hash;

  if ( not exists $group_hash->{$group} )
    {
      $logger->error("NO GLOSSARY GROUP \'$group\'");
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

Return an ArrayRef to a list of entries for the specified group.
Entries are grouped by the first character of the defined term so
basically this will return a group of entries for terms that all have
the same first character.

  my $aref = $glossary->get_group_entry_list($group);

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

#   $eh->{$term}{$namespace} = $definition;

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
