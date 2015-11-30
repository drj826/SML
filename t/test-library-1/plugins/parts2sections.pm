#!/usr/bin/perl

package parts2sections;

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
      print "FATAL parts2sections.pm NO DIVISION ID PROVIDED\n";
      return [];
    }

  my $arg_list = [ split(/\s+/,$self->_get_args) ];

  my $division_id = $arg_list->[0];

  unless ( $library->has_division_id($division_id) )
    {
      print "FATAL parts2sections.pm LIBRARY HAS NO DIVISION ID $division_id\n";
      return [];
    }

  my $output = [];

  my $text = "* include:: $division_id\n\n";

  push(@{$output},$text);

  return $output;
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

no Moose;
__PACKAGE__->meta->make_immutable;
1;
