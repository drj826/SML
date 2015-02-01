#!/usr/bin/perl

# $Id$

package SML::Parser;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use lib "..";
use Text::Wrap;
use Cwd;
use Carp;
use File::Basename;
use English;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Parser');

# core classes
use SML;                        # ci-000002
use SML::Options;               # ci-000382
use SML::File;                  # ci-000384
use SML::Line;                  # ci-000385

# string classes
use SML::String;                # ci-000???
use SML::AcronymTermReference;  # ci-000???
use SML::CitationReference;     # ci-000???
use SML::CommandReference;      # ci-000???
use SML::CrossReference;        # ci-000???
use SML::FileReference;         # ci-000???
use SML::FootnoteReference;     # ci-000???
use SML::GlossaryDefinitionReference; # ci-000???
use SML::GlossaryTermReference; # ci-000???
use SML::IDReference;           # ci-000???
use SML::IndexReference;        # ci-000???
use SML::PageReference;         # ci-000???
use SML::PathReference;         # ci-000???
use SML::StatusReference;       # ci-000???
use SML::Symbol;                # ci-000???
use SML::SyntaxErrorString;     # ci-000???
use SML::URLReference;          # ci-000???
use SML::UserEnteredText;       # ci-000???
use SML::VariableReference;     # ci-000???
use SML::EmailAddress;          # ci-000???

# block classes
use SML::Block;                 # ci-000387
use SML::PreformattedBlock;     # ci-000427
use SML::CommentBlock;          # ci-000426
use SML::Paragraph;             # ci-000425
use SML::ListItem;              # ci-000424
use SML::BulletListItem;        # ci-000430
use SML::EnumeratedListItem;    # ci-000431
use SML::DefinitionListItem;    # ci-000432
use SML::Element;               # ci-000386
use SML::Definition;            # ci-000415
use SML::Note;                  # ci-000???

# division classes
use SML::Division;              # ci-000381
use SML::Fragment;              # ci-000nnn
use SML::Document;              # ci-000005
use SML::CommentDivision;       # ci-000388
use SML::Conditional;           # ci-000389
use SML::Section;               # ci-000392
use SML::TableRow;              # ci-000429
use SML::TableCell;             # ci-000428

# environment classes
use SML::Environment;           # ci-000391
use SML::Attachment;            # ci-000393
use SML::Revisions;             # ci-000394
use SML::Epigraph;              # ci-000395
use SML::Figure;                # ci-000396
use SML::Listing;               # ci-000397
use SML::PreformattedDivision;  # ci-000398
use SML::Sidebar;               # ci-000399
use SML::Source;                # ci-000400
use SML::Table;                 # ci-000401
use SML::Baretable;             # ci-000414
use SML::Audio;                 # ci-000402
use SML::Video;                 # ci-000403

# region classes
use SML::Region;                # ci-000390
use SML::Entity;                # ci-000416
use SML::Assertion;             # ci-000404
use SML::Slide;                 # ci-000405
use SML::Demo;                  # ci-000406
use SML::Exercise;              # ci-000407
use SML::Keypoints;             # ci-000408
use SML::Quotation;             # ci-000409
use SML::RESOURCES;             # ci-000xxx

$OUTPUT_AUTOFLUSH = 1;

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
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub parse {

  # Parse an SML fragment. Add parsed entities to the library. Return
  # the fragment object.

  my $self     = shift;
  my $filename = shift;

  my $library  = $self->get_library;
  my $startdir = getcwd;
  my $filespec = $library->get_filespec($filename);
  my $fragdir  = dirname($filespec);
  my $basename = basename($filespec);

  chdir($fragdir);

  $logger->info("parse $basename");

  my $file = SML::File->new(filespec=>$basename);

  if ( not $file->validate )
    {
      $logger->logcroak("CAN'T PARSE \'$basename\'");
    }

  my $fragment = SML::Fragment->new(file=>$file);

  $self->_init;
  $self->_set_line_list( $fragment->get_line_list );
  $self->_set_fragment( $fragment );

  do
    {
      $self->_resolve_includes  while $self->_contains_include;
      $self->_run_scripts       while $self->_contains_script;

      $self->_gather_data;

      $self->_insert_content       if $self->_contains_insert;
      $self->_resolve_templates    if $self->_contains_template;
      $self->_resolve_lookups      if $self->_contains_lookup;
      $self->_substitute_variables if $self->_contains_variable;
      $self->_generate_content     if $self->_contains_generate;
    }

      while $self->_text_requires_processing;

  $logger->info("parse blocks");

  foreach my $block (@{ $fragment->get_block_list })
    {
      next if $block->isa('SML::CommentBlock');
      next if $block->isa('SML::PreformattedBlock');

      $self->_parse_block($block);
    }

  # add documents to the library
  foreach my $division (@{ $fragment->get_division_list })
    {
      if ( $division->isa('SML::Document') )
	{
	  $library->add_document($division);
	}
    }

  chdir($startdir);

  return $fragment;
}

######################################################################

sub extract_division_name {

  # Extract a division name string from a sequence of lines.

  # NOTE: This ONLY works for a sequence of lines that represents a
  # division.  In other words, the first line must be a division
  # starting line.

  my $self  = shift;
  my $lines = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  $_ = $lines->[0]->get_content;

  if ( /$syntax->{start_region}/ )
    {
      return $2;
    }

  elsif ( /$syntax->{start_environment}/ )
    {
      return $2;
    }

  elsif ( /$syntax->{start_section}/ )
    {
      return 'SECTION';
    }

  else
    {
      $logger->error("DIVISION NAME NOT FOUND");
      return '';
    }

}

######################################################################

sub extract_title_text {

  # Extract the preamble title from an array of lines and return it as
  # a string.

  my $self  = shift;
  my $lines = shift;

  my $sml         = SML->instance;
  my $syntax      = $sml->get_syntax;
  my $in_preamble = 1;
  my $in_title    = 0;
  my $first_line  = 1;
  my $title_text  = '';

  # Ignore the first line if it begins a division.

 LINE:
  foreach my $line (@{ $lines })
    {
      $_ = $line->get_content;

      s/[\r\n]*$//;
      # chomp;

      # skip first line if it starts a division
      if (
	  $first_line
	  and
	  (
	   /$syntax->{start_region}/
	   or
	   /$syntax->{start_environment}/
	  )
	 )
	{
	  next;
	}

      # begin title element
      elsif (
	  $in_preamble
	  and
	  not $in_title
	  and
	  /$syntax->{title_element}/
	 )
	{
	  $first_line = 0;
	  $in_title   = 1;
	  $title_text = $1;
	}

      # begin section title
      elsif (
	  $in_preamble
	  and
	  not $in_title
	  and
	  /$syntax->{start_section}/
	 )
	{
	  $first_line = 0;
	  $in_title   = 1;
	  $title_text = $2;
	}

      # blank line ends title
      elsif (
	     $in_title
	     and
	     /$syntax->{blank_line}/
	    )
	{
	  $logger->trace("extracted title: \"$title_text\"");
	  return $title_text;
	}

      # new element ends title
      elsif (
	     $in_title
	     and
	     /$syntax->{start_element}/
	    )
	{
	  $logger->trace("extracted title: \"$title_text\"");
	  return $title_text;
	}

      # preamble ending text?
      elsif ( _line_ends_preamble($_) )
	{
	  $logger->trace("preamble ending text: $_");
	  $logger->trace("extracted title: \"$title_text\"");
	  return $title_text;
	}

      # anything else continues the title
      elsif ( $in_title )
	{
	  $first_line = 0;
	  $title_text .= " $_";
	}

    }

  $logger->trace("extracted title: \"$title_text\"");
  return $title_text;
}

######################################################################

sub extract_preamble_lines {

  # Extract preamble lines from a sequence of division lines.

  # !!! BUG HERE !!!
  #
  #   This method doesn't work for sections.

  my $self  = shift;
  my $lines = shift;

  my $sml                 = SML->instance;
  my $syntax              = $sml->get_syntax;
  my $ontology            = $sml->get_ontology;
  my $preamble_lines      = [];
  my $divname             = $self->extract_division_name($lines);
  my $in_preamble         = 1;
  my $in_preamble_element = 0;
  my $i                   = 0;
  my $last                = scalar @{ $lines };

  foreach my $line (@{ $lines })
    {
      $_ = $line->get_content;

      s/[\r\n]*$//;
      # chomp;
      ++ $i;

      next if $i == 1;     # skip first line
      last if $i == $last; # skip last line

      if ( _line_ends_preamble($_) )
	{
	  return $preamble_lines;
	}

      elsif (
	     $in_preamble
	     and
	     /$syntax->{start_element}/
	     and
	     not $ontology->allows_property($divname,$1)
	    )
	{
	  return $preamble_lines;
	}

      elsif (
	     $in_preamble
	     and
	     /$syntax->{start_element}/
	     and
	     $ontology->allows_property($divname,$1)
	    )
	{
	  $in_preamble_element = 1;
	  push @{ $preamble_lines }, $line;
	}

      elsif (
	     /$syntax->{paragraph_text}/
	     and
	     not $in_preamble_element
	    )
	{
	  return $preamble_lines;
	}

      elsif ( /$syntax->{blank_line}/ )
	{
	  $in_preamble_element = 0;
	  push @{ $preamble_lines }, $line;
	}

      elsif ( $in_preamble )
	{
	  push @{ $preamble_lines }, $line;
	}

      else
	{
	  # do nothing.
	}
    }

  return $preamble_lines;
}

######################################################################

sub extract_narrative_lines {

  # Extract narrative lines from a sequence of division lines.

  # !!! BUG HERE !!!
  #
  #   This method doesn't work for sections.

  my $self  = shift;
  my $lines = shift;

  my $sml                 = SML->instance;
  my $syntax              = $sml->get_syntax;
  my $ontology            = $sml->get_ontology;
  my $narrative_lines     = [];
  my $divname             = $self->extract_division_name($lines);
  my $in_preamble         = 1;
  my $in_preamble_element = 0;
  my $i                   = 0;
  my $last                = scalar @{ $lines };

  foreach my $line (@{ $lines })
    {
      $_ = $line->get_content;

      s/[\r\n]*$//;
      # chomp;
      ++ $i;

      next if $i == 1;     # skip first line
      last if $i == $last; # skip last line

      if ( _line_ends_preamble($_) )
	{
	  $in_preamble = 0;
	  push @{ $narrative_lines }, $line;
	}

      elsif (
	     /$syntax->{start_element}/
	     and
	     $in_preamble
	     and
	     not $ontology->allows_property($divname,$1)
	    )
	{
	  $in_preamble = 0;
	  push @{ $narrative_lines }, $line;
	}

      elsif (
	     /$syntax->{start_element}/
	     and
	     $in_preamble
	     and
	     $ontology->allows_property($divname,$1)
	    )
	{
	  $in_preamble_element = 1;
	}

      elsif (
	     /$syntax->{paragraph_text}/
	     and
	     $in_preamble_element
	    )
	{
	  # do nothing
	}

      elsif (
	     /$syntax->{paragraph_text}/
	     and
	     $in_preamble
	     and
	     not $in_preamble_element
	    )
	{
	  $in_preamble = 0;
	  push @{ $narrative_lines }, $line;
	}

      elsif (
	     /$syntax->{blank_line}/
	     and
	     $in_preamble
	     and
	     $in_preamble_element
	    )
	{
	  $in_preamble_element = 0;
	}

      elsif ( $in_preamble )
	{
	  # do nothing
	}

      else
	{
	  push @{ $narrative_lines }, $line;
	}
    }

  return $narrative_lines;
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has 'fragment' =>
  (
   isa       => 'SML::Fragment',
   reader    => '_get_fragment',
   writer    => '_set_fragment',
  );

# This is the object returned by parse method, usually a document or
# an entity.

######################################################################

has 'line_list' =>
  (
   isa       => 'ArrayRef',
   reader    => '_get_line_list',
   writer    => '_set_line_list',
   clearer   => '_clear_line_list',
   default   => sub {[]},
  );

# This is the sequential array of lines that make up the file being
# parsed.

######################################################################

has 'block' =>
  (
   isa       => 'SML::Block',
   reader    => '_get_block',
   writer    => '_set_block',
   clearer   => '_clear_block',
  );

# This is the current block at any given time during parsing. A block
# is a contiguous sequence of one or more whole lines of text.  Blocks
# end with either a blank line or the beginning of another
# block. Blocks cannot contain blank lines. Blocks may contain inline
# elements which span lines.

######################################################################

has 'division_stack' =>
  (
   isa       => 'ArrayRef',
   reader    => '_get_division_stack',
   writer    => '_set_division_stack',
   clearer   => '_clear_division_stack',
   predicate => '_has_division_stack',
   default   => sub {[]},
  );

# This is a stack of nested divisions at any point during document
# parsing.  A division is a contiguous sequence of blocks.  Divisions
# may be nested within one another. A division has an unambiguous
# beginning and end. Sometimes the beginning and end are explicit and
# other times they are implicit.
#
#   $current_division = $division_stack->[-1];
#   $self->_push_division_stack($division);
#   my $division = $self->_pop_division_stack;

######################################################################

has 'column' =>
  (
   isa       => 'Int',
   reader    => '_get_column',
   writer    => '_set_column',
   default   => 0,
  );

# This is the current table column.

######################################################################

has 'in_preamble' =>
  (
   isa       => 'Bool',
   reader    => '_in_preamble',
   writer    => '_set_in_preamble',
   default   => 0,
  );

# This is a boolean flag that indicates whether the current line is in
# a preamble.  A preamble is the opening part of a division that
# contains (structured data) elements.

######################################################################

has 'count_total_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_count_total_hash',
   writer    => '_set_count_total_hash',
   default   => sub {{}},
  );

# This is a count of the total number of "things" in document.

#   $count = $count_total->{$name};

######################################################################

has 'count_method_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_count_method_hash',
   writer    => '_set_count_method_hash',
   clearer   => '_clear_count_method_hash',
   default   => sub {{}},
  );

# This is a count of the number of times a method has been invoked.

#   $count = $count_method->{$name};

######################################################################

has 'gen_content_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_gen_content_hash',
   default   => sub {{}},
  );

# This is a hash of generated content.

######################################################################

has 'to_be_gen_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_to_be_gen_hash',
   writer    => '_set_to_be_gen_hash',
   default   => sub {{}},
  );

# This is a hash of 'to be generated' content items.

######################################################################

has 'outcome_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_outcome_hash',
   writer    => '_set_outcome_hash',
   default   => sub {{}},
  );

# This is the outcome data structure containing test outcomes indexed
# by test case ID.
#
#   $outcome_description = $outcome->{$test} ?????

######################################################################

has 'review_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_review_hash',
   writer    => '_set_review_hash',
   default   => sub {{}},
  );

# This is the review data structure containing test reviews indexed
# by test case ID.
#
#   $review_description = $review->{$test} ?????

######################################################################

has 'acronym_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_acronym_hash',
   writer    => '_set_acronym_hash',
   default   => sub {{}},
  );

#   $definition = $acronyms->{$term}{$alt};

######################################################################

has 'source_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_source_hash',
   writer    => '_set_source_hash',
   default   => sub {{}},
  );

# $sources->{$sourceid} =
#   {
#    title        => 'CMMI for Development, Version 1.2',
#    label        => 'cmmi',
#    description  => '',
#    address      => '',
#    annote       => '',
#    author       => '',
#    booktitle    => '',
#    chapter      => '',
#    crossref     => '',
#    edition      => '',
#    editor       => '',
#    howpublished => '',
#    institution  => '',
#    journal      => '',
#    key          => '',
#    month        => 'August',
#    note         => 'CMU/SEI-2006-TR-008, ESC-TR-2006-008',
#    number       => '',
#    organization => '',
#    pages        => '',
#    publisher    => '',
#    school       => '',
#    series       => '',
#    source       => 'misc',
#    subtitle     => '',
#    type         => '',
#    volume       => '',
#    year         => '2006',
#    appearance   => '',
#    color        => '',
#    date         => '',
#    icon         => '',
#    mimetype     => '',
#    file         => 'files/cmmi/CMMI-DEV-v1-2.pdf',
#   };

######################################################################

has 'index_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_index_hash',
   writer    => '_set_index_hash',
   default   => sub {{}},
  );

# This is a hash of indexed terms where the key is the term and the
# value is an anonymous array of IDs of the divisions in which the
# terms appear.
#
#   $index->{$term} = [$id1, $id2, $id3...]

######################################################################

has 'table_data_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_table_data_hash',
   writer    => '_set_table_data_hash',
   default   => sub {{}},
  );

# This is a data structure containing information about the tables in
# the document.

######################################################################

has 'baretable_data_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_baretable_data_hash',
   writer    => '_set_baretable_data_hash',
   default   => sub {{}},
  );

# This is a data structure containing information about the baretables
# in the document.  A baretable is a table without a title, ID, or
# description used only to present content in a tabular layout.

######################################################################

has 'template_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_template_hash',
   writer    => '_set_template_hash',
   default   => sub {{}},
  );

# This is a data structure for memoizing templates.  Memoizing
# templates improves performance by avoiding reading oft used
# templates from the file over-and-over again.

######################################################################

has 'requires_processing' =>
  (
   isa     => 'Bool',
   reader  => '_requires_processing',
   writer  => '_set_requires_processing',
   default => 0,
  );

# Don't confuse this boolean value with the private method
# '_text_requires_processing' that determines whether or not the text
# requires further processing.

######################################################################

