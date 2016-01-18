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

use SML::Syntax;
use SML::Ontology;
use SML::Parser;
use SML::Reasoner;
use SML::Glossary;
use SML::AcronymList;
use SML::References;
use SML::Publisher;
use SML::Util;
use SML::Value;
use SML::Error;

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

# Specify the ID in the library configuration file.

######################################################################

has name =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_name',
   writer    => '_set_name',
   default   => 'library',
  );

# Specify the name in the library configuration file.

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

# This is the current version of the library.  Specify the version in
# the library configuration file.

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

# This is the previous version of the library.  Specify the previous
# version in the library configuration file.

######################################################################

has util =>
  (
   is        => 'ro',
   isa       => 'SML::Util',
   reader    => 'get_util',
   lazy      => 1,
   builder   => '_build_util',
  );

######################################################################

has syntax =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => 'get_syntax',
   lazy      => 1,
   builder   => '_build_syntax',
  );

######################################################################

has ontology =>
  (
   is        => 'ro',
   isa       => 'SML::Ontology',
   reader    => 'get_ontology',
   lazy      => 1,
   builder   => '_build_ontology',
  );

# The ontology describes the semantics of the library.

######################################################################

has ontology_rule_filespec_list =>
  (
   is        => 'ro',
   isa       => 'ArrayRef',
   reader    => 'get_ontology_rule_filespec_list',
   lazy      => 1,
   builder   => '_build_ontology_rule_filespec_list',
  );

# This is a list of filespecs containing individual ontology rules.
# These ontology rules specify the semantics of the library.

######################################################################

has reasoner =>
  (
   is        => 'ro',
   isa       => 'SML::Reasoner',
   reader    => 'get_reasoner',
   lazy      => 1,
   builder   => '_build_reasoner',
  );

# The reasoner performs first order inferences based on semantics
# declared in the ontology.

######################################################################

has publisher =>
  (
   is        => 'ro',
   isa       => 'SML::Publisher',
   reader    => 'get_publisher',
   lazy      => 1,
   builder   => '_build_publisher',
  );

# The publisher renders content presentations.

######################################################################

has glossary =>
  (
   is        => 'ro',
   isa       => 'SML::Glossary',
   reader    => 'get_glossary',
   lazy      => 1,
   builder   => '_build_glossary',
  );

# The glossary contains a library-wide collection of terms and their
# definitions.

######################################################################

has acronym_list =>
  (
   is        => 'ro',
   isa       => 'SML::AcronymList',
   reader    => 'get_acronym_list',
   lazy      => 1,
   builder   => '_build_acronym_list',
  );

# The acronym list contains a library-wide collection of acronyms and
# their meanings.

######################################################################

has references =>
  (
   is        => 'ro',
   isa       => 'SML::References',
   reader    => 'get_references',
   lazy      => 1,
   builder   => '_build_references',
  );

# The references object contains a library-wide collaction of source
# references.

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

# This is the name of the directory containing the library.

######################################################################

has include_path =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_include_path',
   default => sub {[]},
  );

# This is a list of paths that contain library text files.

######################################################################

# has division_name_list =>
#   (
#    is        => 'ro',
#    isa       => 'ArrayRef',
#    reader    => 'get_division_name_list',
#    lazy      => 1,
#    builder   => '_build_division_names',
#   );

######################################################################

has template_dir =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_template_dir',
   writer    => '_set_template_dir',
   default   => 'templates',
  );

# This is the path to the directory containing Perl Template Toolkit
# templates used to render content presentations.

######################################################################

has published_dir =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_published_dir',
   writer    => '_set_published_dir',
   default   => 'published',
  );

# This is the directory to which files containing published renditions
# are placed.

######################################################################

has plugins_dir =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_plugins_dir',
   writer    => '_set_plugins_dir',
   default   => 'plugins',
  );

# This is the directory containing plugins.  Plugins are
# library-specific perl modules that perform special rendering
# functions.

######################################################################

has images_dir =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_images_dir',
   writer    => '_set_images_dir',
   default   => 'images',
  );

# This is the directory containing images.  These are standard images
# used in documents.  For instance, they include a paperclip image
# that indicates attachements, and other icons used to represent
# status, priority, etc.

######################################################################

has image_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_image_list',
   default => sub {[]},
  );

######################################################################

has document_presentation_id_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_document_presentation_id_list',
   default => sub {[]},
  );

# This 'document_presentation_id_list' is a list of document IDs in
# the order they should be presented in the library index.

######################################################################

has change_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_change_list',
   lazy    => 1,
   builder => '_build_change_list',
  );

# push @{$list}, [$action,$division_id];

######################################################################

has add_count =>
  (
   is      => 'ro',
   isa     => 'Int',
   reader  => 'get_add_count',
   lazy    => 1,
   builder => '_build_add_count',
  );

# This is number of divisions that have been ADDED since the previous
# version.

######################################################################

has delete_count =>
  (
   is      => 'ro',
   isa     => 'Int',
   reader  => 'get_delete_count',
   lazy    => 1,
   builder => '_build_delete_count',
  );

# This is number of divisions that have been DELETED since the
# previous version.

######################################################################

has update_count =>
  (
   is      => 'ro',
   isa     => 'Int',
   reader  => 'get_update_count',
   lazy    => 1,
   builder => '_build_update_count',
  );

# This is number of divisions that have been UPDATED since the
# previous version.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

# sub publish {

#   # Publish a document.

#   my $self      = shift;
#   my $id        = shift;                # document ID
#   my $rendition = shift;                # html, latex, pdf...
#   my $style     = shift;                # default, fancy...

#   my $publisher = $self->get_publisher;

#   my $result = $publisher->publish($id,$rendition,$style);

#   return $result;
# }

######################################################################

