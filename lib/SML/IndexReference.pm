#!/usr/bin/perl

# $Id$

package SML::IndexReference;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.IndexReference');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has 'tag' =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_tag',
   required => 1,
  );

######################################################################

has 'entry' =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_entry',
   required => 1,
  );

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'index_ref',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

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