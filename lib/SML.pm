#!/usr/bin/perl

# $Id: SML.pm 250 2015-03-29 15:31:53Z drj826@gmail.com $

package SML;

use Moose;

use version; our $VERSION = qv('2.0.0');

use MooseX::Singleton;
use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.SML');

use SML::Syntax;
use SML::Ontology;
use SML::Util;

use Text::CSV;
use Cwd;

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has 'syntax' =>
  (
   isa     => 'HashRef',
   reader  => 'get_syntax',
   lazy    => 1,
   builder => '_build_syntax',
  );

######################################################################

has 'util' =>
  (
   isa     => 'SML::Util',
   reader  => 'get_util',
   lazy    => 1,
   builder => '_build_util',
  );

######################################################################

has 'font_size_list' =>
  (
   isa     => 'ArrayRef',
   reader  => 'get_font_size_list',
   lazy    => 1,
   builder => '_build_font_size_list',
  );

# BUG HERE -- Perhaps this should be part of SML::Formatter?

######################################################################

has 'font_weight_list' =>
  (
   isa     => 'ArrayRef',
   reader  => 'get_font_weight_list',
   lazy    => 1,
   builder => '_build_font_weight_list',
  );

# BUG HERE -- Perhaps this should be part of SML::Formatter?

######################################################################

has 'font_shape_list' =>
  (
   isa     => 'ArrayRef',
   reader  => 'get_font_shape_list',
   lazy    => 1,
   builder => '_build_font_shape_list',
  );

# BUG HERE -- Perhaps this should be part of SML::Formatter?

######################################################################

has 'font_family_list' =>
  (
   isa     => 'ArrayRef',
   reader  => 'get_font_family_list',
   lazy    => 1,
   builder => '_build_font_family_list',
  );

# BUG HERE -- Perhaps this should be part of SML::Formatter?

######################################################################

has 'background_color_list' =>
  (
   isa     => 'ArrayRef',
   reader  => 'get_background_color_list',
   lazy    => 1,
   builder => '_build_background_color_list',
  );

# BUG HERE -- Perhaps this should be part of SML::Formatter?

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_library {

  my $self = shift;
  my $id   = shift;

  if ( not $id )
    {
      $logger->error("YOU MUST SUPPLY THE ID OF THE LIBRARY YOU WANT");
      return 0;
    }

  my $hash = $self->_get_library_hash;

  if ( exists $hash->{$id} )
    {
      return $hash->{$id};
    }

  else
    {
      $logger->error("LIBRARY DOESN'T EXIST: $id");
      return 0;
    }
}

######################################################################

sub add_library {

  my $self    = shift;
  my $library = shift;

  if ( not ref $library and $library->isa('SML::Library') )
    {
      $logger->error("CAN'T ADD NON-LIBRARY OBJECT: $library");
      return 0;
    }

  my $hash = $self->_get_library_hash;
  my $id = $library->get_id;

  $hash->{$id} = $library;

  return 1;
}

######################################################################