sub publish_all_documents {

  my $self = shift;

  my $rendition = shift;
  my $style     = shift;

  my $begin = time();

  $logger->info("publish all library documents");

  my $publisher = $self->get_publisher;
  my $id_list   = $self->get_division_id_list_by_name('DOCUMENT');

  foreach my $id (@{ $id_list })
    {
      $publisher->publish($id,$rendition,$style);
    }

  my $end = time();
  my $duration = duration($end - $begin);

  $logger->info("publish all library documents $duration");

  return 1;
}

######################################################################

sub publish_library_pages {

  # Publish a library ontology and entities pages.

  my $self      = shift;
  my $rendition = shift || 'html';
  my $style     = shift || 'default';

  my $begin = time();

  $logger->info("publish $style $rendition library pages");

  my $publisher = $self->get_publisher;

  my $result = $publisher->publish_library_pages($rendition,$style);

  my $end = time();
  my $duration = duration($end - $begin);

  $logger->info("publish $style $rendition library pages $duration");

  return $result;
}

######################################################################

sub publish_library_index_page {

  # Publish a library index.

  my $self      = shift;
  my $rendition = shift || 'html';
  my $style     = shift || 'default';

  my $begin = time();

  $logger->info("publish $style $rendition library index");

  my $publisher = $self->get_publisher;

  my $result = $publisher->publish_index($rendition,$style);

  my $end = time();
  my $duration = duration($end - $begin);

  $logger->info("publish $style $rendition library index $duration");

  return $result;
}

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

######################################################################

sub get_file_containing_id {

  # Return the SML::File containing the specified division ID.

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

  if ( not $self->has_file($filename) )
    {
      my $filespec = $self->get_filespec($filename);
      my $file = SML::File->new(filespec=>$filespec,library=>$self);

      return $file;
    }

  my $file_hash = $self->_get_file_hash;

  return $file_hash->{$filename};
}

######################################################################

