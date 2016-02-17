#!/usr/bin/perl

package SML::Library;                   # ci-000410

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Cwd;                                # current working directory
use Carp;                               # error reporting
use File::Basename;                     # determine file basename
use File::Slurp;                        # slurp a file into a string
use Time::Duration;                     # measure how long it takes

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Library');

use SML::Syntax;                        # ci-000433
use SML::Ontology;                      # ci-000437
use SML::Parser;                        # ci-000003
use SML::Reasoner;                      # ci-000380
use SML::Glossary;                      # ci-000435
use SML::AcronymList;                   # ci-000439
use SML::References;                    # ci-000463
use SML::Publisher;                     # ci-000462
use SML::Util;                          # ci-000383
use SML::Error;                         # ci-000446
use SML::PropertyStore;                 # ci-000473

######################################################################

=head1 NAME

SML::Library - a collection of related documents

=head1 SYNOPSIS

  SML::Library->new(config_filename=>'library.conf');

  $library->get_id;                               # Str
  $library->get_name;                             # Str
  $library->get_version;                          # Str
  $library->has_version;                          # Bool
  $library->get_previous_version;                 # Str
  $library->has_previous_version;                 # Bool
  $library->get_syntax;                           # SML::Syntax
  $library->get_ontology_rule_filespec_list;      # ArrayRef
  $library->get_directory_path;                   # Str
  $library->get_include_path_list;                # ArrayRef
  $library->get_template_dir;                     # Str
  $library->get_published_dir;                    # Str
  $library->get_plugins_dir;                      # Str
  $library->get_images_dir;                       # Str
  $library->get_images_list;                      # ArrayRef
  $library->get_document_presentation_id_list;    # ArrayRef
  $library->get_change_list;                      # ArrayRef
  $library->get_add_count;                        # Int
  $library->get_delete_count;                     # Int
  $library->get_update_count;                     # Int
  $library->get_options;                          # SML::Options
  $library->get_util;                             # SML::Util
  $library->get_ontology;                         # SML::Ontology
  $library->get_reasoner;                         # SML::Reasoner
  $library->get_publisher;                        # SML::Publisher
  $library->get_glossary;                         # SML::Glossary
  $library->get_acronym_list;                     # SML::AcronymList
  $library->get_references;                       # SML::References
  $library->get_index;                            # SML::Index
  $library->get_property_store;                   # SML::PropertyStore

  $library->get_parser;                           # SML::Parser
  $library->get_file_containing_id;               # SML::File
  $library->has_filespec($filespec);              # Bool
  $library->get_filespec($filename);              # Str
  $library->add_file($file);                      # Bool
  $library->add_document($document);              # Bool
  $library->add_entity($entity);                  # Bool
  $library->add_division($division);              # Bool
  $library->add_variable($definition);            # Bool
  $library->add_outcome($outcome);                # Bool
  $library->add_review($review);                  # Bool
  $library->has_document($id);                    # Bool
  $library->has_document_id($id);                 # Bool
  $library->has_division_id($id);                 # Bool
  $library->has_entity($id);                      # Bool
  $library->has_division($id);                    # Bool
  $library->has_variable($name,$namespace);       # Bool
  $library->has_outcome($entity_id,$date);        # Bool
  $library->has_review($entity_id,$date);         # Bool
  $library->has_images;                           # Bool
  $library->get_file($filename);                  # SML::File
  $library->get_document_list;                    # ArrayRef
  $library->get_entity($id);                      # SML::Entity
  $library->get_division($id);                    # SML::Division
  $library->get_division_name_for_id($id)         # Str
  $library->get_all_entities;                     # Bool
  $library->get_all_documents;                    # Bool
  $library->get_division_id_list_by_name($name);  # ArrayRef
  $library->get_variable($name,$namespace);       # SML::Definition;
  $library->get_variable_value($name,$namespace); # Str
  $library->get_type($value);                     # Str
  $library->get_outcome($entity_id,$date);        # SML::Outcome;
  $library->get_review($entity_id,$date);         # SML::Outcome;
  $library->get_outcome_entity_id_list;           # ArrayRef
  $library->get_review_entity_id_list;            # ArrayRef
  $library->get_outcome_date_list($entity_id);    # ArrayRef
  $library->get_review_date_list($entity_id);     # ArrayRef
  $library->get_outcome_status($entity_id,$date); # Str
  $library->get_review_status($entity_id,$date);  # Str
  $library->get_outcome_description($entity_id,$date); # Str
  $library->get_review_description($entity_id,$date);  # Str
  $library->summarize_content;                    # Str
  $library->summarize_entities;                   # Str
  $library->summarize_divisions;                  # Str
  $library->summarize_glossary;                   # Str
  $library->summarize_acronyms;                   # Str
  $library->summarize_variables;                  # Str
  $library->summarize_sources;                    # Str
  $library->summarize_outcomes;                   # Str
  $library->summarize_reviews;                    # Str
  $library->update_status_from_outcome($outcome); # Bool
  $library->contains_entities;                    # Bool
  $library->get_division_count($name);            # Int
  $library->increment_division_count($name);      # Int
  $library->has_published_file($state,$filename); # Bool
  $library->has_published_document($state,$id);   # Bool
  $library->has_published_document_rendition($state,$id,$rendition); # Bool
  $library->has_published_document_property_value($state,$id,$property_name); # Bool
  $library->get_published_document_property_value($state,$id,$property_name); # Str
  $library->has_published_library_property_value($state,$property_name);      # Bool
  $library->get_published_library_property_value($state,$property_name);      # Str
  $library->add_error($error);                    # Bool
  $library->get_error_list;                       # ArrayRef
  $library->get_error_count;                      # Int
  $library->contains_error;                       # Bool
  $library->store_sha_digest_file;                # Bool
  $library->contains_changes;                     # Bool

=head1 DESCRIPTION

An SML::Library is a collection of SML documents and reusable content
stored in text files.

Library rules:

=over 4

=item

Each file name must be unique.  Even though you can organize text
files into directories, each filename must be unique in the library.

=item

Each division name must be valid.  Every division name in the library
must be declared in the ontology.

=item

Each division ID must be unique.  Every division in the library must
have a unique ID.

=back

If you violate any of these rules you won't be able to even
instantiate your library object.  Don't worry.  It will tell you where
you went wrong.

=head1 CONFIGURATION

Here's an example configuration file:

  name               "SML Engineering Library"
  id                 "sml_engineering_library"

  version            "v0.11"
  previous_version   "v0.10"

  directory_path     ".."
  directory_name     "library"
  template_dir       "templates"
  published_dir      "../sml-library-published"
  plugins_dir        "plugins"
  images_dir         "files/images"

  ontology_rule_file "ontology/ontology_rules_sml.conf"
  ontology_rule_file "ontology/ontology_rules_lib.conf"

  include_path       "."
  include_path       "allocations"
  include_path       "incl"
  include_path       "requirements"
  include_path       "roles"
  include_path       "configuration_items"
  include_path       "tests"

  document           "sml-ug"
  document           "sml-brd"
  document           "sml-dfrd"
  document           "sml-srd"
  document           "sml-sdd"
  document           "sml-ted"

  pdflatex           "..\..\miktex\miktex\bin\pdflatex.exe"
  pdflatex_args      "--main-memory=50000000 --extra-mem-bot=50000000"
  bibtex             "..\..\miktex\miktex\bin\bibtex.exe"
  makeindex          "..\..\miktex\miktex\bin\makeindex.exe"
  svn                "..\..\..\svn\svn.exe"
  use_git            "1"
  git                "..\..\PortableGit\bin\git.exe"
  convert            "..\..\ImageMagick-6.8.0-3\convert.exe"

=head1 METHODS

=head2 new

Instantiate a new SML::Library.

  my $library = SML::Library->new(config_filename=>'library.conf');

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has id =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_id',
   writer    => '_set_id',
   clearer   => '_clear_id',
   predicate => '_has_id',
   default   => 'lib',
  );

=head2 get_id

Return a scalar text value which is the ID of this library. Specify
the ID in the library configuration file.

  my $id = $library->get_id;

=cut

######################################################################

has name =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_name',
   writer    => '_set_name',
   default   => 'library',
  );

=head2 get_name

Return a scalar text value which is the name of this library. Specify
the name in the library configuration file.

  my $name = $library->get_name;

=cut

######################################################################

has version =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_version',
   writer    => '_set_version',
   predicate => 'has_version',
   clearer   => '_clear_version',
  );

=head2 get_version

Return a scalar text value which is the current version of this
library. Specify the version in the library configuration file.

  my $version = $library->get_version;

=head2 has_version

Return 1 if this library has a current version string.

  my $result = $library->has_version;

=cut

######################################################################

has previous_version =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_previous_version',
   writer    => '_set_previous_version',
   predicate => 'has_previous_version',
   clearer   => '_clear_previous_version',
  );

=head2 get_previous_version

Return a scalar text value which is the previous version of this
library. Specify the previous version in the library configuration
file.

  my $previous = $library->get_previous_version;

=head2 has_previous_version

Return 1 if this library has a previous version string.

  my $result = $library->has_previous_version;

=cut

######################################################################

has syntax =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => 'get_syntax',
   lazy      => 1,
   builder   => '_build_syntax',
  );

=head2 get_syntax

Return the L<SML::Syntax> object for this library.

  my $syntax = $library->get_syntax;

=cut

######################################################################

has ontology_rule_filespec_list =>
  (
   is        => 'ro',
   isa       => 'ArrayRef',
   reader    => 'get_ontology_rule_filespec_list',
   lazy      => 1,
   builder   => '_build_ontology_rule_filespec_list',
  );

=head2 get_ontology_rule_filespec_list

Return an ArrayRef to a list of filespecs of files containing ontology
rules. These ontology rules specify the semantics of the library.

  my $aref = $library->get_ontology_rule_filespec_list;

=cut

######################################################################

has directory_path =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_directory_path',
   writer    => '_set_directory_path',
   clearer   => '_clear_directory_path',
   predicate => '_has_directory_path',
   default   => q{.},
  );

=head2 get_directory_path

Return a scalar text value which is the full directory path to the
library.

  my $path = $library->get_directory_path;

=cut

######################################################################

has include_path_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_include_path_list',
   default => sub {[]},
  );

=head2 get_include_path_list

Return an ArrayRef to a list of path strings of directories containing
SML files.

  my $aref = $library->get_include_path_list;

=cut

######################################################################

has template_dir =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_template_dir',
   writer    => '_set_template_dir',
   default   => 'templates',
  );

=head2 get_template_dir

Return a scalar text value of the template directory path. This is the
path to the directory containing Perl Template Toolkit templates used
to render content presentations.

  my $path = $library->get_template_dir;

=cut

######################################################################

has published_dir =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_published_dir',
   writer    => '_set_published_dir',
   default   => 'published',
  );

=head2 get_published_dir

Return a scalar text value of the published directory path.  The
published directory is where the published documents are placed.

  my $path = $library->get_published_dir;

=cut

######################################################################

has plugins_dir =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_plugins_dir',
   writer    => '_set_plugins_dir',
   default   => 'plugins',
  );

=head2 get_plugins_dir

