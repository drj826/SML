#!/usr/bin/perl

# $Id$

package SML::Document;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Region';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Document');

use SML;                 # ci-000002
use SML::Library;        # ci-000410
use SML::Glossary;

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'document',
  );

######################################################################

has 'lookup_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_lookup_hash',
   writer    => 'set_lookup_hash',
   clearer   => 'clear_lookup_hash',
   predicate => 'has_lookup_hash',
  );

# This is a hash of division properties indexed by ID and property
# name.
#
# A division is A contiguous sequence of whole lines.  The smallest
# possible division is a block.  The largest possible division is a
# document. A division has an unambiguous beginning and end.
# Sometimes the beginning and end are explicit and other times they
# are implicit.
#
# A property is a characteristic attribute that describes any division
# of document content.  Properties are expressed using elements.
#
#   my $title = $lookup->{$id}{'title'};

######################################################################

# has 'region_list' =>
#   (
#    isa       => 'ArrayRef',
#    reader    => 'get_region_list',
#    writer    => 'set_region_list',
#    clearer   => 'clear_region_list',
#    predicate => 'has_region_list',
#   );

# This is a sequential array of all regions in the document.
#
# A region is a division that describes the intended content of the
# text.  Regions consist of a preamble followed by an optional region
# narrative. Regions may contain environments. Some regions represent
# entitys (problems, solutions, tests, results, tasks, and
# roles). Other common regions include demo, exercise, keypoints,
# quotation, and slide.
#
#   my $rl = $self->get_region_list;

######################################################################

# has 'environment_list' =>
#   (
#    isa       => 'ArrayRef',
#    reader    => 'get_environment_list',
#    writer    => 'set_environment_list',
#    clearer   => 'clear_environment_list',
#    predicate => 'has_environment_list',
#   );

# This is a sequential array of all environments in the document.
#
# An environment is a division that describes the intended format,
# structure, or content of the contained blocks of text.  Environments
# are composed of a preamble followed by an optional environment
# narrative.  Environments may not be nested. Environments may not
# contain regions.  Environments commonly have titles, IDs, and
# descriptions. Common environments include tables, figures, listings,
# and attachments.
#
#     my $el = $self->get_environment_list;

######################################################################

# has 'section_list' =>
#   (
#    isa       => 'ArrayRef',
#    reader    => 'get_section_list',
#    writer    => 'set_section_list',
#    clearer   => 'clear_section_list',
#    predicate => 'has_section_list',
#    default   => sub {[]},
#   );

# This is a sequential array of all sections in the document.
#
# A section is a division of document structure, that begins with a
# section heading, and contains information about a specific topic.
# Authors may create section headings at different levels to create a
# hierarchy of sections to organize document content.
#
#     my $sl = $self->get_section_list;

######################################################################

has 'note_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_note_hash',
   # writer    => '_set_note_hash',
   # clearer   => '_clear_note_hash',
   # predicate => '_has_note_hash',
   default   => sub {{}},
  );

# This data structure contains note text indexed by division ID and
# note tag.

#   my $note = $nh->{section-2}{a};

######################################################################

has 'outcome_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_outcome_hash',
   writer    => 'set_outcome_hash',
   clearer   => 'clear_outcome_hash',
   predicate => 'has_outcome_hash',
  );

######################################################################

has 'review_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_review_hash',
   writer    => 'set_review_hash',
   clearer   => 'clear_review_hash',
   predicate => 'has_review_hash',
  );

######################################################################

has 'define_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_define_hash',
   writer    => 'set_define_hash',
   clearer   => 'clear_define_hash',
   predicate => 'has_define_hash',
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

has 'source_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_source_hash',
   writer    => 'set_source_hash',
   clearer   => 'clear_source_hash',
   predicate => 'has_source_hash',
  );

######################################################################

has 'previous_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_previous_hash',
   writer    => 'set_previous_hash',
   clearer   => 'clear_previous_hash',
   predicate => 'has_previous_hash',
  );

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
#   $index_ds->{$term} = { $divid_1 => 1, $divid_2 => 1, ... };

######################################################################

has 'table_data_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_table_data_hash',
   writer    => 'set_table_data_hash',
   clearer   => 'clear_table_data_hash',
   predicate => 'has_table_data_hash',
  );

######################################################################

has 'baretable_data_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_baretable_data_hash',
   writer    => 'set_baretable_data_hash',
   clearer   => 'clear_baretable_data_hash',
   predicate => 'has_baretable_data_hash',
  );

######################################################################

