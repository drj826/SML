#!/usr/bin/perl

# $Id$

package SML::String;

use Moose;

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

has 'name' =>
  (
   isa      => 'Str',
   reader   => 'get_name',
   default  => 'STRING',
  );

######################################################################

has 'content' =>
  (
   isa       => 'Str',
   reader    => 'get_content',
   required  => 1,
  );

######################################################################

has 'part_list' =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_part_list',
   default   => sub {[]},
  );

# The 'part_list' is the array of strings within this string.  All of
# the content of a block can be represented by an array of strings.
# Strings can contain other strings.

######################################################################

has 'containing_block' =>
  (
   isa       => 'SML::Block',
   reader    => 'get_containing_block',
   writer    => 'set_containing_block',
   clearer   => 'clear_containing_block',
   predicate => '_has_containing_block',
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

sub add_part {

  my $self = shift;
  my $part = shift;

  if (
      not
      (
       ref $part
       or
       $part->isa('SML::String')
      )
     )
    {
      $logger->error("CAN'T ADD NON-STRING PART \'$part\'");
      return 0;
    }

  push(@{$self->get_part_list},$part);

  return 1;
}

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

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;
