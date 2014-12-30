#!/usr/bin/perl

# $Id: Library.pm 11633 2012-12-04 23:07:21Z don.johnson $

package SML::Library; # ci-000410

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Cwd;
use Carp;
use File::Basename;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Library');

use SML;
use SML::Parser;
use SML::Reasoner;
use SML::Formatter;
use SML::Glossary;
use SML::AcronymList;
use SML::References;

######################################################################
######################################################################
##
## Attributes
##
######################################################################
######################################################################

has 'config_filename' =>
  (
   isa      => 'Str',
   reader   => 'get_config_filename',
   default  => 'library.conf',
  );

######################################################################

has 'config_filespec' =>
  (
   isa      => 'Str',
   reader   => 'get_config_filespec',
   lazy     => 1,
   builder  => '_build_config_filespec',
  );

######################################################################

has 'sml' =>
  (
   isa      => 'SML',
   reader   => 'get_sml',
   default  => sub { SML->instance },
  );

######################################################################

has 'parser' =>
  (
   isa      => 'SML::Parser',
   reader   => 'get_parser',
   lazy     => 1,
   builder  => '_build_parser',
  );

######################################################################

has 'reasoner' =>
  (
   isa      => 'SML::Reasoner',
   reader   => 'get_reasoner',
   lazy     => 1,
   builder  => '_build_reasoner',
  );

######################################################################

has 'formatter' =>
  (
   isa      => 'SML::Formatter',
   reader   => 'get_formatter',
   lazy     => 1,
   builder  => '_build_formatter',
  );

######################################################################

has 'glossary' =>
  (
   isa      => 'SML::Glossary',
   reader   => 'get_glossary',
   lazy     => 1,
   builder  => '_build_glossary',
  );

######################################################################

has 'acronym_list' =>
  (
   isa      => 'SML::AcronymList',
   reader   => 'get_acronym_list',
   lazy     => 1,
   builder  => '_build_acronym_list',
  );

######################################################################

has 'references' =>
  (
   isa      => 'SML::References',
   reader   => 'get_references',
   lazy     => 1,
   builder  => '_build_references',
  );

######################################################################

has 'lib_ontology_config_filename' =>
  (
   isa       => 'Str',
   reader    => '_get_lib_ontology_config_filename',
   writer    => '_set_lib_ontology_config_filename',
   default   => 'ontology_rules_lib.conf',
  );

######################################################################

has 'lib_ontology_config_filespec' =>
  (
   isa       => 'Str',
   reader    => '_get_lib_ontology_config_filespec',
   lazy      => 1,
   builder   => '_build_lib_ontology_config_filespec',
  );

######################################################################

has 'sml_ontology_config_filename' =>
  (
   isa       => 'Str',
   reader    => '_get_sml_ontology_config_filename',
   writer    => '_set_sml_ontology_config_filename',
   default   => 'ontology_rules_sml.conf',
  );

######################################################################

has 'sml_ontology_config_filespec' =>
  (
   isa       => 'Str',
   reader    => '_get_sml_ontology_config_filespec',
   lazy      => 1,
   builder   => '_build_sml_ontology_config_filespec',
  );

# The SML ontology configuration file contains the core rules for the
# Structured Manuscript Language.

######################################################################

has 'lib_ontology_config_filespec' =>
  (
   isa       => 'Str',
   reader    => '_get_lib_ontology_config_filespec',
   lazy      => 1,
   builder   => '_build_lib_ontology_config_filespec',
  );

# The library ontology configuration file contains the ontology rules
# for a specific library.

######################################################################

has 'title' =>
  (
   isa       => 'Str',
   reader    => 'get_title',
   writer    => '_set_title',
   clearer   => '_clear_title',
   predicate => '_has_title',
   default   => 'library',
  );

######################################################################

has 'id' =>
  (
   isa       => 'Str',
   reader    => 'get_id',
   writer    => '_set_id',
   clearer   => '_clear_id',
   predicate => '_has_id',
   default   => 'lib',
  );

######################################################################

has 'author' =>
  (
   isa       => 'Str',
   reader    => 'get_author',
   writer    => '_set_author',
   clearer   => '_clear_author',
   predicate => '_has_author',
   default   => 'unknown',
  );

######################################################################

has 'date' =>
  (
   isa       => 'Str',
   reader    => 'get_date',
   writer    => '_set_date',
   clearer   => '_clear_date',
   predicate => '_has_date',
   default   => 'unknown',
  );

######################################################################

has 'revision' =>
  (
   isa       => 'Str',
   reader    => 'get_revision',
   writer    => '_set_revision',
   clearer   => '_clear_revision',
   predicate => '_has_revision',
   default   => 'lib',
  );

######################################################################

has 'directory_name' =>
  (
   isa       => 'Str',
   reader    => 'get_directory_name',
   default   => 'library',
  );

# This is the name of the directory containing the library.

######################################################################

has 'directory_path' =>
  (
   isa       => 'Str',
   reader    => 'get_directory_path',
   writer    => '_set_directory_path',
   clearer   => '_clear_directory_path',
   predicate => '_has_directory_path',
   default   => q{.},
  );

# This is the name of the directory containing the library.

######################################################################

has 'catalog_filespec' =>
  (
   isa       => 'Str',
   reader    => 'get_catalog_filespec',
   writer    => '_set_catalog_filespec',
   clearer   => '_clear_catalog_filespec',
   predicate => '_has_catalog_filespec',
   default   => 'catalog.txt',
  );

######################################################################