# has 'specials' =>
#   (
#    is        => 'ro',
#    isa       => 'HashRef',
#    writer    => 'set_specials',
#    clearer   => 'clear_specials',
#    predicate => 'has_specials',
#   );

######################################################################

# has 'properties' =>
#   (
#    is        => 'ro',
#    isa       => 'HashRef',
#    default   => sub {{}},
#    writer    => 'set_properties',
#    clearer   => 'clear_properties',
#    predicate => 'has_properties',
#   );

# Allowed properties are defined in the SML ontology.  Every property
# has a name and value.  The value is an anonymous array of elements.

######################################################################

has 'html_glossary_filename' =>
  (
   isa       => 'Str',
   reader    => 'get_html_glossary_filename',
   lazy      => 1,
   builder   => '_build_html_glossary_filename',
  );

######################################################################

has 'html_acronyms_filename' =>
  (
   isa       => 'Str',
   reader    => 'get_html_acronyms_filename',
   lazy      => 1,
   builder   => '_build_html_acronyms_filename',
  );

######################################################################

has 'html_sources_filename' =>
  (
   isa       => 'Str',
   reader    => 'get_html_sources_filename',
   lazy      => 1,
   builder   => '_build_html_sources_filename',
  );

######################################################################

has 'author' =>
  (
   isa       => 'Str',
   reader    => 'get_author',
  );

######################################################################

has 'date' =>
  (
   isa    => 'Str',
   reader => 'get_date',
  );

######################################################################

has 'revision' =>
  (
   isa    => 'Str',
   reader => 'get_revision',
  );

######################################################################

has 'subtitle',           is => 'ro', isa => 'Str';
has 'description',        is => 'ro', isa => 'Str';

has 'editor',             is => 'ro', isa => 'Str';
has 'translator',         is => 'ro', isa => 'Str';

has 'publisher',          is => 'ro', isa => 'Str';
has 'publisher_location', is => 'ro', isa => 'Str';
has 'publisher_logo',     is => 'ro', isa => 'Str';
has 'publisher_address',  is => 'ro', isa => 'Str';

has 'edition',            is => 'ro', isa => 'Str';

has 'biographical_note',  is => 'ro', isa => 'Str';
has 'copyright',          is => 'ro', isa => 'Str';
has 'full_copyright',     is => 'ro', isa => 'Str';
has 'publication_year',   is => 'ro', isa => 'Str';

has 'isbn',               is => 'ro', isa => 'Str';
has 'issn',               is => 'ro', isa => 'Str';
has 'cip_data',           is => 'ro', isa => 'Str';

has 'permissions',        is => 'ro', isa => 'Str';
has 'grants',             is => 'ro', isa => 'Str';

has 'paper_durability',   is => 'ro', isa => 'Str';

has 'dedication',         is => 'ro', isa => 'Str';
has 'epigraph',           is => 'ro', isa => 'Str';
has 'epigraph_source',    is => 'ro', isa => 'Str';

has 'doctype',            is => 'ro', isa => 'Str';
has 'fontsize',           is => 'ro', isa => 'Str';
has 'organization',       is => 'ro', isa => 'Str';
has 'version',            is => 'ro', isa => 'Str';

has 'classification',     is => 'ro', isa => 'Str';
has 'classified_by',      is => 'ro', isa => 'Str';
has 'classif_reason',     is => 'ro', isa => 'Str';
has 'declassify_on',      is => 'ro', isa => 'Str';
has 'handling_caveat',    is => 'ro', isa => 'Str';

has 'priority',           is => 'ro', isa => 'Str';
has 'status',             is => 'ro', isa => 'Str';
has 'attr',               is => 'ro', isa => 'Str';

has 'use_formal_status',  is => 'ro', isa => 'Str';

has 'effort_units',       is => 'ro', isa => 'Str';

has 'var',                is => 'ro', isa => 'Str';

has 'logo_image_left',    is => 'ro', isa => 'Str';
has 'logo_image_center',  is => 'ro', isa => 'Str';
has 'logo_image_right',   is => 'ro', isa => 'Str';

has 'header_left',        is => 'ro', isa => 'Str';
has 'header_left_odd',    is => 'ro', isa => 'Str';
has 'header_left_even',   is => 'ro', isa => 'Str';

has 'header_center',      is => 'ro', isa => 'Str';
has 'header_center_odd',  is => 'ro', isa => 'Str';
has 'header_center_even', is => 'ro', isa => 'Str';

has 'header_right',       is => 'ro', isa => 'Str';
has 'header_right_odd',   is => 'ro', isa => 'Str';
has 'header_right_even',  is => 'ro', isa => 'Str';

