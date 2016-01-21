#!/usr/bin/perl

package SML::Glossary;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Glossary');

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

######################################################################

sub get_entry_list {

  my $self = shift;

  my $list = [];
  my $eh   = $self->_get_entry_hash;

  foreach my $term ( sort keys %{ $eh } )
    {
      foreach my $namespace ( sort keys %{ $eh->{$term} } )
	{
	  push @{ $list }, $eh->{$term}{$namespace};
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

  return 0;
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
      $logger->error("NO GLOSSARY GROUP \'$group\'");
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

=head1 NAME

C<SML::Glossary> - a list of terms in a special subject, field, or
area of usage, with accompanying definitions.

=head1 VERSION

This documentation refers to L<"SML::Glossary"> version 2.0.0.

=head1 SYNOPSIS

  my $gloss = SML::Glossary->new();

=head1 DESCRIPTION

A glossary is a list of terms in a special subject, field, or area of
usage, with accompanying definitions.

=head1 METHODS

=head2 add_entry

Add a glossary entry.

=head2 has_entry

Check whether a specific glossary entry exists.

=head2 get_entry

Return a specific glossary entry.

=head2 get_entry_list

Return an alphabetically sorted list of all glossary entries.

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
