#!/usr/bin/perl

package IncludeAllocations;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.plugin');

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

sub render {

  my $self = shift;

  my $library  = $self->_get_library;
  my $ontology = $library->get_ontology;

  unless ( $ontology->allows_division_name('allocation') )
    {
      $logger->fatal("ONTOLOGY DOES NOT ALLOW allocations");
      return [];
    }

  my $id_list = $library->get_division_id_list_by_name('allocation');

  my $output_line_list = [];

  foreach my $id ( @{ $id_list } )
    {
      my $text = "include:: $id\n\n";

      push @{ $output_line_list }, $text;
    }

  return $output_line_list;
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has library =>
  (
   is        => 'ro',
   isa       => 'SML::Library',
   reader    => '_get_library',
   required  => 1,
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

# NONE.

no Moose;
__PACKAGE__->meta->make_immutable;
1;