has 'footer_left',        is => 'ro', isa => 'Str';
has 'footer_left_odd',    is => 'ro', isa => 'Str';
has 'footer_left_even',   is => 'ro', isa => 'Str';

has 'footer_center',      is => 'ro', isa => 'Str';
has 'footer_center_odd',  is => 'ro', isa => 'Str';
has 'footer_center_even', is => 'ro', isa => 'Str';

has 'footer_right',       is => 'ro', isa => 'Str';
has 'footer_right_odd',   is => 'ro', isa => 'Str';
has 'footer_right_even',  is => 'ro', isa => 'Str';

has 'DEFAULT_RENDITION',       is => 'ro', isa => 'Str';
has 'MAX_SEC_DEPTH',           is => 'ro', isa => 'Str';
has 'MAX_ID_HIERARCHY_DEPTH',  is => 'ro', isa => 'Str';

has 'MAX_PASS_TWO_ITERATIONS', is => 'ro', isa => 'Str';
has 'pass_two_count',          is => 'ro', isa => 'Str';

has 'using_longtable',         is => 'ro', isa => 'Boolean';
has 'using_supertabular',      is => 'ro', isa => 'Boolean';

######################################################################

has 'text_line_list' =>
  (
   isa    => 'ArrayRef',
   reader => 'get_text_line_list',
  );

######################################################################

