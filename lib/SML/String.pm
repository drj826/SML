#!/usr/bin/perl

package SML::String;

use Moose;

extends 'SML::Part';

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.String');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default  => 'STRING',
  );

######################################################################

has '+content' =>
  (
   required  => 1,
  );

######################################################################

has remaining =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_remaining',
   writer  => 'set_remaining',
   default => q{},
  );

# This is text remaining to be parsed into string objects.

######################################################################

has containing_division =>
  (
   is       => 'ro',
   isa      => 'SML::Division',
   reader   => 'get_containing_division',
   lazy     => 1,
   builder  => '_build_containing_division',
  );

######################################################################

has containing_block =>
  (
   is       => 'ro',
   isa      => 'SML::Block',
   reader   => 'get_containing_block',
   builder  => '_build_containing_block',
   lazy     => 1,
  );

######################################################################

has plain_text =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_plain_text',
   builder => '_build_plain_text',
   lazy    => 1,
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_location {

  my $self = shift;

  if ( $self->get_containing_block )
    {
      my $block = $self->get_containing_block;
      return $block->get_location;
    }

  return 'unknown';
}

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

sub BUILD {

  my $self = shift;

  if ( $self->has_content )
    {
      $self->set_remaining( $self->get_content );
    }

  return 1;
}

######################################################################

sub _build_containing_division {

  my $self = shift;

  my $block = $self->get_containing_block;

  return $block->get_containing_division;
}

######################################################################

sub _build_containing_block {

  my $self = shift;

  if ( not $self->has_container )
    {
      $logger->error("STRING HAS NO CONTAINER \'$self\'");
      return 0;
    }

  my $container = $self->get_container;

  if ( $container->isa('SML::Block') )
    {
      return $container;
    }

  while ( $container->has_container )
    {
      $container = $container->get_container;

      if ( $container->isa('SML::Block') )
	{
	  return $container;
	}
    }

  $logger->error("THIS SHOULD NEVER HAPPEN");
  return 0;
}

######################################################################

sub _build_plain_text {

  my $self = shift;

  if ( $self->contains_parts )
    {
      my $aref = [];

      foreach my $part (@{ $self->get_part_list })
	{
	  push @{$aref}, $part->get_plain_text;
	}

      return join(' ', @{$aref});
    }

  else
    {
      return $self->get_content;
    }

}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::String> - a C<SML::Part> of a document that is a sequence of
characters.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Part

  my $string = SML::String->new
                 (
                   name            => $name,
                   content         => $content,
                   library         => $library,
                   containing_part => $part,
                 );

  my $division = $string->get_containing_division;
  my $block    = $string->get_containing_block;

=head1 DESCRIPTION

A C<SML::Part> of a document that is a sequence of characters.

=head1 METHODS

=head2 get_containing_division

=head2 get_containing_block

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