Return a scalar text value of the plugins directory path. This is the
directory containing plugins.  Plugins are library-specific perl
modules that perform special rendering functions.

  my $path = $library->get_plugins_dir;

=cut


######################################################################

has images_dir =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_images_dir',
   writer    => '_set_images_dir',
   default   => 'images',
  );

=head2 get_images_dir

Return a scalar text value of the images directory path. This is the
directory containing images.  These are standard images used in
documents.  For instance, they include a paperclip image that
indicates attachements, and other icons used to represent status,
priority, etc.

  my $path = $library->get_images_dir;

=cut


######################################################################

has image_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_image_list',
   default => sub {[]},
  );

=head2 get_image_list

Return an ArrayRef to a list of image filenames.

  my $aref = $library->get_image_list;

=cut

######################################################################

has document_presentation_id_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_document_presentation_id_list',
   default => sub {[]},
  );

=head2 get_document_presentation_id_list

Return an ArrayRef to a list of document IDs in the order in which
they should be presented in any listing of library documents.

  my $aref = $library->get_document_presentation_id_list;

=cut

######################################################################

has change_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_change_list',
   lazy    => 1,
   builder => '_build_change_list',
  );

=head2 get_change_list

Return an ArrayRef to a list of changes made to the library since the
previous version.  Each change is represented by an ArrayRef to a
2-element list.  The first element is the change type (ADDED, DELETED,
or UPDATED), and the second element is the division ID of the division
that changed.

  my $aref = $library->get_change_list;

=cut

######################################################################

has add_count =>
  (
   is      => 'ro',
   isa     => 'Int',
   reader  => 'get_add_count',
   lazy    => 1,
   builder => '_build_add_count',
  );

=head2 get_add_count

Return an integer count of the number of divisions that have been
ADDED since the previous library version.

  my $count = $library->get_add_count;

=cut

######################################################################

has delete_count =>
  (
   is      => 'ro',
   isa     => 'Int',
   reader  => 'get_delete_count',
   lazy    => 1,
   builder => '_build_delete_count',
  );

=head2 get_delete_count

Return an integer count of the number of divisions that have been
DELETED since the previous library version.

  my $count = $library->get_delete_count;

=cut

######################################################################

has update_count =>
  (
   is      => 'ro',
   isa     => 'Int',
   reader  => 'get_update_count',
   lazy    => 1,
   builder => '_build_update_count',
  );

=head2 get_update_count

Return an integer count of the number of divisions that have been
UPDATED since the previous library version.

  my $count = $library->get_update_count;

=cut

######################################################################

has options =>
  (
   is        => 'ro',
   isa       => 'SML::Options',
   reader    => 'get_options',
   lazy      => 1,
   builder   => '_build_options',
  );

=head2 get_options

Return the L<SML::Options> object that holds the library configuration
options.

  my $options = $library->get_options;

=cut

######################################################################

has util =>
  (
   is        => 'ro',
   isa       => 'SML::Util',
   reader    => 'get_util',
   lazy      => 1,
   builder   => '_build_util',
  );

=head2 get_util

Return the L<SML::Util> object that provides various library utility
methods.

  my $util = $library->get_util;

=cut

######################################################################

has ontology =>
  (
   is        => 'ro',
   isa       => 'SML::Ontology',
   reader    => 'get_ontology',
   lazy      => 1,
   builder   => '_build_ontology',
  );

=head2 get_ontology

Return the L<SML::Ontology> object that defines the allowed library
structures and entities, their properties, and how they relate to one
another. The ontology describes the semantics of the library.

  my $ontology = $library->get_ontology;

=cut

######################################################################

has reasoner =>
  (
   is        => 'ro',
   isa       => 'SML::Reasoner',
   reader    => 'get_reasoner',
   lazy      => 1,
   builder   => '_build_reasoner',
  );

=head2 get_reasoner

Return the L<SML::Reasoner> object that infers relationships between
entities based on ontology rules. The reasoner performs first order
inferences based on semantics declared in the ontology.

  my $reasoner = $library->get_reasoner;

=cut

######################################################################

has publisher =>
  (
   is        => 'ro',
   isa       => 'SML::Publisher',
   reader    => 'get_publisher',
   lazy      => 1,
   builder   => '_build_publisher',
  );

=head2 get_publisher

Return a L<SML::Publisher> object that can publish library documents
to various renditions and styles.

  my $publisher = $library->get_publisher;

=cut

######################################################################

has glossary =>
  (
   is        => 'ro',
   isa       => 'SML::Glossary',
   reader    => 'get_glossary',
   lazy      => 1,
   builder   => '_build_glossary',
  );

=head2 get_glossary

Return the L<SML::Glossary> object that belongs to the library. The
glossary contains a library-wide collection of terms and their
definitions.

  my $glossary = $library->get_glossary;

=cut


######################################################################

has acronym_list =>
  (
   is        => 'ro',
   isa       => 'SML::AcronymList',
   reader    => 'get_acronym_list',
   lazy      => 1,
   builder   => '_build_acronym_list',
  );

=head2 get_acronym_list

Return the L<SML::AcronymList> that belongs to the library. The
acronym list contains a library-wide collection of acronyms and their
meanings.

  my $acronym_list = $library->get_acronym_list;

=cut


######################################################################

has references =>
  (
   is        => 'ro',
   isa       => 'SML::References',
   reader    => 'get_references',
   lazy      => 1,
   builder   => '_build_references',
  );

=head2 get_references

Return the L<SML::References> object that belongs to the library. The
references object contains a library-wide collection of source
references.

  my $references = $library->get_references;

=cut


######################################################################

has index =>
  (
   is        => 'ro',
   isa       => 'SML::Index',
   reader    => 'get_index',
   lazy      => 1,
   builder   => '_build_index',
  );

=head2 get_index

Return the L<SML::Index> object that belongs to the library. The index
object contains a library-wide index of terms.

  my $index = $library->get_index;

=cut

######################################################################

has property_store =>
  (
   is      => 'ro',
   isa     => 'SML::PropertyStore',
   reader  => 'get_property_store',
   lazy    => 1,
   builder => '_build_property_store',
  );

=head2 get_property_store

Return the L<SML::PropertyStore> object that belongs to the library.

  my $ps = $library->get_property_store;

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_parser {

  my $self = shift;

  my $count = $self->_get_parser_count;

  $self->_set_parser_count( $count + 1 );

  return SML::Parser->new
    (
     number  => $count,
     library => $self,
    );
}

=head2 get_parser

Return a new L<SML::Parser> object.

  my $parser = $library->get_parser;

=cut

######################################################################

sub get_file_containing_id {

  my $self = shift;
  my $id   = shift;

  if ( not $id )
    {
      $logger->logcluck("CAN'T GET FILE CONTAINING ID, YOU MUST SPECIFY AN ID");
      return 0;
    }

  # validate the library has a division with this ID
  if ( not $self->has_division_id($id) )
    {
      $logger->error("LIBRARY HAS NO DIVISION \'$id\'");
      return 0;
    }

  my $id_hash   = $self->_get_id_hash;
  my $filename  = $id_hash->{$id}->[0];

  if ( not $self->_has_file($filename) )
    {
      my $filespec = $self->get_filespec($filename);
      my $file = SML::File->new(filespec=>$filespec,library=>$self);

      return $file;
    }

  my $file_hash = $self->_get_file_hash;

  return $file_hash->{$filename};
}

=head2 get_file_containing_id

Return the L<SML::File> containing the specified division ID.

  my $file = $library->get_file_containing_id($id);

=cut

######################################################################

sub has_filespec {

  # Given a filename, determine if the file is in the library by
  # looking in each include path.

  my $self     = shift;
  my $filespec = shift;

  my $include_path   = $self->get_include_path_list;
  my $directory_path = $self->get_directory_path;

  if ( -f "$directory_path/$filespec" )
    {
      return 1;
    }

  foreach my $path ( @{$include_path} )
    {
      if ( -f "$directory_path/$path/$filespec" )
	{
	  return 1;
	}
    }

  return 0;
}

=head2 has_filespec

Return 1 if the library contains the specified filespec.

  my $result = $library->has_filespec($filespec)

=cut

######################################################################

sub get_filespec {

  # Given a filename, find the file in the library by looking in each
  # include path.

  my $self     = shift;
  my $filename = shift;

  my $include_path   = $self->get_include_path_list;
  my $directory_path = $self->get_directory_path;

  if ( -f "$directory_path/$filename" )
    {
      return "$directory_path/$filename";
    }

  foreach my $path ( @{$include_path} )
    {
      if ( -f "$directory_path/$path/$filename" )
	{
	  return "$directory_path/$path/$filename";
	}
    }

  $logger->error("FILE NOT FOUND \'$filename\'");

  $logger->error("  checked path $directory_path");

  foreach my $path ( @{$include_path} )
    {
      $logger->error("  checked path $directory_path/$path");
    }

  return 0;
}

=head2 get_filespec

Return the filespec for the specified filename.

  my $filespec = $library->get_filespec($filename);

=cut

######################################################################

sub add_file {

  my $self = shift;
  my $file = shift;

  unless ( $file->isa('SML::File') )
    {
      $logger->error("CAN'T ADD FILE \'$file\' is not a SML::File");
      return 0;
    }

  my $id = $file->get_id;

  $self->_get_file_hash->{$id} = $file;

  return 1;
}

=head2 add_file

Add an L<SML::File> object to the library. Return 1 if the specified
file is successfully added to the library.

  my $result = $library->add_file($file);

=cut

######################################################################

sub add_document {

  my $self     = shift;
  my $document = shift;

  unless ( $document->isa('SML::Document') )
    {
      $logger->error("CAN'T ADD DOCUMENT \'$document\' is not a SML::Document");
      return 0;
    }

  my $id = $document->get_id;

  $self->_get_document_hash->{$id} = $document;

  return 1;
}

=head2 add_document

Add an L<SML::Document> object to the library.  Return 1 of the
specified document is successfully added to the library.

  my $result = $library->add_document($document);

=cut

######################################################################

sub add_entity {

  my $self   = shift;
  my $entity = shift;

  unless ( $entity->isa('SML::Entity') )
    {
      $logger->error("CAN'T ADD ENTITY \'$entity\' is not a SML::Entity");
      return 0;
    }

  my $id = $entity->get_id;

  $self->_get_entity_hash->{$id} = $entity;

  return 1;
}

=head2 add_entity

Add an L<SML::Entity> object to the library.  Return 1 if the
specified entity is successfully added to the library.

  my $result = $library->add_entity($entity);

=cut

######################################################################

sub add_division {

  my $self     = shift;
  my $division = shift;

  if ( not $division->isa('SML::Division') )
    {
      $logger->error("CAN'T ADD DIVISION \'$division\' is not a SML::Division");
      return 0;
    }

  my $id   = $division->get_id;
  my $href = $self->_get_division_hash;

  # Replace the division if it already exists.

  $href->{$id} = $division;

  return 1;
}

=head2 add_division

Add an L<SML::Division> object to the library.  Return 1 if the
specified division is successfully added to the library.

  my $result = $library->add_division($division);

=cut

######################################################################