has 'valid' =>
  (
   isa       => 'Bool',
   reader    => 'is_valid',
   writer    => 'set_valid',
   clearer   => 'clear_valid',
   predicate => 'has_valid',
   default   => 1,
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_note {

  my $self = shift;
  my $note = shift;

  if ( $note->isa('SML::Note') )
    {
      my $divid = $note->get_containing_division->get_id;
      my $tag   = $note->get_tag;

      if ( exists $self->get_note_hash->{$divid}{$tag} )
	{
	  $logger->warn("NOTE ALREADY EXISTS: \'$divid\' \'$tag\'");
	}

      $self->get_note_hash->{$divid}{$tag} = $note;

      return 1;
    }

  else
    {
      $logger->error("CAN'T ADD NOTE: \'$note\' is not a SML::Note");
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

sub has_note {

  my $self  = shift;
  my $divid = shift;
  my $tag   = shift;

  if ( exists $self->get_note_hash->{$divid}{$tag} )
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

sub has_glossary_term {

  my $self = shift;
  my $term = shift;
  my $alt  = shift || q{};

  if ( defined $self->get_glossary->{$term}{$alt} )
    {
      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub has_acronym {

  my $self = shift;
  my $term = shift;
  my $alt  = shift || q{};

  if ( defined $self->acronyms->{$term}{$alt} )
    {
      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub has_source {

  my $self   = shift;
  my $source = shift;

  if ( defined $self->get_source_hash->{$source} )
    {
      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub get_acronym_definition {

  my $self = shift;
  my $term = shift;
  my $alt  = shift || q{};

  my $acronyms = $self->acronyms;

  return $acronyms->{$term}{$alt};
}

######################################################################

sub get_note {

  my $self  = shift;
  my $divid = shift;
  my $tag   = shift;
  my $nh    = $self->get_note_hash;

  return $nh->{$divid}{$tag};
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
      # $logger->error("CAN'T GET INDEX TERM");
      return 0;
    }
}

######################################################################

sub get_html_outfile_for {

  # Given an ID, return the filespec for the HTML output file that
  # contains the content of the identified division.
  #
  # Static HTML file naming convention:
  #
  #   <filename>-<section>.html (i.e. all-items-1-1-3.html)

  my $self = shift;
  my $id   = shift;

  my $section  = q{};
  my $sml      = SML->instance;
  my $util     = $sml->get_util;
  my $library  = $util->get_library;
  my $division = undef;

  if ( $library->has_division($id) )
    {
      $division = $library->get_division($id);
    }

  else
    {
      $logger->error("NO DIVISION CONTAINS ID \"$id\"");
      return q{};
    }

  if ( $division->isa('SML::Section') )
    {
      $section = $division;
    }

  else
    {
      $section = $division->get_section;
    }

  if ( not $section->isa('SML::Section') )
    {
      $logger->error("NO SECTION CONTAINS DIVISION \"$id\"");
    }

  my $number            = $section->get_number;
  my $hyphenated_number = $util->hyphenate($number);
  my $docid             = $self->get_id;

  my $filename = $docid . q{-} . $hyphenated_number . '.html';

  return $filename;
}

######################################################################

sub get_html_status_icon {

  my $self    = shift;
  my $status  = shift;
  my $sml     = SML->instance;
  my $util    = $sml->get_util;
  my $options = $util->get_options;

  my $grey_icon = $options->get_status_icon_grey_filespec;

  # default to grey
  #
  my $icon = "<image src=\"$grey_icon\" border=\"0\"/>";

  # green?
  #
  if ( $status =~ /green/xms ) {
    my $green_icon = $options->get_status_icon_green_filespec;
    $icon = "<image src=\"$green_icon\" border=\"0\"/>";
  }

  # yellow?
  #
  elsif ( $status =~ /yellow/xms ) {
    my $yellow_icon = $options->get_status_icon_yellow_filespec;
    $icon = "<image src=\"$yellow_icon\" border=\"0\"/>";
  }

  # red?
  #
  elsif ( $status =~ /red/xms ) {
    my $red_icon = $options->get_status_icon_red_filespec;
    $icon = "<image src=\"$red_icon\" border=\"0\"/>";
  }

  return $icon;
}

######################################################################

sub get_latex_status_icon {

  my $self    = shift;
  my $status  = shift;
  my $sml     = SML->instance;
  my $util    = $sml->get_util;
  my $options = $util->get_options;

  # default to grey
  #
  my $icon = '\textcolor{fg-grey}{$\blacksquare$}';

  # green?
  #
  if ( $status =~ /green/xms ) {
    $icon = '\textcolor{fg-green}{$\blacksquare$}';
  }

  # yellow?
  #
  elsif ( $status =~ /yellow/xms ) {
    $icon = '\textcolor{fg-yellow}{$\blacksquare$}';
  }

  # red?
  #
  elsif ( $status =~ /red/xms ) {
    $icon = '\textcolor{fg-red}{$\blacksquare$}';
  }

  return $icon;
}

######################################################################

sub validate {

  my $self    = shift;
  my $sml     = SML->instance;
  my $util    = $sml->get_util;
  my $library = $util->get_library;
  my $valid   = 1;
  my $id      = $self->get_id;

  foreach my $block (@{ $self->get_block_list })
    {
      if ( not $block->has_valid_syntax )
	{
	  $valid = 0;
	}

      if ( not $block->has_valid_semantics )
	{
	  $valid = 0;
	}
    }

  foreach my $element (@{ $self->get_element_list })
    {
      if ( not $element->has_valid_syntax )
	{
	  $valid = 0;
	}

      if ( not $element->has_valid_semantics )
	{
	  $valid = 0;
	}
    }

  if ( not $self->validate_id_uniqueness )
    {
      $valid = 0;
    }

  foreach my $division (@{ $self->get_division_list })
    {
      if ( $division->get_name eq 'document' )
	{
	  next;
	}

      if ( not $division->validate_semantics )
	{
	  $valid = 0;
	}

      if ( not $division->validate_composition )
	{
	  $valid = 0;
	}
    }

  if ( not $valid )
    {
      $self->set_valid(0);
    }

  if ( $self->is_valid )
    {
      $logger->info("the document is valid \'$id\'");
    }

  else
    {
      $logger->warn("THE DOCUMENT IS NOT VALID \'$id\'");
    }

  return $valid;
}

######################################################################

sub validate_id_uniqueness {

  my $self   = shift;
  my $valid  = 1;
  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $seen   = {};

  foreach my $element (@{ $self->get_element_list })
    {
      if ( $element->get_name ne 'id' )
	{
	  next;
	}

      my $id = $element->get_value;

      if ( not exists $seen->{$id} )
	{
	  $seen->{$id} = $element;
	}

      else
	{
	  my $current_line  = $element->get_first_line;
	  my $filespec      = $current_line->get_file->get_filespec;
	  my $num           = $current_line->get_num;
	  my $previous      = $seen->{$id};
	  my $previous_line = $previous->get_first_line;

	  if (
	      defined $current_line->get_included_from_line
	      and
	      defined $previous_line->get_included_from_line
	     )
	    {
	      my $line_filespec = $current_line->get_included_from_line->get_file->get_filespec;
	      my $line_num      = $current_line->get_included_from_line->get_num;
	      my $prev_filespec = $previous_line->get_file->get_filespec;
	      my $prev_num      = $previous_line->get_num;
	      my $incl_filespec = $previous_line->get_included_from_line->get_file->get_filespec;
	      my $incl_num      = $previous_line->get_included_from_line->get_num;
	      $logger->warn("INVALID NON-UNIQUE ID \"$id\" at $filespec:$num: (included at $line_filespec:$line_num) previously defined in $prev_filespec:$prev_num (included at $incl_filespec:$incl_num)");
	      $self->set_valid(0);
	      $valid = 0;
	    }

	  elsif ( defined $previous_line->get_included_from_line )
	    {
	      my $prev_filespec = $previous_line->get_file->get_filespec;
	      my $prev_num      = $previous_line->get_num;
	      my $incl_filespec = $previous_line->get_included_from_line->get_file->get_filespec;
	      my $incl_num      = $previous_line->get_included_from_line->get_num;
	      $logger->warn("INVALID NON-UNIQUE ID \"$id\" at $filespec:$num: previously defined in $prev_filespec:$prev_num (included at $incl_filespec:$incl_num)");
	      $self->set_valid(0);
	      $valid = 0;
	    }

	  else
	    {
	      my $prev_filespec = $previous_line->get_file->get_filespec;
	      my $prev_num      = $previous_line->get_num;
	      $logger->warn("INVALID NON-UNIQUE ID \"$id\" at $filespec:$num: previously defined at $prev_filespec:$prev_num");
	      $self->set_valid(0);
	      $valid = 0;
	    }
	}
    }

  return $valid;
}

######################################################################

sub as_latex {

  my $self  = shift;
  my $latex = q{};

  return $latex;
}

######################################################################

sub as_csv {

  my $self = shift;
  my $csv  = q{};

  return $csv;
}

######################################################################

sub as_xml {

  my $self = shift;
  my $xml  = q{};

  return $xml;
}

######################################################################

sub start_html {

  my $self = shift;
  my $name = $self->get_name;
  my $html = q{};

  $html .= "\n<html>\n";

  return $html;
}

######################################################################

sub end_html {

  my $self = shift;
  my $name = $self->get_name;
  my $html = q{};

  $html .= "\n</html>\n";

  return $html;
}

######################################################################

# sub division_with_id {

#   # return the division with the specified ID.

#   my $self = shift;
#   my $id   = shift;

#   if ( defined $self->get_division_hash->{$id} )
#     {
#       return $self->get_division_hash->{$id};
#     }

#   else
#     {
#       return undef;
#     }
# }

######################################################################

sub replace_division_id {

  # This is a hack.  I should change the syntax of the division start
  # markup to include the ID so this isn't necessary.  That way the
  # document can remember the correct division ID at the start of the
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

  return 1;
}

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

# sub _init {

#   my $self = shift;

#   $self->clear_footnote;
#   $self->clear_lookup;
#   $self->clear_outcome;
#   $self->clear_review;
#   $self->clear_define;
#   $self->clear_glossary;
#   $self->clear_acronym;
#   $self->clear_previous;
#   $self->clear_index;
#   $self->clear_table_data;
#   $self->clear_baretable_data;
#   $self->clear_specials;
#   $self->clear_html;

# }

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

sub _build_html_glossary_filename {

  my $self  = shift;
  my $docid = $self->get_id;

  return $docid . ".glossary.html";
}

######################################################################

sub _build_html_acronyms_filename {

  my $self  = shift;
  my $docid = $self->get_id;

  return $docid . ".acronyms.html";
}

######################################################################

sub _build_html_sources_filename {

  my $self  = shift;
  my $docid = $self->get_id;

  return $docid . ".source.html";
}

######################################################################

sub _render_html_navigation_pane {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_title_page {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_table_of_contents {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_revisions {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_recent_updates {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_slides {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_sidebars {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_quotations {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_demonstrations {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_exercises {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_listings {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_to_do_items {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_tables {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_figures {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_attachments {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_footnotes {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_glossary {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_acronyms {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_changelog {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_list_of_references {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_index {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_document_section {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

sub _render_html_copyright_page {

  my $self = shift;
  my $html = q{};

  return $html;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Document> - a written work about a topic.

=head1 VERSION

This documentation refers to L<"SML::Document"> version 2.0.0.

=head1 SYNOPSIS

  my $doc = SML::Document->new();

=head1 DESCRIPTION

A document is a written work about a topic.  Documents have types:
book, report, or article. An SML document is composed of a preamble
block followed by a narrative block.

=head1 METHODS

=head2 get_type

=head2 get_name

=head2 get_lookup_hash

=head2 get_region_list

=head2 get_environment_list

=head2 get_section_list

=head2 get_note_hash

=head2 get_outcome_hash

=head2 get_review_hash

=head2 get_define_hash

=head2 get_glossary

=head2 get_acronym_list

=head2 get_references

=head2 get_source_hash

=head2 get_previous_hash

=head2 get_index_hash

=head2 get_table_data_hash

=head2 get_baretable_data_hash

=head2 get_html_glossary_filename

=head2 get_html_acronyms_filename

=head2 get_html_sources_filename

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