has 'file_list' =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_file_list',
   default   => sub {[]},
  );

# This is a list of all files in the library.

######################################################################

has 'fragment_file_list' =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_fragment_file_list',
   default   => sub {[]},
  );

# This is a list of fragment files in the library.  A fragment file
# contains SML text designed to be re-used in multiple documents.

######################################################################

has 'reference_file_list' =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_reference_file_list',
   default   => sub {[]},
  );

# This is a list of reference files in the library.  A reference file
# is any non-SML file referenced by library documents.  Reference
# files can be used as attachments and cited as sources.

######################################################################

has 'script_file_list' =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_script_file_list',
   default   => sub {[]},
  );

# This is a list of script files in the library.  The purpose of a
# script file is to automatically generate document content at publish
# time.

######################################################################

has 'fragment_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_fragment_hash',
   writer    => 'set_fragment_hash',
   clearer   => 'clear_fragment_hash',
   predicate => 'has_fragment_hash',
   default   => sub {{}},
  );

# This is the collection of fragments in the library.  The keys of
# this hash are the fragment file names and the values are the
# fragment objects.

######################################################################

has 'document_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_document_hash',
   writer    => 'set_document_hash',
   clearer   => 'clear_document_hash',
   predicate => 'has_document_hash',
   default   => sub {{}},
  );

# This is the collection of documents in the library.  The keys of
# this hash are the document IDs and the values are the document
# objects.

######################################################################

has 'entity_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_entity_hash',
   writer    => 'set_entity_hash',
   clearer   => 'clear_entity_hash',
   predicate => 'has_entity_hash',
   default   => sub {{}},
  );

# This is the collection of entities in the library.  The keys of this
# hash are the entity IDs and the values are the entity objects.

######################################################################

has 'division_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_division_hash',
   writer    => '_set_division_hash',
   clearer   => '_clear_division_hash',
   predicate => '_has_division_hash',
   default   => sub {{}},
  );

# This is a hash of all divisions indexed by division ID.
#
#   my $division = $dh->{$id};

######################################################################

has 'property_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_property_hash',
   writer    => '_set_property_hash',
   clearer   => '_clear_property_hash',
   predicate => '_has_property_hash',
   default   => sub {{}},
  );

# Property data structure.  This is a hash of all properties indexed
# by division ID and property name.
#
#   my $property = $ph->{$division_id}{$property_name};

######################################################################

has 'variable_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_variable_hash',
   writer    => 'set_variable_hash',
   clearer   => 'clear_variable_hash',
   predicate => 'has_variable_hash',
   default   => sub {{}},
  );

#   $variable_ds->{$name}{$alt} = $definition;

######################################################################

has 'resource_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_resource_hash',
   writer    => 'set_resource_hash',
   clearer   => 'clear_resource_hash',
   predicate => 'has_resource_hash',
   default   => sub {{}},
  );

#   $resource_ds->{$filespec} = $resource;

######################################################################

has 'index_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_index_hash',
   writer    => 'set_index_hash',
   clearer   => 'clear_index_hash',
   predicate => 'has_index_hash',
   default   => sub {{}},
  );

# Index term data structure.  This is a hash of all index terms.  The
# hash keys are the indexed terms.  The hash values are anonymous
# hashes in which the key is the division ID in which the term
# appears, and the value is simply a boolean.
#
#   $ih->{$term} = { $divid_1 => 1, $divid_2 => 1, ... };

######################################################################

has 'outcome_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_outcome_hash',
   writer    => 'set_outcome_hash',
   clearer   => 'clear_outcome_hash',
   predicate => 'has_outcome_hash',
   default   => sub {{}},
  );

# Outcome Data structure.  An outcome describes the result of a test
# or audit of an entity.

# PROBLEM: This outcome data structure does not allow for more than
# one test or audit of an entity in the same day.

# PROBLEM: The semantics of outcomes and the status of entities are
# specific to the engineering domain.  Perhaps this functionality
# should be in a PLUG-IN rather than in the core code.

#   $outcome_ds->{$entity}{$date}{'status'}      = $status;
#   $outcome_ds->{$entity}{$date}{'description'} = $description;

######################################################################

has 'review_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_review_hash',
   writer    => 'set_review_hash',
   clearer   => 'clear_review_hash',
   predicate => 'has_review_hash',
   default   => sub {{}},
  );

# Review Data structure.  A review describes the result of an informal
# test or informal audit of an entity.

#   $review_ds->{$entity}{$date}{'status'}      = $status;
#   $review_ds->{$entity}{$date}{'description'} = $description;

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_fragment {

  my $self     = shift;
  my $fragment = shift;

  if ( $fragment->isa('SML::Fragment') )
    {
      my $id = $fragment->get_id;
      $self->get_fragment_hash->{$id} = $fragment;
      return 1;
    }

  else
    {
      $logger->error("CAN'T ADD FRAGMENT \'$fragment\' is not a SML::Fragment");
      return 0;
    }
}

######################################################################

sub add_entity {

  my $self   = shift;
  my $entity = shift;

  if ( $entity->isa('SML::Entity') )
    {
      my $id = $entity->get_id;
      $self->get_entity_hash->{$id} = $entity;
      return 1;
    }

  else
    {
      $logger->error("CAN'T ADD ENTITY \'$entity\' is not a SML::Entity");
      return 0;
    }
}

######################################################################