sub add_variable {

  my $self       = shift;
  my $definition = shift;

  unless ( $definition->isa('SML::Definition') )
    {
      $logger->error("CAN'T ADD VARIABLE \'$definition\' is not a SML::Definition");
      return 0;
    }

  my $name      = $definition->get_term;
  my $namespace = $definition->get_namespace || q{};

  $self->_get_variable_hash->{$name}{$namespace} = $definition;

  return 1;
}

=head2 add_variable

Add a variable definition (an L<SML::Definition> object) to the
library.  Return 1 if the specified variable definition is
successfully added to the library.

  my $result = $library->add_variable($definition);

=cut

######################################################################

sub add_outcome {

  my $self    = shift;
  my $outcome = shift;

  my $date      = $outcome->get_date;
  my $entity_id = $outcome->get_entity_id;
  my $href      = $self->_get_outcome_hash;

  $href->{$entity_id}{$date}{status}      = $outcome->get_status;
  $href->{$entity_id}{$date}{description} = $outcome->get_description;
  $href->{$entity_id}{$date}{outcome}     = $outcome;

  my $options = $self->get_options;

  if ( $options->use_formal_status )
    {
      $self->update_status_from_outcome($outcome);
    }

  return 1;
}

=head2 add_outcome

Add an L<SML::Outcome> object to the library.  Return 1 if the
specified outcome is successfully added to the library.

An "outcome" decribes the outcome of a test, audit, inspection, or
review.  If the library's "use_formal_status" option is set to true
then the most recent outcome will set the formal status of the entity.

  my $result = $library->add_outcome($outcome);

=cut

######################################################################

sub add_review {

  my $self   = shift;
  my $review = shift;

  unless ( ref $review and $review->isa('SML::Outcome') )
    {
      $logger->error("CAN'T ADD REVIEW \'$review\'");
      return 0;
    }

  my $entity_id = $review->get_entity_id;
  my $date      = $review->get_date;

  my $rh = $self->_get_review_hash;

  $rh->{$entity_id}{$date}{status}      = $review->get_status;
  $rh->{$entity_id}{$date}{description} = $review->get_description;
  $rh->{$entity_id}{$date}{review}      = $review;

  return 1;
}

=head2 add_review

Add a review (an L<SML::Outcome> object) to the library.  Return 1 if
the specified review is successfully added to the library.

A "review" is an informal outcome of a test, audit, or inspection.  If
the library's "use_formal_status" option is set to true then the m

  my $result = $library->add_review($outcome);

=cut

######################################################################

sub has_document {

  my $self = shift;
  my $id   = shift;

  if ( exists $self->_get_document_hash->{$id} )
    {
      return 1;
    }

  return 0;
}

=head2 has_document

Return 1 if the library contains a parsed document with the specified
ID.  This means the document has already been parsed into memory.

  my $result = $library->has_document($id);

=cut

######################################################################

sub has_document_id {

  my $self = shift;
  my $id   = shift;

  unless ( defined $id )
    {
      $logger->logcluck("CAN'T DETERMINE IF LIBRARY HAS DOCUMENT, YOU MUST SPECIFY AN ID");
      return 0;
    }

  my $id_hash = $self->_get_id_hash;

  if ( exists $id_hash->{$id} )
    {
      if ( $id_hash->{$id}->[1] eq 'DOCUMENT' )
	{
	  return 1;
	}
    }

  return 0;
}

=head2 has_document_id

Return 1 if the document ID exists in the library.  This means that
some file in the library contains a DOCUMENT division with the
specified ID.

  my $result = $library->has_document_id($id);

=cut

######################################################################

sub has_division_id {

  my $self = shift;
  my $id   = shift;

  unless ( defined $id )
    {
      $logger->logcluck("CAN'T DETERMINE IF LIBRARY HAS DIVISION, YOU MUST SPECIFY AN ID");
      return 0;
    }

  my $id_hash = $self->_get_id_hash;

  if ( exists $id_hash->{$id} )
    {
      return 1;
    }

  return 0;
}

=head2 has_division_id

Return 1 if the specified division ID exists in the library.  This
means that some file in the library contains a division with the
specified ID.

  my $result = $library->has_division_id($id);

=cut

######################################################################

sub has_entity {

  my $self = shift;
  my $id   = shift;

  unless ( $id )
    {
      $logger->error("CAN'T DETERMINE IF LIBRARY HAS ENTITY, MISSING ARGUMENT");
      return 0;
    }

  if ( exists $self->_get_entity_hash->{$id} )
    {
      return 1;
    }

  return 0;
}

=head2 has_entity

Return 1 if the library contains a parsed entity with the specified
ID.  This means the entity has already been parsed into memory.

  my $result = $library->has_entity($id);

=cut

######################################################################

sub has_division {

  my $self = shift;
  my $id   = shift;

  unless ( $id )
    {
      $logger->error("CAN'T DETERMINE IF LIBRARY HAS DIVISION, MISSING ARGUMENT");
      return 0;
    }

  if ( exists $self->_get_division_hash->{$id} )
    {
      return 1;
    }

  return 0;
}

=head2 has_division

Return 1 if the library contains a parsed division with the specified
ID.  This means the division has already been parsed into memory.

  my $result = $library->has_division($id);

=cut

######################################################################

sub has_variable {

  my $self      = shift;
  my $name      = shift;
  my $namespace = shift || q{};

  if ( exists $self->_get_variable_hash->{$name}{$namespace} )
    {
      return 1;
    }

  return 0;
}

=head2 has_variable

Return 1 if the library contains a variable with the specified name in
the specified namespace.

  my $result = $library->has_variable($name,$namespace);

=cut

######################################################################

sub has_outcome {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( defined $self->_get_outcome_hash->{$entity_id}{$date} )
    {
      return 1;
    }

  return 0;
}

=head2 has_outcome

Return 1 if the library contains an outcome for the specified entity
from the specified date.

  my $outcome = $library->has_outcome($entity_id,$date);

=cut

######################################################################

sub has_review {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( defined $self->_get_review_hash->{$entity_id}{$date} )
    {
      return 1;
    }

  return 0;
}

=head2 has_review

Return 1 if the library contains a review of the specified entity on
the specified date.

  my $review = $library->has_review($entity_id,$date);

=cut

######################################################################

sub has_images {

  my $self = shift;

  if ( scalar @{ $self->get_image_list } )
    {
      return 1;
    }

  return 0;
}

=head2 has_images

Return 1 if the library contains images.

  my $result = $library->has_images;

=cut

######################################################################

sub get_file {

  my $self     = shift;
  my $filename = shift;

  unless ( exists $self->_get_file_hash->{$filename} )
    {
      $logger->error("CAN'T GET FILE \'$filename\'");
      return 0;
    }

  return $self->_get_file_hash->{$filename};
}

=head2 get_file

Return the L<SML::File> with the specified filename.

  my $file = $library->get_file($filename);

=cut

######################################################################

sub get_document_list {

  my $self = shift;

  my $aref = [];

  foreach my $division ( values %{ $self->_get_division_hash })
    {
      if ( $division->isa('SML::Document') )
	{
	  push @{ $aref }, $division;
	}
    }

  return $aref;
}

=head2 get_document_list

Return an ArrayRef to a list of L<SML::Document> objects in the
library.

  my $list = $library->get_document_list;

=cut

######################################################################

sub get_entity {

  my $self = shift;
  my $id   = shift;

  unless ( exists $self->_get_entity_hash->{$id} )
    {
      $logger->warn("ENTITY DOESN'T EXIST \'$id\'");
      return 0;
    }

  return $self->_get_entity_hash->{$id};
}

=head2 get_entity

Return an L<SML::Entity> object with the specified ID.

  my $entity = $library->get_entity($id);

=cut

######################################################################

sub get_division {

  my $self = shift;
  my $id   = shift;

  unless ( $id )
    {
      $logger->logcluck("CAN'T GET DIVISION, YOU MUST SPECIFY AN ID");
      return 0;
    }

  if ( exists $self->_get_division_hash->{$id} )
    {
      return $self->_get_division_hash->{$id};
    }

  else
    {
      my $parser = $self->get_parser;

      my $division = $parser->parse($id);

      return $division;
    }
}

=head2 get_division

Return the L<SML::Division> with the specified ID.

  my $division = $library->get_division($id);

=cut

######################################################################

sub get_division_name_for_id {

  my $self = shift;
  my $id   = shift;

  unless ( $id )
    {
      $logger->error("CAN'T GET DIVISION NAME FOR ID \'$id\' YOU MUST SPECIFY AN ID");
      return 0;
    }

  unless ( $self->has_division_id($id) )
    {
      $logger->logcluck("CAN'T GET DIVISION NAME FOR ID \'$id\' THERE IS NO DIVISION WITH ID \'$id\'");
      return 0;
    }

  my $href = $self->_get_id_hash;
  my $pair = $href->{$id};
  my $name = $pair->[1];

  return $name;
}

=head2 get_division_name_for_id

Return the name of the division with the specified ID.

  my $name = $library->get_division_name_for_id($id);

=cut

######################################################################

sub get_all_entities {

  my $self = shift;

  if ( $self->_got_all_entities )
    {
      return 1;
    }

  my $begin = time();

  $logger->info("get all library entities");

  my $ontology = $self->get_ontology;

  foreach my $name (@{ $ontology->get_entity_name_list })
    {
      my $id_list = $self->get_division_id_list_by_name($name);

      foreach my $id (@{ $id_list })
	{
	  $self->get_division($id);
	}
    }

  $self->_set_got_all_entities(1);

  my $end = time();
  my $duration = duration($end - $begin);

  $logger->info("get all library entities $duration");

  return 1;
}

=head2 get_all_entities

Parse all library entities into memory.  Return 1 if successsful.

  my $result = $library->get_all_entities;

=cut

######################################################################

sub get_all_documents {

  my $self = shift;

  if ( $self->_got_all_documents )
    {
      return 1;
    }

  my $begin = time();

  $logger->info("get all library documents");

  my $id_list = $self->get_division_id_list_by_name('DOCUMENT');

  foreach my $id (@{ $id_list })
    {
      $self->get_division($id);
    }

  $self->_set_got_all_documents(1);

  my $end = time();
  my $duration = duration($end - $begin);

  $logger->info("get all library documents $duration");

  return 1;
}

=head2 get_all_documents

Parse all library documents into memory.  Return 1 if successsful.

  my $result = $library->get_all_documents;

=cut

######################################################################

sub get_division_id_list_by_name {

  my $self = shift;
  my $name = shift;

  my $id_list = [];
  my $id_hash = $self->_get_id_hash;

  foreach my $id ( sort keys %{ $id_hash } )
    {
      my $pair          = $id_hash->{$id};
      my $division_name = $pair->[1];

      if ( $division_name eq $name )
	{
	  push(@{$id_list},$id);
	}
    }

  return $id_list;
}

=head2 get_division_id_list_by_name

Return an ArrayRef to a list of division IDs that have the specified
name.

  my $aref = $library->get_division_id_list_by_name($name);

=cut

######################################################################