has 'section_counter_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_section_counter_hash',
   writer    => '_set_section_counter_hash',
   default   => sub {{}},
  );

# $section_counter->{$depth} = $count;
# $section_counter->{1}      = 3;         # third top-level section

######################################################################

has 'division_counter_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_divsion_counter_hash',
   writer    => '_set_division_counter_hash',
   default   => sub {{}},
  );

# $division_counter->{$name}   = $count;
# $division_counter->{'table'} = 4;      # forth table in this top-level

######################################################################

has 'valid' =>
  (
   isa       => 'Bool',
   reader    => '_is_valid',
   writer    => '_set_is_valid',
   default   => 1,
  );

######################################################################

has substring_type_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => '_get_substring_type_list',
   lazy    => 1,
   builder => '_build_substring_type_list',
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _init {

  # Initialize parser.

  # 1. Initialize 'lines' array
  # 2. Initialize method invocation counter

  my $self = shift;

  my $sml     = SML->instance;
  my $util    = $sml->get_util;
  my $options = $util->get_options;

  if ( not $options->use_svn )
    {
      $logger->info("not using SVN, won't warn about uncommitted changes");
    }

  $self->_clear_line_list;
  $self->_set_line_list([]);

  $self->_clear_count_method_hash;
  $self->_set_count_method_hash({});

  return 1;
}

######################################################################

sub _resolve_includes {

  # Scan lines, replace 'include' requests with 'included' lines.

  my $self = shift;

  my $sml            = SML->instance;
  my $syntax         = $sml->get_syntax;
  my $util           = $sml->get_util;
  my $library        = $self->get_library;
  my $count_method   = $self->_get_count_method_hash;
  my $options        = $util->get_options;
  my $max_iterations = $options->get_MAX_RESOLVE_INCLUDES;
  my $count          = ++ $count_method->{'_resolve_includes'};
  my $newlines       = [];
  my $oldlines       = $self->_get_line_list;
  my $in_comment     = 0;
  my $depth          = 1;

  $logger->info("($count) resolve includes");

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }

 LINE:
  foreach my $oldline (@{ $oldlines })
    {
      $_        = $oldline->get_content;
      my $location = $oldline->get_location;

      s/[\r\n]*$//;
      # chomp;

      #---------------------------------------------------------------
      # Ignore comments in containing document
      #
      if (/$syntax->{comment_marker}/) {
	if ( $in_comment ) {
	  $in_comment = 0;
	} else {
	  $in_comment = 1;
	}
	push @{ $newlines }, $oldline;
	next LINE;
      } elsif ( $in_comment ) {
	push @{ $newlines }, $oldline;
	next LINE;
      } elsif ( /$syntax->{'comment_line'}/ ) {
	push @{ $newlines }, $oldline;
	next LINE;
      }

      #---------------------------------------------------------------
      # ELSIF include statement
      #
      elsif ( /$syntax->{include_element}/ )
	{
	  my $asterisks          = $1 || '';
	  my $args               = $2 || '';
	  my $incl_id            = '';
	  my $included_filespec  = '';
	  my $included_lines     = undef;
	  my $fragment           = undef;
	  my $division           = undef;

	  #-----------------------------------------------------------
	  # Determine Division ID and Filespec
	  #
	  #   If the include statement syntax has BOTH a division ID
	  #   AND a filespec the author's intent is to extract the
	  #   division from the fragment.
	  #
	  if ( $3 and $5 )
	    {
	      $incl_id           = $3;
	      $included_filespec = $5;
	    }

	  elsif ( $3 )
	    {
	      $included_filespec = $3;
	    }

	  #-----------------------------------------------------------
	  # Get Fragment From Library Or Die
	  #
	  #   The fragment object should have been created by the
	  #   SML::Fragment::_read_file method and added to the
	  #   library when the fragment was created.
	  #
	  if ( $library->has_fragment( $included_filespec ) )
	    {
	      $fragment = $library->get_fragment( $included_filespec );
	    }

	  else
	    {
	      $logger->logcroak("RESOURCE DETECTED BY _resolve_includes: \'$included_filespec\'");
	    }

	  #-----------------------------------------------------------
	  # Get Division (If Necessary)
	  #
	  if ( $incl_id and not $library->has_division( $incl_id ) )
	    {
	      $included_lines = $fragment->extract_division_lines( $incl_id );
	    }

	  elsif ( $incl_id and $library->has_division( $incl_id ) )
	    {
	      $division = $library->get_division($incl_id);
	      $included_lines = $division->get_line_list;
	    }

	  #-----------------------------------------------------------
	  # IF (1) division is in the library AND (2) one or more
	  # asterisks are present in arguments, THEN include parsed
	  # division as section
	  #
	  if (
	      $division
	      and
	      (
	       $asterisks =~ /(\*+)/
	       or
	       $args =~ /(\*+):/
	      )
	     )
	    {
	      my $asterisks  = $1;
	      my $level      = length($asterisks);
	      my $title      = $division->get_property_value('title');
	      my $narrative  = $division->get_narrative_line_list;
	      my $sechead    = $self->_sechead_line($asterisks,$title);

	      push @{ $included_lines }, $sechead;
	      push @{ $included_lines }, $util->get_blank_line;

	      foreach my $line (@{ $narrative })
		{
		  push @{ $included_lines }, $line;
		}
	    }

	  #-----------------------------------------------------------
	  # IF (1) we have included lines AND (2) one or more
	  # asterisks are present in arguments, THEN include narrative
	  # part of extracted division lines as section
	  #
	  elsif (
	      $included_lines
	      and
	      (
	       $asterisks =~ /(\*+)/
	       or
	       $args =~ /(\*+):/
	      )
	     )
	    {
	      my $asterisks = $1;
	      my $level     = length($asterisks);
	      my $title     = $self->extract_title_text($included_lines);
	      my $narrative = $self->extract_narrative_lines($included_lines);
	      my $sechead   = $self->_sechead_line($asterisks,$title);
	      my $replacement_lines = [];

	      push @{ $replacement_lines }, $sechead;
	      push @{ $replacement_lines }, $util->get_blank_line;

	      foreach my $line (@{ $narrative })
		{
		  push @{ $replacement_lines }, $line;
		}

	      $included_lines = $replacement_lines;
	    }

	  #-----------------------------------------------------------
	  # include flat
	  #
	  elsif (
		 $division
		 and
		 $args =~ /flat:/
		)
	    {
	      foreach my $line (@{ $division->get_line_list }) {
		my $content = $line->get_content;
		if ($content =~ /^(title::\s|\*+\s)/)
		  {
		    $line = $self->_flatten($line);
		  }
		push( @{ $included_lines }, $line );
	      }
	    }

	  #-----------------------------------------------------------
	  # include hide
	  #
	  elsif (
		 $division
		 and
		 $args =~ /hide:/
		)
	    {
	      my $begin_line = $self->_hide_tag;
	      my $end_line   = $self->_hide_tag;

	      push @{ $included_lines }, $begin_line;

	      foreach my $line (@{ $division->get_line_list })
		{
		  push @{ $included_lines }, $line;
		}

	      push @{ $included_lines }, $end_line;
	    }

	  #-----------------------------------------------------------
	  # include raw
	  #
	  elsif (
		 $division
		 and
		 $args =~ /raw:/
		)
	    {
	      foreach my $line (@{ $division->get_line_list })
		{
		  push @{ $included_lines }, $line;
		}
	    }

	  #-----------------------------------------------------------
	  # default
	  #
	  elsif ( $division )
	    {
	      my $asterisks  = '';
	      $asterisks .= '*' until length($asterisks) == $depth;

	      my $title      = $division->get_property_value('title');
	      my $narrative  = $division->get_narrative_line_list;
	      my $sechead    = $self->_sechead_line($asterisks,$title);

	      push @{ $included_lines }, $sechead;
	      push @{ $included_lines }, $util->get_blank_line;

	      foreach my $line (@{ $narrative })
		{
		  push @{ $included_lines }, $line;
		}
	    }

	  else # NOT $incl_id
	    {
	      my $fragment = undef;

	      if ( $library->has_fragment($included_filespec) )
		{
		  $fragment = $library->get_fragment($included_filespec);

		  foreach my $line (@{ $fragment->get_line_list })
		    {
		      push @{ $included_lines }, $line;
		    }
		}

	      else
		{
		  $logger->warn("LIBRARY DOESN'T HAVE FRAGMENT: \'$included_filespec\' at $location");
		}
	    }

	  foreach my $line (@{ $included_lines })
	    {
	      push @{ $newlines }, $line;
	    }
	}

      #---------------------------------------------------------------
      # Section headings (to track current depth)
      #
      elsif (/^(\*+)/)
	{
	  $depth = length($1);
	  push @{ $newlines }, $oldline;
	}

      # no include statement on this line
      else
	{
	  push @{ $newlines }, $oldline;
	}
    }

  $self->_set_line_list($newlines);

  return 1;
}

#---------------------------------------------------------------------
#
#   There are six variations on how a file can be included: (1)
#   default, (2) flat, (3) section, (4) region, (5) hide, and (6) raw:
#
#   (1) default
#
#       The default behavior is to include a file ``as-is'' with the
#       exception that the document title is converted to a section
#       heading at the same section depth as the previous section
#       heading.
#
#         include:: my-file.txt
#
#   (2) flat
#
#       On rare occasions, you may wish to convert all section
#       headings in the included file to simple bold text to
#       "flatten" the section structure.
#
#         include::flat: my-sectioned-file.txt
#
#   (3) section
#
#       Many files have titles.  Titles of included files become
#       section headings in the containing document.  Section
#       heading in included files become sub-section headings in the
#       containing document.
#
#       In SML, section headings are indicated using one or more
#       asterisks at the beginning of a line.  You can choose the
#       section heading level of the included file title using the
#       following syntax.
#
#         include::*: my-section.txt
#
#         include::**: my-subsection.txt
#
#         include::***: my-subsubsection.txt
#
#   (4) region
#
#       There are some special cases when you need to include a file
#       as a document region such as an exercise, demo, problem, or
#       solution.  For instance, if you want to include a file as an
#       exercise, use the syntax:
#
#         include::exercise: my-exercise.txt
#
#   (5) hide
#
#       Occasionally you may need meta-data from included regions,
#       (i.e. data elements such as titles and descriptions) even
#       though you DON'T want the region to appear in the published
#       document.  In other words, you want to include, but hide,
#       the included file's content:
#
#         include::problem:hide: my-problem-for-reference.txt
#
#         include::hide: my-hidden-file.txt
#
#   (6) raw
#
#       If the included file contains an environment like a table or
#       listing the author needs it included in it's 'raw' state.
#       In other words, don't convert the title to and section, and
#       also don't convert the title to a bold string.
#
#         include::raw: my-table.txt
#
#---------------------------------------------------------------------

######################################################################

sub _run_scripts {

  # Scan lines, replace 'script' requests with script outputs.

  my $self = shift;

  my $sml            = SML->instance;
  my $syntax         = $sml->get_syntax;
  my $util           = $sml->get_util;
  my $count_method   = $self->_get_count_method_hash;
  my $newlines       = [];
  my $oldlines       = $self->_get_line_list;
  my $gen_content    = $self->_get_gen_content_hash;
  my $options        = $util->get_options;
  my $library        = $self->get_library;
  my $glossary       = $library->get_glossary;
  my $max_iterations = $options->get_MAX_RUN_SCRIPTS;
  my $count          = ++ $count_method->{'_run_scripts'};
  my $in_comment     = 0;

  $logger->info("($count) run scripts");

  return if not $options->run_scripts;

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }

 LINE:
  foreach my $line (@{ $oldlines })
    {
      my $file = $line->get_file;
      my $num  = $line->get_num;
      $_    = $line->get_content;

      #---------------------------------------------------------------
      # Ignore comments
      #
      if ( /$syntax->{comment_marker}/ ) {
	if ( $in_comment ) {
	  $in_comment = 0;
	} else {
	  $in_comment = 1;
	}
	push @{ $newlines }, $line;
	next LINE;
      } elsif ( $in_comment ) {
	push @{ $newlines }, $line;
	next LINE;
      } elsif ( /$syntax->{'comment_line'}/ ) {
	push @{ $newlines }, $line;
	next LINE;
      }

      # !!! BUG HERE !!!
      #
      # Should the 'script' feature be subject to conditional text?
      # In other words, should the parser run a script if its in a
      # division that is conditionally ignored?

      #---------------------------------------------------------------
      # script:
      #
      elsif ( /$syntax->{script_element}/ )
	{
	  my $script_attr1 = $1 || '';
	  my $command      = $2;
	  my @output       = ();

	  $logger->info("    $command");

	  if ($^O eq 'MSWin32')
	    {
	      $command =~ s/\//\\/g;
	    }

	  @output = eval { `"$command"` };

	  if ( $script_attr1 eq 'hide:' )
	    {
	      next LINE;
	    }
	  else
	    {
	      foreach my $text (@output)
		{
		  my $newline = SML::Line->new
		    (
		     file    => $file,
		     num     => $num,
		     content => $text,
		    );
		  push @{ $newlines }, $newline;
		}
	      next LINE;
	    }
	}

      #---------------------------------------------------------------
      # no script statement on this line
      #
      else
	{
	  push @{ $newlines }, $line;
	}
    }

  $self->_set_line_list($newlines);

  return 1;
}

######################################################################

sub _gather_data {

  # Scan lines, gather data into objects.

  my $self = shift;

  my $sml            = SML->instance;
  my $syntax         = $sml->get_syntax;
  my $util           = $sml->get_util;
  my $options        = $util->get_options;
  my $count_method   = $self->_get_count_method_hash;
  my $max_iterations = $options->get_MAX_GATHER_DATA;
  my $count          = ++ $count_method->{'_gather_data'};

  $logger->info("($count) gather data");

  #-------------------------------------------------------------------
  # MAX interations exceeded?
  #
  if ( $count > $max_iterations )
    {
      my $msg = "$count: EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }

  $self->_set_division_stack([]);

  $self->_set_to_be_gen_hash({});
  $self->_set_outcome_hash({});
  $self->_set_review_hash({});
  $self->_set_acronym_hash({});
  $self->_set_source_hash({});
  $self->_set_index_hash({});
  # $self->_set_table_data_hash({});
  # $self->_set_baretable_data_hash({});
  $self->_set_template_hash({});
  $self->_set_section_counter_hash({});
  # $self->_set_division_counter_hash({});
  $self->_set_count_total_hash({});

  $self->_clear_block;

  $self->_set_column(0);
  $self->_set_requires_processing(0);

  my $library     = $self->get_library;
  my $reasoner    = $library->get_reasoner;

  my $fragment    = $self->_get_fragment;
  my $acronyms    = $self->_get_acronym_hash;
  my $sources     = $self->_get_source_hash;
  my $index       = $self->_get_index_hash;
  my $outcome     = $self->_get_outcome_hash;
  my $review      = $self->_get_review_hash;

  my $to_be_gen   = $self->_get_to_be_gen_hash;
  my $count_total = $self->_get_count_total_hash;

  $fragment->init;

  $self->_begin_division($fragment);

  #-------------------------------------------------------------------
  # parse line-by-line
  #
 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      $_        = $line->get_content;
      my $location = $line->get_location;

      s/[\r\n]*$//;
      # chomp;

      $logger->trace("line: $_");

      if ( /$syntax->{comment_marker}/ )
	{
	  $self->_process_comment_division_marker($line);
	}

      elsif ( /$syntax->{comment_line}/ )
	{
	  $self->_process_comment_line($line);
	}

      elsif ( $self->_in_comment_division )
	{
	  $self->_process_comment_division_line($line);
	}

      elsif ( /$syntax->{start_conditional}/ )
	{
	  $self->_process_conditional_division_marker($line,$2);
	}

      elsif ( /$syntax->{start_region}/ )
	{
	  $self->_process_start_region_marker($line,$2);
	}

      elsif ( /$syntax->{end_region}/ )
	{
	  $self->_process_end_region_marker($line,$2);
	}

      elsif ( /$syntax->{start_environment}/ )
	{
	  $self->_process_environment_marker($line,$2);
	}

      elsif ( /$syntax->{start_section}/ )
	{
	  $self->_process_section_heading($line,length($1));
	}

      elsif ( /$syntax->{end_table_row}/ )
	{
	  $self->_process_end_table_row($line);
	}

      elsif ( /$syntax->{blank_line}/ )
	{
	  $self->_process_blank_line($line);
	}

      elsif ( /$syntax->{id_element}/ )
	{
	  $self->_process_id_element($line,$2);
	}

      elsif ( /$syntax->{note_element}/ )
	{
	  $self->_process_start_note($line,$2);
	}

      elsif ( /$syntax->{glossary_element}/ )
	{
	  $self->_process_start_glossary_entry($line,$1,$3);
	}

      elsif ( /$syntax->{acronym_element}/ )
	{
	  $self->_process_start_acronym_entry($line,$1,$3);
	}

      elsif ( /$syntax->{variable_element}/ )
	{
	  $self->_process_start_variable_definition($line,$1,$3);
	}

      elsif ( /$syntax->{start_element}/ )
	{
	  $self->_process_start_element($line,$1);
	}

      elsif ( /$syntax->{bull_list_item}/ )
	{
	  $self->_process_bull_list_item($line);
	}

      elsif ( /$syntax->{enum_list_item}/ )
	{
	  $self->_process_enum_list_item($line);
	}

      elsif ( /$syntax->{def_list_item}/ )
	{
	  $self->_process_def_list_item($line);
	}

      elsif ( /$syntax->{table_cell}/ )
	{
	  $self->_process_start_table_cell($line);
	}

      elsif ( /$syntax->{paragraph_text}/ )
	{
	  $self->_process_paragraph_text($line);
	}

      elsif ( /$syntax->{indented_text}/ )
	{
	  $self->_process_indented_text($line);
	}

      elsif ( /$syntax->{non_blank_line}/ )
	{
	  $self->_process_non_blank_line($line);
	}

      else
	{
	  $logger->warn("SOMETHING UNEXPECTED HAPPENED: at $location");
	  $self->_set_is_valid(0);
	}
    }

  #-------------------------------------------------------------------
  # end fragment
  #
  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  if ( $self->_in_region )
    {
      my $region = $self->_current_region;
      my $name   = $region->get_name;
      $logger->logdie("FILE ENDED WHILE IN REGION $name");
    }

  if ( $self->_in_environment )
    {
      my $name = $self->_current_environment->get_name;
      $logger->logdie("FILE ENDED WHILE IN ENVIRONMENT $name");
    }

  my $division = $self->_get_current_division;
  while ( not $division->isa('SML::Fragment') )
    {
      $self->_end_division;
      $division = $self->_get_current_division;
    }

  $self->_end_division;

  $self->_generate_section_numbers;
  $self->_generate_division_numbers;

  $reasoner->infer_status_from_outcomes;

  return 1;
}