sub add_division {

  my $self     = shift;
  my $division = shift;

  if ( $division->isa('SML::Division') )
    {
      my $id = $division->get_id;
      $self->get_division_hash->{$id} = $division;
      return 1;
    }

  else
    {
      $logger->error("CAN'T ADD DIVISION \'$division\' is not a SML::Division");
      return 0;
    }

}

######################################################################

sub add_variable {

  my $self       = shift;
  my $definition = shift;

  if ( $definition->isa('SML::Definition') )
    {
      my $name = $definition->get_term;
      my $alt  = $definition->get_alt;
      $self->get_variable_hash->{$name}{$alt} = $definition;
      return 1;
    }

  else
    {
      $logger->error("CAN'T ADD VARIABLE \'$definition\' is not a SML::Definition");
      return 0;
    }
}

######################################################################

sub add_resource {

  my $self     = shift;
  my $resource = shift;

  if ( $resource->isa('SML::Resource') )
    {
      my $filespec = $resource->get_filespec;
      $self->get_resource_hash->{$filespec} = $resource;
      return 1;
    }

  else
    {
      $logger->error("CAN'T ADD RESOOURCE \'$resource\' is not a SML::Resource");
      return 0;
    }
}

######################################################################

sub add_index_term {

  my $self  = shift;
  my $term  = shift;
  my $divid = shift;

  if ( exists $self->get_index_hash->{$term} )
    {
      my $index = $self->get_index_hash->{$term};
      $index->{ $divid } = 1;
    }

  else
    {
      $self->get_index_hash->{$term} = { $divid => 1 };
    }

  return 1;
}

######################################################################

sub add_fragment_file {

  my $self     = shift;
  my $filespec = shift;

  push @{ $self->fragment_files }, $filespec;

  return 1;
}

######################################################################

sub add_reference_file {

  my $self     = shift;
  my $filespec = shift;

  push @{ $self->reference_files }, $filespec;

  return 1;
}

######################################################################

sub add_script_file {

  my $self     = shift;
  my $filespec = shift;

  push @{ $self->script_files }, $filespec;

  return 1;
}

######################################################################

sub add_outcome {

  # Add an outcome to the outcome data structure.  An outcome is a
  # SML::Element.

  my $self       = shift;
  my $outcome    = shift;
  my $outcome_ds = $self->get_outcome_hash;
  my $sml        = SML->instance;
  my $syntax     = $sml->get_syntax;
  my $util       = $sml->get_util;
  my $options    = $util->get_options;

  $_ = $outcome->get_content;

  chomp;

  if ( /$syntax->{outcome_element}/xms )
    {
      my $date        = $1;
      my $entity_id   = $2;
      my $status      = $3;
      my $description = $4;

      $outcome_ds->{$entity_id}{$date}{status}      = $status;
      $outcome_ds->{$entity_id}{$date}{description} = $description;
      $outcome_ds->{$entity_id}{$date}{outcome}     = $outcome;

      if ( $options->use_formal_status )
	{
	  $self->update_status_from_outcome($outcome);
	}

      return 1;
    }

  else
    {
      my $location = $outcome->location;
      $logger->error("CAN'T ADD OUTCOME at $location (outcome syntax error)");
      return 0;
    }
}

######################################################################

sub add_review {

  # Add an review to the review data structure.  An review is a
  # SML::Element.

  my $self      = shift;
  my $review    = shift;
  my $review_ds = $self->get_review_hash;
  my $sml       = SML->instance;
  my $syntax    = $sml->get_syntax;
  my $util      = $sml->get_util;
  my $options   = $util->get_options;

  $_ = $review->get_content;

  chomp;

  if ( /$syntax->{review_element}/xms )
    {
      my $date        = $1;
      my $entity_id   = $2;
      my $status      = $3;
      my $description = $4;

      $review_ds->{$entity_id}{$date}{status}      = $status;
      $review_ds->{$entity_id}{$date}{description} = $description;
      $review_ds->{$entity_id}{$date}{review}      = $review;

      return 1;
    }

  else
    {
      my $location = $review->location;
      $logger->error("CAN'T ADD REVIEW at $location (review syntax error)");
      return 0;
    }
}

######################################################################

sub has_fragment {

  my $self = shift;
  my $id   = shift;

  if ( exists $self->get_fragment_hash->{$id} )
    {
      return 1;
    }

  else
    {
      return 0;
    }

}

######################################################################