sub get_variable {

  my $self      = shift;
  my $name      = shift;
  my $namespace = shift || q{};

  unless ( exists $self->_get_variable_hash->{$name}{$namespace} )
    {
      $logger->error("CAN'T GET VARIABLE \'$name\' \'$namespace\'");
      return 0;
    }

  return $self->_get_variable_hash->{$name}{$namespace};
}

=head2 get_variable

Return the variable definition (an L<SML::Definition> object) for the
specified name and namespace.

  my $variable = $library->get_variable($name,$namespace);

=cut

######################################################################

sub get_variable_value {

  my $self      = shift;
  my $name      = shift;
  my $namespace = shift || q{};

  unless ( exists $self->_get_variable_hash->{$name}{$namespace} )
    {
      $logger->error("CAN'T GET VARIABLE VALUE \'$name\' \'$namespace\' not defined");
      return 0;
    }

  my $definition = $self->_get_variable_hash->{$name}{$namespace};

  return $definition->get_value;
}

=head2 get_variable_value

Return the scalar text value of the variable for the specified name
and namespace.

  my $variable = $library->get_variable_value($name,$namespace);

=cut

######################################################################

sub get_type {

  my $self  = shift;
  my $value = shift;

  if ( not $value )
    {
      $logger->logcluck("YOU MUST PROVIDE A VALUE");
      return 0;
    }

  my $id_hash = $self->_get_id_hash;

  if ( defined $id_hash->{$value} )
    {
      my $pair = $id_hash->{$value};

      return $pair->[1];
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

=head2 get_type

Return the type of the specified value (division name, STRING, or
BOOLEAN)

  my $type = $library->get_type($value);

=cut

######################################################################

sub get_outcome {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  unless ( exists $self->_get_outcome_hash->{$entity_id}{$date}{outcome} )
    {
      $logger->("OUTCOME DOESN'T EXIST \'$entity_id\' \'$date\'");
      return 0;
    }

  return $self->_get_outcome_hash->{$entity_id}{$date}{outcome};
}

=head2 get_outcome

Return the outcome (an L<SML::Outcome> object) with the specified
entity ID and date.

  my $outcome = $library->get_outcome($entity_id,$date);

=cut

######################################################################

sub get_review {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  unless ( exists $self->_get_review_hash->{$entity_id}{$date}{review} )
    {
      $logger->("REVIEW DOESN'T EXIST \'$entity_id\' \'$date\'");
      return 0;
    }

  return $self->_get_review_hash->{$entity_id}{$date}{review};
}

=head2 get_review

Return the review (an L<SML::Outcome> object) with the specified
entity ID and date.

  my $review = $library->get_review($entity_id,$date);

=cut

######################################################################

sub get_outcome_entity_id_list {

  my $self = shift;

  my $aref = [];                        # outcome entity list

  foreach my $entity_id ( keys %{ $self->_get_outcome_hash } )
    {
      push @{ $aref }, $entity_id;
    }

  return $aref;
}

=head2 get_outcome_entity_id_list

Return an ArrayRef for a list of entities for which there are outcome
elements.

  my $aref = $library->get_outcome_entity_id_list;

=cut

######################################################################

sub get_review_entity_id_list {

  my $self = shift;

  my $aref = [];                        # review entity list

  foreach my $entity_id ( keys %{ $self->_get_review_hash } )
    {
      push @{ $aref }, $entity_id;
    }

  return $aref;
}

=head2 get_review_entity_id_list

Return an ArrayRef for a list of entities for which there are review
elements.

  my $aref = $library->get_review_entity_id_list;

=cut

######################################################################

sub get_outcome_date_list {

  my $self      = shift;
  my $entity_id = shift;

  my $date_list = [];

  if ( exists $self->_get_outcome_hash->{$entity_id} )
    {
      foreach my $date ( sort by_date keys %{ $self->_get_outcome_hash->{$entity_id} } )
	{
	  push @{ $date_list }, $date;
	}

      return $date_list;
    }

  else
    {
      $logger->error("CAN'T GET OUTCOME DATE LIST no outcomes for \'$entity_id\'");
    }

  return $date_list;
}

=head2 get_outcome_date_list

Return an ArrayRef to a list of dates for which there are outcome
elements for the specified entity.

  my $aref = $library->get_outcome_date_list($entity_id);

=cut

######################################################################

sub get_review_date_list {

  my $self      = shift;
  my $entity_id = shift;

  my $date_list = [];

  if ( exists $self->_get_review_hash->{$entity_id} )
    {
      foreach my $date ( sort by_date keys %{ $self->_get_review_hash->{$entity_id} } )
	{
	  push @{ $date_list }, $date;
	}

      return $date_list;
    }

  else
    {
      $logger->error("CAN'T GET REVIEW DATE LIST no reviews for \'$entity_id\'");
    }

  return $date_list;
}

=head2 get_outcome_date_list

Return an ArrayRef to a list of dates for which there are review
elements for the specified entity.

  my $aref = $library->get_review_date_list($entity_id);

=cut

######################################################################

sub get_outcome_status {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  unless ( defined $self->_get_outcome_hash->{$entity_id}{$date}{status} )
    {
      $logger->error("CAN'T GET OUTCOME STATUS \'$entity_id\' \'$date\'");
      return 0;
    }

  return $self->_get_outcome_hash->{$entity_id}{$date}{status};
}

=head2 get_outcome_status

Return the status determined by the specified outcome.

  my $status = $library->get_outcome_status($entity_id,$date);

=cut

######################################################################

sub get_review_status {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  unless ( defined $self->_get_review_hash->{$entity_id}{$date}{status} )
    {
      $logger->error("CAN'T GET REVIEW STATUS \'$entity_id\' \'$date\'");
      return 0;
    }

  return $self->_get_review_hash->{$entity_id}{$date}{status};
}

=head2 get_review_status

Return the status determined by the specified review.

  my $status = $library->get_review_status($entity_id,$date);

=cut

######################################################################

sub get_outcome_description {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  unless ( defined $self->_get_outcome_hash->{$entity_id}{$date}{description} )
    {
      $logger->error("CAN'T GET OUTCOME DESCRIPTION \'$entity_id\' \'$date\'");
      return 0;
    }

  return $self->_get_outcome_hash->{$entity_id}{$date}{description};
}

=head2 get_outcome_description

Return the description of the specified outcome.

  my $description = $library->get_outcome_description($entity_id,$date);

=cut

######################################################################

sub get_review_description {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  unless ( defined $self->_get_review_hash->{$entity_id}{$date}{description} )
    {
      $logger->error("CAN'T GET REVIEW DESCRIPTION \'$entity_id\' \'$date\'");
      return 0;
    }

  return $self->_get_review_hash->{$entity_id}{$date}{description};
}

=head2 get_review_description

Return the description of the specified review.

  my $description = $library->get_review_description($entity_id,$date);

=cut

######################################################################

sub summarize_content {

  my $self = shift;

  my $summary = q{};

  $summary .= $self->summarize_entities;
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

=head2 summarize_content

Return a summary of the library's content.

  my $text = $library->summarize_content;

=cut

######################################################################

sub summarize_entities {

  # Return a summary of the library's entities.

  my $self = shift;

  my $summary = q{};
  my $ps      = $self->get_property_store;

  if ( keys %{ $self->_get_entity_hash } )
    {
      $summary .= "Entities:\n\n";

      foreach my $entity (sort by_division_name_and_id values %{ $self->_get_entity_hash })
	{
	  my $id      = $entity->get_id;
	  my $entname = $entity->get_name;

	  $summary .= "  $entname: $id";

	  my $property_name_list = $ps->get_property_name_list($id);

	  if ( scalar @{ $property_name_list } )
	    {
	      $summary .= ' (' . join(', ', @{ $property_name_list}) . ')';
	    }

	  $summary .= "\n";
	}

      $summary .= "\n";
    }

  return $summary;
}

=head2 summarize_entities

Return a summary of the library's entities.

  my $text = $library->summarize_entities;

=cut

######################################################################

sub summarize_divisions {

  # Return a summary of the library's divisions.
  #
  # - Don't include divisions of type: BARE_TABLE, COMMENT, REVISIONS,
  #   TABLE_CELL, or TABLE_ROW.
  #
  # - Don't include entities

  my $self = shift;

  my $summary = q{};
  my $ps      = $self->get_property_store;

  my $ignore =
    {
     BARE_TABLE => 1,
     COMMENT    => 1,
     REVISIONS  => 1,
     TABLE_CELL => 1,
     TABLE_ROW  => 1,
    };

  if ( keys %{ $self->_get_division_hash } )
    {
      $summary .= "Divisions:\n\n";

      foreach my $division (sort by_division_name_and_id values %{ $self->_get_division_hash })
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

	  my $property_name_list = $ps->get_property_name_list($id);

	  if ( scalar @{ $property_name_list } )
	    {
	      $summary .= ' (' . join(', ', @{ $property_name_list}) . ')';
	    }

	  $summary .= "\n";
	}

      $summary .= "\n";
    }

  return $summary;
}

=head2 summarize_divisions

Return a summary of the library's divisions.

  my $text = $library->summarize_divisions;

=cut

######################################################################

sub summarize_glossary {

  my $self = shift;

  my $summary  = q{};
  my $glossary = $self->get_glossary;

  if ( my $entry_list = $glossary->get_entry_list )
    {
      $summary .= "Glossary Entries:\n\n";

      foreach my $definition (@{ $entry_list })
	{
	  my $term      = $definition->get_term;
	  my $namespace = $definition->get_namespace;

	  $summary .= "  $term";
	  if ($namespace) {
	    $summary .= " {$namespace}";
	  }
	  $summary .= "\n";
	}

      $summary .= "\n";
    }

  return $summary;
}

=head2 summarize_glossary

Return a summary of the library's glossary.

  my $text = $library->summarize_glossary;

=cut

######################################################################

sub summarize_acronyms {

  my $self = shift;

  my $summary      = q{};
  my $acronym_list = $self->get_acronym_list;

  if ( my $entry_list = $acronym_list->get_entry_list )
    {
      $summary .= "Acronyms:\n\n";

      foreach my $definition (@{ $entry_list })
	{
	  my $acronym   = $definition->get_term;
	  my $namespace = $definition->get_namespace;

	  $summary .= "  $acronym";
	  if ($namespace) {
	    $summary .= " {$namespace}";
	  }
	  $summary .= "\n";
	}

      $summary .= "\n";
    }

  return $summary;
}

=head2 summarize_acronyms

Return a summary of the library's acronyms list.

  my $text = $library->summarize_acronyms;

=cut

######################################################################

sub summarize_variables {

  my $self = shift;

  my $summary = q{};

  if (keys %{ $self->_get_variable_hash })
    {
      $summary .= "Variables:\n\n";

      foreach my $name (sort keys %{ $self->_get_variable_hash })
	{
	  foreach my $namespace ( sort keys %{ $self->_get_variable_hash->{$name} } )
	    {
	      $summary .= "  $name \[$namespace\]\n";
	    }
	}

      $summary .= "\n";
    }

  return $summary;
}

=head2 summarize_variables

Return a summary of the library's variables.

  my $text = $library->summarize_variables;

=cut

######################################################################

sub summarize_sources {

  my $self = shift;

  my $summary = q{};
  my $ps      = $self->get_property_store;
  my $href    = $self->get_references;

  if ( $self->get_references->contains_entries )
    {
      $summary .= "Source References:\n\n";

      foreach my $source (@{ $href->get_entry_list })
	{
	  my $id    = $source->get_id;
	  my $title = $ps->get_property_text($id,'title');

	  $summary .= "  $id => $title\n";
	}

      $summary .= "\n";
    }

  return $summary;
}

=head2 summarize_sources

Return a summary of the library's source references.

  my $text = $library->summarize_sources;

=cut

######################################################################

sub summarize_outcomes {

  my $self = shift;

  my $summary = q{};

  if ( keys %{ $self->_get_outcome_hash } )
    {
      $summary .= "Test Outcomes:\n\n";

      foreach my $entity (sort keys %{ $self->_get_outcome_hash })
	{
	  foreach my $date (sort keys %{ $self->_get_outcome_hash->{$entity} })
	    {
	      my $status = $self->_get_outcome_hash->{$entity}{$date}{status};

	      $summary .= "  $entity $date => $status\n";
	    }
	}

      $summary .= "\n";
    }

  return $summary;
}

=head2 summarize_outcomes

Return a summary of the library's outcomes.

  my $text = $library->summarize_outcomes;

=cut

######################################################################

sub summarize_reviews {

  my $self = shift;

  my $summary = q{};

  if ( keys %{ $self->_get_review_hash } )
    {
      $summary .= "Review Results:\n\n";

      foreach my $entity (sort keys %{ $self->_get_review_hash })
	{
	  foreach my $date (sort keys %{ $self->_get_review_hash->{$entity} })
	    {
	      my $status = $self->_get_review_hash->{$entity}{$date}{status};

	      $summary .= "  $entity $date => $status\n";
	    }
	}

      $summary .= "\n";
    }

  return $summary;
}

=head2 summarize_reviews

Return a summary of the library's reviews.

  my $text = $library->summarize_reviews;

=cut

######################################################################

sub update_status_from_outcome {

  my $self    = shift;
  my $outcome = shift;

  my $date        = $outcome->get_date;
  my $entity_id   = $outcome->get_entity_id;
  my $status      = $outcome->get_status;
  my $description = $outcome->get_description;

  unless ( $self->has_division($entity_id) )
    {
      my $location = $outcome->location;
      $logger->error("CAN'T UPDATE STATUS FROM OUTCOME ON NON-EXISTENT ENTITY at $location ($entity_id)");
      return 0;
    }

  my $entity = $self->get_division($entity_id);

  $self->set_property_value($entity_id,'status',$status);

  return 1;
}

=head2 update_status_from_outcome

Update the status of an entity based on an outcome.

  my $result = $library->update_status_from_outcome($outcome);

=cut

######################################################################

sub contains_entities {

  my $self = shift;

  my $ontology         = $self->get_ontology;
  my $entity_name_list = $ontology->get_entity_name_list;
  my $ps               = $self->get_property_store;

  foreach my $division_id (@{ $ps->get_division_id_list })
    {
      if ( $self->has_division_id($division_id) )
	{
	  my $division_name = $self->get_division_name_for_id($division_id);

	  foreach my $entity_name (@{ $entity_name_list })
	    {
	      if ( $division_name eq $entity_name )
		{
		  return 1;
		}
	    }
	}
    }

  return 0;
}

=head2 contains_entities

Return 1 if the library contains any entities.

  my $result = $library->contains_entities;

=cut

######################################################################

sub get_division_count {

  my $self = shift;
  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T GET DIVISION COUNT, MISSING ARGUMENT");
      return 0;
    }

  my $href = $self->_get_division_counter_hash;

  return $href->{$name};
}

=head2 get_division_count

Return an integer count of the number of divisions in the library with
the specified name.

  my $count = $library->get_division_count($name);

=cut

######################################################################

sub increment_division_count {

  my $self = shift;
  my $name = shift;                     # division name (i.e. COMMENT)

  unless ( $name )
    {
      $logger->logcluck("CAN'T INCREMENT DIVISION COUNT, MISSING ARGUMENT");
      return 0;
    }

  my $counter = $self->_get_division_counter_hash;

  return ++ $counter->{$name};
}

=head2 increment_division_count

Increment and return the integer count of the number of divisions in
the library with the specified name.

  my $count = $library->increment_division_count($name);

=cut

######################################################################

sub has_published_file {

  my $self = shift;

  my $state    = shift;                 # DRAFT, REVIEW, APPROVED
  my $filename = shift;

  my $published_dir = $self->get_published_dir;

  if ( -f "$published_dir/$state/LIBRARY/$filename" )
    {
      return 1;
    }

  return 0;
}

=head2 has_published_file

Check for the existence of a specific file in the 'published'
directory under the specified state (DRAFT, REVIEW, or APPROVED).
Return 1 if the file exists.

  my $result = $library->has_published_file($state,$filename);

=cut

######################################################################

sub has_published_document {

  my $self = shift;

  my $state       = shift;              # DRAFT, REVIEW, APPROVED
  my $document_id = shift;

  my $href = $self->_get_published_document_hash;

  if ( exists $href->{$state}{$document_id} )
    {
      return 1;
    }

  return 0;
}

=head2 has_published_document

Check for the existence of a published document in the 'published'
directory under the specified state (DRAFT, REVIEW, or APPROVED).
Return 1 if the document exists.

  my $result = $library->has_published_document($state,$filename);

=cut

######################################################################

sub has_published_document_rendition {

  my $self = shift;

  my $state       = shift;
  my $document_id = shift;
  my $rendition   = shift;

  my $published_dir = $self->get_published_dir;
  my $filespec      = q{};

  if ( $rendition eq 'html' )
    {
      $filespec = "$published_dir/$state/$document_id/titlepage.html";
    }

  elsif ( $rendition eq 'pdf' )
    {
      $filespec = "$published_dir/$state/$document_id/$document_id.pdf";
    }

  else
    {
      $logger->error("UNKNOWN RENDITION $rendition");
      return 0;
    }

  if ( -f $filespec )
    {
      return 1;
    }

  return 0;
}

=head2 has_published_document

Check for the existence of a published document rendition (HTML, PDF)
in the 'published' directory under the specified state (DRAFT, REVIEW,
or APPROVED).  Return 1 if the published document exists.

  my $result = $library->has_published_document_rendition($state,$id,$rendition);

=cut

######################################################################

sub has_published_document_property_value {

  my $self = shift;

  my $state         = shift;            # DRAFT, REVIEW, APPROVED
  my $document_id   = shift;
  my $property_name = shift;

  my $href = $self->_get_published_document_hash;

  if ( exists $href->{$state}{$document_id}{$property_name} )
    {
      return 1;
    }

  return 0;
}

=head2 has_published_document_property_value

Check for the existence of a published document property name in the
'published' directory under the specified state (DRAFT, REVIEW, or
APPROVED).  Return 1 if the published document property name exists.

  my $result = $library->has_published_document_property_value($state,$id,$property_name);

=cut

######################################################################

sub get_published_document_property_value {

  my $self = shift;

  my $state         = shift;            # DRAFT, REVIEW, APPROVED
  my $document_id   = shift;
  my $property_name = shift;

  my $href = $self->_get_published_document_hash;

  unless ( exists $href->{$state}{$document_id}{$property_name} )
    {
      $logger->error("CAN'T GET PUBLISHED DOCUMENT PROPERTY VALUE $state $document_id $property_name");
      return 0;
    }

  my $util = $self->get_util;

  my $text = $href->{$state}{$document_id}{$property_name};

  return $util->strip_string_markup($text);
}

=head2 get_published_document_property_value

Return the value of a published document property.

  my $result = $library->get_published_document_property_value($state,$id,$property_name);

=cut

######################################################################

sub has_published_library_property_value {

  my $self = shift;

  my $state         = shift;            # DRAFT, REVIEW, APPROVED
  my $property_name = shift;

  my $href = $self->_get_published_library_hash;

  if ( exists $href->{$state}{$property_name} )
    {
      return 1;
    }

  return 0;
}

=head2 has_published_library_property_value

Check if the published library in the specified state (DRAFT, REVIEW,
APPROVED) has a property with the specified name.

  my $result = $library->has_published_library_property_value($state,$property_name);

=cut

######################################################################

sub get_published_library_property_value {

  my $self = shift;

  my $state         = shift;            # DRAFT, REVIEW, APPROVED
  my $property_name = shift;

  my $href = $self->_get_published_library_hash;

  unless ( exists $href->{$state}{$property_name} )
    {
      $logger->error("CAN'T GET PUBLISHED LIBRARY PROPERTY VALUE $state $property_name");
      return 0;
    }

  my $util = $self->get_util;

  return $href->{$state}{$property_name};
}

=head2 get_published_library_property_value

Return the value of the specified published library property for the
specified state (DRAFT, REVIEW, APPROVED).

  my $text = $library->get_published_library_property_value($state,$property_name);

=cut

######################################################################

sub add_error {

  my $self  = shift;
  my $error = shift;

  unless ( $error )
    {
      $logger->error("CAN'T ADD ERROR, MISSING ARGUMENT");
      return 0;
    }

  unless ( ref $error and $error->isa('SML::Error') )
    {
      $logger->error("CAN'T ADD ERROR, NOT AN ERROR $error");
      return 0;
    }

  my $href     = $self->_get_error_hash;
  my $level    = $error->get_level;
  my $location = $error->get_location;
  my $message  = $error->get_message;

  if ( exists $href->{$level}{$location}{$message} )
    {
      # $logger->warn("ERROR ALREADY EXISTS $level $location $message");
      return 0;
    }

  $href->{$level}{$location}{$message} = $error;

  return 1;
}

=head2 add_error

Add the specified error to the library's error collection.

  my $result = $library->add_error($error);

=cut

######################################################################

sub get_error_list {

  my $self = shift;

  my $aref = [];

  my $href = $self->_get_error_hash;

  foreach my $level ( sort keys %{ $href } )
    {
      foreach my $location ( sort keys %{ $href->{$level} } )
	{
	  foreach my $message ( sort keys %{ $href->{$level}{$location} })
	    {
	      my $error = $href->{$level}{$location}{$message};

	      push @{$aref}, $error;
	    }
	}
    }

  return $aref;
}

=head2 get_error_list

Return an ArrayRef to a list of errors in the library.

  my $aref = $library->get_error_list;

=cut

######################################################################

sub get_error_count {

  my $self = shift;

  return scalar @{ $self->get_error_list };
}

=head2 get_error_count

Return an integer count of the number of errors in the library.

  my $count = $library->get_error_count;

=cut

######################################################################

sub contains_error {

  my $self = shift;

  my $href = $self->_get_error_hash;

  if ( scalar keys %{$href} )
    {
      return 1;
    }

  return 0;
}

=head2 contains_error

Return 1 if the library contains an error.

  my $result = $library->contains_error;

=cut

######################################################################

sub store_sha_digest_file {

  my $self = shift;

  $logger->info("update sha digest file");

  my $begin = time();

  $self->get_all_entities;
  $self->get_all_documents;

  my $filespec = $self->_get_sha_digest_filespec;

  my $us_id_hash = $self->_get_user_specified_id_hash;
  my $us_id_list = [ sort keys %{ $us_id_hash } ];

  open my $fh, ">", $filespec or die "Can't open $filespec: $!\n";
  foreach my $id (@{ $us_id_list })
    {
      my $division = $self->get_division($id);

      if ( $division )
	{
	  my $sha_digest = $division->get_sha_digest;
	  print $fh "$sha_digest $id\n";
	}
    }
  close $fh;

  my $end = time();
  my $duration = duration($end - $begin);

  $logger->info("update sha digest file $duration");

  return 1;
}

=head2 store_sha_digest_file

Store a SHA1 digest file containing a SHA1 digest for every division
with an ID.  Return 1 if successful.

  my $result = $library->store_sha_digest_file;

=cut

######################################################################

sub contains_changes {

  my $self = shift;

  my $aref = $self->get_change_list;

  if ( scalar @{$aref} )
    {
      return 1;
    }

  return 0;
}

=head2 contains_changes

Return 1 if this document contains changes from a previous version
that can be enumerated on a change page.

  my $result = $library->contains_changes;

=cut

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has config_filespec =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => '_get_config_filespec',
   lazy      => 1,
   builder   => '_build_config_filespec',
  );