######################################################################

sub _begin_preamble {

  my $self = shift;

  $logger->trace("..... begin preamble");
  $self->_set_in_preamble(1);

  return 1;
}

######################################################################

sub _end_preamble {

  my $self = shift;

  return if not $self->_in_preamble;

  $logger->trace("..... end preamble");
  $self->_set_in_preamble(0);

  return 1;
}

######################################################################

sub _begin_division {

  my $self     = shift;
  my $division = shift;

  my $name    = $division->get_name;
  my $type    = ref $division;
  my $sml     = SML->instance;
  my $util    = $sml->get_util;
  my $library = $self->get_library;

  $logger->trace("..... begin division $type");

  $library->add_division($division);

  if ( $self->_in_document )
    {
      my $document = $self->_current_document;
      $document->add_division($division);
    }

  $self->_begin_preamble;

  # add this division to the one it is part of
  #
  my $containing_division = $self->_get_current_division;

  if ( defined $containing_division)
    {
      $containing_division->add_part($division);
    }

  $self->_push_division_stack($division);

  if ( $division->isa('SML::Document') )
    {
      return 1;
    }

  elsif ( $division->isa('SML::Fragment') )
    {
      $self->_set_fragment($division);
      return 1;
    }

  elsif ( $division->isa('SML::Entity') )
    {
      $library->add_entity($division);
      return 1;
    }

  elsif ( $division->isa('SML::Source') )
    {
      my $references = $library->get_references;
      $references->add_source($division);
      return 1;
    }

  elsif ( $division->isa('SML::Region') )
    {
      return 1;
    }

  elsif ( $division->isa('SML::TableCell') )
    {
      return 1;
    }

  elsif ( $division->isa('SML::TableRow') )
    {
      $self->_set_column(0);
      return 1;
    }

  elsif ( $division->isa('SML::Table') )
    {
      return 1;
    }

  elsif ( $division->isa('SML::Environment') )
    {
      return 1;
    }

  elsif ( $division->isa('SML::Section') )
    {
      return 1;
    }

  elsif ( $division->isa('SML::CommentDivision') )
    {
      return 1;
    }

  elsif ( $division->isa('SML::Conditional') )
    {
      return 1;
    }

  else
    {
      my $type = ref $division;
      $logger->error("THIS SHOULD NEVER HAPPEN (1) ($type)");
      return 0;
    }
}

######################################################################

sub _end_division {

  # End the CURRENT division.

  my $self = shift;

  my $division = $self->_get_current_division;
  my $type     = ref $division;
  my $sml      = SML->instance;
  my $util     = $sml->get_util;
  my $library  = $self->get_library;

  return 0 if not $division;

  if ( $division->isa('SML::Fragment') )
    {
      while ( $self->_in_region )
	{
	  $self->_end_division;
	}

      if ( $self->_in_environment )
	{
	  $self->_end_division;
	}
    }

  elsif ( $division->isa('SML::Document') )
    {
      while (
	     $self->_in_region
	     and
	     $self->_in_document
	     and
	     $self->_current_region ne $self->_current_document
	    )
	{
	  $self->_end_division;
	}

      if ( $self->_in_environment )
	{
	  $self->_end_division;
	}
    }

  elsif ( $division->isa('SML::TableRow') )
    {
      $self->_set_column(0);
    }

  elsif ( $division->isa('SML::Section') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Entity') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Exercise') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::TableCell') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Table') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Baretable') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Figure') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::CommentDivision') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Conditional') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Listing') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Source') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::PreformattedDivision') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::RESOURCES') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Revisions') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Epigraph') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Attachment') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Slide') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Demo') )
    {
      # do nothing.
    }

  else
    {
      $logger->warn("WHAT JUST HAPPENED? ($type)");
      return 0;
    }

  my $olddiv  = $self->_pop_division_stack;
  my $oldname = $olddiv->get_name;
  my $oldtype = ref $olddiv;

  $logger->trace("..... end division $oldtype");

  return 1;
}

######################################################################

sub _end_table_row {

  my $self = shift;

  return if not $self->_in_table_row;

  $logger->trace("..... end table row");

  if ( $self->_in_table_cell )
    {
      $self->_end_division;
    }

  if ( $self->_in_table_row )
    {
      $self->_end_division;
    }

  return 1;
}

######################################################################

sub _end_baretable {

  my $self = shift;

  return if not $self->_in_baretable;

  $logger->trace("..... end baretable");

  if ( $self->_in_table_cell )
    {
      $self->_end_division;
    }

  if ( $self->_in_table_row )
    {
      $self->_end_table_row;
    }

  if ( $self->_in_baretable )
    {
      $self->_end_division;
    }

  return 1;
}

######################################################################

sub _end_table {

  my $self = shift;

  return if not $self->_in_table;

  $logger->trace("..... end table");

  if ( $self->_in_table_cell )
    {
      $self->_end_division;
    }

  if ( $self->_in_table_row )
    {
      $self->_end_table_row;
    }

  if ( $self->_in_table )
    {
      $self->_end_division;
    }

  return 1;
}

######################################################################

sub _end_section {

  my $self = shift;

  return if not $self->_in_section;

  $self->_end_division;

  return 1;

}

######################################################################

sub _begin_default_section {

  my $self = shift;

  return if $self->_in_section;

  $logger->trace("..... begin default section");

  my $division = $self->_get_current_division;
  my $sml      = SML->instance;
  my $util     = $sml->get_util;
  my $section  = $util->get_default_section;

  $self->_begin_division($section);

  return 1;
}

######################################################################

sub _insert_content {

  # Scan lines, insert requested content lines.

  my $self = shift;

  my $sml            = SML->instance;
  my $syntax         = $sml->get_syntax;
  my $util           = $sml->get_util;
  my $newlines       = [];
  my $fragment       = $self->_get_fragment;
  my $count_method   = $self->_get_count_method_hash;
  my $oldlines       = $self->_get_line_list;
  my $gen_content    = $self->_get_gen_content_hash;
  my $options        = $util->get_options;
  my $library        = $self->get_library;
  my $glossary       = $library->get_glossary;
  my $max_iterations = $options->get_MAX_INSERT_CONTENT;
  my $count          = ++ $count_method->{'_insert_content'};

  $logger->info("($count) insert content");

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }

 LINE:
  foreach my $line (@{ $oldlines })
    {
      $_        = $line->get_content;
      my $location = $line->get_location;

      #----------------------------------------------------------------
      # insert::
      #
      if (/$syntax->{insert_element}/)
	{
	  my $string = $1;
	  my $name   = $string;
	  my $args   = $3 || '';

	  $logger->trace("$name $args");

	  if ( not $sml->allows_insert($name) )
	    {
	      $logger->error("UNKNOWN INSERT NAME at $location: \"$name\"");
	      $fragment->_set_is_valid(0);
	      s/^(.*)/# $1/;

	      my $newline = SML::Line->new
		(
		 included_from => $line,
		 content       => $_,
		);

	      push @{ $newlines }, $newline;

	      next LINE;
	    }

	  else
	    {
	      my $id      = $args;
	      my $options = '';;
	      my $parts   = [ split(',',$args) ];

	      $id      = $parts->[0] if $parts->[0];
	      $options = $parts->[1] if $parts->[1];

	      my $newline = SML::Line->new
		(
		 included_from => $line,
		 content       => "insert_ins:: $name;$id;$options\n",
		);

	      push @{ $newlines }, $newline;

	      next LINE;
	    }
	}

    #----------------------------------------------------------------
    # insert_ins::
    #
    elsif (/$syntax->{'insert_ins_element'}/)
      {
	my $request           = $1;
	my @parts             = split(';',$request);
	my $name              = $parts[0];
	my $id                = $parts[1] || '';
	my $args              = $parts[2] || '';
	my $replacement_lines = [];

	if ($name eq 'PREAMBLE')
	  {
	    $replacement_lines = $library->get_preamble_line_list($id);
	    foreach my $newline (@{ $replacement_lines })
	      {
		push @{ $newlines }, $newline;
	      }
	  }

	elsif ($name eq 'NARRATIVE')
	  {
	    $replacement_lines = $library->get_narrative_line_list($id);
	    foreach my $newline (@{ $replacement_lines })
	      {
		push @{ $newlines }, $newline;
	      }
	  }

	elsif ($name eq 'DEFINITION')
	  {
	    my @parts = split(':',$id);
	    my $term  = $parts[0];
	    my $alt   = $parts[1] || '';
	    my $entry = $library->get_glossary->get_entry($term,$alt);
	    my $replacement_text = $entry->get_value;
	    my $newline = SML::Line->new
	      (
	       included_from => $line,
	       content       => "$replacement_text\n",
	      );
	    push @{ $newlines }, $newline;
	  }

	else
	  {
	    $logger->warn("THIS SHOULD NEVER HAPPEN (2)");
	  }

	next LINE;
      }

    #----------------------------------------------------------------
    # insert_gen::
    #
    elsif (/$syntax->{'insert_gen_element'}/)
      {
	my $request = $1;
	my @parts   = split(';',$request);
	my $name    = $parts[0];
	my $divid   = $parts[1] || '';
	my $args    = $parts[2] || '';

	my $replacement_text = $gen_content->{$name}{$divid}{$args};

	my @new = split(/\n/s,"$replacement_text");

	foreach my $text (@new)
	  {
	    my $newline = SML::Line->new
	      (
	       included_from => $line,
	       content       => "$text\n",
	      );
	    push @{ $newlines }, $newline;
	  }

	next LINE;
      }

    #----------------------------------------------------------------
    # no insert statement on this line
    #
    else {
      push @{ $newlines }, $line;
    }
  }

  $self->_set_requires_processing(1);
  $self->_set_line_list($newlines);

  return 1;
}

######################################################################

sub _substitute_variables {

  # Scan blocks, substitute inline variable tags with values.

  my $self = shift;

  my $sml            = SML->instance;
  my $syntax         = $sml->get_syntax;
  my $util           = $sml->get_util;
  my $options        = $util->get_options;
  my $library        = $self->get_library;
  my $fragment       = $self->_get_fragment;
  my $block_list     = $fragment->get_block_list;
  my $count_method   = $self->_get_count_method_hash;
  my $max_iterations = $options->get_MAX_SUBSTITUTE_VARIABLES;
  my $count          = ++ $count_method->{'_substitute_variables'};
  my $document       = undef;
  my $docid          = '';

  $logger->info("($count) substitute variables");

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }


 BLOCK:
  foreach my $block (@{ $block_list })
    {
      next if $block->isa('SML::CommentBlock');
      next if $block->is_in_a('SML::CommentDivision');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('SML::PreformattedDivision');

      $_ = $block->get_content;

      next if /$syntax->{'comment_line'}/;

      while ( /$syntax->{variable_ref}/ )
	{
	  my $name = $1;
	  my $alt  = $3 || '';

	  if ( $library->has_variable($name,$alt) )
	    {
	      # substitute variable value
	      my $value = $library->get_variable_value($name,$alt);
	      s/$syntax->{variable_ref}/$value/;

	      $logger->trace("substituted $name $alt variable with $value");
	    }

	  else
	    {
	      # error handling
	      my $location = $block->get_location;
	      $logger->warn("UNDEFINED VARIABLE: \'$name\' at $location");
	      $self->_set_is_valid(0);
	      $fragment->_set_is_valid(0);
	      s/$syntax->{variable_ref}/$name/;
	    }
	}

      $block->set_content($_);
    }

  return 1;
}

######################################################################

sub _resolve_lookups {

  my $self = shift;

  my $count_method   = $self->_get_count_method_hash;
  my $fragment       = $self->_get_fragment;
  my $block_list     = $fragment->get_block_list;
  my $sml            = SML->instance;
  my $syntax         = $sml->get_syntax;
  my $util           = $sml->get_util;
  my $options        = $util->get_options;
  my $max_iterations = $options->get_MAX_RESOLVE_LOOKUPS;
  my $count          = ++ $count_method->{'_resolve_lookups'};
  my $library        = $self->get_library;

  $logger->info("($count) resolve lookups");

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }


 BLOCK:
  foreach my $block (@{ $block_list })
    {
      next if $block->isa('SML::CommentBlock');
      next if $block->is_in_a('SML::CommentDivision');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('SML::PreformattedDivision');

      $_ = $block->get_content;

      next if /$syntax->{'comment_line'}/;

      while ( /$syntax->{lookup_ref}/ )
	{
	  my $name = $2;
	  my $id   = $3;

	  if ( $library->has_property($id,$name) )
	    {
	      $logger->trace("..... $id $name is in library");
	      my $value = $library->get_property_value($id,$name);

	      s/$syntax->{lookup_ref}/$value/;
	    }

	  else
	    {
	      my $location = $block->get_location;
	      my $msg = "LOOKUP FAILED: at $location: \'$id\' \'$name\'";
	      $logger->warn($msg);
	      $self->_set_is_valid(0);
	      $fragment->_set_is_valid(0);
	      s/$syntax->{lookup_ref}/($msg)/;
	    }
	}

      $block->set_content($_);
    }

  return 1;
}

######################################################################

sub _resolve_templates {

  my $self = shift;

  my $sml            = SML->instance;
  my $syntax         = $sml->get_syntax;
  my $util           = $sml->get_util;
  my $fragment       = $self->_get_fragment;
  my $count_method   = $self->_get_count_method_hash;
  my $newlines       = [];
  my $oldlines       = $self->_get_line_list;
  my $options        = $util->get_options;
  my $max_iterations = $options->get_MAX_RESOLVE_TEMPLATES;
  my $count          = ++ $count_method->{'_resolve_templates'};
  my $in_comment     = 0;

  $logger->info("($count) resolve templates");

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }

 LINE:
  foreach my $line ( @{ $oldlines } )
    {
      my $num = $line->get_num;            # line number in file
      $_   = $line->get_content;        # line content

      #---------------------------------------------------------------
      # Ignore comments
      #
      if (/$syntax->{comment_marker}/) {
	if ( $in_comment ) {
	  $in_comment = 0;
	} else {
	  $in_comment = 1;
	}
	push @{ $newlines }, $line;
	next LINE;
      } elsif ( $in_comment ) {
	push @{ $newlines }, $line;
	next LINE;
      } elsif ( /$syntax->{'comment_line'}/ ) {
	push @{ $newlines }, $line;
	next LINE;
      }

      #---------------------------------------------------------------
      # Process template element
      #
      elsif (/$syntax->{template_element}/)
	{
	  my $attrs     = $1;
	  my $template  = $4;
	  my $comment   = $6;
	  my $variables = {};
	  my $text      = '';

	  if ( not -f $template )
	    {
	      my $cwd = getcwd;
	      $logger->logcroak("NO TEMPLATE FILE \"$template\" (from \"$cwd\")");
	    }

	  elsif ( exists $self->_get_template_hash->{$template} )
	    {
	      $text = $self->_get_template_hash->{$template};
	    }

	  else
	    {
	      # read template file
	      my $file = SML::File->new(filespec=>$template);
	      if ( not $file->validate )
		{
		  my $location = $line->get_location;
		  $logger->error("TEMPLATE FILE NOT FOUND \'$template\' at $location");
		  $fragment->_set_is_valid(0);
		}
	      $text = $file->get_text;
	      $self->_get_template_hash->{$template} = $text;
	    }

	  my @vars = split(/:/,$attrs);

	  for my $var (@vars)
	    {
	      if ($var =~ /^\s*(.*?)\s*=\s*(.*?)\s*$/)
		{
		  $variables->{$1} = $2;
		}
	      else
		{
		  # ignore it
		}
	    }

	  for my $key ( keys %{ $variables } )
	    {
	      my $value = $variables->{$key};
	      $text =~ s/\[var:$key\]/$value/g;
	    }

	  for my $newlinetext ( split(/\n/s, $text) )
	    {
	      my $newline = SML::Line->new
		(
		 file    => $line->get_file,
		 num     => $num,
		 content => "$newlinetext\n",
		);
	      push @{ $newlines }, $newline;
	    }
	  next LINE;
	}
      else
	{
	  push @{ $newlines }, $line;
	}
    }

  $self->_set_requires_processing(1);
  $self->_set_line_list($newlines);

  return 1;
}

######################################################################