sub has_document {

  my $self = shift;
  my $id   = shift;

  if ( exists $self->get_document_hash->{$id} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_entity {

  my $self = shift;
  my $id   = shift;

  if ( exists $self->get_entity_hash->{$id} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_division {

  my $self = shift;
  my $id   = shift;

  if ( exists $self->get_division_hash->{$id} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_property {

  my $self = shift;
  my $id   = shift;
  my $name = shift;

  if ( exists $self->get_division_hash->{$id} )
    {
      my $division = $self->get_division_hash->{$id};

      if ( $division->has_property($name) )
	{
	  return 1;
	}
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_variable {

  my $self = shift;
  my $name = shift;
  my $alt  = shift || q{};

  if ( exists $self->get_variable_hash->{$name}{$alt} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_resource {

  my $self     = shift;
  my $filespec = shift;

  if ( exists $self->get_resource_hash->{$filespec} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_index_term {

  my $self  = shift;
  my $term  = shift;

  if ( exists $self->get_index_hash->{$term} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_outcome {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( defined $self->get_outcome_hash->{$entity_id}{$date} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_review {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( defined $self->get_review_hash->{$entity_id}{$date} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_fragment {

  my $self     = shift;
  my $filespec = shift;

  if ( exists $self->get_fragment_hash->{$filespec} )
    {
      return $self->get_fragment_hash->{$filespec};
    }

  else
    {
      $logger->error("CAN'T GET FRAGMENT \'$filespec\'");
      return 0;
    }
}

######################################################################

sub get_fragments {

  my $self = shift;
  my $list = [];

  foreach my $division ( values %{ $self->get_division_hash })
    {
      if ( $division->isa('SML::Fragment') )
	{
	  push @{ $list }, $division;
	}
    }

  return $list;
}

######################################################################

sub get_document {

  my $self = shift;
  my $id   = shift;

  foreach my $document (@{ $self->get_documents })
    {
      return $document if $document->get_id eq $id;
    }

  $logger->error("CAN'T GET DOCUMENT \'$id\'");
  return 0;
}

######################################################################

sub get_documents {

  my $self = shift;
  my $list = [];

  foreach my $division ( values %{ $self->get_division_hash })
    {
      if ( $division->isa('SML::Document') )
	{
	  push @{ $list }, $division;
	}
    }

  return $list;
}

######################################################################

sub get_entity {

  my $self = shift;
  my $id   = shift;

  if ( exists $self->get_entity_hash->{$id} )
    {
      return $self->get_entity_hash->{$id};
    }

  else
    {
      $logger->warn("ENTITY DOESN'T EXIST \'$id\'");
      return 0;
    }
}

######################################################################

sub get_division {

  my $self = shift;
  my $id   = shift;

  if ( exists $self->get_division_hash->{$id} )
    {
      return $self->get_division_hash->{$id};
    }

  else
    {
      $logger->warn("DIVISION DOESN'T EXIST \'$id\'");
      return 0;
    }
}

######################################################################

sub get_property {

  my $self = shift;
  my $id   = shift;
  my $name = shift;

  if ( exists $self->get_division_hash->{$id} )
    {
      my $division = $self->get_division_hash->{$id};

      if ( $division->has_property($name) )
	{
	  return $division->get_property($name);
	}

      else
	{
	  $logger->error("CAN'T GET PROPERTY \'$id\' entity doesn't have \'$name\' property");
	  return 0;
	}
    }

  else
    {
      $logger->error("CAN'T GET PROPERTY \'$id\' entity doesn't exist");
      return 0;
    }
}

######################################################################

sub get_variable {

  my $self = shift;
  my $name = shift;
  my $alt  = shift || q{};

  if ( exists $self->get_variable_hash->{$name}{$alt} )
    {
      return $self->get_variable_hash->{$name}{$alt};
    }

  else
    {
      $logger->error("CAN'T GET VARIABLE \'$name\' \'$alt\'");
      return 0;
    }
}

######################################################################

sub get_resource {

  my $self     = shift;
  my $filespec = shift;

  if ( exists $self->get_resource_hash->{$filespec} )
    {
      return $self->get_resource_hash->{$filespec};
    }

  else
    {
      $logger->error("CAN'T GET RESOURCE \'$filespec\'");
      return 0;
    }
}

######################################################################

sub get_index_term {

  my $self  = shift;
  my $term  = shift;

  if ( exists $self->get_index_hash->{$term} )
    {
      return $self->get_index_hash->{$term};
    }

  else
    {
      $logger->error("CAN'T GET INDEX TERM \'$term\'");
      return 0;
    }
}

######################################################################

sub get_property_value {

  my $self = shift;
  my $id   = shift;
  my $name = shift;

  if ( $self->has_division($id) )
    {
      my $division = $self->get_division($id);

      if ( $division->has_property($name) )
	{
	  my $property = $division->get_property($name);
	  return $property->get_value;
	}

      else
	{
	  $logger->error("CAN'T GET PROPERTY VALUE \'$id\' has no \'$name\' property");
	  return 0;
	}
    }

  else
    {
      $logger->error("CAN'T GET PROPERTY VALUE \'$id\' division not found");
      return 0;
    }

}

######################################################################

sub get_variable_value {

  my $self = shift;
  my $name = shift;
  my $alt  = shift || q{};

  if ( exists $self->get_variable_hash->{$name}{$alt} )
    {
      my $definition = $self->get_variable_hash->{$name}{$alt};
      return $definition->get_value;
    }

  else
    {
      $logger->error("CAN'T GET VARIABLE VALUE \'$name\' \'$alt\' not defined");
      return 0;
    }
}

######################################################################

sub get_preamble_line_list {

  my $self     = shift;
  my $id       = shift;
  my $division = $self->get_division($id);

  if ( $division->isa('SML::Division') )
    {
      return $division->get_preamble_line_list;
    }

  else
    {
      $logger->error("CAN'T GET PREAMBLE LINES \'$id\' is not a division ID");
      return 0;
    }
}

######################################################################

sub get_narrative_line_list {

  my $self     = shift;
  my $id       = shift;
  my $division = $self->get_division($id);

  if ( $division->isa('SML::Division') )
    {
      return $division->get_narrative_line_list;
    }

  else
    {
      $logger->error("CAN'T GET NARRATIVE LINES \'$id\' is not a division ID");
      return 0;
    }

}

######################################################################

sub get_type {

  # Return the type of a value (object name, STRING, or BOOLEAN)

  my $self  = shift;
  my $value = shift;
  my $name  = q{};

  if ( defined $self->get_division_hash->{$value} )
    {
      my $division = $self->get_division_hash->{$value};
      return $division->get_name;
    }

  elsif ( $value eq '0' or $value eq '1' )
    {
      return 'BOOLEAN';
    }

  else
    {
      return 'STRING';
    }
}

######################################################################

sub get_outcome {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( exists $self->get_outcome_hash->{$entity_id}{$date}{outcome} )
    {
      return $self->get_outcome_hash->{$entity_id}{$date}{outcome};
    }

  else
    {
      $logger->("OUTCOME DOESN'T EXIST \'$entity_id\' \'$date\'");
      return 0;
    }
}

######################################################################

sub get_review {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( exists $self->get_review_hash->{$entity_id}{$date}{review} )
    {
      return $self->get_review_hash->{$entity_id}{$date}{review};
    }

  else
    {
      $logger->("REVIEW DOESN'T EXIST \'$entity_id\' \'$date\'");
      return 0;
    }
}

######################################################################

sub get_outcome_entity_id_list {

  # Return a list of entities for which there are outcome elements.

  my $self = shift;
  my $oel  = []; # outcome entity list

  foreach my $entity_id ( keys %{ $self->get_outcome_hash } )
    {
      push @{ $oel }, $entity_id;
    }

  return $oel;
}

######################################################################

sub get_review_entity_id_list {

  # Return a list of entities for which there are review elements.

  my $self = shift;
  my $rel  = []; # review entity list

  foreach my $entity_id ( keys %{ $self->get_review_hash } )
    {
      push @{ $rel }, $entity_id;
    }

  return $rel;
}

######################################################################

sub get_outcome_date_list {

  # Return a list of dates for which there are outcome elements for a
  # specified entity.

  my $self      = shift;
  my $entity_id = shift;
  my $dates     = [];

  if ( exists $self->get_outcome_hash->{$entity_id} )
    {
      foreach my $date ( sort by_date keys %{ $self->get_outcome_hash->{$entity_id} } )
	{
	  push @{ $dates }, $date;
	}

      return $dates;
    }

  else
    {
      $logger->error("CAN'T GET OUTCOME DATE LIST no outcomes for \'$entity_id\'");
    }

  return $dates;
}

######################################################################

sub get_review_date_list {

  # Return a list of dates for which there are review elements for a
  # specified entity.

  my $self      = shift;
  my $entity_id = shift;
  my $dates     = [];

  if ( exists $self->get_review_hash->{$entity_id} )
    {
      foreach my $date ( sort by_date keys %{ $self->get_review_hash->{$entity_id} } )
	{
	  push @{ $dates }, $date;
	}

      return $dates;
    }

  else
    {
      $logger->error("CAN'T GET REVIEW DATE LIST no reviews for \'$entity_id\'");
    }

  return $dates;
}

######################################################################

sub get_outcome_status {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( defined $self->get_outcome_hash->{$entity_id}{$date}{status} )
    {
      return $self->get_outcome_hash->{$entity_id}{$date}{status};
    }

  else
    {
      $logger->error("CAN'T GET OUTCOME STATUS \'$entity_id\' \'$date\'");
      return 0;
    }
}

######################################################################

sub get_review_status {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( defined $self->get_review_hash->{$entity_id}{$date}{status} )
    {
      return $self->get_review_hash->{$entity_id}{$date}{status};
    }

  else
    {
      $logger->error("CAN'T GET REVIEW STATUS \'$entity_id\' \'$date\'");
      return 0;
    }
}

######################################################################

sub get_outcome_description {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( defined $self->get_outcome_hash->{$entity_id}{$date}{description} )
    {
      return $self->get_outcome_hash->{$entity_id}{$date}{description};
    }

  else
    {
      $logger->error("CAN'T GET OUTCOME DESCRIPTION \'$entity_id\' \'$date\'");
      return 0;
    }
}

######################################################################

sub get_review_description {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( defined $self->get_review_hash->{$entity_id}{$date}{description} )
    {
      return $self->get_review_hash->{$entity_id}{$date}{description};
    }

  else
    {
      $logger->error("CAN'T GET REVIEW DESCRIPTION \'$entity_id\' \'$date\'");
      return 0;
    }
}

######################################################################

sub summarize_content {

  # Return a summary of the library's content.

  my $self    = shift;
  my $summary = "\n";

  $summary .= $self->summarize_entities;
  $summary .= $self->summarize_fragments;
  $summary .= $self->summarize_divisions;
  $summary .= $self->summarize_glossary;
  $summary .= $self->summarize_acronyms;
  $summary .= $self->summarize_variables;
  $summary .= $self->summarize_resources;
  $summary .= $self->summarize_index;
  $summary .= $self->summarize_sources;
  $summary .= $self->summarize_outcomes;
  $summary .= $self->summarize_reviews;

  return $summary;
}

######################################################################

sub summarize_entities {

  # Return a summary of the library's entities.

  my $self    = shift;
  my $summary = q{};

  if ( keys %{ $self->get_entity_hash } )
    {
      $summary .= "Entities:\n\n";

      foreach my $entity (sort by_division_name_and_id values %{ $self->get_entity_hash })
	{
	  my $id      = $entity->get_id;
	  my $entname = $entity->get_name;

	  $summary .= "  $entname: $id";

	  my $properties = [];
	  foreach my $property (@{ $entity->get_property_list })
	    {
	      my $propname = $property->get_name;
	      push @{ $properties }, $propname;
	    }

	  if ( scalar @{ $properties } )
	    {
	      $summary .= ' (' . join(', ', @{ $properties}) . ')';
	    }

	  $summary .= "\n";
	}
    }

  return $summary;
}

######################################################################

sub summarize_fragments {

  # Return a summary of the library's fragments.

  my $self    = shift;
  my $summary = q{};

  if ( keys %{ $self->get_fragment_hash } )
    {
      $summary .= "\nFragments:\n\n";

      foreach my $fragment_id (sort keys %{ $self->get_fragment_hash })
	{
	  $summary .= "  $fragment_id\n";
	}
    }

  return $summary;
}

######################################################################

sub summarize_divisions {

  # Return a summary of the library's divisions.
  #
  # - Don't include divisions of type: BARETABLE, COMMENT, REVISIONS,
  #   TABLECELL, or TABLEROW.
  #
  # - Don't include entities

  my $self    = shift;
  my $summary = q{};

  my $ignore =
    {
     BARETABLE => 1,
     COMMENT   => 1,
     REVISIONS => 1,
     TABLECELL => 1,
     TABLEROW  => 1,
    };

  if ( keys %{ $self->get_division_hash } )
    {
      $summary .= "\nDivisions:\n\n";

      foreach my $division (sort by_division_name_and_id values %{ $self->get_division_hash })
	{
	  my $id      = $division->get_id;
	  my $divname = $division->get_name;

	  if ( $ignore->{$divname} )
	    {
	      next;
	    }

	  if ( $division->isa('SML::Entity') )
	    {
	      next;
	    }

	  $summary .= "  $divname: $id";

	  my $properties = [];
	  foreach my $property (@{ $division->get_property_list })
	    {
	      my $propname = $property->get_name;
	      push @{ $properties }, $propname;
	    }

	  if ( scalar @{ $properties } )
	    {
	      $summary .= ' (' . join(', ', @{ $properties}) . ')';
	    }

	  $summary .= "\n";
	}
    }

  return $summary;
}

######################################################################

sub summarize_glossary {

  my $self    = shift;
  my $summary = q{};

  if (@{ $self->get_glossary->get_entry_list })
    {
      $summary .= "\nGlossary Entries:\n\n";

      foreach my $definition (@{ $self->get_glossary->get_entry_list })
	{
	  my $term = $definition->get_term;
	  my $alt  = $definition->get_alt;
	  $summary .= "  $term";
	  if ($alt) {
	    $summary .= " [$alt]";
	  }
	  $summary .= "\n";
	}
    }

  return $summary;
}

######################################################################

sub summarize_acronyms {

  my $self    = shift;
  my $summary = q{};

  if (@{ $self->get_acronym_list->get_acronym_list })
    {
      $summary .= "\nAcronyms:\n\n";

      foreach my $definition (@{ $self->get_acronym_list->get_acronym_list })
	{
	  my $acronym = $definition->get_term;
	  my $alt     = $definition->get_alt;
	  $summary .= "  $acronym";
	  if ($alt) {
	    $summary .= " [$alt]";
	  }
	  $summary .= "\n";
	}
    }

  return $summary;
}

######################################################################

sub summarize_variables {

  my $self    = shift;
  my $summary = q{};

  if (keys %{ $self->get_variable_hash })
    {
      $summary .= "\nVariables:\n\n";

      foreach my $name (sort keys %{ $self->get_variable_hash })
	{
	  foreach my $alt ( sort keys %{ $self->get_variable_hash->{$name} } )
	    {
	      $summary .= "  $name \[$alt\]\n";
	    }
	}
    }

  return $summary;
}

######################################################################

sub summarize_resources {

  my $self    = shift;
  my $summary = q{};

  if (keys %{ $self->get_resource_hash })
    {
      $summary .= "\nResources:\n\n";

      foreach my $filespec (sort keys %{ $self->get_resource_hash })
	{
	  $summary .= "  $filespec\n";
	}
    }

  return $summary;
}

######################################################################

sub summarize_index {

  my $self    = shift;
  my $summary = q{};

  if (keys %{ $self->get_index_hash })
    {
      $summary .= "\nIndexed Terms:\n\n";

      foreach my $term (sort keys %{ $self->get_index_hash })
	{
	  my $index     = $self->get_index_hash->{$term};
	  my $locations = join(', ', sort keys %{$index});

	  $summary .= "  $term => $locations\n";
	}
    }

  return $summary;
}

######################################################################

sub summarize_sources {

  my $self    = shift;
  my $summary = q{};

  if ( $self->get_references->has_sources )
    {
      $summary .= "\nSource References:\n\n";

      foreach my $source ( values %{ $self->get_references->get_sources })
	{
	  my $id    = $source->get_id;
	  my $title = $source->get_property_value('title');

	  $summary .= "  $id => $title\n";
	}
    }

  return $summary;
}

######################################################################

sub summarize_outcomes {

  my $self    = shift;
  my $summary = q{};

  if ( keys %{ $self->get_outcome_hash } )
    {
      $summary .= "\nTest Outcomes:\n\n";

      foreach my $entity (sort keys %{ $self->get_outcome_hash })
	{
	  foreach my $date (sort keys %{ $self->get_outcome_hash->{$entity} })
	    {
	      my $status = $self->get_outcome_hash->{$entity}{$date}{status};

	      $summary .= "  $entity $date => $status\n";
	    }
	}
    }

  return $summary;
}

######################################################################

sub summarize_reviews {

  my $self    = shift;
  my $summary = q{};

  if ( keys %{ $self->get_review_hash } )
    {
      $summary .= "\nReview Results:\n\n";

      foreach my $entity (sort keys %{ $self->get_review_hash })
	{
	  foreach my $date (sort keys %{ $self->get_review_hash->{$entity} })
	    {
	      my $status = $self->get_review_hash->{$entity}{$date}{status};

	      $summary .= "  $entity $date => $status\n";
	    }
	}
    }

  return $summary;
}

######################################################################

sub replace_division_id {

  # THIS IS A HACK.  I should change the syntax of the division start
  # markup to include the ID so this isn't necessary.  That way the
  # library can remember the correct division ID at the start of the
  # division.

  my $self     = shift;
  my $division = shift;
  my $id       = shift;

  foreach my $stored_id (keys %{ $self->get_division_hash })
    {
      my $stored_division = $self->get_division_hash->{$stored_id};
      if ( $stored_division == $division )
	{
	  delete $self->get_division_hash->{$stored_id};
	  $self->get_division_hash->{$id} = $division;
	}
    }

  if ( $division->isa('SML::Source') )
    {
      $self->get_references->replace_division_id($division,$id);
    }

  return 1;
}

######################################################################

sub update_status_from_outcome {

  # Update the status of an entity based on an outcome.

  my $self    = shift;
  my $outcome = shift;
  my $sml     = SML->instance;
  my $syntax  = $sml->get_syntax;
  my $util    = $sml->get_util;

  $_ = $outcome->get_content;

  chomp;

  if ( /$syntax->{outcome_element}/xms )
    {
      my $date        = $1;
      my $entity_id   = $2;
      my $status      = $3;
      my $description = $4;

      if ( $self->has_division($entity_id) )
	{
	  my $entity = $self->get_division($entity_id);
	  my $status_property = undef;

	  if ( $entity->has_property('status') )
	    {
	      $status_property = $entity->get_property('status');
	    }

	  else
	    {
	      $status_property = SML::Property->new(id=>$entity_id,name=>'status');
	    }

	  $status_property->add_element($outcome);

	  return 1;
	}

      else
	{
	  my $location = $outcome->location;
	  $logger->error("CAN'T UPDATE STATUS FROM OUTCOME ON NON-EXISTENT ENTITY at $location ($entity_id)");
	  return 0;
	}
    }

  else
    {
      my $location = $outcome->location;
      $logger->error("OUTCOME SYNTAX ERROR at $location ($_)");
      return 0;
    }

}

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub BUILD {

  my $self = shift;

  my $config_filespec = $self->get_config_filespec;
  my $sml             = SML->instance;
  my $syntax          = $sml->get_syntax;
  my $ontology        = $sml->get_ontology;
  my %config          = ();
  my $directory_path  = q{};
  my $catalog_file    = q{};
  my $current_dir     = getcwd;
  my $library_dir     = dirname($config_filespec);

  use Config::General;
  use SML::Parser;

  #-------------------------------------------------------------------
  # read the config file
  #
  if ( not -f $config_filespec )
    {
      die "Couldn't read $config_filespec\n";
    }

  else
    {
      my $config = Config::General->new($config_filespec);
      %config = $config->getall;
    }

  #-------------------------------------------------------------------
  # determine the library directory path
  #
  #     Assume the config file is in the library directory.
  #
  if ( $library_dir )
    {
      $self->_set_directory_path( $library_dir );
    }

  else
    {
      $logger->error("no such library directory: $library_dir");
    }

  #-------------------------------------------------------------------
  # determine the catalog file
  #
  if ( $config{'catalog_file'} )
    {
      if ( -r "$library_dir/$config{'catalog_file'}" )
	{
	  $catalog_file = "$library_dir/$config{'catalog_file'}";
	  $self->_set_catalog_filespec( $catalog_file );
	}

      else
	{
	  $logger->error("catalog not readable: $catalog_file from $current_dir");
	}
    }

  else
    {
      $logger->error("config file lacks \'catalog_file\'");
    }

  #-------------------------------------------------------------------
  # add SML ontology rules
  #
  if ( $config{'sml_ontology_config_file'} )
    {
      my $filename = "$config{'sml_ontology_config_file'}";
      $self->_set_sml_ontology_config_filename($filename);
    }

  my $sml_ontology_config_filespec = $self->_get_sml_ontology_config_filespec;
  $ontology->add_rules($sml_ontology_config_filespec);

  $logger->debug("added ontology rules from $sml_ontology_config_filespec");

  #-------------------------------------------------------------------
  # add LIB ontology rules
  #
  if ( $config{'lib_ontology_config_file'} )
    {
      my $filename = "$config{'lib_ontology_config_file'}";
      $self->_set_lib_ontology_config_filename($filename);
    }

  my $lib_ontology_config_filespec = $self->_get_lib_ontology_config_filespec;
  $ontology->add_rules($lib_ontology_config_filespec);

  $logger->debug("added ontology rules from $lib_ontology_config_filespec");

  #-------------------------------------------------------------------
  # read the catalog file
  #
  if (-f $catalog_file)
    {
      open my $catalog, '<', $catalog_file or croak("Couldn't open $catalog_file");
      my @catalog_lines = <$catalog>;
      close $catalog or croak("Couldn't close $catalog_file");

      for (@catalog_lines)
	{
	  if    (/$syntax->{'comment_line'}/xms)           { next                          }
	  elsif (/$syntax->{'title_element'}/xms)          { $self->_set_title($1)         }
	  elsif (/$syntax->{'id_element'}/xms)             { $self->_set_id($2)            }
	  elsif (/$syntax->{'author_element'}/xms)         { $self->_set_author($1)        }
	  elsif (/$syntax->{'date_element'}/xms)           { $self->_set_date($1)          }
	  elsif (/$syntax->{'revision_element'}/xms)       { $self->_set_revision($1)      }
	  elsif (/$syntax->{'fragment_file_element'}/xms)  { $self->add_fragment_file($1)  }
	  elsif (/$syntax->{'reference_file_element'}/xms) { $self->add_reference_file($1) }
	  elsif (/$syntax->{'script_file_element'}/xms)    { $self->add_script_file($1)    }
	}
    }

  #-------------------------------------------------------------------
  # Teach util about library
  #
  my $util = $sml->get_util;
  $util->set_library($self);

  return 1;
}

######################################################################

sub _build_config_filespec {

  # Find the configuration file by looking for it in a list of
  # directories.

  use FindBin qw($Bin);

  my $self = shift;

  my $directory_name = $self->get_directory_name;
  my $filename       = $self->get_config_filename;

  my $dir_list =
    [
     "$Bin/$directory_name",
     "$Bin/../$directory_name",
     "$Bin/../../$directory_name",
    ];

  foreach my $dir (@{ $dir_list })
    {
      if ( -r "$dir/$filename" )
	{
	  $logger->info("library config filespec: $dir/$filename");
	  return "$dir/$filename";
	}
    }

  $logger->error("COULD NOT LOCATE LIBRARY CONFIG FILE");
  return 0;
}

######################################################################

sub _build_sml_ontology_config_filespec {

  use FindBin qw($Bin);

  my $self = shift;

  my $directory_name = $self->get_directory_name;
  my $filename       = $self->_get_sml_ontology_config_filename;

  my $dir_list =
    [
     "$Bin/$directory_name",
     "$Bin/../$directory_name",
     "$Bin/../../$directory_name",
    ];

  foreach my $dir (@{ $dir_list })
    {
      if ( -r "$dir/$filename" )
	{
	  $logger->info("SML ontology config filespec: $dir/$filename");
	  return "$dir/$filename";
	}
    }

  $logger->error("COULD NOT LOCATE SML ONTOLOGY CONFIG FILE");
  return 0;
}

######################################################################

sub _build_lib_ontology_config_filespec {

  use FindBin qw($Bin);

  my $self = shift;

  my $filename = $self->_get_lib_ontology_config_filename;

  my $dir_list =
    [
     "$Bin/library",
     "$Bin/../library",
     "$Bin/../../library",
    ];

  foreach my $dir (@{ $dir_list })
    {
      if ( -r "$dir/$filename" )
	{
	  $logger->info("library ontology config filespec: $dir/$filename");
	  return "$dir/$filename";
	}
    }

  $logger->error("COULD NOT LOCATE LIBRARY ONTOLOGY CONFIG FILE");
  return 0;
}

######################################################################

sub _build_parser {
  my $self = shift;
  return SML::Parser->new(library=>$self);
}

######################################################################

sub _build_reasoner {
  my $self = shift;
  return SML::Reasoner->new(library=>$self);
}

######################################################################

sub _build_formatter {
  my $self = shift;
  return SML::Formatter->new(library=>$self);
}

######################################################################

sub _build_glossary {
  my $self = shift;
  return SML::Glossary->new;
}

######################################################################

sub _build_acronym_list {
  my $self = shift;
  return SML::AcronymList->new;
}

######################################################################

sub _build_references {
  my $self = shift;
  return SML::References->new;
}

######################################################################

sub by_division_name_and_id {

  # sort method

  return $a->get_name cmp $b->get_name || $a->get_id cmp $b->get_id;
}

######################################################################

sub by_date {

  # sort routine

  my ($a_yr,$a_mo,$a_dy,$b_yr,$b_mo,$b_dy);

  if ( $a =~ /^(\d\d\d\d)-(\d\d)-(\d\d)$/xms )
    {
      $a_yr = $1;
      $a_mo = $2;
      $a_dy = $3;
    }

  else
    {
      $logger->error("INVALID DATE \'$a\'");
    }

  if ( $b =~ /^(\d\d\d\d)-(\d\d)-(\d\d)$/xms )
    {
      $b_yr = $1;
      $b_mo = $2;
      $b_dy = $3;
    }

  else
    {
      $logger->error("INVALID DATE \'$b\'");
    }

  return $a_yr <=> $b_yr || $a_mo <=> $b_mo || $a_dy <=> $b_dy;

}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Library> - a collection of related L<"SML::Document">s and
reusable L<"SML::Fragment">s.

=head1 VERSION

This documentation refers to L<"SML::Library"> version 2.0.0.

=head1 SYNOPSIS

  my $lib = SML::Library->new();

=head1 DESCRIPTION

A library is A collection of related SML documents and reusable
document fragments.

=head1 METHODS

=head2 get_config_filespec

=head2 get_sml

=head2 get_parser

=head2 get_reasoner

=head2 get_glossary

=head2 get_acronym_list

=head2 get_references

=head2 get_sml_ontology_config_filespec

=head2 get_lib_ontology_config_filespec

=head2 get_title

=head2 get_id

=head2 get_author

=head2 get_date

=head2 get_revision

=head2 get_directory_path

=head2 get_catalog_filespec

=head2 get_file_list

=head2 get_fragment_file_list

=head2 get_reference_file_list

=head2 get_script_file_list

=head2 get_fragment_hash

=head2 get_document_hash

=head2 get_entity_hash

=head2 get_division_hash

=head2 get_property_hash

=head2 get_variable_hash

=head2 get_resource_hash

=head2 get_index_hash

=head2 get_outcome_hash

=head2 get_review_hash

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
