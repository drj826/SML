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

has 'entry_hash' =>
  (
   isa     => 'HashRef',
   reader  => 'get_entry_hash',
   default => sub {{}},
  );

#   $eh->{$term}{$alt} = $definition;

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

  if ( $definition->isa('SML::Definition') )
    {
      my $eh   = $self->get_entry_hash;
      my $term = $definition->get_term;
      my $alt  = $definition->get_alt;

      $eh->{$term}{$alt} = $definition;

      return 1;
    }

  else
    {
      $logger->error("CAN'T ADD GLOSSARY ENTRY: \'$definition\' is not a definition");

      return 0;
    }

}

######################################################################

sub has_entry {

  my $self = shift;
  my $term = shift;
  my $alt  = shift || q{};
  my $eh   = $self->get_entry_hash;

  if ( exists $eh->{$term}{$alt} )
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

  my $self = shift;
  my $term = shift;
  my $alt  = shift || q{};

  if ( $self->has_entry($term,$alt) )
    {
      my $eh = $self->get_entry_hash;

      return $eh->{$term}{$alt};
    }

  else
    {
      $logger->error("CAN'T GET GLOSSARY ENTRY: \'$term\' \'$alt\'");
      return 0;
    }
}

######################################################################

sub get_entry_list {

  my $self = shift;
  my $list = [];
  my $eh   = $self->get_entry_hash;

  foreach my $term ( sort keys %{ $eh } )
    {
      foreach my $alt ( sort keys %{ $eh->{$term} } )
	{
	  push @{ $list }, $eh->{$term}{$alt};
	}
    }

  return $list;
}

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

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

=head2 get_entry_hash

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