sub _generate_content {

  # 1. Generate requested content.
  # 2. Replace 'generate' statement(s) with 'insert_gen' statement(s)

  my $self = shift;

  my $sml            = SML->instance;
  my $syntax         = $sml->get_syntax;
  my $util           = $sml->get_util;
  my $count_method   = $self->_get_count_method_hash;
  my $to_be_gen      = $self->_get_to_be_gen_hash;
  my $gen_content    = $self->_get_gen_content_hash;
  my $oldlines       = $self->_get_line_list;
  my $options        = $util->get_options;
  my $newlines       = [];
  my $max_iterations = $options->get_MAX_GENERATE_CONTENT;
  my $count          = ++ $count_method->{'_generate_content'};
  my $divid          = '';
  my $docid          = '';

  $logger->info("($count) generate content");

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }

 LINE:
  foreach my $line (@{ $oldlines })
    {
      $_ = $line->get_content;         # line content

      # !!! BUG HERE !!!
      #
      # The following 3 lines of code implement an UNRELIABLE method
      # of detecting an remembering the docid.  It assumes the first
      # ID element after the start of the document is the document ID.
      #
      # I think the solution is to require the docid to be part of the
      # start document markup like this:
      #
      #     ---> document.frd-tvs
      #
      #     ...document goes here...
      #
      #     <--- document
      #
      $docid = '' if /$syntax->{start_document}/;
      $docid = '' if /$syntax->{end_document}/;
      $docid = $2 if /$syntax->{id_element}/ and not $docid;

      #----------------------------------------------------------------
      # generate::
      #
      if (/$syntax->{generate_element}/)
	{
	  my $name = $1;
	  my $args = $2 || '';

	  my $newline = SML::Line->new
	    (
	     content  => "insert_gen:: $name;$divid;$args",
	    );

	  push(@{ $newlines }, $newline);
	}
      else
	{
	  push(@{ $newlines }, $line);
	}
    }

  $self->_set_requires_processing(1);
  $self->_set_line_list($newlines);

  #-------------------------------------------------------------------
  # If there is content to be generated, do it now.
  #
  #    This subroutine gets called during runs of pass 2, meaning that
  #    the lookup data structure has not yet been created.  DO NOT try
  #    to use the lookup data structure to generate requested
  #    content. You'll have to rely on the 'data' data structure.
  #
  #    !!! Bug Here !!!
  #
  #    When I first designed the generated content mechanism I assumed
  #    there would only be one instance of each type of generated
  #    content in a document.  For example, I didn't imaging generating
  #    more than one problem domain listing in the same document.
  #
  #    But now I find myself with the requirement to have multiple
  #    intances of certain blocks of generated content.  For example,
  #    I want the script to be able to generate a listing of
  #    associated problems for any id.  There could be many of
  #    these.  The script needs to maintain a sense of context
  #    (i.e. the current id) for each request to generate a list of
  #    associated problems.
  #
  foreach my $name (keys %{ $to_be_gen })
    {
      my $args  = '';

      #-----------------------------------------------------------------
      # Generate problem-domain-listing
      #
      #     The problem-domain-listing is NOT context sensitive.
      #     Therefore, no matter how many times one was requested in the
      #     document, we only have to generate it ONCE.
      #
      if ( $name eq 'problem-domain-listing' )
	{
	  $logger->trace("generating problem-domain-listing");
	  $gen_content->{$name}{$divid}{$args} = $self->_traceability_matrix('problem');
	  delete $to_be_gen->{'problem-domain-listing'};
	}

      #-----------------------------------------------------------------
      # Generate solution-domain-listing
      #
      #     The solution-domain-listing is NOT context sensitive.
      #     Therefore, no matter how many times one was requested in the
      #     document, we only have to generate it ONCE.
      #
      if ( $name eq 'solution-domain-listing' )
	{
	  $logger->trace("generating solution-domain-listing");
	  $gen_content->{$name}{$docid}{$args} = $self->_traceability_matrix('solution');
	  delete $to_be_gen->{'solution-domain-listing'};
	}

      #-----------------------------------------------------------------
      # Generate prioritized-problem-listing
      #
      #     The prioritized-problem-listing is NOT context sensitive.
      #     Therefore, no matter how many times one was requested in the
      #     document, we only have to generate it ONCE.
      #
      if ( $name eq 'prioritized-problem-listing' )
	{
	  $logger->trace("generating prioritized-problem-listing");
	  $gen_content->{$name}{$docid}{$args} = $self->_generate_prioritized_problem_listing;
	  delete $to_be_gen->{'prioritized-problem-listing'};
	}

      #-----------------------------------------------------------------
      # Generate prioritized-solution-listing
      #
      #     The prioritized-solution-listing is NOT context sensitive.
      #     Therefore, no matter how many times one was requested in the
      #     document, we only have to generate it ONCE.
      #
      if ( $name eq 'prioritized-solution-listing' )
	{
	  $logger->trace("generating prioritized-solution-listing");
	  $gen_content->{$name}{$docid}{$args} = $self->_generate_prioritized_solution_listing;
	  delete $to_be_gen->{'prioritized-solution-listing'};
	}

      #-----------------------------------------------------------------
      # Generate associated problem listing
      #
      #     The associated-problem-listing IS context sensitive.
      #     Therefore, generate the associated-problem-listing for each
      #     relevant id.
      #
      if (    $name eq 'associated-problem-listing'
	  and $to_be_gen->{'associated-problem-listing'}
	 )
	{
	  my @divids = keys %{$to_be_gen->{'associated-problem-listing'}};
	  foreach my $divid (@divids)
	    {
	      $logger->trace("generating $divid associated-problem-listing");
	      $gen_content->{$name}{$divid}{$args} = $self->_generate_associated_problem_listing($divid);
	      delete $to_be_gen->{'associated-solution-listing'}{$divid};
	    }
	}

      #-----------------------------------------------------------------
      # Generate associated solution listing
      #
      #     The associated-solution-listing IS context sensitive.
      #     Therefore, generate the associated-solution-listing for each
      #     relevant id.
      #
      if (    $name eq 'associated-solution-listing'
	  and $to_be_gen->{'associated-solution-listing'}
	 )
	{
	  my @divids = keys %{$to_be_gen->{'associated-solution-listing'}};
	  foreach my $divid (@divids)
	    {
	      $logger->trace("generating $divid associated-solution-listing");
	      $gen_content->{$name}{$divid}{$args} = $self->_generate_associated_solution_listing($divid);
	      delete $to_be_gen->{'associated-solution-listing'}{$divid};
	    }
	}
    }

  return 1;
}

######################################################################

sub _generate_section_numbers {

  # Do this BEFORE generating division numbers!

  my $self = shift;

  # initialize section counter
  my $section_counter = $self->_get_section_counter_hash;

  $section_counter = {};

  my $previous_section;
  my $previous_number = q{};
  my $previous_depth  = 1;
  my $fragment        = $self->_get_fragment;
  my $section_list    = $fragment->get_section_list;

  foreach my $section (@{ $section_list }) {

    my $current_depth = $section->get_depth;

    # adjust counts by depth if prev section was deeper than this one
    if ($previous_depth > $current_depth) {
      my $temp_depth = $previous_depth;
      while ($temp_depth > $current_depth) {
	$section_counter->{$temp_depth} = 0;
	-- $temp_depth;
      }
    }

    # increment counter for current depth
    ++ $section_counter->{$current_depth};

    # formulate section number
    my $number = q{};
    my $depth  = 1;
    $number = $section_counter->{$depth};
    while ($depth < $current_depth) {
      ++$depth;
      $number .= '.' . $section_counter->{$depth};
    }

    # set section number and top_number
    my $top_number = $section_counter->{1};
    $section->set_top_number($top_number);
    $section->set_number($number);

    # previous and next
    $section->set_previous_number($previous_number);

    if ( $previous_section )
      {
	$previous_section->set_next_number($number);
      }

    # prepare for next iteration
    $previous_depth   = $current_depth;
    $previous_section = $section;
    $previous_number  = $number;

  }

  return 1;
}

######################################################################

sub _generate_division_numbers {

  # Do this AFTER generating section numbers!

  my $self = shift;

  $logger->trace("generate division numbers");

  # initialize division counter
  my $division_counter = $self->_get_divsion_counter_hash;

  $division_counter = {};

  my $previous_depth = 1;
  my $fragment       = $self->_get_fragment;
  my $division_list  = $fragment->get_division_list;

  foreach my $division (@{ $division_list }) {

    next if $division->isa('SML::Document'); # skip document division
    next if $division->isa('SML::Section');  # skip section division

    my $section = $division->get_section;

    if ($section) {
      my $name       = $division->get_name;
      my $top_number = $section->get_top_number || '0';
      my $count      = ++ $division_counter->{$name}{$top_number};
      my $number     = $top_number . '-' . $count;

      $division->set_number($number);
    }
  }

  return 1;
}

######################################################################

sub _begin_block {

  # End the old block.  Remember the new block.

  my $self  = shift;
  my $block = shift;

  $self->_end_block if $self->_get_block;

  $self->_set_block($block);

  return 1;
}

######################################################################

sub _end_block {

  # End the current block.

  my $self = shift;

  my $block = $self->_get_block;

  if ( $block->isa('SML::Element') )
    {
      $self->_end_element($block);
    }

  # parse the block into parts (strings)
  # $self->_parse_block($block);

  $self->_clear_block;

  return 1;
}

######################################################################

sub _end_element {

  my $self    = shift;
  my $element = shift;

  my $sml      = SML->instance;
  my $util     = $sml->get_util;
  my $library  = $self->get_library;
  my $name     = $element->get_name;
  my $division = $element->get_containing_division;
  my $divname  = $element->get_containing_division->get_name;
  my $divid    = $element->get_containing_division->get_id;
  my $document = $self->_current_document;

  $library->get_reasoner->infer_inverse_property($element);

  if ( $name eq 'var' )
    {
      $library->add_variable($element);
    }

  elsif ( $name eq 'generate' )
    {
      $self->_add_generate_request($element);
    }

  elsif ( $name eq 'attr' )
    {
      $division->add_attribute($element);
    }

  elsif ( $name eq 'glossary' )
    {
      $library->get_glossary->add_entry($element);
      $document->get_glossary->add_entry($element) if $document;
    }

  elsif ( $name eq 'acronym' )
    {
      $library->get_acronym_list->add_acronym($element);
      $document->get_acronym_list->add_acronym($element) if $document;
    }

  elsif ( $name eq 'outcome' )
    {
      $library->add_outcome($element);
    }

  elsif ( $name eq 'review' )
    {
      $library->add_review($element);
    }

  elsif ( $element->isa('SML::Note') )
    {
      $document->add_note($element) if $document;
    }

  elsif ( $name eq 'image' )
    {
      # do nothing.
    }

  elsif ( $name eq 'index' )
    {
      my $value = $element->get_value;
      my $terms = [ split(/\s*;\s*/,$value) ];

      foreach my $term (@{ $terms })
	{
	  $library->add_index_term($term,$divid);
	  $document->add_index_term($term,$divid) if $document;
	}
    }

  elsif ( $name eq 'use_formal_status' )
    {
      my $options = $util->get_options;
      my $value   = $element->get_value;

      $options->set_use_formal_status($value);
    }

  else
    {
      # do nothing
    }

  return 1;
}

######################################################################