sub has_library {

  my $self = shift;
  my $id   = shift;

  if ( not $id )
    {
      $logger->error("YOU MUST SUPPLY A LIBRARY ID");
      return 0;
    }

  my $hash = $self->_get_library_hash;

  if ( exists $hash->{$id} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub allows_insert {

  my $self = shift;
  my $name = shift;

  if (
      defined $self->_get_insert_name_hash->{$name}
      and
      $self->_get_insert_name_hash->{$name} == 1
     )
    {
      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub allows_generate {

  my $self = shift;
  my $name = shift;

  if ( defined $self->_get_generated_content_type_hash->{$name} )
    {
      return 1;
    }

  else
    {
      return 0;
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

has 'library_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_library_hash',
   default => sub {{}},
  );

# A hash of libraries keyed by library name.

######################################################################

has 'division_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_division_hash',
   lazy    => 1,
   builder => '_build_divisions',
  );

######################################################################

has 'insert_name_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_insert_name_hash',
   lazy    => 1,
   builder => '_build_insert_name_hash',
  );

######################################################################

has 'generated_content_type_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_generated_content_type_hash',
   lazy    => 1,
   builder => '_build_generated_content_type_hash',
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _build_syntax {

  my $self = shift;

  my $syn       = {};
  my $syntax    = SML::Syntax->new;
  my $metaclass = $syntax->meta;

  foreach my $attribute ( $metaclass->get_attribute_list )
    {
      $syn->{$attribute} = $syntax->$attribute;
    }

  return $syn;
}

######################################################################

sub _build_util {
  my $self = shift;
  return SML::Util->new;
}

######################################################################

sub _build_divisions {

  my $self     = shift;
  my $ontology = $self->get_ontology;

  return $ontology->divisions_by_name;
}

######################################################################

sub _build_insert_name_hash {

  my $self = shift;
  my $hash = {};

  $hash->{PREAMBLE}   = 1;
  $hash->{NARRATIVE}  = 1;
  $hash->{DEFINITION} = 1;

  return $hash;
}

######################################################################

sub _build_generated_content_type_hash {

  my $self = shift;
  my $hash = {};

  $hash->{'problem-domain-listing'}       = "not context sensitive";
  $hash->{'solution-domain-listing'}      = "not context sensitive";
  $hash->{'prioritized-problem-listing'}  = "not context sensitive";
  $hash->{'prioritized-solution-listing'} = "not context sensitive";
  $hash->{'associated-problem-listing'}   = "context sensitive";
  $hash->{'associated-solution-listing'}  = "context sensitive";

  return $hash;
}

######################################################################

sub _build_font_size_list {

  my $self = shift;

  return
    [
     'tiny', 'scriptsize', 'footnotesize', 'small', 'normalsize',
     'large', 'Large', 'LARGE', 'huge', 'Huge',
    ];
}

######################################################################

sub _build_font_weight_list {

  my $self = shift;

  return
     [
      'medium', 'bold', 'bold_extended', 'semi_bold', 'condensed',
     ];
}

######################################################################

sub _build_font_shape_list {

  my $self = shift;

  return
     [
      'normal', 'italic', 'slanted', 'smallcaps',
     ];
}

######################################################################

sub _build_font_family_list {

  my $self = shift;

  return
     [
      'roman', 'serif', 'typewriter'
     ];
}

######################################################################

sub _build_background_color_list {

  my $self = shift;

  return
     [
      'red',      'yellow',     'blue',
      'green',    'orange',     'purple',
      'white',    'litegrey',   'grey',    'darkgrey',
     ];
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML> - a singleton that represents a customizable Structured Manuscript Language.

=head1 VERSION

This documentation refers to L<SML> version 2.0.0.

=head1 SYNOPSIS

  use SML;

  my $sml      = SML->instance;

  my $syntax   = $sml->get_syntax;
  my $ontology = $sml->get_ontology;
  my $util     = $sml->get_util;
  my $fsl      = $sml->get_font_size_list;
  my $fwl      = $sml->get_font_weight_list;
  my $fshl     = $sml->get_font_shape_list;
  my $ffl      = $sml->get_font_family_list;
  my $bcl      = $sml->get_background_color_list;
  my $dnl      = $sml->get_division_name_list;
  my $rnl      = $sml->get_region_name_list;
  my $enl      = $sml->get_environment_name_list;

=head1 DESCRIPTION

Structured Manuscript Language (SML) is a minimalistic descriptive
markup language designed to be: human readable, customizable, easy to
edit, easy to automatically generate, able to express and validate
semantic relationships, and contain all information necessary to
publish professional documentation from plain text manuscripts.

=head1 METHODS

=head2 allows_insert

Return 1 if SML allows you to insert specified name. Return 0
otherwise.

=head2 allows_generate

Return 1 if SML allows you to generate specified type of generated
content. Return 0 otherwise;

=head2 get_ontology_config_filespec

Return the filespec string for the ontology configuration file.

=head2 get_syntax

Return the L<SML::Syntax> object that represents the language syntax.

=head2 get_ontology

Return the L<SML::Ontology> object that represents the language
semantics.

=head2 get_util

Return the L<SML::Util> object that performs amazing string
manipulation feats.

=head2 get_font_size_list

Return an C<ArrayRef> to a list of allowed font sizes.

=head2 get_font_weight_list

Return an C<ArrayRef> to a list of allowed font weights.

=head2 get_font_shape_list

Return an C<ArrayRef> to a list of allowed font shapes.

=head2 get_font_family_list

Return an C<ArrayRef> to a list of allowed font families.

=head2 get_background_color_list

Return an C<ArrayRef> to a list of allowed background colors.

=head2 get_division_name_list

Return an C<ArrayRef> to a list of allowed division names.

=head2 get_region_name_list

Return an C<ArrayRef> to a list of allowed region names.

=head2 get_environment_name_list

Return an C<ArrayRef> to a list of allowed environment names.

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
