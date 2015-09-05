#!/usr/bin/perl

# $Id: String.pm 230 2015-03-21 17:50:52Z drj826@gmail.com $

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

has 'containing_division' =>
  (
   isa       => 'SML::Division',
   reader    => 'get_containing_division',
   lazy      => 1,
   builder   => '_build_containing_division',
  );

######################################################################

has 'containing_block' =>
  (
   isa       => 'SML::Block',
   reader    => 'get_containing_block',
   writer    => 'set_containing_block',
   clearer   => 'clear_containing_block',
   predicate => '_has_containing_block',
   required  => 0,
  );

# The block that contains this string.

after 'set_containing_block' => sub {
  my $self = shift;
  my $cd = $self->get_containing_block;
  $logger->trace("..... containing block for \'$self\' now: \'$cd\'");
};

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_location {

  my $self = shift;

  if ( $self->_has_containing_block )
    {
      my $block = $self->get_containing_block;
      return $block->get_location;
    }

  else
    {
      return 'unknown';
    }
}

######################################################################

sub get_containing_document {

  # Return the document to which this string belongs.

  my $self     = shift;
  my $block    = $self->get_containing_block;
  my $division = $block->get_containing_division;

  if ( not defined $division )
    {
      # $logger->error("DIVISION DOESN'T EXIST");
      return 0;
    }

  elsif ( $division->isa('SML::Document') )
    {
      return $division;
    }

  else
    {
      return $division->get_containing_document;
    }
}

######################################################################
######################################################################
##
## Private Attributes
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

sub _build_containing_division {

  my $self = shift;

  my $block = $self->get_containing_block;

  return $block->get_containing_division;
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