sub has_filespec {

  # Given a filename, determine if the file is in the library by
  # looking in each include path.

  my $self     = shift;
  my $filename = shift;

  my $include_path   = $self->get_include_path;
  my $directory_path = $self->get_directory_path;

  if ( -f "$directory_path/$filename" )
    {
      return 1;
    }

  foreach my $path ( @{$include_path} )
    {
      if ( -f "$directory_path/$path/$filename" )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub get_filespec {

  # Given a filename, find the file in the library by looking in each
  # include path.

  my $self     = shift;
  my $filename = shift;

  my $include_path   = $self->get_include_path;
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
  my $hash = $self->_get_division_hash;

  # Replace the division if it already exists.

  $hash->{$id} = $division;

  return 1;
}

######################################################################

sub add_variable {

  my $self       = shift;
  my $definition = shift;

  if ( $definition->isa('SML::Definition') )
    {
      my $name      = $definition->get_term;
      my $namespace = $definition->get_namespace || q{};

      $self->_get_variable_hash->{$name}{$namespace} = $definition;

      return 1;
    }

  else
    {
      $logger->error("CAN'T ADD VARIABLE \'$definition\' is not a SML::Definition");
      return 0;
    }
}

######################################################################

sub add_index_term {

  my $self  = shift;
  my $term  = shift;
  my $divid = shift;

  if ( exists $self->_get_index_hash->{$term} )
    {
      my $index = $self->_get_index_hash->{$term};
      $index->{ $divid } = 1;
    }

  else
    {
      $self->_get_index_hash->{$term} = { $divid => 1 };
    }

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

  my $self    = shift;
  my $outcome = shift;

  my $oh = $self->_get_outcome_hash;

  my $date      = $outcome->get_date;
  my $entity_id = $outcome->get_entity_id;

  $oh->{$entity_id}{$date}{status}      = $outcome->get_status;
  $oh->{$entity_id}{$date}{description} = $outcome->get_description;
  $oh->{$entity_id}{$date}{outcome}     = $outcome;

  my $util    = $self->get_util;
  my $options = $util->get_options;

  if ( $options->use_formal_status )
    {
      $self->update_status_from_outcome($outcome);
    }

  return 1;
}

######################################################################

sub add_review {

  # Add an review to the review data structure.  An review is a
  # SML::Element.

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

######################################################################

sub add_property_value {

  my $self = shift;

  my $division_id    = shift;
  my $property_name  = shift;
  my $property_value = shift;
  my $origin         = shift;

  unless ( $division_id and $property_name and $property_value and $origin )
    {
      $logger->logcluck("CAN'T ADD PROPERTY VALUE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $hash = $self->_get_property_hash;

  if ( exists $hash->{$division_id}{$property_name}{$property_value} )
    {
      # $logger->warn("PROPERTY ALREADY EXISTS $division_id $property_name $property_value");
      return 0;
    }

  my $args = {};

  if ( ref $origin and $origin->isa('SML::Element') )
    {
      $args->{element}         = $origin;
      $args->{from_manuscript} = 1;
    }

  else
    {
      $args->{from_manuscript} = 0;
    }

  my $value = SML::Value->new(%{$args});

  $hash->{$division_id}{$property_name}{$property_value} = $value;

  return 1;
}

######################################################################

sub set_property_value {

  my $self = shift;

  my $division_id    = shift;
  my $property_name  = shift;
  my $property_value = shift;

  unless ( $division_id and $property_name and $property_value )
    {
      $logger->error("CAN'T SET PROPERTY VALUE, MISSING ARGUMENT(S)");
      return 0;
    }

  my $hash = $self->_get_property_hash;

  if ( exists $hash->{$division_id}{$property_name} )
    {
      delete $hash->{$division_id}{$property_name};
    }

  $hash->{$division_id}{$property_name}{$property_value} = 1;

  return 1;
}

######################################################################

sub has_property {

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->error("CAN'T CHECK IF LIBRARY HAS PROPERTY, MISSING ARGUMENTS");
      return 0;
    }

  my $hash = $self->_get_property_hash;

  if ( exists $hash->{$division_id}{$property_name} )
    {
      return 1;
    }

  return 0;
}

######################################################################

sub has_property_value {

  my $self = shift;

  my $division_id    = shift;
  my $property_name  = shift;
  my $property_value = shift;

  unless ( $division_id and $property_name and $property_value )
    {
      $logger->error("CAN'T CHECK IF LIBRARY HAS PROPERTY VALUE, MISSING ARGUMENTS");
      return 0;
    }

  my $hash = $self->_get_property_hash;

  if ( exists $hash->{$division_id}{$property_name}{$property_value} )
    {
      return 1;
    }

  return 0;
}

######################################################################

sub get_first_property_value {

  # Return the first property value for the specified division ID and
  # property name.  WARN if there is more than one value.

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->error("CAN'T GET PROPERTY, MISSING ARGUMENTS");
      return 0;
    }

  my $hash = $self->_get_property_hash;

  unless ( exists $hash->{$division_id}{$property_name} )
    {
      $logger->error("CAN'T GET PROPERTY VALUE LIST FOR $division_id $property_name, NO VALUES");
      return 0;
    }

  my $list = [ sort keys %{ $hash->{$division_id}{$property_name} } ];

  if ( scalar @{ $list } > 1 )
    {
      $logger->warn("RETURNING ONLY ONE VALUE. $division_id $property_name HAS MULTIPLE VALUES");
    }

  return $list->[0];
}

######################################################################

sub get_first_property_value_element {

  # Return the first SML::Element associated with the specified
  # division ID and property name.  WARN if there is more than one
  # value (and therefore more than one element).

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->error("CAN'T GET PROPERTY, MISSING ARGUMENTS");
      return 0;
    }

  my $hash = $self->_get_property_hash;

  unless ( exists $hash->{$division_id}{$property_name} )
    {
      $logger->error("CAN'T GET PROPERTY VALUE LIST FOR $division_id $property_name, NO VALUES");
      return 0;
    }

  my $list = [ sort keys %{ $hash->{$division_id}{$property_name} } ];

  if ( scalar @{ $list } > 1 )
    {
      $logger->warn("RETURNING ONLY ONE VALUE. $division_id $property_name HAS MULTIPLE VALUES");
    }

  my $property_value = $list->[0];

  my $value = $hash->{$division_id}{$property_name}{$property_value};

  unless ( $value->has_element )
    {
      $logger->error("FIRST PROPERTY VALUE HAS NO ELEMENT $division_id $property_name");
      return 0;
    }

  return $value->get_element;
}

######################################################################

sub get_property_value_element {

  # Return the SML::Element associated with the specified division ID,
  # property name, and property value.

  my $self = shift;

  my $division_id    = shift;
  my $property_name  = shift;
  my $property_value = shift;

  unless ( $division_id and $property_name and $property_value )
    {
      $logger->error("CAN'T GET PROPERTY VALUE ELEMENT, MISSING ARGUMENTS");
      return 0;
    }

  my $hash = $self->_get_property_hash;

  unless ( exists $hash->{$division_id}{$property_name}{$property_value} )
    {
      $logger->error("CAN'T GET PROPERTY VALUE ELEMENT FOR $division_id $property_name $property_value, NO VALUE");
      return 0;
    }

  my $value = $hash->{$division_id}{$property_name}{$property_value};

  unless ( $value->has_element )
    {
      $logger->error("PROPERTY VALUE HAS NO ELEMENT $division_id $property_name $property_value");
      return 0;
    }

  return $value->get_element;
}

######################################################################

sub get_property_value_object {

  # Return the SML::Value object associated with the specified
  # division ID, property name, and property value.

  my $self = shift;

  my $division_id    = shift;
  my $property_name  = shift;
  my $property_value = shift;

  unless ( $division_id and $property_name and $property_value )
    {
      $logger->error("CAN'T GET PROPERTY VALUE OBJECT, MISSING ARGUMENTS");
      return 0;
    }

  my $hash = $self->_get_property_hash;

  unless ( exists $hash->{$division_id}{$property_name}{$property_value} )
    {
      $logger->error("CAN'T GET PROPERTY VALUE OBJECT FOR $division_id $property_name $property_value, NO VALUE");
      return 0;
    }

  return $hash->{$division_id}{$property_name}{$property_value};

}

######################################################################

sub get_property_value_list {

  # Return a list of property values for the specified division_id and
  # property_name.

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->error("CAN'T GET PROPERTY, MISSING ARGUMENTS");
      return 0;
    }

  my $hash = $self->_get_property_hash;

  unless ( exists $hash->{$division_id}{$property_name} )
    {
      $logger->error("CAN'T GET PROPERTY VALUE LIST FOR $division_id $property_name, NO VALUES");
      return 0;
    }

  return [ sort keys %{ $hash->{$division_id}{$property_name} } ];
}

######################################################################

sub get_property_value_element_list {

  # Return a list of SML::Element's associated with the specified
  # property value.

  my $self = shift;

  my $division_id   = shift;
  my $property_name = shift;

  unless ( $division_id and $property_name )
    {
      $logger->error("CAN'T GET PROPERTY, MISSING ARGUMENTS");
      return 0;
    }

  my $hash = $self->_get_property_hash;

  unless ( exists $hash->{$division_id}{$property_name} )
    {
      $logger->error("CAN'T GET PROPERTY VALUE ELEMENT LIST FOR $division_id $property_name, NO VALUES");
      return 0;
    }

  my $list = [];

  foreach my $property_value ( sort keys %{ $hash->{$division_id}{$property_name} } )
    {
      my $value = $hash->{$division_id}{$property_name}{$property_value};

      if ( $value->has_element )
	{
	  my $element = $value->get_element;

	  push(@{$list},$element);
	}
    }

  return $list;
}

######################################################################

sub get_property_name_list {

  # Return a list of existing property names for the specified
  # division_id.

  my $self = shift;

  my $division_id = shift;

  unless ( $division_id )
    {
      $logger->error("CAN'T GET PROPERTY NAME LIST, MISSING ARGUMENT");
      return 0;
    }

  my $hash = $self->_get_property_hash;

  unless ( exists $hash->{$division_id} )
    {
      $logger->error("CAN'T GET PROPERTY NAME LIST FOR $division_id, NO SUCH DIVISION");
      return 0;
    }

  return [ sort keys %{ $hash->{$division_id} } ];
}

######################################################################

sub has_file {

  my $self     = shift;
  my $filename = shift;

  if ( exists $self->_get_file_hash->{$filename} )
    {
      return 1;
    }

  return 0;
}

######################################################################

sub has_document {

  # Return 1 if the document object is in the library.  This means the
  # document has already been parsed and the document object is
  # available for use.

  my $self = shift;
  my $id   = shift;

  if ( exists $self->_get_document_hash->{$id} )
    {
      return 1;
    }

  return 0;
}

######################################################################

sub has_document_id {

  # Return 1 if the document ID exists in the library.  This means
  # that some file in the library contains a DOCUMENT division with
  # the specified ID.

  my $self = shift;
  my $id   = shift;

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

######################################################################

sub has_division_id {

  # Return 1 if the division ID exists in the library.  This means
  # that some file in the library contains a division with the
  # specified ID.

  my $self = shift;
  my $id   = shift;

  if ( not $id )
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

######################################################################

sub has_entity {

  my $self = shift;
  my $id   = shift;

  if ( not $id )
    {
      $logger->error("CAN'T DETERMINE IF LIBRARY HAS ENTITY, YOU MUST SPECIFY AN ID");
      return 0;
    }

  if ( exists $self->_get_entity_hash->{$id} )
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

  if ( not $id )
    {
      $logger->error("CAN'T DETERMINE IF LIBRARY HAS DIVISION, YOU MUST SPECIFY AN ID");
      return 0;
    }

  if ( exists $self->_get_division_hash->{$id} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_variable {

  my $self      = shift;
  my $name      = shift;
  my $namespace = shift || q{};

  if ( exists $self->_get_variable_hash->{$name}{$namespace} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

# sub has_resource {

#   my $self     = shift;
#   my $filespec = shift;

#   if ( exists $self->_get_resource_hash->{$filespec} )
#     {
#       return 1;
#     }

#   else
#     {
#       return 0;
#     }
# }

######################################################################

sub has_index_term {

  my $self  = shift;
  my $term  = shift;

  if ( exists $self->_get_index_hash->{$term} )
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

  if ( defined $self->_get_outcome_hash->{$entity_id}{$date} )
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

  if ( defined $self->_get_review_hash->{$entity_id}{$date} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_images {

  my $self = shift;

  my $list = $self->get_image_list;

  if ( scalar @{$list} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_file {

  my $self     = shift;
  my $filename = shift;

  if ( exists $self->_get_file_hash->{$filename} )
    {
      return $self->_get_file_hash->{$filename};
    }

  else
    {
      $logger->error("CAN'T GET FILE \'$filename\'");
      return 0;
    }
}

######################################################################

# sub get_document {

#   my $self = shift;
#   my $id   = shift;

#   return $self->get_division($id);
# }

######################################################################

sub get_document_list {

  my $self = shift;

  my $list = [];

  foreach my $division ( values %{ $self->_get_division_hash })
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

  if ( exists $self->_get_entity_hash->{$id} )
    {
      return $self->_get_entity_hash->{$id};
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

  my $hash = $self->_get_id_hash;
  my $pair = $hash->{$id};
  my $name = $pair->[1];

  return $name;
}

######################################################################

sub get_all_entities {

  # Parse all library entities into memory.

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

######################################################################

sub get_all_documents {

  # Parse all library documents into memory.

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

######################################################################

sub get_division_id_list_by_name {

  # Return a list of division IDs that have the specified name.

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

######################################################################

sub get_variable {

  my $self      = shift;
  my $name      = shift;
  my $namespace = shift || q{};

  if ( exists $self->_get_variable_hash->{$name}{$namespace} )
    {
      return $self->_get_variable_hash->{$name}{$namespace};
    }

  else
    {
      $logger->error("CAN'T GET VARIABLE \'$name\' \'$namespace\'");
      return 0;
    }
}

######################################################################

# sub get_resource {

#   my $self     = shift;
#   my $filespec = shift;

#   if ( exists $self->_get_resource_hash->{$filespec} )
#     {
#       return $self->_get_resource_hash->{$filespec};
#     }

#   else
#     {
#       $logger->error("CAN'T GET RESOURCE \'$filespec\'");
#       return 0;
#     }
# }

######################################################################

sub get_index_term {

  my $self  = shift;
  my $term  = shift;

  if ( exists $self->_get_index_hash->{$term} )
    {
      return $self->_get_index_hash->{$term};
    }

  else
    {
      $logger->error("CAN'T GET INDEX TERM \'$term\'");
      return 0;
    }
}

######################################################################

sub get_variable_value {

  my $self      = shift;
  my $name      = shift;
  my $namespace = shift || q{};

  if ( exists $self->_get_variable_hash->{$name}{$namespace} )
    {
      my $definition = $self->_get_variable_hash->{$name}{$namespace};

      return $definition->get_value;
    }

  else
    {
      $logger->error("CAN'T GET VARIABLE VALUE \'$name\' \'$namespace\' not defined");
      return 0;
    }
}

######################################################################

sub get_type {

  # Return the type of a value (division name, STRING, or BOOLEAN)

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

######################################################################

sub get_outcome {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( exists $self->_get_outcome_hash->{$entity_id}{$date}{outcome} )
    {
      return $self->_get_outcome_hash->{$entity_id}{$date}{outcome};
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

  if ( exists $self->_get_review_hash->{$entity_id}{$date}{review} )
    {
      return $self->_get_review_hash->{$entity_id}{$date}{review};
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

  my $oel = [];                         # outcome entity list

  foreach my $entity_id ( keys %{ $self->_get_outcome_hash } )
    {
      push @{ $oel }, $entity_id;
    }

  return $oel;
}

######################################################################

sub get_review_entity_id_list {

  # Return a list of entities for which there are review elements.

  my $self = shift;

  my $rel = [];                         # review entity list

  foreach my $entity_id ( keys %{ $self->_get_review_hash } )
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

######################################################################

sub get_review_date_list {

  # Return a list of dates for which there are review elements for a
  # specified entity.

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

######################################################################

sub get_outcome_status {

  my $self      = shift;
  my $entity_id = shift;
  my $date      = shift;

  if ( defined $self->_get_outcome_hash->{$entity_id}{$date}{status} )
    {
      return $self->_get_outcome_hash->{$entity_id}{$date}{status};
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

  if ( defined $self->_get_review_hash->{$entity_id}{$date}{status} )
    {
      return $self->_get_review_hash->{$entity_id}{$date}{status};
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

  if ( defined $self->_get_outcome_hash->{$entity_id}{$date}{description} )
    {
      return $self->_get_outcome_hash->{$entity_id}{$date}{description};
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

  if ( defined $self->_get_review_hash->{$entity_id}{$date}{description} )
    {
      return $self->_get_review_hash->{$entity_id}{$date}{description};
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

######################################################################

sub summarize_entities {

  # Return a summary of the library's entities.

  my $self = shift;

  my $summary = q{};

  if ( keys %{ $self->_get_entity_hash } )
    {
      $summary .= "Entities:\n\n";

      foreach my $entity (sort by_division_name_and_id values %{ $self->_get_entity_hash })
	{
	  my $id      = $entity->get_id;
	  my $entname = $entity->get_name;

	  $summary .= "  $entname: $id";

	  my $property_name_list = $self->get_property_name_list($id);

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

	  my $property_name_list = $self->get_property_name_list($id);

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

######################################################################

# sub summarize_resources {

#   my $self = shift;

#   my $summary = q{};

#   if (keys %{ $self->_get_resource_hash })
#     {
#       $summary .= "Resources:\n\n";

#       foreach my $filespec (sort keys %{ $self->_get_resource_hash })
# 	{
# 	  $summary .= "  $filespec\n";
# 	}

#       $summary .= "\n";
#     }

#   return $summary;
# }

######################################################################

sub summarize_index {

  my $self = shift;

  my $summary = q{};

  if (keys %{ $self->_get_index_hash })
    {
      $summary .= "Indexed Terms:\n\n";

      foreach my $term (sort keys %{ $self->_get_index_hash })
	{
	  my $index     = $self->_get_index_hash->{$term};
	  my $locations = join(', ', sort keys %{$index});

	  $summary .= "  $term => $locations\n";
	}

      $summary .= "\n";
    }

  return $summary;
}

######################################################################

sub summarize_sources {

  my $self = shift;

  my $summary = q{};

  if ( $self->get_references->contains_entries )
    {
      $summary .= "Source References:\n\n";

      foreach my $source ( values %{ $self->get_references->get_sources })
	{
	  my $id    = $source->get_id;
	  my $list  = $self->get_property_value_list($id,'title');
	  my $title = $list->[0];

	  $summary .= "  $id => $title\n";
	}

      $summary .= "\n";
    }

  return $summary;
}

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

######################################################################

# sub replace_division_id {

#   # THIS IS A HACK.  I should change the syntax of the division start
#   # markup to include the ID so this isn't necessary.  That way the
#   # library can remember the correct division ID at the start of the
#   # division.

#   my $self     = shift;
#   my $division = shift;
#   my $id       = shift;

#   foreach my $stored_id (keys %{ $self->_get_division_hash })
#     {
#       my $stored_division = $self->_get_division_hash->{$stored_id};
#       if ( $stored_division == $division )
# 	{
# 	  delete $self->_get_division_hash->{$stored_id};
# 	  $self->_get_division_hash->{$id} = $division;
# 	}
#     }

#   if ( $division->isa('SML::Source') )
#     {
#       $self->get_references->replace_division_id($division,$id);
#     }

#   return 1;
# }

######################################################################

sub update_status_from_outcome {

  # Update the status of an entity based on an outcome.

  my $self    = shift;
  my $outcome = shift;

  my $syntax = $self->get_syntax;
  my $util   = $self->get_util;

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

######################################################################

# sub allows_insert {

#   my $self = shift;
#   my $name = shift;

#   if (
#       defined $self->_get_insert_name_hash->{$name}
#       and
#       $self->_get_insert_name_hash->{$name} == 1
#      )
#     {
#       return 1;
#     }
#   else
#     {
#       return 0;
#     }
# }

######################################################################

# sub allows_generate {

#   my $self = shift;
#   my $name = shift;

#   if ( defined $self->_get_generated_content_type_hash->{$name} )
#     {
#       return 1;
#     }

#   else
#     {
#       return 0;
#     }
# }

######################################################################

# sub get_bullet_list_count {

#   my $self = shift;

#   my $hash  = $self->_get_division_hash;
#   my $count = 0;

#   foreach my $division ( values %{ $hash } )
#     {
#       if ( $division->isa("SML::BulletList") )
# 	{
# 	  ++ $count;
# 	}
#     }

#   return $count;
# }

######################################################################

# sub get_enumerated_list_count {

#   my $self = shift;

#   my $hash  = $self->_get_division_hash;
#   my $count = 0;

#   foreach my $division ( values %{ $hash } )
#     {
#       if ( $division->isa("SML::EnumeratedList") )
# 	{
# 	  ++ $count;
# 	}
#     }

#   return $count;
# }

######################################################################

# sub get_step_list_count {

#   my $self = shift;

#   my $hash  = $self->_get_division_hash;
#   my $count = 0;

#   foreach my $division ( values %{ $hash } )
#     {
#       my $name = $division->get_name;

#       if ( $name eq 'STEP_LIST' )
# 	{
# 	  ++ $count;
# 	}
#     }

#   return $count;
# }

######################################################################

# sub get_definition_list_count {

#   my $self = shift;

#   my $hash  = $self->_get_division_hash;
#   my $count = 0;

#   foreach my $division ( values %{ $hash } )
#     {
#       my $name = $division->get_name;

#       if ( $name eq 'DEFINITION_LIST' )
# 	{
# 	  ++ $count;
# 	}
#     }

#   return $count;
# }

######################################################################

sub add_triple {

  my $self   = shift;
  my $triple = shift;

  unless ( ref $triple and $triple->isa('SML::Triple') )
    {
      $logger->error("CAN'T ADD TRIPLE \'$triple\' NOT A TRIPLE");
      return 0;
    }

  my $subject   = $triple->get_subject;
  my $predicate = $triple->get_predicate;
  my $object    = $triple->get_object;

  my $hash = $self->_get_triple_hash;

  if ( exists $hash->{$subject}{$predicate}{$object} )
    {
      $logger->warn("TRIPLE ALREADY EXISTS $subject $predicate $object");
      return 0;
    }

  $logger->trace("adding triple $subject $predicate $object");
  $hash->{$subject}{$predicate}{$object} = $triple;

  return 1;
}

######################################################################

sub has_triple {

  my $self      = shift;
  my $subject   = shift;
  my $predicate = shift;
  my $object    = shift;

  unless ( $subject and $predicate and $object )
    {
      $logger->error("CAN'T CHECK IF LIBRARY HAS TRIPLE $subject $predicate $object");
      return 0;
    }

  my $hash = $self->_get_triple_hash;

  if ( exists $hash->{$subject}{$predicate}{$object} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_triple {

  my $self      = shift;
  my $subject   = shift;
  my $predicate = shift;
  my $object    = shift;

  unless ( $subject and $predicate and $object )
    {
      $logger->error("CAN'T GET TRIPLE $subject $predicate $object");
      return 0;
    }

  my $hash = $self->_get_triple_hash;

  if ( exists $hash->{$subject}{$predicate}{$object} )
    {
      return $hash->{$subject}{$predicate}{$object};
    }

  else
    {
      $logger->error("CAN'T GET TRIPLE $subject $predicate $object TRIPLE DOESN'T EXIST");
      return 0;
    }
}

######################################################################

sub has_triple_for {

  # Return 1 if the library has a triple for the specified subject and
  # predicate.

  my $self      = shift;
  my $subject   = shift;
  my $predicate = shift;

  unless ( $subject and $predicate )
    {
      $logger->error("CAN'T CHECK FOR TRIPLES WITHOUT SUBJECT AND PREDICATE");
      return 0;
    }

  my $hash = $self->_get_triple_hash;

  if ( exists $hash->{$subject}{$predicate} )
    {
      return 1;
    }

  return 0;
}

######################################################################

sub get_object_list {

  my $self      = shift;
  my $subject   = shift;
  my $predicate = shift;

  my $hash = $self->_get_triple_hash;

  return [ sort keys %{ $hash->{$subject}{$predicate} } ];
}

######################################################################

sub contains_entities {

  # Return 1 if the library contains any entities.

  my $self = shift;

  my $ontology         = $self->get_ontology;
  my $entity_name_list = $ontology->get_entity_name_list;
  my $property_hash    = $self->_get_property_hash;

  foreach my $division_id ( keys %{ $property_hash } )
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

######################################################################

sub get_division_count {

  my $self = shift;
  my $name = shift;

  unless ( $name )
    {
      $logger->error("CAN'T GET DIVISION COUNT, MISSING ARGUMENT");
      return 0;
    }

  my $hash = $self->_get_division_counter_hash;

  return $hash->{$name};
}

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

######################################################################

sub has_published_file {

  # Check for the existence of a specific file in the 'published'
  # directory.

  my $self = shift;

  my $state    = shift;                 # DRAFT, REVIEW, APPROVED
  my $filename = shift;

  my $published_dir = $self->get_published_dir;

  if ( -f "$published_dir/$state/$filename" )
    {
      return 1;
    }

  return 0;
}

######################################################################

sub has_published_document {

  my $self = shift;

  my $state       = shift;              # DRAFT, REVIEW, APPROVED
  my $document_id = shift;

  my $hash = $self->_get_published_document_hash;

  if ( exists $hash->{$state}{$document_id} )
    {
      return 1;
    }

  return 0;
}

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

  else
    {
      return 0;
    }
}

######################################################################

sub get_published_document_property_value {

  # Return the (string) value of the specified published document
  # property.

  my $self = shift;

  my $state         = shift;            # DRAFT, REVIEW, APPROVED
  my $document_id   = shift;
  my $property_name = shift;

  my $hash = $self->_get_published_document_hash;

  if ( exists $hash->{$state}{$document_id}{$property_name} )
    {
      my $u = $self->get_util;

      my $text = $hash->{$state}{$document_id}{$property_name};

      return $u->strip_string_markup($text);
    }

  else
    {
      $logger->error("CAN'T GET PUBLISHED DOCUMENT PROPERTY VALUE $state $document_id $property_name");
      return 0;
    }
}

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

  my $hash     = $self->_get_error_hash;
  my $level    = $error->get_level;
  my $location = $error->get_location;
  my $message  = $error->get_message;

  if ( exists $hash->{$level}{$location}{$message} )
    {
      $logger->warn("ERROR ALREADY EXISTS $level $location $message");
      return 0;
    }

  $hash->{$level}{$location}{$message} = $error;

  return 1;
}

######################################################################

sub get_error_list {

  my $self = shift;

  my $list = [];

  my $hash = $self->_get_error_hash;

  foreach my $level ( sort keys %{ $hash } )
    {
      foreach my $location ( sort keys %{ $hash->{$level} } )
	{
	  foreach my $message ( sort keys %{ $hash->{$level}{$location} })
	    {
	      my $error = $hash->{$level}{$location}{$message};

	      push @{$list}, $error;
	    }
	}
    }

  return $list;
}

######################################################################

sub get_error_count {

  my $self = shift;

  return scalar @{ $self->get_error_list };
}

######################################################################

sub contains_error {

  # Return 1 if the library contains an error.

  my $self = shift;

  my $hash = $self->_get_error_hash;

  if ( scalar keys %{$hash} )
    {
      return 1;
    }

  return 0;
}

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

######################################################################

sub contains_changes {

  # Return 1 if this document contains changes from a previous version
  # that can be enumerated on a change page.

  my $self = shift;

  my $list = $self->get_change_list;

  if ( scalar @{$list} )
    {
      return 1;
    }

  return 0;
}

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

# $hash->{$id} = [$filename,$division_name];
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

# $hash->{$id} = [$filename,$division_name];
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

has property_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_property_hash',
   default   => sub {{}},
  );

# This is a hash of all properties of division in the library.
#
# $hash->{$division_id}{$property_name}{$property_value} = $value_object;
#
# where:
#
#   $division_id    => STRING
#   $property_name  => STRING
#   $property_value => STRING
#   $value_object   => SML::Value object

######################################################################

has triple_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_triple_hash',
   default => sub {{}},
  );

# $hash->{$subject}{$predicate}{$object} = 1;

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

# has resource_hash =>
#   (
#    is        => 'ro',
#    isa       => 'HashRef',
#    reader    => '_get_resource_hash',
#    default   => sub {{}},
#   );

#   $resource_ds->{$filespec} = $resource;

######################################################################

has index_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_index_hash',
   default   => sub {{}},
  );

# Index term data structure.  This is a hash of all index terms.  The
# hash keys are the indexed terms.  The hash values are anonymous
# hashes in which the key is the division ID in which the term
# appears, and the value is simply a boolean.
#
#   $ih->{$term} = { $divid_1 => 1, $divid_2 => 1, ... };

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

# $hash->{$division_name} = $count;

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
# $hash->{$state}{$document_id}{$property_name} = $string;
#
# $hash->{'DRAFT'}{'sdd-sml'}{'version'} = 'v2.0';
# $hash->{'DRAFT'}{'sdd-sml'}{'date'}    = '2015-12-20';

######################################################################

has error_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_error_hash',
   default => sub {{}},
  );

# This is a hash of error objects.

# $hash->{$level}{$location}{$message} = $error;

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
      my $list       = $self->get_image_list;

      opendir(DIR,"$images_dir") or die "Couldn't open dir: $images_dir";
      foreach my $image ( grep {/\.(png|jpg|jpeg|gif)$/} readdir(DIR) )
	{
	  push(@{$list},$image);
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

  foreach my $directory (@{ $self->get_include_path })
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

  my $hash             = {};
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

		      $hash->{$state}{$id}{$property_name} = $property_value;
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

		      $hash->{$state}{$id}{$property_name} = $property_value;
		    }
		}
	    }
	}
    }

  return $hash;
}

######################################################################

sub _add_include_path {

  # Add a directory to the include_path array (if it exists).

  my $self = shift;
  my $path = shift;

  my $include_path   = $self->get_include_path;
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

  my $list = $self->get_document_presentation_id_list;

  push @{$list}, $id;

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

sub _build_division_names {

  my $self = shift;
  my $list = [ sort keys %{ $self->_get_division_hash } ];

  return $list;
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
      my $util    = $self->get_util;
      my $options = $util->get_options;

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

  # Return a hash that represents changes since the previous version
  # of the document:
  #
  #   $hash->{$division_id}{$action} = 1;
  #
  #   $division_id => division that changed
  #   $action      => add, update, delete

  my $self = shift;

  # To have a complete view of all changes, the library must first
  # parse all entities and documents into memory.  If an entity or
  # document is already in memory it will not be re-parsed.

  $self->get_all_entities;
  $self->get_all_documents;

  my $hash = {};

  unless ( $self->has_version and $self->has_previous_version )
    {
      return $hash;
    }

  my $previous_version = $self->get_previous_version;
  my $util             = $self->get_util;
  my $options          = $util->get_options;

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
	      $hash->{DELETED}{$id} = 1;
	    }

	  else
	    {
	      my $previous_digest = $previous_sha_hash->{$id};
	      my $current_digest  = $current_sha_hash->{$id};

	      if ( $current_digest ne $previous_digest )
		{
		  $hash->{UPDATED}{$id} = 1;
		}
	    }
	}

      foreach my $id ( keys %{ $current_sha_hash } )
	{
	  if ( not exists $previous_sha_hash->{$id} )
	    {
	      $hash->{ADDED}{$id} = 1;
	    }

	  else
	    {
	      my $previous_digest = $previous_sha_hash->{$id};
	      my $current_digest  = $current_sha_hash->{$id};

	      if ( $current_digest ne $previous_digest )
		{
		  $hash->{UPDATED}{$id} = 1;
		}
	    }
	}
    }

  my $list = [];

  # list adds first
  foreach my $division_id ( sort keys %{ $hash->{ADDED} } )
    {
      push @{$list}, ['ADDED',$division_id];
    }

  # list deletes second
  foreach my $division_id ( sort keys %{ $hash->{DELETED} } )
    {
      push @{$list}, ['DELETED',$division_id];
    }

  # list updates third
  foreach my $division_id ( sort keys %{ $hash->{UPDATED} } )
    {
      push @{$list}, ['UPDATED',$division_id];
    }

  return $list;
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

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Library> - a collection of related L<"SML::Document">s and
reusable content.

=head1 VERSION

2.0.0.

=head1 SYNOPSIS

  my $library = SML::Library->new
                  (
                    config_filename => 'library.conf',
                  );

  my $id           = $library->get_id;
  my $name         = $library->get_name;
  my $revision     = $library->get_revision;
  my $ontology     = $library->get_ontology;
  my $list         = $library->get_ontology_rule_filespec_list;
  my $parser       = $library->get_parser;
  my $reasoner     = $library->get_reasoner;
  my $publisher    = $library->get_publisher;
  my $glossary     = $library->get_glossary;
  my $acronym_list = $library->get_acronym_list;
  my $references   = $library->get_references;
  my $string       = $library->get_directory_path;
  my $list         = $library->get_include_path;
  my $list         = $library->get_region_name_list;
  my $list         = $library->get_environment_name_list;
  my $string       = $library->get_template_dir;
  my $string       = $library->get_published_dir;

  my $boolean      = $library->publish($id,$rendition,$style);
  my $boolean      = $library->has_filespec($filespec);
  my $string       = $library->get_filespec($filename);
  my $boolean      = $library->add_file($file);
  my $boolean      = $library->add_document($document);
  my $boolean      = $library->add_entity($entity);
  my $boolean      = $library->add_division($division);
  my $boolean      = $library->add_variable($definition);
  my $boolean      = $library->add_resource($resource);
  my $boolean      = $library->add_index_term($term,$divid);
  my $boolean      = $library->add_reference_file($filespec);
  my $boolean      = $library->add_script_file($filespec);
  my $boolean      = $library->add_outcome($outcome);
  my $boolean      = $library->add_review($review);
  my $boolean      = $library->has_file($filename);
  my $boolean      = $library->has_document($id);
  my $boolean      = $library->has_entity($id);
  my $boolean      = $library->has_division($id);
  my $boolean      = $library->has_property($id,$name);
  my $boolean      = $library->has_variable($name,$namespace);
  my $boolean      = $library->has_resource($filespec);
  my $boolean      = $library->has_index_term($term);
  my $boolean      = $library->has_outcome($entity_id,$date);
  my $boolean      = $library->has_review($entity_id,$date);
  my $file         = $library->get_file($filename);
  my $list         = $library->get_document_list;
  my $entity       = $library->get_entity($id);
  my $division     = $library->get_division($id);
  my $variable     = $library->get_variable($name,$namespace);
  my $resource     = $library->get_resource($filespec);
  my $term         = $library->get_index_term($term);
  my $string       = $library->get_variable_value($name,$namespace);
  my $type         = $library->get_type($value);
  my $outcome      = $library->get_outcome($entity_id,$date);
  my $review       = $library->get_review($entity_id,$date);
  my $list         = $library->get_outcome_entity_id_list;
  my $list         = $library->get_review_entity_id_list;
  my $list         = $library->get_outcome_date_list($entity_id);
  my $list         = $library->get_review_date_list($entity_id);
  my $list         = $library->get_outcome_status($entity_id,$date);
  my $list         = $library->get_review_status($entity_id,$date);
  my $description  = $library->get_outcome_description($entity_id,$date);
  my $description  = $library->get_review_description($entity_id,$date);
  my $string       = $library->summarize_content;
  my $string       = $library->summarize_entities;
  my $string       = $library->summarize_divisions;
  my $string       = $library->summarize_glossary;
  my $string       = $library->summarize_acronyms;
  my $string       = $library->summarize_variables;
  my $string       = $library->summarize_resources;
  my $string       = $library->summarize_index;
  my $string       = $library->summarize_sources;
  my $string       = $library->summarize_outcomes;
  my $string       = $library->summarize_reviews;
  my $boolean      = $library->update_status_from_outcome($outcome);

=head1 DESCRIPTION

A library is a collection of SML documents and reusable content stored
in text files.

Library rules:

Each file name must be unique.  Even though you can organize text files
into directories, each filename must be unique in the library.

Each division name must be valid.  Every division name in the library
mus be declared in the ontology.

Each division ID must be unique.  Every division in the library must
have a unique ID.

If you violate any of these rules you won't be able to even
instantiate your library object.  Don't worry.  It will tell you where
you went wrong.

=head1 METHODS

=head2 get_id

=head2 get_name

=head2 get_revision

=head2 get_sml

=head2 get_ontology

=head2 get_ontology_rule_filespec_list

=head2 get_parser

=head2 get_reasoner

=head2 get_publisher

=head2 get_glossary

=head2 get_acronym_list

=head2 get_references

=head2 get_directory_path

=head2 get_include_path

=head2 get_division_name_list

=head2 get_region_name_list

=head2 get_environment_name_list

=head2 get_template_dir

=head2 has_filespec($filespec)

=head2 get_filespec($filename)

=head2 add_file($file)

=head2 add_document($document)

=head2 add_entity($entity)

=head2 add_division($division)

=head2 add_variable($definition)

=head2 add_resource($resource)

=head2 add_index_term($term,$divid)

=head2 add_reference_file($filespec)

=head2 add_script_file($filespec)

=head2 add_outcome($outcome)

=head2 add_review($review)

=head2 has_file($filename)

=head2 has_document($id)

=head2 has_entity($id)

=head2 has_division($id)

=head2 has_property($id,$name)

=head2 has_variable($name,$namespace)

=head2 has_resource($filespec)

=head2 has_index_term($term)

=head2 has_outcome($entity_id,$date)

=head2 has_review($entity_id,$date)

=head2 get_file($filename)

=head2 get_document($id)

=head2 get_document_list

=head2 get_entity($id)

=head2 get_division($id)

=head2 get_variable($name,$namespace)

=head2 get_resource($filespec)

=head2 get_index_term($term)

=head2 get_variable_value($name,$namespace)

=head2 get_data_segment_line_list($id)

=head2 get_narrative_line_list($id)

=head2 get_type($value)

=head2 get_outcome($entity_id,$date)

=head2 get_review($entity_id,$date)

=head2 get_outcome_entity_id_list

=head2 get_review_entity_id_list

=head2 get_outcome_date_list($entity_id)

=head2 get_review_date_list($entity_id)

=head2 get_outcome_status($entity_id,$date)

=head2 get_review_status($entity_id,$date)

=head2 get_outcome_description($entity_id,$date)

=head2 get_review_description($entity_id,$date)

=head2 summarize_content

=head2 summarize_entities

=head2 summarize_divisions

=head2 summarize_glossary

=head2 summarize_acronyms

=head2 summarize_variables

=head2 summarize_resources

=head2 summarize_index

=head2 summarize_sources

=head2 summarize_outcomes

=head2 summarize_reviews

=head2 replace_division_id($division,$id)

=head2 update_status_from_outcome($outcome)

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
