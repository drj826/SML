#!/usr/bin/perl

# $Id$

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
