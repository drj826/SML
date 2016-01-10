#!/usr/bin/perl

package SML::Publisher;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Cwd;
use File::Basename;
use File::Copy;
use File::Copy::Recursive qw( dircopy );
use Time::Duration;
use Template;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Publisher');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has library =>
  (
   is        => 'ro',
   isa       => 'SML::Library',
   reader    => 'get_library',
   required  => 1,
  );

######################################################################

has publish_date_time =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_publish_date_time',
   writer  => '_set_publish_date_time',
   default => q{},
  );

######################################################################

has font_size_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_font_size_list',
   lazy    => 1,
   builder => '_build_font_size_list',
  );

######################################################################

has font_weight_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_font_weight_list',
   lazy    => 1,
   builder => '_build_font_weight_list',
  );

######################################################################

has font_shape_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_font_shape_list',
   lazy    => 1,
   builder => '_build_font_shape_list',
  );

######################################################################

has font_family_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_font_family_list',
   lazy    => 1,
   builder => '_build_font_family_list',
  );

######################################################################

has background_color_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_background_color_list',
   lazy    => 1,
   builder => '_build_background_color_list',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub publish {

  my $self = shift;

  my $id        = shift;                          # document ID
  my $rendition = shift || 'html';                # html, latex, pdf...
  my $style     = shift || 'default';             # default

  my $begin = time();

  $logger->info("publish $style $rendition $id");

  my $now = localtime();
  $self->_set_publish_date_time( $now );

  my $library = $self->get_library;

  # validate the library has a document with this ID
  if ( not $library->has_document_id($id) )
    {
      $logger->error("LIBRARY HAS NO DOCUMENT \'$id\'");
      return 0;
    }

  # validate the publisher can publish this rendition and style
  if ( not $self->can_publish($rendition,$style) )
    {
      $logger->error("PUBLISHER CAN'T PUBLISH \'$rendition\' \'$style\'");
      return 0;
    }

  my $parser   = $library->get_parser;
  my $document = $parser->parse($id);

  if ( $rendition eq 'html' )
    {
      $self->_publish_html_document($document,$style);
    }

  elsif ( $rendition eq 'latex' )
    {
      $self->_publish_latex_document($document,$style);
    }

  elsif ( $rendition eq 'pdf' )
    {
      $self->_publish_pdf_document($document,$style);
    }

  elsif ( $rendition eq 'sml' )
    {
      $self->_publish_sml_document($document,$style);
    }

  else
    {
      $logger->error("THIS SHOULD NEVER HAPPEN");
      return 0;
    }

  my $end = time();
  my $duration = duration($end - $begin);

  $logger->info("publish $style $rendition $id $duration");

  return 1;
}

######################################################################

sub publish_index {

  my $self = shift;

  my $rendition = shift || 'html';
  my $style     = shift || 'default';

  my $now = localtime();
  $self->_set_publish_date_time( $now );

  if ( $rendition eq 'html' )
    {
      $self->_publish_html_library_index_page($style);
      $self->_publish_html_overall_index_page($style);
    }

  else
    {
      $logger->error("CAN ONLY PUBLISH HTML INDEX AT THIS TIME");
      return 0;
    }

  return 1;
}

######################################################################

sub publish_library_pages {

  my $self = shift;

  my $rendition = shift || 'html';
  my $style     = shift || 'default';

  my $now = localtime();
  $self->_set_publish_date_time( $now );

  if ( $rendition eq 'html' )
    {
      my $library       = $self->get_library;
      my $published_dir = $library->get_published_dir;
      my $state_dir     = "$published_dir/DRAFT";

      if ( -f "$state_dir/errors.html" )
	{
	  unlink "$state_dir/errors.html";
	}

      if ( $library->contains_error )
	{
	  $self->_publish_html_library_errors_page($style);
	}

      $self->_publish_html_traceability_page($style);
      $self->_publish_html_ontology_page($style);
      $self->_publish_html_entities_page($style);
      $self->_publish_html_library_glossary_page($style);
      $self->_publish_html_library_acronyms_page($style);
      $self->_publish_html_library_references_page($style);

      if ( $library->contains_changes )
	{
	  $self->_publish_html_change_page($style);
	}
    }

  else
    {
      $logger->error("CAN ONLY PUBLISH HTML LIBRARY PAGES AT THIS TIME");
      return 0;
    }

  return 1;
}