######################################################################

has config_filename =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => '_get_config_filename',
   default   => 'library.conf',
  );

######################################################################

has ontology_rule_filename_list =>
  (
   is        => 'ro',
   isa       => 'ArrayRef',
   reader    => '_get_ontology_rule_filename_list',
   writer    => '_set_ontology_rule_filename_list',
   default   => sub {['ontology_rules_sml.conf','ontology_rules_lib.conf']}
  );

######################################################################

has directory_name =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => '_get_directory_name',
   default   => 'library',
  );

# This is the name of the directory containing the library.

######################################################################

has id_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_id_hash',
   default   => sub {{}},
  );

# $href->{$id} = [$filename,$division_name];
#
# This is the collection of all divisions IDs in the library.
# Division IDs are either user-specified or system generated.  This
# hash contains ALL divisions IDs.

######################################################################

has user_specified_id_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_user_specified_id_hash',
   default   => sub {{}},
  );

# $href->{$id} = [$filename,$division_name];
#
# This is the collection of user-specified divisions IDs in the
# library.  Division IDs are either user-specified or system
# generated.  This hash contains ONLY USER SPECIFIED divisions IDs.

######################################################################

has filespec_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_filespec_hash',
   default   => sub {{}},
  );

# $filespec_hash->{$filename} = "$path/$filename";
#
# This is the collection of all text files in the library.

