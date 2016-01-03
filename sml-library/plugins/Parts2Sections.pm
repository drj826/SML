#!/usr/bin/perl

package Parts2Sections;

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

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub render {

  my $self = shift;

  my $library = $self->_get_library;

  unless ( $self->_has_args )
    {
      print "FATAL Parts2Sections.pm NO DIVISION ID PROVIDED\n";
      return [];
    }

  my $arg_list = [ split(/\s+/,$self->_get_args) ];

  my $division_id = $arg_list->[0];

  unless ( $library->has_division_id($division_id) )
    {
      print "FATAL Parts2Sections.pm LIBRARY HAS NO DIVISION ID $division_id\n";
      return [];
    }

  my $division = $library->get_division($division_id);
  my $name     = $division->get_name;
  my $id_list  = $library->get_division_id_list_by_name($name);

  foreach my $id ( sort @{ $id_list } )
    {
      $library->get_division($id);
    }

  my $output_line_list = [];

  my $text = "* include:: $division_id\n\n";

  push(@{ $output_line_list }, $text);

  my $part_id_list = $library->get_property_value_list($division_id,'has_part');
  my $depth        = 2;

  foreach my $part_id (@{ $part_id_list })
    {
      if ( $part_id )
	{
	  $self->_render_subsection_include_element
	    (
	     $output_line_list,
	     $depth,
	     $part_id,
	    );
	}
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

has document =>
  (
   is        => 'ro',
   isa       => 'Maybe[SML::Document]',
   reader    => '_get_document',
   predicate => '_has_document',
  );

######################################################################

has args =>
  (
   is        => 'ro',
   isa       => 'Maybe[Str]',
   reader    => '_get_args',
   predicate => '_has_args',
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _render_subsection_include_element {

  my $self             = shift;
  my $output_line_list = shift;
  my $depth            = shift;
  my $division_id      = shift;

  my $asterisks = q{};

  $asterisks .= '*' until length $asterisks == $depth;

  my $text = "$asterisks include:: $division_id\n\n";

  push(@{ $output_line_list }, $text);

  my $library  = $self->_get_library;
  my $division = $library->get_division($division_id);

  if ( $library->has_property($division_id,'has_part') )
    {
      $depth = $depth + 1;

      my $part_id_list = $library->get_property_value_list($division_id,'has_part');

      foreach my $part_id (@{ $part_id_list })
	{
	  $self->_render_subsection_include_element
	    (
	     $output_line_list,
	     $depth,
	     $part_id,
	    );
	}
    }
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;