######################################################################

sub can_publish {

  my $self      = shift;
  my $rendition = shift;
  my $style     = shift;

  if ( $rendition eq 'html' )
    {
      if ( $style eq 'default' )
	{
	  return 1;
	}

      else
	{
	  return 0;
	}
    }

  elsif ( $rendition eq 'latex' )
    {
      if ( $style eq 'default' )
	{
	  return 1;
	}

      else
	{
	  return 0;
	}
    }

  elsif ( $rendition eq 'pdf' )
    {
      if ( $style eq 'default' )
	{
	  return 1;
	}

      else
	{
	  return 0;
	}
    }

  elsif ( $rendition eq 'sml' )
    {
      if ( $style eq 'default' )
	{
	  return 1;
	}

      else
	{
	  return 0;
	}
    }
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has scaled_image_width =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => '_get_scaled_image_width',
   default => '605',
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _publish_html_document {

  my $self     = shift;
  my $document = shift;                 # document to publish
  my $style    = shift || 'default';    # default

  unless ( ref $document and $document->isa('SML::Document') )
    {
      $logger->error("CAN'T PUBLISH HTML DOCUMENT, $document IS NOT A DOCUMENT");
      return 0;
    }

  my $library      = $self->get_library;
  my $template_dir = $library->get_template_dir . "/html/$style";

  unless ( -d $template_dir )
    {
      $logger->error("CAN'T PUBLISH HTML DOCUMENT, $template_dir IS NOT A TEMPLATE DIRECTORY");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  unless ( -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  foreach my $state ('DRAFT','REVIEW','APPROVED')
    {
      my $state_dir = "$published_dir/$state";

      unless ( -d $state_dir )
	{
	  mkdir "$state_dir", 0755;
	  $logger->debug("made directory $state_dir");
	}
    }

  my $id         = $document->get_id;
  my $state      = 'DRAFT';
  my $state_dir  = "$published_dir/$state";
  my $output_dir = "$state_dir/$id";

  unless ( -d $output_dir )
    {
      mkdir "$output_dir", 0755;
      $logger->debug("made directory $output_dir");
    }

  # delete old errors file (if any)
  if ( -f "$output_dir/$id.errors.html" )
    {
      unlink "$output_dir/$id.errors.html";
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $output_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  if ( $document->contains_division_with_name('SECTION') )
    {
      my $section_list = $document->get_list_of_divisions_with_name('SECTION');

      foreach my $section (@{ $section_list })
	{
	  my $num     = $section->get_number;
	  my $outfile = "$id.$num.html";
	  my $vars    = { self => $section };

	  $logger->debug("publishing $outfile");

	  $tt->process('section_page.tt',$vars,$outfile)
	    || die $tt->error(), "\n";
	}

      my $vars = { document => $document };

      # document title page
      $logger->debug("publishing $id.titlepage.html");
      $tt->process("titlepage.tt",$vars,"$id.titlepage.html")
	|| die $tt->error(), "\n";

      # document table of contents
      $logger->debug("publishing $id.toc.html");
      $tt->process("toc.tt",$vars,"$id.toc.html")
	|| die $tt->error(), "\n";

      # document list of tables
      if ( $document->contains_division_with_name('TABLE') )
	{
	  $logger->debug("publishing $id.tables.html");
	  $tt->process("list_of_tables_page.tt",$vars,"$id.tables.html")
	    || die $tt->error(), "\n";
	}

      # document list of figures
      if ( $document->contains_division_with_name('FIGURE') )
	{
	  $logger->debug("publishing $id.figures.html");
	  $tt->process("list_of_figures_page.tt",$vars,"$id.figures.html")
	    || die $tt->error(), "\n";
	}

      # document list of attachments
      if ( $document->contains_division_with_name('ATTACHMENT') )
	{
	  $logger->debug("publishing $id.attachments.html");
	  $tt->process("list_of_attachments_page.tt",$vars,"$id.attachments.html")
	    || die $tt->error(), "\n";
	}

      # document list of listings
      if ( $document->contains_division_with_name('LISTING') )
	{
	  $logger->debug("publishing $id.listings.html");
	  $tt->process("list_of_listings_page.tt",$vars,"$id.listings.html")
	    || die $tt->error(), "\n";
	}

      # document list of demos
      if ( $document->contains_division_with_name('DEMO') )
	{
	  $logger->debug("publishing $id.demos.html");
	  $tt->process("list_of_demos_page.tt",$vars,"$id.demos.html")
	    || die $tt->error(), "\n";
	}

      # document list of exercises
      if ( $document->contains_division_with_name('EXERCISE') )
	{
	  $logger->debug("publishing $id.exercises.html");
	  $tt->process("list_of_exercises_page.tt",$vars,"$id.exercises.html")
	    || die $tt->error(), "\n";
	}

      # document list of slides
      if ( $document->contains_division_with_name('SLIDE') )
	{
	  $logger->debug("publishing $id.slides.html");
	  $tt->process("list_of_slides_page.tt",$vars,"$id.slides.html")
	    || die $tt->error(), "\n";
	}

      # document version history
      if ( $document->contains_version_history )
	{
	  $logger->debug("publishing $id.history.html");
	  $tt->process("version_history_page.tt",$vars,"$id.history.html")
	    || die $tt->error(), "\n";
	}

      # document changes
      if ( $document->contains_changes )
	{
	  $logger->debug("publishing $id.change.html");
	  $tt->process("document_change_page.tt",$vars,"$id.change.html")
	    || die $tt->error(), "\n";
	}

      # document glossary
      my $glossary = $document->get_glossary;

      if ( $glossary->contains_entries )
	{
	  $logger->debug("publishing $id glossary.html");
	  $tt->process("document_glossary_page.tt",$vars,"glossary.html")
	    || die $tt->error(), "\n";
	}

      # document acronym list
      my $acronym_list = $document->get_acronym_list;

      if ( $acronym_list->contains_entries )
	{
	  $logger->debug("publishing $id acronyms.html");
	  $tt->process("document_acronyms_page.tt",$vars,"acronyms.html")
	    || die $tt->error(), "\n";
	}

      # document references (bibliography)
      my $references = $document->get_references;

      if ( $references->contains_entries )
	{
	  $logger->debug("publishing $id references.html");
	  $tt->process("document_references_page.tt",$vars,"references.html")
	    || die $tt->error(), "\n";
	}

      # document index
      if ( $document->get_index->contains_entries )
	{
	  $logger->debug("publishing $id index.html");
	  $tt->process("index_page.tt",$vars,"index.html")
	    || die $tt->error(), "\n";
	}

      if ( $document->contains_error )
	{
	  $logger->debug("publishing $id.errors.html");
	  $tt->process("document_errors_page.tt",$vars,"$id.errors.html")
	    || die $tt->error(), "\n";
	}

      $logger->debug("publishing METADATA.txt");
      $tt->process("METADATA.tt",$vars,"METADATA.txt")
	|| die $tt->error(), "\n";
    }

  else
    {
      $logger->error("document has no sections!");
    }

  if ( $library->has_images )
    {
      my $id            = $document->get_id;
      my $library_dir   = $library->get_directory_path;
      my $images_dir    = $library->get_images_dir;

      unless ( -d "$published_dir/images" )
	{
	  mkdir "$published_dir/images", 0755;
	  $logger->debug("made directory $published_dir/images");
	}

      unless ( -d "$state_dir/images" )
	{
	  mkdir "$state_dir/images", 0755;
	  $logger->debug("made directory $state_dir/images");
	}

      unless ( -d "$output_dir/images" )
	{
	  mkdir "$output_dir/images", 0755;
	  $logger->debug("made directory $output_dir/images");
	}

      foreach my $image (@{ $library->get_image_list })
	{
	  my $orig  = "$images_dir/$image";
	  my $copy1 = "$published_dir/images/$image";
	  my $copy2 = "$state_dir/images/$image";
	  my $copy3 = "$output_dir/images/$image";

	  if ( not -f $orig )
	    {
	      $logger->error("IMAGE FILE NOT FOUND \'$orig\'");
	      next;
	    }

	  if ( not -f $copy1 )
	    {
	      $logger->debug("copying image $image");
	      File::Copy::copy($orig,$copy1);
	      utime undef, undef, "$copy1";
	    }

	  if ( not -f $copy2 )
	    {
	      $logger->debug("copying image $image");
	      File::Copy::copy($orig,$copy2);
	      utime undef, undef, "$copy2";
	    }

	  if ( not -f $copy3 )
	    {
	      $logger->debug("copying image $image");
	      File::Copy::copy($orig,$copy3);
	      utime undef, undef, "$copy3";
	    }
	}
    }

  if ( $document->contains_element_with_name('image') )
    {
      my $image_list = $document->get_list_of_elements_with_name('image');

      foreach my $image (@{ $image_list })
	{
	  $self->_publish_html_image($document,$image);
	}
    }

  if ( $document->contains_element_with_name('file') )
    {
      my $file_list = $document->get_list_of_elements_with_name('file');

      foreach my $file (@{ $file_list })
	{
	  $self->_publish_html_file($document,$file);
	}
    }

  if ( -d "$template_dir/images" )
    {
      dircopy("$template_dir/images","$output_dir/images")
	|| die "Couldn't copy images directory";

      dircopy("$template_dir/images","$state_dir/images")
	|| die "Couldn't copy images directory";
    }

  if ( -d "$template_dir/css" )
    {
      dircopy("$template_dir/css","$output_dir/css")
	|| die "Couldn't copy css directory";

      dircopy("$template_dir/css","$state_dir/css")
	|| die "Couldn't copy css directory";
    }

  if ( -d "$template_dir/javascript" )
    {
      dircopy("$template_dir/javascript","$output_dir/javascript")
	|| die "Couldn't copy javascript directory";

      dircopy("$template_dir/javascript","$state_dir/javascript")
	|| die "Couldn't copy javascript directory";
    }

  return 1;
}

######################################################################

sub _publish_sml_document {

  my $self     = shift;
  my $document = shift;                 # document to publish
  my $style    = shift;                 # default

  if (
      not ref $document
      or
      not $document->isa('SML::Document')
     )
    {
      $logger->error("NOT A DOCUMENT $document");
      return 0;
    }

  my $library      = $self->get_library;
  my $template_dir = $library->get_template_dir . "/sml/$style";

  if ( not -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  if ( not -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  my $id         = $document->get_id;
  my $output_dir = "$published_dir/$id";

  if ( not -d $output_dir )
    {
      mkdir "$output_dir", 0755;
      $logger->debug("made directory $output_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $output_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars =
    {
     document => $document,
    };

  $logger->debug("publishing $id.txt");
  $tt->process("DOCUMENT.tt",$vars,"$id.txt")
    || die $tt->error(), "\n";

  return 1;
}

######################################################################

sub _publish_latex_document {

  my $self     = shift;
  my $document = shift;                 # document to publish
  my $style    = shift;                 # default

  my $library       = $self->get_library;
  my $published_dir = $library->get_published_dir;
  my $template_dir  = $library->get_template_dir . "/html/$style";

  if (
      not ref $document
      or
      not $document->isa('SML::Document')
     )
    {
      $logger->error("NOT A DOCUMENT $document");
      return 0;
    }

  my $id = $document->get_id;

  my $output_dir = "$published_dir/$id";

  if ( not -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  if ( not -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  if ( not -d $output_dir )
    {
      mkdir "$output_dir", 0755;
      $logger->debug("made directory $output_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $output_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars =
    {
     document => $document,
    };

  $logger->debug("publishing $id.latex");

  $tt->process("document.tt",$vars,"$id.latex");

  return 1;
}

######################################################################

sub _publish_html_image {

  # Copy an image to the <published>/images directory.  If necessary,
  # put a resized copy of the image in <published>/images-scaled.

  my $self     = shift;
  my $document = shift;                 # document being published
  my $image    = shift;                 # image to resize and/or copy

  my $id             = $document->get_id;
  my $library        = $self->get_library;
  my $state          = 'DRAFT';
  my $published_dir  = $library->get_published_dir;
  my $filespec       = $image->get_value;
  my $library_dir    = $library->get_directory_path;
  my $state_dir      = "$published_dir/$state";
  my $output_dir     = "$state_dir/$id";
  my $images_dir     = "$output_dir/images";
  my $scaled_dir     = "$output_dir/images-scaled";
  my $thumbnails_dir = "$output_dir/images-thumbnails";

  my $basename = basename($filespec);
  my $orig     = "$library_dir/$filespec";
  my $copy     = "$images_dir/$basename";
  my $scaled   = "$scaled_dir/$basename";

  unless ( -f $orig )
    {
      $logger->error("IMAGE FILE NOT FOUND \'$orig\'");
      return 0;
    }

  foreach my $dir ($images_dir,$scaled_dir,$thumbnails_dir)
    {
      unless ( -d $dir )
	{
	  mkdir "$dir", 0755;
	  $logger->debug("made directory $dir");
	}
    }

  if ( (not -f $copy) or ( _file_is_stale($orig,$copy) ) )
    {
      $logger->debug("copying image $basename");
      File::Copy::copy($orig,$copy);
      utime undef, undef, "$copy";
    }

  my $width        = $image->get_width;
  my $scaled_width = $self->_get_scaled_image_width;

  if ( $width > $scaled_width )
    {
      if ( (not -f $scaled) or ( $self->_file_is_stale($orig,$scaled) ) )
	{
	  my $util    = $library->get_util;
	  my $options = $util->get_options;
	  my $convert = $options->get_convert_executable;

	  if ( not -e $convert )
	    {
	      my $cwd = getcwd();
	      $logger->error("NOT EXECUTABLE \'$convert\' from \'$cwd\'");
	      return 0;
	    }

	  my $command = "$convert -size ${scaled_width}x${scaled_width} $orig -resize ${scaled_width}x${scaled_width} +profile \"*\" $scaled";

	  $self->_system_nw($command);
	}
    }

  return 1;
}

######################################################################

sub _publish_html_overall_index_page {

  # Publish an HTML 'overall' index page.  This page summarizes DRAFT,
  # REVIEW, and APPROVED libraries.

  my $self  = shift;
  my $style = shift || 'default';

  my $library      = $self->get_library;
  my $template_dir = $library->get_template_dir . "/html/$style";

  unless ( -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  unless ( -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $published_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars = { library => $library };

  # overall index page
  $logger->debug("publishing overall index.html");
  $tt->process("overall_index_page.tt",$vars,"index.html")
    || die $tt->error(), "\n";

  return 1;
}

######################################################################

sub _publish_html_library_index_page {

  # Publish an HTML library index page.  This page summarizes only the
  # DRAFT library.

  my $self  = shift;
  my $style = shift || 'default';

  my $library      = $self->get_library;
  my $template_dir = $library->get_template_dir . "/html/$style";

  unless ( -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  unless ( -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  my $state     = 'DRAFT';
  my $state_dir = "$published_dir/$state";

  unless ( -d $state_dir )
    {
      mkdir "$state_dir", 0755;
      $logger->debug("made directory $state_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $state_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars = { library => $library };

  # library index page
  $logger->debug("publishing library index.html");
  $tt->process("library_index_page.tt",$vars,"index.html")
    || die $tt->error(), "\n";

  return 1;
}

######################################################################

sub _publish_html_traceability_page {

  # Publish an HTML traceability page.

  my $self  = shift;
  my $style = shift || 'default';

  my $library      = $self->get_library;
  my $template_dir = $library->get_template_dir . "/html/$style";

  unless ( -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  unless ( -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  my $state     = 'DRAFT';
  my $state_dir = "$published_dir/$state";

  unless ( -d $state_dir )
    {
      mkdir "$state_dir", 0755;
      $logger->debug("made directory $state_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $state_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars = { library => $library };

  # traceability page
  $logger->debug("publishing traceability.html");
  $tt->process("library_traceability_page.tt",$vars,"traceability.html")
    || die $tt->error(), "\n";

  my $ontology         = $library->get_ontology;
  my $entity_name_list = $ontology->get_entity_name_list;

  foreach my $entity_name (@{ $entity_name_list })
    {
      $vars->{entity_name} = $entity_name;

      # traceability tree page
      #
      # Only publish a traceability tree page if this entity_name
      # allows the 'is_part_of' property.
      if ( $ontology->allows_property_name_in_division_name('is_part_of',$entity_name) )
	{
	  $logger->debug("publishing tm_tree.$entity_name.html");
	  $tt->process("tm_tree_page.tt",$vars,"tm_tree.$entity_name.html")
	    || die $tt->error(), "\n";
	}
    }

  return 1;
}

######################################################################

sub _publish_html_change_page {

  # Publish an HTML change page.

  my $self  = shift;
  my $style = shift || 'default';

  my $library      = $self->get_library;
  my $template_dir = $library->get_template_dir . "/html/$style";

  unless ( -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  unless ( -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  my $state     = 'DRAFT';
  my $state_dir = "$published_dir/$state";

  unless ( -d $state_dir )
    {
      mkdir "$state_dir", 0755;
      $logger->debug("made directory $state_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $state_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars = { library => $library };

  # change page
  $logger->debug("publishing change.html");
  $tt->process("library_change_page.tt",$vars,"change.html")
    || die $tt->error(), "\n";

  return 1;
}

######################################################################

sub _publish_html_ontology_page {

  # Publish an HTML ontology page.

  my $self  = shift;
  my $style = shift || 'default';

  my $library      = $self->get_library;
  my $template_dir = $library->get_template_dir . "/html/$style";

  unless ( -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  unless ( -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  my $state     = 'DRAFT';
  my $state_dir = "$published_dir/$state";

  unless ( -d $state_dir )
    {
      mkdir "$state_dir", 0755;
      $logger->debug("made directory $state_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $state_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars = { library => $library };

  # ontology page
  $logger->debug("publishing ontology.html");
  $tt->process("ontology_page.tt",$vars,"ontology.html")
    || die $tt->error(), "\n";

  return 1;
}

######################################################################

sub _publish_html_entities_page {

  # Publish an HTML entities page.

  my $self  = shift;
  my $style = shift || 'default';

  my $library      = $self->get_library;
  my $template_dir = $library->get_template_dir . "/html/$style";

  unless ( -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  unless ( -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  my $state     = 'DRAFT';
  my $state_dir = "$published_dir/$state";

  unless ( -d $state_dir )
    {
      mkdir "$state_dir", 0755;
      $logger->debug("made directory $state_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $state_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars = { library => $library };

  # entities page
  $logger->debug("publishing entities.html");
  $tt->process("library_entities_page.tt",$vars,"entities.html")
    || die $tt->error(), "\n";

  return 1;
}

######################################################################

sub _publish_html_library_glossary_page {

  # Publish an HTML library glossary page.

  my $self  = shift;
  my $style = shift || 'default';

  my $library  = $self->get_library;
  my $glossary = $library->get_glossary;

  unless ( $glossary->contains_entries )
    {
      $logger->error("GLOSSARY HAS NO ENTRIES");
      return 0;
    }

  my $template_dir = $library->get_template_dir . "/html/$style";

  unless ( -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  unless ( -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  my $state     = 'DRAFT';
  my $state_dir = "$published_dir/$state";

  unless ( -d $state_dir )
    {
      mkdir "$state_dir", 0755;
      $logger->debug("made directory $state_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $state_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars = { library => $library };

  # entities page
  $logger->debug("publishing glossary.html");
  $tt->process("library_glossary_page.tt",$vars,"glossary.html")
    || die $tt->error(), "\n";

  return 1;
}

######################################################################

sub _publish_html_library_acronyms_page {

  # Publish an HTML library acronyms page.

  my $self  = shift;
  my $style = shift || 'default';

  my $library      = $self->get_library;
  my $acronym_list = $library->get_acronym_list;

  unless ( $acronym_list->contains_entries )
    {
      $logger->error("ACRONYM LIST HAS NO ENTRIES");
      return 0;
    }

  my $template_dir = $library->get_template_dir . "/html/$style";

  unless ( -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  unless ( -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  my $state     = 'DRAFT';
  my $state_dir = "$published_dir/$state";

  unless ( -d $state_dir )
    {
      mkdir "$state_dir", 0755;
      $logger->debug("made directory $state_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $state_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars = { library => $library };

  # entities page
  $logger->debug("publishing acronyms.html");
  $tt->process("library_acronyms_page.tt",$vars,"acronyms.html")
    || die $tt->error(), "\n";

  return 1;
}

######################################################################

sub _publish_html_library_references_page {

  # Publish an HTML library references page.

  my $self  = shift;
  my $style = shift || 'default';

  my $library    = $self->get_library;
  my $references = $library->get_references;

  unless ( $references->contains_entries )
    {
      $logger->error("REFERENCES LIST HAS NO ENTRIES");
      return 0;
    }

  my $template_dir = $library->get_template_dir . "/html/$style";

  unless ( -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  unless ( -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  my $state     = 'DRAFT';
  my $state_dir = "$published_dir/$state";

  unless ( -d $state_dir )
    {
      mkdir "$state_dir", 0755;
      $logger->debug("made directory $state_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $state_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars = { library => $library };

  # entities page
  $logger->debug("publishing references.html");
  $tt->process("library_references_page.tt",$vars,"references.html")
    || die $tt->error(), "\n";

  return 1;
}

######################################################################

sub _publish_html_library_errors_page {

  # Publish an HTML library errors page.

  my $self  = shift;
  my $style = shift || 'default';

  my $library = $self->get_library;

  my $template_dir = $library->get_template_dir . "/html/$style";

  unless ( -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $published_dir = $library->get_published_dir;

  unless ( -d $published_dir )
    {
      mkdir "$published_dir", 0755;
      $logger->debug("made directory $published_dir");
    }

  my $state     = 'DRAFT';
  my $state_dir = "$published_dir/$state";

  unless ( -d $state_dir )
    {
      mkdir "$state_dir", 0755;
      $logger->debug("made directory $state_dir");
    }

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $state_dir,
     RECURSION    => 1,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars = { library => $library };

  # errors page
  $logger->debug("publishing errors.html");
  $tt->process("library_errors_page.tt",$vars,"errors.html")
    || die $tt->error(), "\n";

  return 1;
}

######################################################################

sub _publish_html_file {

  # Copy a file to the <published>/files directory.

  my $self     = shift;
  my $document = shift;                 # document being published
  my $file     = shift;                 # file to copy

  my $id             = $document->get_id;
  my $library        = $self->get_library;
  my $state          = 'DRAFT';
  my $published_dir  = $library->get_published_dir;
  my $filespec       = $file->get_value;
  my $library_dir    = $library->get_directory_path;
  my $state_dir      = "$published_dir/$state";
  my $output_dir     = "$state_dir/$id";
  my $files_dir      = "$output_dir/files";

  my $basename = basename($filespec);
  my $orig     = "$library_dir/$filespec";
  my $copy     = "$files_dir/$basename";

  unless ( -f $orig )
    {
      $logger->error("FILE NOT FOUND \'$orig\'");
      return 0;
    }

  unless ( -d $files_dir )
    {
      mkdir "$files_dir", 0755;
      $logger->debug("made directory $files_dir");
    }

  if ( (not -f $copy) or ( _file_is_stale($orig,$copy) ) )
    {
      $logger->debug("copying file $basename");
      File::Copy::copy($orig,$copy);
      utime undef, undef, "$copy";
    }

  return 1;
}

######################################################################

sub _system_nw {

  my $self    = shift;
  my $command = shift;

  if ($^O eq 'MWWin32')
    {
      my @cmd = split (" ", $command);
      my $ProcessObj;
      Win32::Process::Create
	  (
	   $ProcessObj,
	   $cmd[0],
	   $command,
	   0,
	   'NORMAL_PRIORITY_CLASS' | 'CREATE_NO_WINDOW',
	   ".",
	  ) || die ErrorReport();

      $ProcessObj->Wait('INFINITE');
    }

  else
    {
      system($command);
    }

  return 1;
}

######################################################################

sub _publish_html_library {

  my $self = shift;

  my $library = shift;                  # library to publish
  my $style   = shift;                  # default

  my $template_dir = $library->get_template_dir;
}

######################################################################

sub _build_font_size_list {

  my $self = shift;

  return
    [
     'tiny',
     'scriptsize',
     'footnotesize',
     'small',
     'normalsize',
     'large',
     'Large',
     'LARGE',
     'huge',
     'Huge',
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

sub _file_is_stale {

  my $orig = shift;
  my $copy = shift;

  return 1 if not -f $copy;

  my $time_orig = (stat $orig)[9] || 0;
  my $time_copy = (stat $copy)[9] || 0;

  if ($time_orig > $time_copy) {
    return 1;
  }

  else {
    return 0;
  }
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Publisher> - generates published output files from SML
documents

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  my $publisher = SML::Publisher->new
                    (
                      library => $library,
                    );

  my $boolean = $publisher->publish($id,$rendition,$style);

=head1 DESCRIPTION

A publisher generates published output files from SML documents.  You
can specify the rendition and style to which you wish to publish the
document.

Currently supported renditions are: html, latex, and pdf.

Currently supported styles are: default.

=head1 METHODS

=head2 publish

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