######################################################################

has file_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_file_hash',
   default   => sub {{}},
  );

# This is the collection of text files in the library.  The keys of
# this hash are the file names and the values are the file objects.

######################################################################

has document_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_document_hash',
   default   => sub {{}},
  );

# This is the collection of documents in the library.  The keys of
# this hash are the document IDs and the values are the document
# objects.

######################################################################

has division_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_division_hash',
   writer    => '_set_division_hash',
   clearer   => '_clear_division_hash',
   predicate => '_has_division_hash',
   default   => sub {{}},
  );

# This is a hash of all divisions indexed by division ID.
#
#   my $division = $dh->{$id};

######################################################################

has entity_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_entity_hash',
   predicate => 'has_entity_hash',
   default   => sub {{}},
  );

# This is the collection of entities in the library.  The keys of this
# hash are the entity IDs and the values are the entity objects.

######################################################################

has variable_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_variable_hash',
   default   => sub {{}},
  );

#   $variable_ds->{$name}{$namespace} = $definition;

######################################################################

has outcome_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_outcome_hash',
   default   => sub {{}},
  );

# Outcome Data structure.  An outcome describes the result of a test
# or audit of an entity.

# PROBLEM: This outcome data structure does not allow for more than
# one test or audit of an entity in the same day.

# PROBLEM: The semantics of outcomes and the status of entities are
# specific to the engineering domain.  Perhaps this functionality
# should be in a PLUG-IN rather than in the core code.

#   $oh->{$entity}{$date}{'status'}      = $status;
#   $oh->{$entity}{$date}{'description'} = $description;

######################################################################

has review_hash =>
  (
   is       => 'ro',
   isa      => 'HashRef',
   reader   => '_get_review_hash',
   default  => sub {{}},
  );

# Review Data structure.  A review describes the result of an informal
# test or informal audit of an entity.

#   $rh->{$entity}{$date}{'status'}      = $status;
#   $rh->{$entity}{$date}{'description'} = $description;

######################################################################

has insert_name_hash =>
  (
   is       => 'ro',
   isa      => 'HashRef',
   reader   => '_get_insert_name_hash',
   lazy     => 1,
   builder  => '_build_insert_name_hash',
  );

######################################################################

has generated_content_type_hash =>
  (
   is       => 'ro',
   isa      => 'HashRef',
   reader   => '_get_generated_content_type_hash',
   lazy     => 1,
   builder  => '_build_generated_content_type_hash',
  );

######################################################################

has parser_count =>
  (
   is       => 'ro',
   isa      => 'Int',
   reader   => '_get_parser_count',
   writer   => '_set_parser_count',
   default  => 0,
  );

# This is a count of the number of parsers the Library has created.

######################################################################

has division_counter_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_division_counter_hash',
   writer    => '_set_division_counter_hash',
   clearer   => '_clear_division_counter_hash',
   default   => sub {{}},
  );

# $href->{$division_name} = $count;

######################################################################

has published_document_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_published_document_hash',
   lazy      => 1,
   builder   => '_build_published_document_hash',
  );

# This hash holds the metadata about published documents and is used
# to produce the library index page.
#
# $href->{$state}{$document_id}{$property_name} = $string;
#
# $href->{'DRAFT'}{'sdd-sml'}{'version'} = 'v2.0';
# $href->{'DRAFT'}{'sdd-sml'}{'date'}    = '2015-12-20';

######################################################################

has published_library_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_published_library_hash',
   lazy      => 1,
   builder   => '_build_published_library_hash',
  );

# This hash holds the metadata about published libraries and is used
# to produce the overall main page.
#
# $href->{$state}{$property_name} = $string;
#
# $href->{'DRAFT'}{'version'} = 'v2.0';
# $href->{'DRAFT'}{'date'}    = '2015-12-20';

######################################################################

has error_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_error_hash',
   default => sub {{}},
  );

# This is a hash of error objects.

# $href->{$level}{$location}{$message} = $error;

# see also: add_error, get_error_list

######################################################################

has sha_digest_filename =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => '_get_sha_digest_filename',
   default => '.sha_digest',
  );

# The SHA digest file is a library file that stores the SHA digest of
# each identified library division.  That is, every division with an
# ID.
#
# The purpose of storing the SHA digest for every identified division
# is to detect when the division changed.  By comparing the SHA digest
# file from one version of the library to the SHA digest file from
# another you can detect what has changed.
#
# Since each SHA digest represents the *parsed* manuscript of the
# division, the digest will change even when an INCLUDED division
# changes.

######################################################################

has sha_digest_filespec =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => '_get_sha_digest_filespec',
   lazy    => 1,
   builder => '_build_sha_digest_filespec',
  );

######################################################################

has got_all_entities =>
  (
   is      => 'ro',
   isa     => 'Bool',
   reader  => '_got_all_entities',
   writer  => '_set_got_all_entities',
   default => 0,
  );

######################################################################

