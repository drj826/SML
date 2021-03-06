#!/usr/bin/perl

package TestPlugin1;

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

  my $library      = $self->_get_library;
  my $library_id   = $library->get_id;
  my $library_name = $library->get_name;

  my $output = << "END_OF_TEXT";
  library ID:   $library_id
  library name: $library_name
END_OF_TEXT

  return [ split(/^/m,$output) ];
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