sub _contains_include {

  # Return 1 if text contains an 'include' statement.  Ignore
  # 'include' statements within comments.  This method MUST parse
  # line-by-line (rather than block-by-block or element-by-element)
  # because it is called BEFORE _gather_data builds arrays of blocks
  # and elements.

  my $self = shift;

  my $sml            = SML->instance;
  my $syntax         = $sml->get_syntax;
  my $in_comment     = 0;
  my $in_conditional = '';

 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      $_ = $line->get_content;

      s/[\r\n]*$//;
      # chomp;

      #---------------------------------------------------------------
      # Ignore comments
      #
      if (/$syntax->{comment_marker}/) {
	if ( $in_comment ) {
	  $in_comment = 0;
	} else {
	  $in_comment = 1;
	}
	next LINE;
      } elsif ( $in_comment ) {
	next LINE;
      } elsif ( /$syntax->{'comment_line'}/ ) {
	next LINE;
      }

      #---------------------------------------------------------------
      # Include statments
      #
      #     NOTE: The following regexp does NOT match 'template'
      #     includes like 'include::id=rq-001234:
      #     tmpl/rq-summary.txt' because it doesn't allow for an equal
      #     sign in arguments.
      #
      elsif (/$syntax->{include_element}/)
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved include: $&");
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_script {

  # This method MUST parse line-by-line (rather than block-by-block or
  # element-by-element) because it is called BEFORE _gather_data
  # builds arrays of blocks and elements.

  my $self = shift;

  my $sml        = SML->instance;
  my $syntax     = $sml->get_syntax;
  my $in_comment = 0;

 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      $_ = $line->get_content;

      s/[\r\n]*$//;
      # chomp;

      #---------------------------------------------------------------
      # Ignore comments
      #
      if (/$syntax->{comment_marker}/) {
	if ( $in_comment ) {
	  $in_comment = 0;
	} else {
	  $in_comment = 1;
	}
	next LINE;
      } elsif ( $in_comment ) {
	next LINE;
      } elsif ( /$syntax->{'comment_line'}/ ) {
	next LINE;
      }

      #---------------------------------------------------------------
      # Script statement
      #
      elsif ( /$syntax->{script_element}/ )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved script: $&");
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_insert {

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  foreach my $element ( @{ $self->_get_fragment->get_element_list } )
    {
      $_ = $element->get_content;

      s/[\r\n]*$//;
      # chomp;

      if (
  	     /$syntax->{'insert_element'}/
	  or /$syntax->{'insert_ins_element'}/
	  or /$syntax->{'insert_gen_element'}/
	 )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved insert: $&");
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_variable {

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  my $fragment   = $self->_get_fragment;
  my $block_list = $fragment->get_block_list;

  foreach my $block ( @{ $block_list } )
    {
      next if $block->isa('SML::CommentBlock');
      next if $block->is_in_a('SML::CommentDivision');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('SML::PreformattedDivision');

      $_ = $block->get_content;

      s/[\r\n]*$//;
      # chomp;

      next if /$syntax->{'comment_line'}/;

      if ( /$syntax->{variable_ref}/ )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved variable: $&");
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_lookup {

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  my $fragment   = $self->_get_fragment;
  my $block_list = $fragment->get_block_list;

  foreach my $block ( @{ $block_list } )
    {
      next if $block->isa('SML::CommentBlock');
      next if $block->is_in_a('SML::CommentDivision');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('SML::PreformattedDivision');

      $_ = $block->get_content;

      s/[\r\n]*$//;
      # chomp;

      next if /$syntax->{'comment_line'}/;

      if ( /$syntax->{lookup_ref}/ )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved lookup: $&");
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_template {

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  my $fragment   = $self->_get_fragment;
  my $block_list = $fragment->get_block_list;

  foreach my $block ( @{ $block_list } )
    {
      next if $block->isa('CommentBlock');
      next if $block->is_in_a('SML::CommentDivision');

      $_ = $block->get_content;

      s/[\r\n]*$//;
      # chomp;

      if (    /^template::/                   # deprecate someday
	   or /^(-){3,}template/              # deprecate someday
	   or /^(\.){3,}template/             # deprecate someday
	   or /$syntax->{template_element}/
	 )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved template: $&");
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_generate {

  my $self = shift;

  my $to_be_gen = $self->_get_to_be_gen_hash;
  my $count     = scalar keys %{ $to_be_gen };

  if ( $count > 0 )
    {
      $logger->debug("unresolved generate");
      return 1;
    }
  else
    {
      return 0;
    }
}

######################################################################

sub _text_requires_processing {

  # Return 1 if text contains anything that needs to be resolved.

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  if ( $self->_requires_processing )
    {
      $self->_set_requires_processing(0);
      return 1;
    }

  # check for unresolved elements
  foreach my $element ( @{ $self->_get_fragment->get_element_list } )
    {
      $_ = $element->get_content;

      if (/$syntax->{include_element}/)
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved include: $&");
	  return 1;
	}

      elsif ( /$syntax->{script_element}/ )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved script: $&");
	  return 1;
	}

      elsif (   /$syntax->{'insert_element'}/
	     or /$syntax->{'insert_ins_element'}/
	     or /$syntax->{'insert_gen_element'}/
	    )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved insert: $&");
	  return 1;
	}

      elsif ( /^template::/ )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved template: $&");
	  return 1;
	}

      elsif ( /$syntax->{generate_element}/ )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved generate: $&");
	  return 1;
	}
    }

  # check for unresolved inline text
  my $fragment   = $self->_get_fragment;
  my $block_list = $fragment->get_block_list;

  foreach my $block ( @{ $block_list } )
    {
      next if $block->isa('SML::CommentBlock');
      next if $block->is_in_a('SML::CommentDivision');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('SML::PreformattedDivision');

      $_ = $block->get_content;

      next if /$syntax->{'comment_line'}/;

      if ( /$syntax->{variable_ref}/ )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved variable: $&");
	  return 1;
	}

      elsif ( /$syntax->{lookup_ref}/ )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved lookup: $&");
	  return 1;
	}

      elsif (   /^(-){3,}template/
	     or /^(\.){3,}template/
	 )
	{
	  $logger->debug("$_");
	  $logger->debug("unresolved template: $&");
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _already_in_array {

  # Determine whether a value is already in an array.

  my $self  = shift;
  my $value = shift;
  my $aref  = shift;

  foreach my $item ( @{ $aref } ) {
    if ($item eq $value) {
      return 1;
    }
  }

  return 0;
}

######################################################################

sub _traceability_matrix {

  my $self = shift;
  my $name = shift;                     # problem, solution, test...

  my $sml     = SML->instance;
  my $util    = $sml->get_util;
  my $library = $self->get_library;
  my $text    = q{};

  # Generate and return the structured manuscript language (SML) text
  # for a complete domain traceability matrix.  Domains include: (1)
  # problem, (2) solution, (3) task, (4) test, (5) result, and (6)
  # role.
  #
  # Items are listed in sets.  Each set consists of a "parent" item
  # and its immediate children. Each set is rendered as a table.  The
  # first set consists of the top level problems, followed by the
  # immediate children of the top level problems, followed by their
  # children, and so on.
  #
  # Each table has five columns: (1) item title and description, (2)
  # number of parts (i.e. children), (3) item priority, (4) item
  # status, and (5) traceability.

  $text .= <<"END_OF_TEXT";
:grey: !!Top Level!!

:grey:

:grey:

:grey:

:grey:

---

:grey: ~~$name~~

:grey: ~~parts~~

:grey: ~~priority~~

:grey: ~~status~~

:grey: ~~traceability~~

---

END_OF_TEXT

  #-------------------------------------------------------------------
  # Make a queue of items to be added to the item domain listing and
  # add all of the toplevel items.  A toplevel item is simply any item
  # that doesn't have a parent.
  #
  my @queue         = ();
  my @toplevelitems = ();

  foreach my $division (@{ $self->_list_by_name($name) }) {
    if ( not $division->has_property('parent')) {
      push @toplevelitems, $division;
    }
  }

  #-------------------------------------------------------------------
  # Add each toplevel item to the domain traceability matrix.
  #
  foreach my $division (@toplevelitems) {

    my $id = $division->get_id;

    #---------------------------------------------------------------
    # If this division has children, add it to the list of divisions
    # in the queue
    #
    if ( $division->has_property('child') )
      {
	push @queue, $division;
      }

    else
      {
	$logger->warn("NO CHILD PROPERTY");
      }

    #---------------------------------------------------------------
    # Look up values that need to go into the domain traceability
    # matrix for this division.
    #
    my $title        = q{};
    my $description  = q{};
    my $type         = q{};
    my $priority     = 'routine';
    my $status       = 'grey';
    my $stakeholders = [];
    my $requests     = [];
    my $childcount   = 0;

    if ( $division->has_property('title') )
      {
	$title = $division->get_property_value('title');
      }

    if ( $division->has_property('description') )
      {
	$description = $division->get_property_value('description');
      }

    if ( $division->has_property('type') )
      {
	$type = $division->get_property_value('type');
      }

    if ( $division->has_property('priority') )
      {
	$priority = $division->get_property_value('priority');
      }

    if ( $division->has_property('stakeholder') )
      {
	$stakeholders = $division->get_property_value('stakeholder');
      }

    if ( $division->has_property('request') )
      {
	$requests = $division->get_property_value('request');
      }

    if ( $division->has_property('child') )
      {
	my $property = $division->get_property('child');
	$childcount = $property->get_element_count;
      }

    #-----------------------------------------------------------------
    # info
    #
    my @info = ();
    push @info, $type            if $type;
    push @info, $id              if $id;
    push @info, $stakeholders    if $stakeholders;
    push @info, $requests        if $requests;
    push @info, "[ref:$id]"      if $id;
    my $info = join(', ', @info);

    #-----------------------------------------------------------------
    # status color
    #
    my $status_color = 'white';
    $status_color = 'red'    if $status eq 'red';
    $status_color = 'yellow' if $status eq 'yellow';
    $status_color = 'green'  if $status eq 'green';
    $status_color = 'grey'   if $status eq 'grey';
    $status_color = 'grey'   if $status eq 'gray';

    #-----------------------------------------------------------------
    # priority color
    #
    my $priority_color = 'white';
    $priority_color = 'red'    if $priority eq 'critical';
    $priority_color = 'orange' if $priority eq 'high';
    $priority_color = 'yellow' if $priority eq 'routine';
    $priority_color = 'grey'   if $priority eq 'low';

    #-----------------------------------------------------------------
    # title, description, and other info
    #
    my $title_description_info = $util->wrap("!!$title:!! $description ~~$info~~");

    #---------------------------------------------------------------
    # Put this toplevel item into the domain traceability matrix.
    #
    $text .= <<"END_OF_TEXT";
: $title_description_info

: $childcount

:$priority_color: $priority

:$status_color: $status

:

END_OF_TEXT

    if ( $division->has_property('directed_by') )
      {
	my $property = $division->get_property('directed_by');
	$text .= $property->get_elements_as_enum_list;
      }

    if ( $division->has_property('problem') )
      {
	my $property = $division->get_property('problem');
	$text .= $property->get_elements_as_enum_list;
      }

    if ( $division->has_property('solution') )
      {
	my $property = $division->get_property('solution');
	$text .= $property->get_elements_as_enum_list;
      }

    if ( $division->has_property('task') )
      {
	my $property = $division->get_property('task');
	$text .= $property->get_elements_as_enum_list;
      }

    if ( $division->has_property('test') )
      {
	my $property = $division->get_property('test');
	$text .= $property->get_elements_as_enum_list;
      }

    if ( $division->has_property('result') )
      {
	my $property = $division->get_property('result');
	$text .= $property->get_elements_as_enum_list;
      }

    if ( $division->has_property('role') )
      {
	my $property = $division->get_property('role');
	$text .= $property->get_elements_as_enum_list;
      }

    $text .= <<"END_OF_TEXT";
---

END_OF_TEXT

  }

  #-----------------------------------------------------------------
  # Now process each item on the queue, adding new items to the back
  # of the queue as you find ones that have children.
  #
  foreach my $division (@queue) {

    my $id = $division->get_id;

    #---------------------------------------------------------------
    # title, parent, children
    #
    my $title    = q{};
    my $parent   = q{};
    my $children = [];

    if ( $division->has_property('title') )
      {
	$title = $division->get_property_value('title');
      }

    if ( $division->has_property('parent') )
      {
	$parent = $division->get_property('parent');
      }

    if ( $division->has_property('child') )
      {
	$children = $division->get_property('child');
      }

    $title = $util->wrap("$title");

    #---------------------------------------------------------------
    # Insert the header row for this item.
    #
    $text .= <<"END_OF_TEXT";
:grey: !!$title!!

:grey:

:grey:

:grey:

:grey:

---

:grey: ~~$name~~

:grey: ~~parts~~

:grey: ~~priority~~

:grey: ~~status~~

:grey: ~~traceability~~

---

END_OF_TEXT

    #---------------------------------------------------------------
    # Insert the children of this division.
    #
    foreach my $element (@{ $children->get_element_list }) {

      my $child_id = $element->get_value;
      my $child    = undef;

      if ( $library->has_division($child_id) )
	{
	  $child = $library->get_division($child_id);
	}

      next if not $child;

      #-------------------------------------------------------------
      # If this child has children, add them to the queue.
      #
      if ( $child->has_property('child') )
	{
	  push @queue, $child;
	}

      #-------------------------------------------------------------
      # Look up the values that need to go into the traceability
      # matrix for this child
      #
      my $title        = q{};
      my $description  = q{};
      my $type         = q{};
      my $priority     = 'routine';
      my $status       = 'grey';
      my $stakeholders = [];
      my $requests     = [];
      my $childcount   = 0;

      if ( $library->has_property($child_id,'title') )
	{
	  $title = $library->get_property_value($child_id,'title');
	}

      if ( $library->has_property($child_id,'description') )
	{
	  $description = $library->get_property_value($child_id,'description');
	}

      if ( $library->has_property($child_id,'type') )
	{
	  $type = $library->get_property_value($child_id,'type');
	}

      if ( $library->has_property($child_id,'priority') )
	{
	  $priority = $library->get_property_value($child_id,'priority');
	}

      if ( $library->has_property($child_id,'stakeholder') )
	{
	  $stakeholders = $library->get_property_value($child_id,'stakeholder');
	}

      if ( $library->has_property($child_id,'request') )
	{
	  $requests = $library->get_property_value($child_id,'request');
	}

      if ( $child->has_property('child') )
	{
	  my $child_child = $child->get_property('child');
	  $childcount = $child_child->get_element_count;
	}

      #---------------------------------------------------------------
      # info
      #
      my @info = ();
      push @info, $type             if $type;
      push @info, $child_id         if $child_id;
      push @info, $stakeholders     if $stakeholders;
      push @info, $requests         if $requests;
      push @info, "[ref:$child_id]" if $child_id;
      my $info = join(', ', @info);

      #---------------------------------------------------------------
      # status color
      #
      my $status_color = 'white';
      $status_color = 'red'    if $status eq 'red';
      $status_color = 'yellow' if $status eq 'yellow';
      $status_color = 'green'  if $status eq 'green';
      $status_color = 'grey'   if $status eq 'grey';
      $status_color = 'grey'   if $status eq 'gray';

      #---------------------------------------------------------------
      # priority color
      #
      my $priority_color = 'white';
      $priority_color = 'red'    if $priority eq 'critical';
      $priority_color = 'orange' if $priority eq 'high';
      $priority_color = 'yellow' if $priority eq 'routine';
      $priority_color = 'grey'   if $priority eq 'low';

      my $title_description_info = $util->wrap("!!$title:!! $description ~~$info~~");

      #-------------------------------------------------------------
      # Add this item to the traceability matrix.
      #
      $text .= <<"END_OF_TEXT";
: $title_description_info

: $childcount

:$priority_color: $priority

:$status_color: $status

:

END_OF_TEXT

      if ( $division->has_property('directed_by') )
	{
	  my $property = $division->get_property('directed_by');
	  $text .= $property->get_elements_as_enum_list;
	}

      if ( $division->has_property('problem') )
	{
	  my $property = $division->get_property('problem');
	  $text .= $property->get_elements_as_enum_list;
	}

      if ( $division->has_property('solution') )
	{
	  my $property = $division->get_property('solution');
	  $text .= $property->get_elements_as_enum_list;
	}

      if ( $division->has_property('task') )
	{
	  my $property = $division->get_property('task');
	  $text .= $property->get_elements_as_enum_list;
	}

      if ( $division->has_property('test') )
	{
	  my $property = $division->get_property('test');
	  $text .= $property->get_elements_as_enum_list;
	}

      if ( $division->has_property('result') )
	{
	  my $property = $division->get_property('result');
	  $text .= $property->get_elements_as_enum_list;
	}

      if ( $division->has_property('role') )
	{
	  my $property = $division->get_property('role');
	  $text .= $property->get_elements_as_enum_list;
	}

      $text .= <<"END_OF_TEXT";
---

END_OF_TEXT

    }

  }

  return $text;
}

######################################################################

sub _generate_prioritized_problem_listing {

  my $self = shift;

  my $sml         = SML->instance;
  my $util        = $sml->get_util;
  my $library     = $self->get_library;
  my $lookup      = $library->get_lookup_hash;
  my $count_total = $self->_get_count_total_hash;

  $logger->trace;

  #-------------------------------------------------------------------
  #
  #    Generate and return the structured text for a prioritized
  #    listing (table) of problems.
  #
  #    This subroutine gets called during pass 2 runs, meaning that
  #    the lookup data structure has not yet been created.  DO NOT try
  #    to use the lookup data structure to generate requested
  #    content. You'll have to rely on the 'data' data structure.
  #
  #    This subroutine generates structured text.
  #
  #-------------------------------------------------------------------

  printstatus("generating prioritized problem listing...");

  my $text = '';

  #-------------------------------------------------------------------
  # Assign ranking number to each problem in the problem domain.
  #
  my %problems  = ();
  foreach my $problem (@{ $self->_list_by_name('problem') }) {
    my $priority = $lookup->{$problem}{'priority'};
    my $status   = 'grey';

    if ( id_exists($problem) )
      {
	$status = status_of($problem);
      }

    my $rank     = rank_for($priority,$status);
    push @{$problems{$rank}}, $problem;
    ++ $count_total->{'priority'}{'total'} if $rank >= 1 and $rank <= 8;
  }

  #-----------------------------------------------------------------
  # Begin the problem priorities table
  #
  $text .= <<"END_OF_TEXT";
:grey: !!Prioritized List of Problems To Be Solved!!

:grey:

:grey:

:grey:

:grey:

---

:grey: ~~problem~~

:grey: ~~rank~~

:grey: ~~importance~~

:grey: ~~priority~~

:grey: ~~status~~

---

END_OF_TEXT

  #-----------------------------------------------------------------
  # Output a row for each problem priority
  #
  foreach my $rank (1..8) {
    foreach my $problem (@{$problems{$rank}}) {

      my $title        = $lookup->{$problem}{'title'};
      my $description  = $lookup->{$problem}{'description'};
      my $priority     = $lookup->{$problem}{'priority'};
      my $status       = 'grey';

      if ( id_exists($problem) )
	{
	  $status = status_of($problem);
	}

      # stakeholders...
      #
      my @stakeholders = @{$lookup->{$problem}{'stakeholder'}};
      my $stakeholders = '';
      if (@stakeholders) {
	$stakeholders = join(', ', @stakeholders);
      }

      # requests...
      #
      my @requests     = @{$lookup->{$problem}{'request'}};
      my $requests     = '';
      if (@requests) {
	$requests = join(', ', @requests);
      }

      # determine importance...
      #
      my $importance   = 'routine';
      $importance      = 'urgent' if $rank <= 4;

      my $info = '';
      $info .= $problem;
      $info .= ", $stakeholders"  if $stakeholders;
      $info .= ", $requests"      if $requests;
      $info .= ", [ref:$problem]" if $problem;

      my $status_color = 'white';
      $status_color = 'red'    if $status eq 'red';
      $status_color = 'yellow' if $status eq 'yellow';
      $status_color = 'green'  if $status eq 'green';
      $status_color = 'grey'   if $status eq 'grey';
      $status_color = 'grey'   if $status eq 'gray';

      my $priority_color = 'white';
      $priority_color = 'red'    if $priority eq 'critical';
      $priority_color = 'orange' if $priority eq 'high';
      $priority_color = 'yellow' if $priority eq 'routine';
      $priority_color = 'grey'   if $priority eq 'low';

      my $title_description_info =
	SML->instance-util->wrap("!!$title:!! $description ~~$info~~");

      $text .= <<"END_OF_TEXT";
: $title_description_info

: $rank

: $importance

:$priority_color: $priority

:$status_color: $status

---

END_OF_TEXT
    }
  }

  return $text;
}

######################################################################

sub _generate_prioritized_solution_listing {

  my $self = shift;

  my $sml         = SML->instance;
  my $util        = $sml->get_util;
  my $library     = $self->get_library;
  my $lookup      = $library->get_lookup_hash;
  my $count_total = $self->_get_count_total_hash;

  $logger->trace;

  #-------------------------------------------------------------------
  #
  #    Generate and return the structured text for a prioritized
  #    listing (table) of solutions requiring attention.
  #
  #    This subroutine gets called during pass 2 runs, meaning that
  #    the lookup data structure has not yet been created.  DO NOT try
  #    to use the lookup data structure to generate requested
  #    content. You'll have to rely on the 'data' data structure.
  #
  #    This subroutine generates structured text.
  #
  #-------------------------------------------------------------------

  my $text = '';

  #-------------------------------------------------------------------
  # Assign ranking number to each solution in the solution domain.
  #
  my %solutions  = ();
  foreach my $solution (@{ $self->_list_by_name('solution') }) {
    my $priority = $lookup->{$solution}{'priority'};
    my $status   = 'grey';

    if ( id_exists($solution) )
      {
	$status = status_of($solution);
      }

    my $rank     = rank_for($priority,$status);
    push @{$solutions{$rank}}, $solution;
    ++ $count_total->{'priority'}{'total'} if $rank >= 1 and $rank <= 8;
  }

  #-----------------------------------------------------------------
  # Begin the solution priorities table
  #
  $text .= <<"END_OF_TEXT";
:grey: !!Prioritized List of Solutions To Be Improved!!

:grey:

:grey:

:grey:

:grey:

---

:grey: ~~solution~~

:grey: ~~rank~~

:grey: ~~importance~~

:grey: ~~priority~~

:grey: ~~status~~

---

END_OF_TEXT

  #-----------------------------------------------------------------
  # Output a row for each solution priority
  #
  foreach my $rank (1..8) {
    foreach my $solution (@{$solutions{$rank}}) {

      my $title        = $lookup->{$solution}{'title'};
      my $description  = $lookup->{$solution}{'description'};
      my $priority     = $lookup->{$solution}{'priority'};
      my $status       = 'grey';

      if ( id_exists($solution) )
	{
	  $status = status_of($solution);
	}

      # stakeholders...
      #
      my @stakeholders = @{$lookup->{$solution}{'stakeholder'}};
      my $stakeholders = '';
      if (@stakeholders) {
	$stakeholders = join(', ', @stakeholders);
      }

      # requests...
      #
      my @requests     = @{$lookup->{$solution}{'request'}};
      my $requests     = '';
      if (@requests) {
	$requests = join(', ', @requests);
      }

      # determine importance...
      #
      my $importance   = 'routine';
      $importance      = 'urgent' if $rank <= 4;

      my $info = '';
      $info .= $solution;
      $info .= ", $stakeholders"   if $stakeholders;
      $info .= ", $requests"       if $requests;
      $info .= ", [ref:$solution]" if $solution;

      my $status_color = 'white';
      $status_color   = 'red'    if $status   eq 'red';
      $status_color   = 'yellow' if $status   eq 'yellow';
      $status_color   = 'green'  if $status   eq 'green';
      $status_color   = 'grey'   if $status   eq 'grey';
      $status_color   = 'grey'   if $status   eq 'gray';

      my $priority_color = 'white';
      $priority_color = 'red'    if $priority eq 'critical';
      $priority_color = 'orange' if $priority eq 'high';
      $priority_color = 'yellow' if $priority eq 'routine';
      $priority_color = 'grey'   if $priority eq 'low';

      my $title_description_info = $util->wrap("!!$title:!! $description ~~$info~~");

      $text .= <<"END_OF_TEXT";
: $title_description_info

: $rank

: $importance

:$priority_color: $priority

:$status_color: $status

---

END_OF_TEXT
    }
  }

  return $text;
}

######################################################################

sub _generate_associated_problem_listing {

  my $self = shift;
  my $id   = shift;

  my $sml     = SML->instance;
  my $syntax  = $sml->get_syntax;
  my $util    = $sml->get_util;
  my $library = $self->get_library;
  my $lookup  = $library->get_lookup_hash;

  $logger->trace("$id");

  #-------------------------------------------------------------------
  #
  #    Generate and return the structured text for a listing of
  #    problems associated with the specified id.
  #
  #-------------------------------------------------------------------

  my $text = '';

  #-------------------------------------------------------------------
  # make a list of everything associated with this id.
  #
  my @associates = @{ $lookup->{$id}{'associated'} };

  #-------------------------------------------------------------------
  # go through the list of associates and pick out the problems
  #
  my @problems = ();
  foreach my $associate (@associates) {
    my $associate_name = name_for($associate);
    if ($associate_name eq 'problem') {
      push @problems, $associate;
    }
  }

  #-------------------------------------------------------------------
  # If there were no problems, insert a statement that no problems
  # have been identified.
  #
  if (not @problems) {
    $text .= <<"END_OF_TEXT";
(U) No problems have been identified.

END_OF_TEXT

    return $text;
  }

  #-------------------------------------------------------------------
  # build the listing
  #
  foreach my $problem (@problems) {

    my $title =    $lookup->{$problem}{'title'};
    my @type  = @{ $lookup->{$problem}{'type'} };
    my $type  = join(', ', @type);

    printstatus("  $problem: $type: $title");

    $text .= <<"END_OF_TEXT";
- $title ([ref:$problem])

END_OF_TEXT

  }

  return $text;
}

######################################################################

sub _generate_associated_solution_listing {

  my $self = shift;
  my $id   = shift;

  my $sml     = SML->instance;
  my $util    = $sml->get_util;
  my $library = $self->get_library;
  my $lookup  = $library->get_lookup_hash;

  $logger->trace("$id");

  #-------------------------------------------------------------------
  #
  #    Generate and return the structured text for a listing of
  #    solutions associated with the specified id.
  #
  #-------------------------------------------------------------------

  my $text = '';

  #-------------------------------------------------------------------
  # make a list of everything associated with this id.
  #
  my @associates = @{ $lookup->{$id}{'associated'} };

  #-------------------------------------------------------------------
  # go through the list of associates and pick out the solutions
  #
  my @solutions = ();
  foreach my $associate (@associates) {
    my $associate_name = name_for($associate);
    if ($associate_name eq 'solution') {
      push @solutions, $associate;
    }
  }

  #-------------------------------------------------------------------
  # If there were no solutions, insert a statement that no solutions
  # have been identified.
  #
  if (not @solutions) {
    $text .= <<"END_OF_TEXT";
(U) No solutions have been identified.

END_OF_TEXT

    return $text;
  }

  #-------------------------------------------------------------------
  # build the listing
  #
  foreach my $solution (@solutions) {

    my $title =    $lookup->{$solution}{'title'};
    my @type  = @{ $lookup->{$solution}{'type'} };
    my $type  = join(', ', @type);

    $text .= <<"END_OF_TEXT";
- $title ([ref:$solution])

END_OF_TEXT

  }

  return $text;
}

######################################################################

sub _print_lines {

  my $self = shift;

  foreach my $line (@{ $self->_get_line_list }) {
    print $line->get_content;
  }

  return 1;
}

######################################################################

sub _list_by_name {

  # List all items by name.  For instance, if the calling code sends
  # the string 'problem' return a list of all 'problem' ids.

  my $self = shift;                     # SML::Parser object
  my $name = shift;                     # string

  my $list = [];

  my $fragment      = $self->_get_fragment;
  my $division_list = $fragment->get_division_list;

  foreach my $division (@{ $division_list })
    {
      if ( $division->get_name eq $name )
	{
	  push(@{ $list }, $division);
	}
    }

  return $list;
}

######################################################################

sub _divname_for {

  # Return the divname (problem, solution, test, task, result,
  # role...)  for the item with the specified id

  my $self = shift;
  my $id   = shift;

  my $sml     = SML->instance;
  my $util    = $sml->get_util;
  my $library = $self->get_library;

  if ( $library->has_division($id) )
    {
      my $division = $library->get_division($id);
      my $divname  = $division->get_name;
      return $divname;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub _class_for {

  my $self = shift;                     # SML::Parser object
  my $name = shift;                     # string

  my $sml      = SML->instance;
  my $ontology = $sml->get_ontology;

  return $ontology->class_for_entity_name($name);
}

######################################################################

sub _region_tag {

  # Create and return a region begin or end tag line.

  my $self   = shift;                   # SML::Parser object
  my $type   = shift;                   # string (begin or end)
  my $region = shift;                   # string
  my $file   = shift;                   # file file for warnings
  my $num    = shift;                   # line number

  my $tag = '';

  if ( $type eq 'begin' )
    {
      $tag = ">>>$region\n\n";
    }
  elsif ( $type eq 'end' )
    {
      $tag = "<<<$region\n\n";
    }
  else
    {
      ERROR "tag type $type is not begin or end";
    }

  my $line = SML::Line->new
    (
     file    => $file,
     num     => $num,
     content => "$tag",
    );

  return $line;
}

######################################################################

sub _hide_tag {

  # Create and return a hide tag line.

  my $self = shift;                     # SML::Parser object

  my $line = SML::Line->new
    (
     file    => 'generated',
     num     => '0',
     content => "###hide\n\n",
    );

  return $line;
}

######################################################################

sub _flatten {

  # Replace title or section heading with bold text in line.

  my $self = shift;                     # SML::Parser object
  my $line = shift;                     # SML::Line object

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  my $content = $line->get_content;

  $content =~ s/$syntax->{'title_element'}/!!$1!!/;
  $content =~ s/$syntax->{'start_section'}/!!$2!!/;

  my $newline = SML::Line->new
    (
     file    => 'generated',
     num     => '0',
     content => "$content",
    );

  return $newline;
}

######################################################################

sub _sechead_line {

  my $self      = shift;                # SML::Parser object
  my $asterisks = shift;                # string
  my $title     = shift;                # string

  my $line = SML::Line->new
    (
     content => "$asterisks $title\n",
    );

  return $line;
}

######################################################################

sub _add_generate_request {

  # Add a request for generated content.

  my $self    = shift;
  my $element = shift;

  my $to_be_gen = $self->_get_to_be_gen_hash;
  my $value     = $element->get_value;
  my $location  = $element->get_location;

  if ( $value =~ /([\w\-]+)(\([\w\-]+\))?/ )
    {
      # GOOD generate request syntax
      my $name = $1;
      my $args = $2 || '';

      if ( SML->instance->allows_generate($name) )
	{
	  # GOOD generate request name
	  my $divid = $element->get_containing_division->get_id || '';
	  $to_be_gen->{$name}{$divid}{$args} = 1;
	  $logger->debug("good generate request \"$name\" \"$divid\" \"$args\"");
	  return 1;
	}

      else
	{
	  # BAD generate request name
	  $logger->warn("INVALID GENERATE REQUEST: at $location: \"$value\"");
	  $self->_set_is_valid(0);
	  return 0;
	}
    }

  else
    {
      # BAD generate request syntax
      $logger->warn("INVALID GENERATE REQUEST SYNTAX: at $location: \"$value\"");
      $self->_set_is_valid(0);
      return 0;
    }

  return 1;
}

######################################################################

sub _add_review {

  my $self    = shift;
  my $element = shift;

  my $sml      = SML->instance;
  my $syntax   = $sml->get_syntax;
  my $util     = $sml->get_util;
  my $review   = $self->_get_review_hash;
  my $division = $element->get_containing_division;
  my $div_id   = $division->get_id;
  my $location = $element->get_location;
  my $library  = $self->get_library;
  $_           = $element->get_content;

  s/[\r\n]*$//;
  # chomp;

  if (/$syntax->{review_element}/)
    {
      my $date        = $1;
      my $item        = $2;
      my $status      = $3;
      my $description = $4;

      # date valid?
      unless ( $date =~ /$syntax->{valid_date}/ )
	{
	  $logger->error("INVALID REVIEW DATE at $location");
	  return 0;
	}

      # item under test valid?
      unless ( $library->has_division($item) )
	{
	  $logger->error("INVALID REVIEW ITEM at $location");
	  return 0;
	}

      # status valid?
      unless ( $status =~ /$syntax->{valid_status}/ )
	{
	  $logger->error("INVALID REVIEW STATUS at $location: must be green, yellow, red, or grey");
	  return 0;
	}

      # description valid?
      unless ( $description =~ /$syntax->{valid_description}/ )
	{
	  $logger->error("INVALID REVIEW DESCRIPTION at $location: description not provided");
	  return 0;
	}

      # review is valid
      $review->{$item}{$date}{'status'}      = $status;
      $review->{$item}{$date}{'description'} = $description;
      $review->{$item}{$date}{'source'}      = $div_id;

    }

  else
    {
      $logger->error("INVALID REVIEW SYNTAX at $location ($_)");
    }

  return 1;
}

######################################################################

sub _increment_toplevel_division_number {

  my $self = shift;

  my $number = $self->toplevel_division_number;

  ++ $number;

  $self->_set_toplevel_division_number($number);

  return $number;
}

######################################################################

sub _add_table {

  my $self     = shift;
  my $division = shift;

  my $id        = $division->get_id;
  my $table     = $self->table;

  $table->{$id} = $division;

  return 1;
}

######################################################################

sub _add_source {

  my $self     = shift;
  my $division = shift;

  my $id       = $division->get_id;
  my $sml      = SML->instance;
  my $util     = $sml->get_util;
  my $library  = $self->get_library;

  $library->get_references->add_source($division);

  return 1;
}

######################################################################

sub _add_template {

  my $self     = shift;
  my $division = shift;

  my $id        = $division->get_id;
  my $template  = $self->template;

  $template->{$id} = $division;

  return 1;
}

######################################################################

# sub _add_fragment_to_library {

#   my $self     = shift;
#   my $filename = shift;
#   my $fragment = shift;
#   my $sml      = SML->instance;
#   my $util     = $sml->get_util;
#   my $library  = $self->get_library;

#   $library->add_fragment($filename,$fragment);
#
#   return 1;
# }

######################################################################

sub _process_comment_division_marker {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- comment division marker");

  # new preformatted block
  my $block = SML::PreformattedBlock->new;
  $block->add_line($line);
  $self->_begin_block($block);

  if ( not $self->_in_comment_division )
    {
      # new comment division
      my $name    = 'comment';
      my $num     = $self->_count_comment_divisions;
      my $id      = "$name-$num";
      my $comment = SML::CommentDivision->new(id=>$id);

      $comment->add_part($block);

      $self->_begin_division($comment);
    }

  else
    {
      # end comment division
      $self->_get_current_division->add_part( $block );
      $self->_end_division;
    }

  return 1;
}

######################################################################

sub _process_comment_line {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- comment line");

  if ( not $self->_in_comment_block )
    {
      $logger->trace("..... begin comment block");

      my $block = SML::CommentBlock->new;
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part( $block );
    }

  else
    {
      $logger->trace("..... continue comment block");

      $self->_get_block->add_line($line);
    }

  return 1;
}

######################################################################

sub _process_comment_division_line {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- line in comment division");

  if ( not $self->_get_block )
    {
      my $block = SML::PreformattedBlock->new;
      $block->add_line($line);
      $self->_begin_block($block);
    }

  else
    {
      $self->_get_block->add_line($line);
    }

  return 1;
}

######################################################################

sub _process_conditional_division_marker {

  my $self  = shift;
  my $line  = shift;
  my $token = shift;

  my $blockname = '';

  $logger->trace("----- conditional marker ($token)");

  if ( $self->_in_conditional )
    {
      $blockname = 'END';
    }

  else
    {
      $blockname = 'BEGIN';
    }

  my $block = SML::PreformattedBlock->new(name=>$blockname);
  $block->add_line($line);
  $self->_begin_block($block);

  if ( $self->_in_conditional )
    {
      my $conditional = $self->_current_conditional;

      if ( not $conditional->get_token eq $token )
	{
	  my $location = $line->get_location;

	  $logger->trace("..... ERROR: not in conditional ($token)");
	  my $msg = "INVALID END OF CONDITIONAL at $location not in conditional \"$token\"";
	  $logger->logcroak("$msg");
	}

      $conditional->add_part($block);
      $self->_end_division;
    }

  else
    {
      my $name        = 'conditional';
      my $num         = $self->_count_conditionals;
      my $id          = "$name-$num";
      my $conditional = SML::Conditional->new
	(
	 id          => $id,
	 token       => $token,
	);

      $conditional->add_part($block);

      $self->_begin_division($conditional);
    }

  return 1;
}

######################################################################

sub _process_start_region_marker {

  my $self = shift;
  my $line = shift;
  my $name = shift;

  my $location = $line->get_location;
  my $sml      = SML->instance;
  my $ontology = $sml->get_ontology;

  $logger->trace("----- region begin marker ($name)");

  if ( not $ontology->allows_region($name) )
    {
      my $msg      = "UNDEFINED REGION at $location: \"$name\"";

      $logger->logdie("$msg");
    }

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  if ( $self->_in_environment )
    {
      my $environment = $self->_current_environment;
      my $envname  = $environment->get_name;
      $logger->fatal("INVALID BEGIN REGION at $location: $name inside $envname");
    }

  # new preformatted block
  my $block = SML::PreformattedBlock->new(name=>'BEGIN');
  $block->add_line($line);
  $self->_begin_block($block);

  my $region = undef;

  if ( $name eq 'DOCUMENT' )
    {
      # new document region
      my $num     = $self->_count_regions;
      my $id      = "$name-$num";
      my $class   = $self->_class_for($name);

      $region = $class->new
	(
	 name => $name,
	 id   => $id,
	);

      $region->add_part($block);
    }

  else
    {
      # new non-document region
      my $num   = $self->_count_regions;
      my $id    = "$name-$num";
      my $class = $self->_class_for($name);

      $region = $class->new
	(
	 name => $name,
	 id   => $id,
	);

      $region->add_part($block);
    }

  $self->_begin_division($region);

  return 1;
}

######################################################################

sub _process_end_region_marker {

  my $self = shift;
  my $line = shift;
  my $name = shift;

  my $location = $line->get_location;

  $logger->trace("----- region end marker ($name)");

  if ( not $self->_in_region )
    {
      my $msg = "INVALID END REGION at $location: not in region";
      $logger->logdie("$msg");
    }

  if (
      $self->_in_region
      and
      not $self->_current_region->get_name eq $name
     )
    {
      my $msg = "INVALID END REGION at $location: not in $name region";
      $logger->logdie("$msg");
    }

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  if ( $self->_in_environment )
    {
      my $envname = $self->_current_environment->get_name;
      my $msg = "INVALID END REGION at $location: $name end inside $envname";
      $logger->logdie("$msg");
    }

  if ( $name eq 'DOCUMENT' )
    {
      my $division = $self->_get_current_division;
      while ( not $division->isa('SML::Document') )
	{
	  $self->_end_division;
	  $division = $self->_get_current_division;
	}
    }

  # new preformatted block
  my $block = SML::PreformattedBlock->new(name=>'END');
  $block->add_line($line);
  $self->_begin_block($block);
  $self->_get_current_division->add_part($block);
  $self->_end_division;

  return 1;
}

######################################################################

sub _process_environment_marker {

  my $self = shift;
  my $line = shift;
  my $name = shift;

  my $location  = $line->get_location;
  my $sml       = SML->instance;
  my $ontology  = $sml->get_ontology;
  my $blockname = '';

  $logger->trace("----- environment marker ($name)");

  if ( not $ontology->allows_environment($name) )
    {
      my $msg = "UNKNOWN ENVIRONMENT at $location: \"$name\"";
      $logger->logcroak("$msg");
    }

  if (
      $self->_in_environment
      and
      not $self->_current_environment->get_name eq $name
     )
    {
      my $msg = "INVALID END ENVIRONMENT: can't end \"$name\" environment at $location";
      $logger->logcroak("$msg");
    }

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }


  if (
      $self->_in_environment
      and
      $self->_current_environment->get_name eq $name
     )
    {
      $blockname = 'END';
    }

  else
    {
      $blockname = 'BEGIN';
    }

  my $block = SML::PreformattedBlock->new(name=>$blockname);
  $block->add_line($line);
  $self->_begin_block($block);

  my $division = $self->_get_current_division;

  if ( $self->_in_table )
    {
      $division->add_part($block);
      $self->_end_table;
    }

  elsif ( not $self->_in_environment )
    {
      my $num         = $self->_count_environments;
      my $id          = "$name-$num";
      my $class       = $self->_class_for($name);
      my $environment = $class->new
	(
	 name        => $name,
	 id          => $id,
	);

      $environment->add_part($block);

      $self->_begin_division($environment);
    }

  else
    {
      $division->add_part($block);
      $self->_end_division;
    }

  return 1;
}

######################################################################

sub _process_section_heading {

  my $self  = shift;
  my $line  = shift;
  my $depth = shift;

  my $location = $line->get_location;

  $logger->trace("----- section heading");

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  if ( $self->_in_environment )
    {
      my $name = $self->_current_environment->get_name;
      my $msg = "INVALID SECTION HEADING IN ENVIRONMENT at $location: $name";
      $logger->logdie("$msg");
    }

  if (
      $self->_in_region
      and
      not $self->_current_region eq $self->_current_document
     )
    {
      my $name = $self->_current_region->get_name;
      my $msg = "INVALID SECTION HEADING IN REGION at $location: $name";
      $logger->logdie("$msg");
    }

  # end previous section
  if ( $self->_in_section )
    {
      $self->_end_section;
    }

  # new title element
  $logger->trace("..... new title");
  my $element = SML::Element->new(name=>'title');
  $element->add_line($line);
  $self->_begin_block($element);

  # new section
  my $num     = $self->_count_sections;
  my $id      = "section-$num";
  my $section = SML::Section->new
    (
     depth    => $depth,
     id       => $id,
    );

  $section->add_part($element);

  $section->add_property_element($element);
  $self->_begin_division($section);

  return 1;
}

######################################################################

sub _process_end_table_row {

  my $self = shift;
  my $line = shift;

  my $name     = 'ENDTABLEROW';
  my $location = $line->get_location;

  $logger->trace("----- end table row marker");

  if ( not $self->_in_table and not $self->_in_baretable )
    {
      $logger->logdie("TABLE ROW END MARKER NOT IN TABLE at $location");
    }

  if ( not $self->_in_table_row )
    {
      $logger->warn("TABLE ROW END MARKER NOT IN TABLE ROW: at $location");
      $self->_set_is_valid(0);
    }

  else
    {
      $self->_end_table_row;
    }

  # new preformatted block
  my $block = SML::PreformattedBlock->new(name=>$name);
  $block->add_line($line);
  $self->_begin_block($block);

  # division handling
  $self->_get_current_division->add_part( $block );

  return 1;
}

######################################################################

sub _process_blank_line {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- blank line");

  if ( $self->_get_block )
    {
      $self->_get_block->add_line($line);
      $self->_end_block if not $self->_get_block->isa('SML::PreformattedBlock');
    }

  else
    {
      $logger->trace("..... blank line not in block?");
      return 0;
    }

  return 1;
}

######################################################################

sub _process_id_element {

  my $self = shift;
  my $line = shift;
  my $id   = shift;

  my $sml     = SML->instance;
  my $util    = $sml->get_util;
  my $library = $self->get_library;

  $logger->trace("----- id element ($id)");

  # block/element handling
  my $element = SML::Element->new(name=>'id');
  $element->add_line($line);
  $self->_begin_block($element);

  # division handling
  my $division = $self->_get_current_division;
  $division->set_id($id);
  $division->add_part($element);
  $division->add_property_element($element);

  # remember this ID
  $logger->trace("..... new id");
  $library->replace_division_id($division,$id);

  if ( $self->_in_document )
    {
      my $document = $self->_current_document;
      $document->replace_division_id($division,$id);
    }

  return 1;
}

######################################################################

sub _process_start_element {

  my $self = shift;
  my $line = shift;
  my $name = shift;

  my $sml      = SML->instance;
  my $ontology = $sml->get_ontology;
  my $location = $line->get_location;
  my $division = $self->_get_current_division;
  my $divname  = $division->get_name;

  my $element = SML::Element->new(name=>$name);

  $logger->trace("----- element ($name) \'$element\'");

  $element->add_line($line);
  $self->_begin_block($element);

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  if ( $self->_in_preamble
       and
       $ontology->allows_property($divname,$name) )
    {
      $logger->trace("..... preamble element ($name)");

      my $division = $self->_get_current_division;
      $division->add_part($element);
      $division->add_property_element($element);
    }

  elsif ( $self->_in_preamble
	  and
	  $ontology->allows_property('UNIVERSAL',$name) )
    {
      $logger->trace("..... UNIVERSAL element in preamble");

      $self->_end_preamble;

      my $division = $self->_get_current_division;
      $division->add_part($element);
      $division->add_property_element($element);
    }

  elsif ( $self->_in_preamble )
    {
      $logger->warn("UNKNOWN DIVISION ELEMENT: \'$divname\' \'$name\' at $location:");
      $self->_set_is_valid(0);
    }

  elsif ( $self->_in_preamble
	  and
	  $ontology->allows_property('DOCUMENT',$name) )
    {
      $logger->trace("..... begin document preamble element");

      my $division = $self->_get_current_division;
      $division->add_part($element);
      $division->add_property_element($element);
    }

  elsif ( $self->_in_preamble
	  and
	  $ontology->allows_property('UNIVERSAL',$name) )
    {
      $logger->trace("..... begin UNIVERSAL element while in doc preamble");

      $logger->trace("..... end document preamble");

      $self->_end_preamble;

      my $division = $self->_get_current_division;
      $division->add_part($element);
      $division->add_property_element($element);
    }

  else
    {
      $logger->trace("..... begin UNIVERSAL element");

      $division->add_part($element);
      $division->add_property_element($element);
    }

  return 1;
}

######################################################################

sub _process_start_note {

  my $self  = shift;
  my $line  = shift;
  my $tag   = shift;
  my $divid = shift;

  my $name = 'note';

  my $division = $self->_get_current_division;
  my $divname  = $division->get_name;

  $logger->trace("----- element ($name)");

  my $element = SML::Note->new
    (
     name     => $name,
     tag      => $tag,
     division => $division,
    );

  $element->add_line($line);

  $self->_begin_block($element);

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  if ( $self->_in_preamble )
    {
      $logger->trace("..... note element in preamble");

      $self->_end_preamble;

      my $division = $self->_get_current_division;
      $division->add_part($element);
      $division->add_property_element($element);
    }

  else
    {
      $logger->trace("..... begin UNIVERSAL element");

      $division->add_part($element);
      $division->add_property_element($element);
    }

  return 1;
}

######################################################################

sub _process_start_glossary_entry {

  my $self = shift;
  my $line = shift;
  my $term = shift;
  my $alt  = shift || '';

  my $sml       = SML->instance;
  my $util      = $sml->get_util;
  my $library   = $self->get_library;
  my $blockname = 'glossary';

  $logger->trace("----- element (glossary)");

  my $definition = SML::Definition->new(name=>$blockname);

  $definition->add_line($line);

  $self->_begin_block($definition);

  $self->_end_baretable if $self->_in_baretable;

  if ( $self->_in_preamble )
    {
      $logger->trace("..... glossary definition in preamble");

      $self->_end_preamble;

      $self->_get_current_division->add_part($definition);
      $self->_get_current_division->add_property_element($definition);
    }

  else
    {
      $logger->trace("..... begin UNIVERSAL element");

      $self->_get_current_division->add_part($definition);
      $self->_get_current_division->add_property_element($definition);
    }

  return 1;
}

######################################################################

sub _process_start_acronym_entry {

  my $self = shift;
  my $line = shift;
  my $term = shift;
  my $alt  = shift || '';

  my $name      = 'acronym';
  my $sml       = SML->instance;
  my $util      = $sml->get_util;
  my $library   = $self->get_library;
  my $document  = $self->_current_document || undef;

  my $division = $self->_get_current_division;
  my $divname  = $division->get_name;

  $logger->trace("----- element ($name)");

  my $definition = SML::Definition->new
    (
     name => $name,
     term => $term,
     alt  => $alt,
    );

  $definition->add_line($line);

  $self->_begin_block($definition);

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  if ( $self->_in_preamble )
    {
      $logger->trace("..... acronym definition in preamble");

      $self->_end_preamble;

      my $division = $self->_get_current_division;
      $division->add_part($definition);
      $division->add_property_element($definition);
    }

  else
    {
      $logger->trace("..... begin UNIVERSAL element");

      $division->add_part($definition);
      $division->add_property_element($definition);
    }

  return 1;
}

######################################################################

sub _process_start_variable_definition {

  my $self = shift;
  my $line = shift;
  my $term = shift;
  my $alt  = shift || '';

  my $name     = 'var';
  my $sml      = SML->instance;
  my $util     = $sml->get_util;
  my $library  = $self->get_library;
  my $division = $self->_get_current_division;
  my $divname  = $division->get_name;

  $logger->trace("----- element ($name)");

  my $definition = SML::Definition->new
    (
     name       => $name,
     term       => $term,
     alt        => $alt,
    );

  $definition->add_line($line);

  $self->_begin_block($definition);

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  if ( $self->_in_preamble )
    {
      $logger->trace("..... glossary definition in preamble");

      $self->_end_preamble;

      my $division = $self->_get_current_division;
      $division->add_part($definition);
      $division->add_property_element($definition);
    }

  else
    {
      $logger->trace("..... begin UNIVERSAL element");

      $division->add_part($definition);
      $division->add_property_element($definition);
    }

  return 1;
}

######################################################################

sub _process_bull_list_item {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- bullet list item");

  $self->_end_preamble if $self->_in_preamble;

  if ( $self->_in_preformatted_division )
    {
      my $block = SML::PreformattedBlock->new;
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  else
    {
      my $block = SML::BulletListItem->new;
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  return 1;
}

######################################################################

sub _process_enum_list_item {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- enumerated list item");

  $self->_end_preamble if $self->_in_preamble;

  if ( $self->_in_preformatted_division )
    {
      my $block = SML::PreformattedBlock->new;
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  else
    {
      my $block = SML::EnumeratedListItem->new;
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  return 1;
}

######################################################################

sub _process_def_list_item {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- definition list item");

  $self->_end_preamble if $self->_in_preamble;

  if ( $self->_in_preformatted_division )
    {
      my $block = SML::PreformattedBlock->new;
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  else
    {
      my $block = SML::DefinitionListItem->new;
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  return 1;
}

######################################################################

sub _process_start_table_cell {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- table cell");

  $self->_end_preamble if $self->_in_preamble;

  # new block
  my $block = SML::Block->new;
  $block->add_line($line);
  $self->_begin_block($block);

  if (
      not $self->_in_table
      and
      not $self->_in_baretable
     )
    {
      # new BARETABLE
      #
      my $tnum      = $self->_count_baretables + 1;
      my $tid       = "BARETABLE-$tnum";
      my $baretable = SML::Baretable->new(id=>$tid);

      $self->_begin_division($baretable);

      # new BARETABLEROW
      #
      my $rnum     = $self->_count_table_rows + 1;
      my $rid      = "BARETABLEROW-$tnum-$rnum";
      my $tablerow = SML::TableRow->new(id=>$rid);

      $self->_begin_division($tablerow);

      # new BARETABLECELL
      #
      my $cnum      = $self->_count_table_cells + 1;
      my $cid       = "BARETABLECELL-$tnum-$rnum-$cnum";
      my $tablecell = SML::TableCell->new(id=>$cid);

      $tablecell->add_part($block);
      $self->_begin_division($tablecell);
    }

  elsif (
	 $self->_in_baretable
	 and
	 not $self->_in_table_row
	)
    {
      # new BARETABLEROW
      #
      my $tnum     = $self->_count_baretables;
      my $rnum     = $self->_count_table_rows + 1;
      my $rid      = "BARETABLEROW-$tnum-$rnum";
      my $tablerow = SML::TableRow->new(id=>$rid);

      $self->_begin_division($tablerow);

      # new BARETABLECELL
      #
      my $cnum      = $self->_count_table_cells + 1;
      my $cid       = "BARETABLECELL-$tnum-$rnum-$cnum";
      my $tablecell = SML::TableCell->new(id=>$cid);

      $tablecell->add_part($block);
      $self->_begin_division($tablecell);
    }

  elsif (
	 $self->_in_table
	 and
	 not $self->_in_table_row
	)
    {
      # new TABLEROW
      #
      my $tnum     = $self->_count_tables;
      my $rnum     = $self->_count_table_rows + 1;
      my $rid      = "TABLEROW-$tnum-$rnum";
      my $tablerow = SML::TableRow->new(id=>$rid);

      $self->_begin_division($tablerow);

      # new TABLECELL
      #
      my $cnum      = $self->_count_table_cells + 1;
      my $cid       = "TABLECELL-$tnum-$rnum-$cnum";
      my $tablecell = SML::TableCell->new(id=>$cid);

      $tablecell->add_part($block);
      $self->_begin_division($tablecell);
    }

  elsif ( $self->_in_baretable )
    {
      # end previous TABLECELL
      #
      $self->_end_division;

      # new TABLECELL
      #
      my $tnum      = $self->_count_baretables;
      my $rnum      = $self->_count_table_rows;
      my $cnum      = $self->_count_table_cells + 1;
      my $cid       = "BARETABLECELL-$tnum-$rnum-$cnum";
      my $tablecell = SML::TableCell->new(id=>$cid);

      $tablecell->add_part($block);
      $self->_begin_division($tablecell);
    }

  elsif ( $self->_in_table )
    {
      # end previous TABLECELL
      #
      $self->_end_division;

      # new TABLECELL
      #
      my $tnum      = $self->_count_tables;
      my $rnum      = $self->_count_table_rows;
      my $cnum      = $self->_count_table_cells + 1;
      my $cid       = "TABLECELL-$tnum-$rnum-$cnum";
      my $tablecell = SML::TableCell->new(id=>$cid);

      $tablecell->add_part($block);
      $self->_begin_division($tablecell);
    }

  else
    {
      my $location = $line->get_location;
      $logger->logdie("UNEXPECTED TABLE CELL at $location");
    }

  return 1;
}

######################################################################

sub _process_paragraph_text {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- paragraph text");

  if ( $self->_in_paragraph )
    {
      $logger->trace("..... continue paragraph");
      $self->_get_block->add_line($line);
    }

  elsif ( $self->_in_element )
    {
      $logger->trace("..... continue element");
      $self->_get_block->add_line($line);
    }

  elsif ( $self->_in_preformatted_division )
    {
      $logger->trace("..... new preformatted block");

      my $block = SML::PreformattedBlock->new;
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  elsif ( $self->_in_table_cell )
    {
      $logger->trace("..... adding to block in table cell");
      $self->_get_block->add_line( $line );
    }

  elsif ( $self->_in_listitem )
    {
      $logger->trace("..... adding to block in list item");
      $self->_get_block->add_line( $line );
    }

  else
    {
      $logger->trace("..... new paragraph");

      $self->_end_preamble if $self->_in_preamble;

      if ( $self->_in_baretable )
	{
	  $self->_end_baretable;
	}

      my $paragraph = SML::Paragraph->new;
      $paragraph->add_line($line);
      $self->_begin_block($paragraph);
      $self->_get_current_division->add_part($paragraph);
    }

  return 1;
}

######################################################################

sub _process_indented_text {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- indented text");

  if ( $self->_in_preformatted_block )
    {
      $logger->trace("..... continue preformatted block");
      $self->_get_block->add_line($line);
    }

  elsif ( $self->_in_listitem )
    {
      $logger->trace("..... continue list item");
      $self->_get_block->add_line($line);
    }

  else
    {
      $logger->trace("..... new preformatted block");

      $self->_end_preamble if $self->_in_preamble;

      my $block = SML::PreformattedBlock->new;
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  return 1;
}

######################################################################

sub _process_non_blank_line {

  my $self = shift;
  my $line = shift;

  my $location = $line->get_location;

  $logger->trace("----- non-blank line");

  if (
      $self->_in_environment
      and
      $self->_current_environment->isa('SML::Baretable')
      and
      $self->_get_column == 0
     )
    {
      $self->_end_division;
    }

  if (
      $self->_in_environment
      and
      (
       $self->_current_environment->isa('SML::Listing')
       or
       $self->_current_environment->isa('SML::Preformatted')
      )
      and
      not $self->_get_block
     )
    {
      my $block = SML::PreformattedBlock->new;
      $block->add_line($line);
      $self->_begin_block($block);
      $self->environment->add_part($block);
    }

  elsif ( not $self->_get_block )
    {
      $logger->logdie("UNRECOGNIZED BLOCK at $location Should I start a paragraph?");
    }

  else
    {
      $logger->trace("..... add non-blank line to block");
      $self->_get_block->add_line($line);
    }

  return 1;
}

######################################################################

sub _push_division_stack {

  my $self     = shift;
  my $division = shift;

  push @{ $self->_get_division_stack }, $division;

  return 1;
}

######################################################################

sub _pop_division_stack {

  my $self = shift;

  my $division = pop @{ $self->_get_division_stack };

  return $division;
}

######################################################################

sub _print_division_stack {

  my $self = shift;

  my $i = 0;

  foreach my $division (@{ $self->_get_division_stack })
    {
      $logger->trace("    division_stack: $i => $division");
      ++ $i;
    }

  return 1;
}

######################################################################

sub _in_comment_block {

  my $self = shift;

  if (
      $self->_get_block
      and
      $self->_get_block->isa('SML::CommentBlock')
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

sub _in_preformatted_block {

  my $self = shift;

  if (
      $self->_get_block
      and
      $self->_get_block->isa('SML::PreformattedBlock')
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

sub _in_preformatted_division {

  my $self = shift;

  my $division = $self->_get_current_division;

  return 0 if not $division;

  if (
      $division->isa('SML::Listing')
      or
      $division->isa('SML::PreformattedDivision')
      or
      $division->isa('SML::RESOURCES')
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

sub _in_paragraph {

  my $self = shift;

  if (
      $self->_get_block
      and
      $self->_get_block->isa('SML::Paragraph')
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

sub _in_listitem {

  my $self = shift;

  if (
      $self->_get_block
      and
      $self->_get_block->isa('SML::Listitem')
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

sub _in_element {

  my $self = shift;

  if (
      $self->_get_block
      and
      $self->_get_block->isa('SML::Element')
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

sub _in_table_cell {

  my $self = shift;

  my $division = $self->_get_current_division;

  if ( $division->is_in_a('SML::TableCell') )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub _in_table_row {

  my $self = shift;

  my $division = $self->_get_current_division;

  if ( $division->is_in_a('SML::TableRow') )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub _in_baretable {

  my $self = shift;

  my $division = $self->_get_current_division;

  if ( $division->is_in_a('SML::Baretable') )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub _in_table {

  my $self = shift;

  my $division = $self->_get_current_division;

  if ( $division->is_in_a('SML::Table') )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub _in_comment_division {

  my $self = shift;

  my $division = $self->_get_current_division;

  if ( $division and $division->isa('SML::CommentDivision') )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub _in_conditional {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Conditional') )
	{
	  return 1;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub _current_conditional {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Conditional') )
	{
	  return $division;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub _count_comment_divisions {

  my $self = shift;

  my $count = 0;

  my $fragment      = $self->_get_fragment;
  my $division_list = $fragment->get_division_list;

  foreach my $division (@{ $division_list })
    {
      if ( $division->isa('SML::CommentDivision') )
	{
	  ++ $count;
	}
    }

  return $count;
}

######################################################################

sub _count_table_rows {

  # Return the number of rows in the current table.  Return 0 if not
  # currently in a table.

  my $self = shift;

  my $division = $self->_get_current_division;

  if (
      not $division->is_in_a('SML::Table')
      and
      not $division->is_in_a('SML::Baretable')
     )
    {
      return 0;
    }

  else
    {
      my $table = $self->_current_table;
      my $count = 0;

      foreach my $part (@{ $table->get_division_list })
	{
	  if ( $part->isa('SML::TableRow') )
	    {
	      ++ $count;
	    }
	}

      return $count;
    }
}

######################################################################

sub _count_table_cells {

  # Return the number of cells in the current table row.  Return 0 if
  # not currently in a table row.

  my $self = shift;

  my $division = $self->_get_current_division;

  if ( not $division->is_in_a('SML::TableRow') )
    {
      return 0;
    }

  else
    {
      my $row   = $self->_current_table_row;
      my $count = 0;

      foreach my $part (@{ $row->get_division_list })
	{
	  if ( $part->isa('SML::TableCell') )
	    {
	      ++ $count;
	    }
	}

      return $count;
    }
}

######################################################################

sub _current_table {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( not $division->isa('SML::Fragment') )
    {
      if (
	  $division->isa('SML::Table')
	  or
	  $division->isa('SML::Baretable')
	 )
	{
	  return $division;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub _current_table_row {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::TableRow') )
	{
	  return $division;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub _count_conditionals {

  my $self = shift;

  my $count = 0;

  my $fragment      = $self->_get_fragment;
  my $division_list = $fragment->get_division_list;

  foreach my $division (@{ $division_list })
    {
      if ( $division->isa('SML::Conditional') )
	{
	  ++ $count;
	}
    }

  return $count;
}

######################################################################

sub _count_regions {

  my $self = shift;

  my $count = 0;

  my $fragment      = $self->_get_fragment;
  my $division_list = $fragment->get_division_list;

  foreach my $division (@{ $division_list })
    {
      if ( $division->isa('SML::Region') )
	{
	  ++ $count;
	}
    }

  return $count;
}

######################################################################

sub _count_environments {

  my $self = shift;

  my $count = 0;

  my $fragment      = $self->_get_fragment;
  my $division_list = $fragment->get_division_list;

  foreach my $division (@{ $division_list })
    {
      if ( $division->isa('SML::Environment') )
	{
	  ++ $count;
	}
    }

  return $count;
}

######################################################################

sub _count_tables {

  my $self = shift;

  my $count = 0;

  my $fragment      = $self->_get_fragment;
  my $division_list = $fragment->get_division_list;

  foreach my $division (@{ $division_list })
    {
      if ( $division->isa('SML::Table') )
	{
	  ++ $count;
	}
    }

  return $count;
}

######################################################################

sub _count_baretables {

  my $self = shift;

  my $count = 0;

  my $fragment      = $self->_get_fragment;
  my $division_list = $fragment->get_division_list;

  foreach my $division (@{ $division_list })
    {
      if ( $division->isa('SML::Baretable') )
	{
	  ++ $count;
	}
    }

  return $count;
}

######################################################################

sub _count_sections {

  my $self = shift;

  my $count = 0;

  my $fragment      = $self->_get_fragment;
  my $division_list = $fragment->get_division_list;

  foreach my $division (@{ $division_list })
    {
      if ( $division->isa('SML::Section') )
	{
	  ++ $count;
	}
    }

  return $count;
}

######################################################################

sub _in_region {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Region') )
	{
	  return 1;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub _in_environment {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Environment') )
	{
	  return 1;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub _in_section {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Section') )
	{
	  return 1;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub _in_document {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Document') )
	{
	  return 1;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub _current_environment {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Environment') )
	{
	  return $division;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub _current_region {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Region') )
	{
	  return $division;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub _current_document {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Document') )
	{
	  return $division;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub _get_current_division {

  my $self = shift;

  return $self->_get_division_stack->[-1];
}

######################################################################

sub _line_ends_preamble {

  $_ = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  if (
         /$syntax->{start_region}/
      or /$syntax->{start_environment}/
      or /$syntax->{start_section}/
      or /$syntax->{generate_element}/
      or /$syntax->{insert_element}/
      or /$syntax->{template_element}/
      or /$syntax->{include_element}/
      or /$syntax->{script_element}/
      or /$syntax->{outcome_element}/
      or /$syntax->{review_element}/
      or /$syntax->{index_element}/
      or /$syntax->{glossary_element}/
      or /$syntax->{list_item}/
      # or /$syntax->{paragraph_text}/
      # or /$syntax->{indented_text}/
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

sub _text_begins_with_substring {

  my $self = shift;
  my $text = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  foreach my $substring_type (@{ $self->_get_substring_type_list })
    {
      if ( $text =~ /^$syntax->{$substring_type}/ )
	{
	  return $substring_type;
	}
    }

  return 0;
}

######################################################################

sub _build_substring_type_list {

  # each substring type is an attribute in the syntax object

  return
    [
     # substrings that represent spanned content
     'underline_string',
     'superscript_string',
     'subscript_string',
     'italics_string',
     'bold_string',
     'fixedwidth_string',
     'keystroke_symbol',

     # substrings that form references
     'cross_ref',
     'url_ref',
     'footnote_ref',
     'gloss_def_ref',
     'gloss_term_ref',
     'acronym_term_ref',
     'index_ref',
     'id_ref',
     'page_ref',
     'status_ref',
     'citation_ref',
     'file_ref',
     'path_ref',
     'variable_ref',

     # substrings that represent symbols
     'take_note_symbol',
     'smiley_symbol',
     'frowny_symbol',
     'left_arrow_symbol',
     'right_arrow_symbol',
     'latex_symbol',
     'tex_symbol',
     'copyright_symbol',
     'trademark_symbol',
     'reg_trademark_symbol',
     'open_dblquote_symbol',
     'close_dblquote_symbol',
     'open_sglquote_symbol',
     'close_sglquote_symbol',
     'section_symbol',
     'emdash_symbol',
     'thepage_ref',
     'version_ref',
     'revision_ref',
     'date_ref',
     'linebreak_symbol',

     # substrings that represent special meaning
     'user_entered_text',
     'command_ref',
     'email_addr',
    ];
}

######################################################################

sub _parse_block {

  # Parse a block into a list of strings.  This list of strings is the
  # block's 'part_list'.

  my $self  = shift;
  my $block = shift;

  $logger->trace("_parse_block");

  if (
      not ref $block
      or
      not $block->isa('SML::Block')
     )
    {
      $logger->error("CAN'T PARSE NON-BLOCK \'$block\'");
      return 0;
    }

  my $text = $block->get_content;

  # If this is a comment block, don't parse it into parts.

  if ( $block->isa('SML::CommentBlock') )
    {
      return 1;
    }

  while ( $text )
    {
      $text = $self->_parse_next_substring($block,$text);
    }

  return 1;
}

######################################################################

sub _parse_string {

  # Parse a string into a list of strings.  This list of strings is
  # the string's 'part_list'.

  my $self   = shift;
  my $string = shift;

  if (
      not ref $string
      or
      not $string->isa('SML::String')
     )
    {
      $logger->error("CAN'T PARSE NON-STRING \'$string\'");
      return 0;
    }

  my $text = $string->get_content;

  while ( $text )
    {
      $text = $self->_parse_next_substring($string,$text);
    }

  return 1;
}

######################################################################

sub _parse_next_substring {

  my $self = shift;
  my $part = shift;
  my $text = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $block;

  if (
      ref $part
      and
      $part->isa('SML::Block')
     )
    {
      $block = $part;
    }

  elsif (
	 ref $part
	 and
	 $part->isa('SML::String')
	)
    {
      $block = $part->get_containing_block;
    }

  else
    {
      $logger->error("THIS SHOULD NEVER HAPPEN (3) \'$part\'");
    }

  if ( my $substring_type = $self->_text_begins_with_substring($text) )
    {
      if ( $text =~ /^$syntax->{$substring_type}/p )
	{
	  my $substring = ${^MATCH};

	  $logger->debug("found $substring_type in $text");
	  my $newstring = _create_string($substring_type,$substring,$block);

	  if (
	      not
	      (
	       $substring_type eq 'email_addr'
	      )
	     )
	    {
	      $self->_parse_string($newstring); # recurse
	    }

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      else
	{
	  $logger->error("THIS SHOULD NEVER HAPPEN (4) \'$text\'");
	}
    }

  else
    {
      if ( $text =~ /^$syntax->{non_substring}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $newstring = _create_string('STRING',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{begin_gloss_term_ref}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("BROKEN GLOSSARY TERM REFERENCE NEAR LINE $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{begin_gloss_def_ref}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("BROKEN GLOSSARY DEFINITION REFERENCE NEAR LINE $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{begin_acronym_term_ref}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("BROKEN ACRONYM TERM REFERENCE NEAR LINE $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{begin_citation_ref}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("BROKEN SOURCE CITATION REFERENCE NEAR LINE $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{begin_cross_ref}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("BROKEN CROSS REFERENCE NEAR LINE $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{begin_id_ref}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("BROKEN ID REFERENCE NEAR LINE $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{begin_page_ref}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("BROKEN PAGE REFERENCE NEAR LINE $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{bold}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("UNMATCHED BOLD MARKUP NEAR $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{italics}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("UNMATCHED ITALICS MARKUP NEAR $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{fixedwidth}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("UNMATCHED FIXED-WIDTH MARKUP NEAR $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{underline}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("UNMATCHED UNDERLINE MARKUP NEAR $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{superscript}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("UNMATCHED SUPERSCRIPT MARKUP NEAR $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      elsif ( $text =~ /^$syntax->{subscript}/p )
	{
	  my $non_substring = ${^MATCH};

	  my $location = $part->get_location;
	  $logger->warn("UNMATCHED SUBSCRIPT MARKUP NEAR $location");

	  my $newstring = _create_string('syntax_error',$non_substring,$block);

	  $part->add_part($newstring);
	  $text = ${^POSTMATCH};
	}

      else
	{
	  my $location = $block->get_location;
	  $logger->error("THIS SHOULD NEVER HAPPEN (5) \'$text\' (at $location)");
	  return 0;
	}
    }

  return $text;
}

######################################################################

sub _create_string {

  my $substring_type = shift;           # i.e. bold_string
  my $substring      = shift;           # i.e. !!my bold text!!
  my $block          = shift;           # containing block

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  if ( $substring_type eq 'STRING' )
    {
      return SML::String->new
	(
	 name             => 'STRING',
	 content          => $substring,
	 containing_block => $block,
	);
    }

  elsif ( $substring_type eq 'syntax_error' )
    {
      return SML::SyntaxErrorString->new
	(
	 content          => $substring,
	 containing_block => $block,
	);
    }

  elsif (
      $substring_type eq 'underline_string'
      or
      $substring_type eq 'superscript_string'
      or
      $substring_type eq 'subscript_string'
      or
      $substring_type eq 'italics_string'
      or
      $substring_type eq 'bold_string'
      or
      $substring_type eq 'fixedwidth_string'
      or
      $substring_type eq 'keystroke_symbol'
     )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::String->new
	    (
	     name             => $substring_type,
	     content          => $1,
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif (
	 $substring_type eq 'take_note_symbol'
	 or
	 $substring_type eq 'smiley_symbol'
	 or
	 $substring_type eq 'frowny_symbol'
	 or
	 $substring_type eq 'left_arrow_symbol'
	 or
	 $substring_type eq 'right_arrow_symbol'
	 or
	 $substring_type eq 'latex_symbol'
	 or
	 $substring_type eq 'tex_symbol'
	 or
	 $substring_type eq 'copyright_symbol'
	 or
	 $substring_type eq 'trademark_symbol'
	 or
	 $substring_type eq 'reg_trademark_symbol'
	 or
	 $substring_type eq 'open_dblquote_symbol'
	 or
	 $substring_type eq 'close_dblquote_symbol'
	 or
	 $substring_type eq 'open_sglquote_symbol'
	 or
	 $substring_type eq 'close_sglquote_symbol'
	 or
	 $substring_type eq 'section_symbol'
	 or
	 $substring_type eq 'emdash_symbol'
	 or
	 $substring_type eq 'thepage_ref'
	 or
	 $substring_type eq 'version_ref'
	 or
	 $substring_type eq 'revision_ref'
	 or
	 $substring_type eq 'date_ref'
	 or
	 $substring_type eq 'linebreak_symbol'
	)
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::Symbol->new
	    (
	     name             => $substring_type,
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'cross_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::CrossReference->new
	    (
	     target_id        => $2,    # target ID
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'url_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  my $content = $3 || '';

	  return SML::URLReference->new
	    (
	     url              => $1,       # uniform resource locator
	     content          => $content, # linked text content
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'footnote_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::FootnoteReference->new
	    (
	     section_id       => $1,    # section in which footnote occurs
	     number           => $2,    # footnote number
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'gloss_term_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  my $namespace = $3 || '';

	  return SML::GlossaryTermReference->new
	    (
	     tag              => $1,         # used as capitalization indicator
	     term             => $4,         # glossary term
	     namespace        => $namespace, # disambiguate identical terms
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'gloss_def_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  my $namespace = $2 || '';

	  return SML::GlossaryDefinitionReference->new
	    (
	     term             => $3,         # glossary term
	     namespace        => $namespace, # disambiguate identical terms
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'acronym_term_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  my $namespace = $2 || '';

	  return SML::AcronymTermReference->new
	    (
	     tag              => $1,         # used as format indicator
	     acronym          => $4,         # acronym
	     namespace        => $namespace, # disambiguate identical acronyms
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'index_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::IndexReference->new
	    (
	     tag              => $1,    # not significant
	     entry            => $2,    # index entry text
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'id_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::IDReference->new
	    (
	     target_id        => $1,    # referenced ID
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'page_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::PageReference->new
	    (
	     target_id        => $2,    # target ID
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'status_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::StatusReference->new
	    (
	     entity_id        => $1,    # referenced entity ID (or color)
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'citation_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  my $details = $4 || '';

	  return SML::CitationReference->new
	    (
	     source_id        => $2,       # ID of cited source
	     details          => $details, # details (citation location)
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'file_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::FileReference->new
	    (
	     filespec         => $1,    # file specification
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'path_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::PathReference->new
	    (
	     pathspec         => $1,    # path specification
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'variable_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  my $namespace = $3 || '';

	  return SML::VariableReference->new
	    (
	     variable_name    => $1,         # variable name
	     namespace        => $namespace, # namespace of variable
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'user_entered_text' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::UserEnteredText->new
	    (
	     content          => $2,   # user entered text
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'command_ref' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::CommandReference->new
	    (
	     content          => $1,   # command
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  elsif ( $substring_type eq 'email_addr' )
    {
      if ( $substring =~ /$syntax->{$substring_type}/ )
	{
	  return SML::EmailAddress->new
	    (
	     content          => $1,   # email address
	     containing_block => $block,
	    );
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $substring_type: $substring");
	  return 0;
	}
    }

  else
    {
      $logger->error("COULDN'T CREATE $substring_type STRING FROM \'$substring\'");
      return 0;
    }

}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Parser> - a mechanism that creates fragment objects from raw
SML text stored in files.

=head1 VERSION

This documentation refers to L<"SML::Parser"> version 2.0.0.

=head1 SYNOPSIS

  my $parser = SML::Parser->new();

=head1 DESCRIPTION

A parser creates fragment objects from raw SML text stored in files.

=head1 METHODS

=head2 parse

=head2 extract_division_name

=head2 extract_title_text

=head2 extract_preamble_lines

=head2 extract_narrative_lines

=head2 in_preamble

=head2 get_gen_countent_hash

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