has got_all_documents =>
  (
   is      => 'ro',
   isa     => 'Bool',
   reader  => '_got_all_documents',
   writer  => '_set_got_all_documents',
   default => 0,
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub BUILD {

  my $self = shift;

  my $config_filespec = $self->_get_config_filespec;
  my $syntax          = $self->get_syntax;
  my $ontology        = $self->get_ontology;
  my %config          = ();
  my $directory_path  = q{};
  my $catalog_file    = q{};
  my $current_dir     = getcwd;
  my $config_dir      = dirname($config_filespec);
  my $library_dir     = '';

  use Config::General;
  use SML::Parser;

  # validate existence of config file
  if ( not -f $config_filespec )
    {
      die "Couldn't read $config_filespec\n";
    }

  # read the config file
  else
    {
      my $config = Config::General->new($config_filespec);
      %config = $config->getall;
    }

  # set library ID
  if ( $config{'id'} )
    {
      $self->_set_id($config{'id'});
    }

  # set library name
  if ( $config{'name'} )
    {
      $self->_set_name($config{'name'});
    }

  # set library version
  if ( $config{'version'} )
    {
      $self->_set_version($config{'version'});
    }

  # set library previous version
  if ( $config{'previous_version'} )
    {
      $self->_set_previous_version($config{'previous_version'});
    }

  # set library directory path
  if ( $config_dir and $config{'directory_path'} )
    {
      $library_dir = "$config_dir/$config{'directory_path'}";

      unless ( -d $library_dir )
	{
	  $logger->logdie("no such library directory: $library_dir");
	}

      $self->_set_directory_path($library_dir);
    }

  # set template_dir
  if ( $config{'template_dir'} )
    {
      my $directory_path = $self->get_directory_path;
      my $template_dir   = "$directory_path/$config{template_dir}";

      $self->_set_template_dir($template_dir);
    }

  # set published_dir
  if ( $config{'published_dir'} )
    {
      my $directory_path = $self->get_directory_path;
      my $published_dir  = "$directory_path/$config{published_dir}";

      $self->_set_published_dir($published_dir);
    }

  # set plugins_dir
  if ( $config{'plugins_dir'} )
    {
      my $directory_path = $self->get_directory_path;
      my $plugins_dir  = "$directory_path/$config{plugins_dir}";

      $self->_set_plugins_dir($plugins_dir);
    }

  # set images_dir
  if ( $config{'images_dir'} )
    {
      my $directory_path = $self->get_directory_path;
      my $images_dir  = "$directory_path/$config{images_dir}";

      $self->_set_images_dir($images_dir);
    }

  # populate images list
  if ( -d $self->get_images_dir )
    {
      my $images_dir = $self->get_images_dir;
      my $aref       = $self->get_image_list;

      opendir(DIR,"$images_dir") or die "Couldn't open dir: $images_dir";
      foreach my $image ( grep {/\.(png|jpg|jpeg|gif)$/} readdir(DIR) )
	{
	  push(@{$aref},$image);
	}
      closedir(DIR);
    }

  # set include_path
  if ( $config{'include_path'} )
    {
      if ( ref $config{'include_path'} eq 'ARRAY' )
	{
	  foreach my $path (@{$config{'include_path'}})
	    {
	      $self->_add_include_path($path);
	    }
	}

      else
	{
	  $self->_add_include_path($config{'include_path'});
	}
    }

  # set document_presentation_id_list
  if ( $config{'document'} )
    {
      if ( ref $config{'document'} eq 'ARRAY' )
	{
	  foreach my $id (@{$config{'document'}})
	    {
	      $self->_add_document_presentation_id($id);
	    }
	}

      else
	{
	  $self->_add_document_presentation_id($config{'document'});
	}
    }

  # set ontology rule file list
  my $rule_file_list = [];

  if ( $config{'ontology_rule_file'} )
    {
      if ( ref $config{'ontology_rule_file'} eq 'ARRAY' )
	{
	  foreach my $filename (@{ $config{'ontology_rule_file'} })
	    {
	      push @{$rule_file_list}, $filename;
	    }
	}

      else
	{
	  push @{$rule_file_list}, $config{'ontology_rule_file'};
	}
    }

  $self->_set_ontology_rule_filename_list($rule_file_list);

  #-------------------------------------------------------------------
  # scan for divisions, populate id_hash
  #
  my $cwd = getcwd();
  chdir($library_dir);

  my $id_hash         = $self->_get_id_hash;
  my $us_id_hash      = $self->_get_user_specified_id_hash;
  my $filespec_hash   = $self->_get_filespec_hash;
  my $division_count  = {};
  my $entity_count    = {};
  my $structure_count = {};

  foreach my $directory (@{ $self->get_include_path_list })
    {
      opendir(DIR,"$directory")
	or die "Couldn't open dir: $directory from $cwd";
      my @filelist = grep { /\.txt$/} readdir(DIR);
      closedir(DIR);

      foreach my $textfile ( @filelist )
	{
	  my $filespec = "$directory/$textfile";
	  $logger->debug("scanning $filespec...");
	  $filespec_hash->{$filespec} = "$filespec";

	  my $lines = [];
	  open my $fh, "<", "$filespec"
	    or die "Can't open $filespec: $!\n";
	  @{ $lines } = <$fh>;
	  close $fh;

	  my $in_comment_division = 0;

	  foreach (@{ $lines })
	    {
	      if (/$syntax->{comment_line}/)
		{
		  next;
		}

	      elsif (/$syntax->{start_division}/ and $1 eq 'COMMENT')
		{
		  $in_comment_division = 1;
		}

	      elsif (/$syntax->{end_division}/ and $1 eq 'COMMENT')
		{
		  $in_comment_division = 0;
		}

	      elsif ( $in_comment_division )
		{
		  next;
		}

	      elsif (/$syntax->{start_division}/)
		{
		  my $name = $1;

		  # validate the ontology allows this division name
		  unless ( $ontology->allows_division_name($name) )
		    {
		      $logger->logdie("UNKNOWN DIVISION \'$name\' IN \'$filespec\'");
		      return 0;
		    }

		  ++ $division_count->{$name};

		  if ( $ontology->is_structure($name) )
		    {
		      ++ $structure_count->{$name};
		    }

		  elsif ( $ontology->is_entity($name) )
		    {
		      ++ $entity_count->{$name};
		    }

		  else
		    {
		      $logger->error("NEITHER STRUCTURE OR ENTITY: $name");
		    }

		  my $id = $3 || $name . "-" . $division_count->{$name};

		  # validate ID uniqueness (unless this is a CONDITIONAL division)
		  unless ( $name eq 'CONDITIONAL' )
		    {
		      if ( exists $id_hash->{$id} )
			{
			  my $firstfile = $id_hash->{$id}->[0];
			  $logger->logdie("DUPLICATE ID \'$id\' IN \'$filespec\' (ALSO IN \'$firstfile\')");
			}

		      else
			{
			  $id_hash->{$id} = [$filespec,$name];

			  if ( $3 )
			    {
			      $us_id_hash->{$id} = [$filespec,$name];
			    }
			}
		    }
		}

	      elsif (/$syntax->{start_section}/)
		{
		  my $name = 'SECTION';

		  ++ $division_count->{$name};
		  ++ $structure_count->{$name};

		  my $id = $3 || $name . "-" . $division_count->{$name};

		  $logger->debug("division: $name $id");

		  if ( exists $id_hash->{$id} )
		    {
		      my $firstfile = $id_hash->{$id}->[0];
		      $logger->logdie("DUPLICATE ID \'$id\' IN \'$filespec\' (ALSO IN \'$firstfile\')");
		    }

		  else
		    {
		      $id_hash->{$id} = [$filespec,$name];

		      if ( $3 )
			{
			  $us_id_hash->{$id} = [$filespec,$name];
			}
		    }
		}
	    }
	}
    }

  my $entity_total = 0;

  my $libname = $self->get_name;
  $logger->info("$libname");
  $logger->info("------------------------------ ------");

  foreach my $name ( sort keys %{ $entity_count } )
    {
      my $count = $entity_count->{$name};
      $entity_total = $entity_total + $count;
      my $msg = sprintf
	(
	 "%-30s %6d",
	 "$name count:",
	 $count,
	);

      $logger->info("$msg");
    }

  my $entity_total_msg = sprintf
    (
     "%-30s %6d",
     "TOTAL ENTITY COUNT:",
     $entity_total,
    );

  $logger->info("------------------------------ ------");
  $logger->info("$entity_total_msg");
  $logger->info("");

  my $structure_total = 0;

  $logger->info("------------------------------ ------");
  foreach my $name ( sort keys %{ $structure_count } )
    {
      my $count = $structure_count->{$name};
      $structure_total = $structure_total + $count;
      my $msg = sprintf
	(
	 "%-30s %6d",
	 "$name count:",
	 $count,
	);

      $logger->info("$msg");
    }

  my $structure_total_msg = sprintf
    (
     "%-30s %6d",
     "TOTAL STRUCTURE COUNT:",
     $structure_total,
    );

  $logger->info("------------------------------ ------");
  $logger->info("$structure_total_msg");
  $logger->info("");

  $logger->info("------------------------------ ------");

  my $div_rule_count = $ontology->get_rule_type_count('div');
  my $prp_rule_count = $ontology->get_rule_type_count('prp');
  my $cmp_rule_count = $ontology->get_rule_type_count('cmp');
  my $enu_rule_count = $ontology->get_rule_type_count('enu');
  my $def_rule_count = $ontology->get_rule_type_count('def');

  my $total_rule_count = $div_rule_count + $prp_rule_count + $cmp_rule_count + $enu_rule_count + $def_rule_count;

  my $msg1 = sprintf("%-30s %6d","Division Declaration Rules:",$div_rule_count);
  my $msg2 = sprintf("%-30s %6d","Property Declaration Rules:",$prp_rule_count);
  my $msg3 = sprintf("%-30s %6d","Composition Declaration Rules:",$cmp_rule_count);
  my $msg4 = sprintf("%-30s %6d","Enumeration Declaration Rules:",$enu_rule_count);
  my $msg5 = sprintf("%-30s %6d","Default Declaration Rules:",$def_rule_count);
  my $msg6 = sprintf("%-30s %6d","TOTAL ONTOLOGY RULE COUNT:",$total_rule_count);

  $logger->info("$msg1");
  $logger->info("$msg2");
  $logger->info("$msg3");
  $logger->info("$msg4");
  $logger->info("$msg5");
  $logger->info("------------------------------ ------");
  $logger->info("$msg6");
  $logger->info("");

  chdir($cwd);

  return 1;
}

######################################################################

sub _build_published_document_hash {

  my $self = shift;

  my $href             = {};
  my $published_dir    = $self->get_published_dir;
  my $state_list       = ['DRAFT','REVIEW','APPROVED'];
  my $document_id_list = $self->get_document_presentation_id_list;
  my $syntax           = $self->get_syntax;

  foreach my $id (@{ $document_id_list })
    {
      foreach my $state (@{ $state_list })
	{
	  my $filespec = "$published_dir/$state/$id/METADATA.txt";

	  if ( -f $filespec )
	    {
	      my $raw_line_list = [];

	      open my $fh, "<", $filespec or die "Can't open $filespec: $!\n";
	      @{ $raw_line_list } = <$fh>;
	      close $fh;

	      my $property_name  = q{};
	      my $property_value = q{};

	      foreach my $line (@{ $raw_line_list })
		{
		  if ( $line =~ /$syntax->{element}/ )
		    {
		      # $1 = element name
		      # $2 = element args
		      # $3 = element value
		      # $4
		      # $5 = comment text

		      $property_name  = $1;
		      $property_value = $3;

		      $href->{$state}{$id}{$property_name} = $property_value;
		    }

		  elsif ( $line =~ /$syntax->{blank_line}/ )
		    {
		      $property_name  = q{};
		      $property_value = q{};
		    }

		  elsif ( $line =~ /$syntax->{paragraph_text}/ )
		    {
		      # $1 = table cell markup (begin table cell)
		      # $2 = paragraph text

		      $property_value .= $2;

		      $href->{$state}{$id}{$property_name} = $property_value;
		    }
		}
	    }
	}
    }

  return $href;
}

######################################################################

sub _build_published_library_hash {

  my $self = shift;

  my $href          = {};
  my $published_dir = $self->get_published_dir;
  my $state_list    = ['DRAFT','REVIEW','APPROVED'];
  my $syntax        = $self->get_syntax;

  foreach my $state (@{ $state_list })
    {
      my $filespec = "$published_dir/$state/LIBRARY/METADATA.txt";

      if ( -f $filespec )
	{
	  my $raw_line_list = [];

	  open my $fh, "<", $filespec or die "Can't open $filespec: $!\n";
	  @{ $raw_line_list } = <$fh>;
	  close $fh;

	  my $property_name  = q{};
	  my $property_value = q{};

	  foreach my $line (@{ $raw_line_list })
	    {
	      if ( $line =~ /$syntax->{element}/ )
		{
		  # $1 = element name
		  # $2 = element args
		  # $3 = element value
		  # $4
		  # $5 = comment text

		  $property_name  = $1;
		  $property_value = $3;

		  $href->{$state}{$property_name} = $property_value;
		}

	      elsif ( $line =~ /$syntax->{blank_line}/ )
		{
		  $property_name  = q{};
		  $property_value = q{};
		}

	      elsif ( $line =~ /$syntax->{paragraph_text}/ )
		{
		  # $1 = table cell markup (begin table cell)
		  # $2 = paragraph text

		  $property_value .= $2;

		  $href->{$state}{$property_name} = $property_value;
		}
	    }
	}
    }

  return $href;
}

######################################################################

sub _add_include_path {

  # Add a directory to the include_path array (if it exists).

  my $self = shift;
  my $path = shift;

  my $include_path   = $self->get_include_path_list;
  my $directory_path = $self->get_directory_path;

  if ( not -d "$directory_path/$path" )
    {
      $logger->error("PATH NOT FOUND \'$path\'");
      return 0;
    }

  push @{$include_path}, $path;

  return 1;
}

######################################################################

sub _add_document_presentation_id {

  # Add a document ID to the document_presentation_id_list.  This is
  # the list of document IDs in the order they should be presented in
  # the library index.

  my $self = shift;
  my $id   = shift;

  my $aref = $self->get_document_presentation_id_list;

  push @{$aref}, $id;

  return 1;
}

######################################################################

sub _build_util {
  my $self = shift;
  return SML::Util->new(library=>$self);
}

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

sub _build_revision {

  my $self = shift;

  my $directory_path = $self->get_directory_path;
  my $svn            = $self->_find_svn_executable;

  if (not -e $svn) {
    $logger->error("svn program $svn is not executable");
    return 0;
  }

  my $info = eval { `$svn info \"$directory_path\"` };

  if ($info =~ /Last\s+Changed\s+Rev:\s+(\d+)/)
    {
      return $1;
    }

  else
    {
      $logger->warn("unknown SVN revision: $directory_path");
      return 0;
    }
}

######################################################################

sub _build_config_filespec {

  # Find the configuration file by looking for it in a list of
  # directories.

  my $self = shift;

  my $directory_name = $self->_get_directory_name;
  my $filename       = $self->_get_config_filename;

  use FindBin qw($Bin);

  my $dir_list =
    [
     "$Bin/..",
     "$Bin/../conf",
     "$Bin",
     "$Bin/conf/$directory_name",
     "$Bin/$directory_name",
     "$Bin/../conf/$directory_name",
     "$Bin/../$directory_name",
     "$Bin/../../conf/$directory_name",
     "$Bin/../../$directory_name",
    ];

  foreach my $dir (@{ $dir_list })
    {
      if ( -r "$dir/$filename" )
	{
	  $logger->debug("library config filespec: $dir/$filename");
	  return "$dir/$filename";
	}
    }

  foreach my $dir (@{ $dir_list })
    {
      $logger->fatal("checked: $dir");
    }

  $logger->logdie("COULD NOT LOCATE LIBRARY CONFIG FILE");
  return 0;
}

######################################################################

sub _build_sml_ontology_rule_filespec {

  use FindBin qw($Bin);

  my $self = shift;

  my $directory_name = $self->_get_directory_name;
  my $filename       = $self->_get_sml_ontology_rule_filename;

  my $dir_list =
    [
     "$Bin/..",
     "$Bin/../conf",
     "$Bin/../ontology",
     "$Bin",
     "$Bin/conf/$directory_name",
     "$Bin/ontology/$directory_name",
     "$Bin/$directory_name",
     "$Bin/../conf/$directory_name",
     "$Bin/../ontology/$directory_name",
     "$Bin/../$directory_name",
     "$Bin/../../conf/$directory_name",
     "$Bin/../../ontology/$directory_name",
     "$Bin/../../$directory_name",
    ];

  foreach my $dir (@{ $dir_list })
    {
      if ( -r "$dir/$filename" )
	{
	  $logger->debug("SML ontology config filespec: $dir/$filename");
	  return "$dir/$filename";
	}
    }

  foreach my $dir (@{ $dir_list })
    {
      $logger->fatal("checked: $dir");
    }

  $logger->logdie("COULD NOT LOCATE SML ONTOLOGY CONFIG FILE");
  return 0;
}

######################################################################

sub _build_ontology_rule_filespec_list {

  use FindBin qw($Bin);

  my $self = shift;

  my $fslist = [];                      # filespec list
  my $fnlist = $self->_get_ontology_rule_filename_list;

  my $dir_list =
    [
     "$Bin",
     "$Bin/conf",
     "$Bin/ontology",
     "$Bin/..",
     "$Bin/../conf",
     "$Bin/../ontology",
     "$Bin/../../conf",
     "$Bin/../../ontology",
     "$Bin/../..",
    ];

  foreach my $filename (@{ $fnlist })
    {
      my $found = 0;
      foreach my $dir (@{ $dir_list })
	{
	  if ( -r "$dir/$filename" )
	    {
	      $found = 1;
	      $logger->debug("library ontology config filespec: $dir/$filename");
	      push(@{$fslist},"$dir/$filename");
	    }
	}

      if ( not $found )
	{
	  foreach my $dir (@{ $dir_list })
	    {
	      $logger->fatal("checked: $dir");
	    }

	  $logger->logdie("COULD NOT LOCATE LIBRARY ONTOLOGY CONFIG FILE");
	}
    }

  return $fslist;
}

######################################################################

sub _build_ontology {
  my $self = shift;
  return SML::Ontology->new(library=>$self);
}

######################################################################

sub _build_reasoner {
  my $self = shift;
  return SML::Reasoner->new(library=>$self);
}

######################################################################

sub _build_publisher {
  my $self = shift;
  return SML::Publisher->new(library=>$self);
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

sub _build_index {
  my $self = shift;
  return SML::Index->new( library => $self );
}

######################################################################

sub _build_division_names {

  my $self = shift;
  my $aref = [ sort keys %{ $self->_get_division_hash } ];

  return $aref;
}

######################################################################

sub _build_region_names {

  # Return a list of region names.

  my $self      = shift;
  my $names     = [];

  foreach my $name ( sort keys %{ $self->_get_division_hash } )
    {
      if
	(
	 $self->_get_division_hash->{$name}[0] eq 'SML::Region'
	 or
	 $self->_get_division_hash->{$name}[0] eq 'SML::Entity'
	)
	{
	  push( @{ $names }, $name );
	}
    }

  return $names;
}

######################################################################

sub _build_environment_names {

  # Return a list of environment names.

  my $self     = shift;
  my $ontology = $self->get_ontology;

  return $ontology->get_allowed_environment_list;
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

sub _find_svn_executable {

  my $self = shift;

  if ( $^O eq 'MSWin32')
    {
      my $options = $self->get_options;

      return $options->get_svn_executable;
    }

  elsif ( $^O eq 'linux' )
    {
      my $svn = `which svn`;

      $svn =~ s/[\r\n]*$//;
      # chomp($svn);

      if ($svn)
	{
	  return $svn;
	}

      else
	{
	  $logger->error("SVN EXECUTABLE NOT FOUND");
	  return 0;
	}
    }

  $logger->error("SVN EXECUTABLE NOT FOUND");
  return 0;
}

######################################################################

sub _build_insert_name_hash {

  my $self = shift;

  return
    {
     PREAMBLE   => 1,
     NARRATIVE  => 1,
     DEFINITION => 1,
    };
}

######################################################################

sub _build_generated_content_type_hash {

  my $self = shift;

  return
    {
     'problem-domain-listing'       => "not context sensitive",
     'solution-domain-listing'      => "not context sensitive",
     'prioritized-problem-listing'  => "not context sensitive",
     'prioritized-solution-listing' => "not context sensitive",
     'associated-problem-listing'   => "context sensitive",
     'associated-solution-listing'  => "context sensitive",
    };
}

######################################################################

sub _build_sha_digest_filespec {

  my $self = shift;

  my $path     = $self->get_directory_path;
  my $filename = $self->_get_sha_digest_filename;

  return "$path/$filename";
}

######################################################################

sub _build_change_list {

  # Return an ArrayRef that represents changes since the previous
  # version of the document:

  my $self = shift;

  # To have a complete view of all changes, the library must first
  # parse all entities and documents into memory.  If an entity or
  # document is already in memory it will not be re-parsed.

  $self->get_all_entities;
  $self->get_all_documents;

  my $href = {};

  unless ( $self->has_version and $self->has_previous_version )
    {
      return $href;
    }

  my $previous_version = $self->get_previous_version;
  my $options          = $self->get_options;

  if ( $options->use_git )
    {
      my $git = $options->get_git_executable;

      unless ( -e $git )
	{
	  $logger->error("CAN'T BUILD CHANGE LIST, git NOT EXECUTABLE $git");
	  return [];
	}

      my $directory_path = $self->get_directory_path;

      unless ( -d "$directory_path/.git" )
	{
	  $logger->error("CAN'T BUILD CHANGE LIST, NO .git DIRECTORY");
	  return [];
	}

      my $sha_digest_filename = '.sha_digest';
      my $sha_digest_filespec = $self->_get_sha_digest_filespec;
      my $previous_sha_text   = `$git show $previous_version:$sha_digest_filename`;
      my $current_sha_text    = read_file($sha_digest_filespec);

      my $previous_sha_hash = {};
      my $current_sha_hash  = {};

      foreach my $line ( split /\n/, $previous_sha_text )
	{
	  if ( $line =~ /^(\S+)\s(\S+)$/ )
	    {
	      my $digest      = $1;
	      my $division_id = $2;

	      $previous_sha_hash->{$division_id} = $digest;
	    }

	  else
	    {
	      $logger->error("WEIRD LINE IN PREVIOUS SHA DIGEST FILE $line");
	    }
	}

      foreach my $line ( split /\n/, $current_sha_text )
	{
	  if ( $line =~ /^(\S+)\s(\S+)$/ )
	    {
	      my $digest      = $1;
	      my $division_id = $2;

	      $current_sha_hash->{$division_id} = $digest;
	    }

	  else
	    {
	      $logger->error("WEIRD LINE IN CURRENT SHA DIGEST FILE $line");
	    }
	}

      foreach my $id ( keys %{ $previous_sha_hash } )
	{
	  if ( not exists $current_sha_hash->{$id} )
	    {
	      $href->{DELETED}{$id} = 1;
	    }

	  else
	    {
	      my $previous_digest = $previous_sha_hash->{$id};
	      my $current_digest  = $current_sha_hash->{$id};

	      if ( $current_digest ne $previous_digest )
		{
		  $href->{UPDATED}{$id} = 1;
		}
	    }
	}

      foreach my $id ( keys %{ $current_sha_hash } )
	{
	  if ( not exists $previous_sha_hash->{$id} )
	    {
	      $href->{ADDED}{$id} = 1;
	    }

	  else
	    {
	      my $previous_digest = $previous_sha_hash->{$id};
	      my $current_digest  = $current_sha_hash->{$id};

	      if ( $current_digest ne $previous_digest )
		{
		  $href->{UPDATED}{$id} = 1;
		}
	    }
	}
    }

  my $aref = [];

  # list adds first
  foreach my $division_id ( sort keys %{ $href->{ADDED} } )
    {
      push @{$aref}, ['ADDED',$division_id];
    }

  # list deletes second
  foreach my $division_id ( sort keys %{ $href->{DELETED} } )
    {
      push @{$aref}, ['DELETED',$division_id];
    }

  # list updates third
  foreach my $division_id ( sort keys %{ $href->{UPDATED} } )
    {
      push @{$aref}, ['UPDATED',$division_id];
    }

  return $aref;
}

######################################################################

sub _build_add_count {

  my $self = shift;

  my $count = 0;

  foreach my $change (@{ $self->get_change_list })
    {
      my $action = $change->[0];

      ++ $count if $action eq 'ADDED';
    }

  return $count;
}

######################################################################

sub _build_delete_count {

  my $self = shift;

  my $count = 0;

  foreach my $change (@{ $self->get_change_list })
    {
      my $action = $change->[0];

      ++ $count if $action eq 'DELETED';
    }

  return $count;
}

######################################################################

sub _build_update_count {

  my $self = shift;

  my $count = 0;

  foreach my $change (@{ $self->get_change_list })
    {
      my $action = $change->[0];

      ++ $count if $action eq 'UPDATED';
    }

  return $count;
}

######################################################################

sub _build_property_store {

  my $self = shift;

  return SML::PropertyStore->new(library=>$self);
}

######################################################################

sub _build_options {

  return SML::Options->new;
}

######################################################################

sub _has_file {

  my $self     = shift;
  my $filename = shift;

  if ( exists $self->_get_file_hash->{$filename} )
    {
      return 1;
    }

  return 0;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012,2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
