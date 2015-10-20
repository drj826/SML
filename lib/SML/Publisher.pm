#!/usr/bin/perl

# $Id: Publisher.pm 77 2015-01-31 17:48:03Z drj826@gmail.com $

package SML::Publisher;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Cwd;
use File::Copy::Recursive qw( dircopy );

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

has 'library' =>
  (
   isa       => 'SML::Library',
   reader    => 'get_library',
   required  => 1,
  );

######################################################################

has 'font_size_list' =>
  (
   isa     => 'ArrayRef',
   reader  => 'get_font_size_list',
   lazy    => 1,
   builder => '_build_font_size_list',
  );

######################################################################

has 'font_weight_list' =>
  (
   isa     => 'ArrayRef',
   reader  => 'get_font_weight_list',
   lazy    => 1,
   builder => '_build_font_weight_list',
  );

######################################################################

has 'font_shape_list' =>
  (
   isa     => 'ArrayRef',
   reader  => 'get_font_shape_list',
   lazy    => 1,
   builder => '_build_font_shape_list',
  );

######################################################################

has 'font_family_list' =>
  (
   isa     => 'ArrayRef',
   reader  => 'get_font_family_list',
   lazy    => 1,
   builder => '_build_font_family_list',
  );

######################################################################

has 'background_color_list' =>
  (
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
  my $rendition = shift;                          # html, latex, pdf...
  my $style     = shift || 'default';             # default

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

  else
    {
      $logger->error("THIS SHOULD NEVER HAPPEN");
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
}

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

sub _publish_html_document {

  my $self = shift;

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
      $logger->info("made directory $published_dir");
    }

  if ( not -d $output_dir )
    {
      mkdir "$output_dir", 0755;
      $logger->info("made directory $output_dir");
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

  if ( $document->has_sections )
    {
      # title page
      $logger->info("publishing $id.titlepage.html");
      $tt->process("titlepage.tt",$vars,"$id.titlepage.html")
	|| die $tt->error(), "\n";

      # table of contents
      $logger->info("publishing $id.toc.html");
      $tt->process("toc.tt",$vars,"$id.toc.html")
	|| die $tt->error(), "\n";

      # list of tables
      if ( $document->has_tables )
	{
	  $logger->info("publishing $id.tables.html");
	  $tt->process("list_of_tables_page.tt",$vars,"$id.tables.html")
	    || die $tt->error(), "\n";
	}

      # list of figures
      if ( $document->has_figures )
	{
	  $logger->info("publishing $id.figures.html");
	  $tt->process("list_of_figures_page.tt",$vars,"$id.figures.html")
	    || die $tt->error(), "\n";
	}

      # list of attachments
      if ( $document->has_attachments )
	{
	  $logger->info("publishing $id.attachments.html");
	  $tt->process("list_of_attachments_page.tt",$vars,"$id.attachments.html")
	    || die $tt->error(), "\n";
	}

      # list of listings
      if ( $document->has_listings )
	{
	  $logger->info("publishing $id.listings.html");
	  $tt->process("list_of_listings_page.tt",$vars,"$id.listings.html")
	    || die $tt->error(), "\n";
	}

      my $glossary = $document->get_glossary;

      if ( $glossary->has_entries )
	{
	  $logger->info("publishing $id.glossary.html");
	  $tt->process("glossary_page.tt",$vars,"$id.glossary.html")
	    || die $tt->error(), "\n";
	}

      my $references = $document->get_references;

      if ( $references->has_sources )
	{
	  $logger->info("publishing $id.references.html");
	  $tt->process("references_page.tt",$vars,"$id.references.html")
	    || die $tt->error(), "\n";
	}

      foreach my $section (@{ $document->get_section_list })
	{
	  my $num     = $section->get_number;
	  my $outfile = "$id.$num.html";
	  my $vars    = { self => $section };

	  $logger->info("publishing $outfile");

	  $tt->process('section.tt',$vars,$outfile)
	    || die $tt->error(), "\n";
	}
    }

  else
    {
      $logger->error("document has no sections!");
    }

  if ( -d "$template_dir/images" )
    {
      dircopy("$template_dir/images","$output_dir/images")
	|| die "Couldn't copy images directory";
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
