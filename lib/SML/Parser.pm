#!/usr/bin/perl

# $Id: Parser.pm 283 2015-07-11 12:56:40Z drj826@gmail.com $

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
use SML::Options;                     # ci-000382
use SML::File;                        # ci-000384
use SML::Line;                        # ci-000385
use SML::Error;                       # ci-000???

# string classes
use SML::String;                      # ci-000???
use SML::AcronymTermReference;        # ci-000???
use SML::CitationReference;           # ci-000???
use SML::CrossReference;              # ci-000???
use SML::LookupReference;             # ci-000???
use SML::TitleReference;              # ci-000???
use SML::FileReference;               # ci-000???
use SML::FootnoteReference;           # ci-000???
use SML::GlossaryDefinitionReference; # ci-000???
use SML::GlossaryTermReference;       # ci-000???
use SML::IDReference;                 # ci-000???
use SML::IndexReference;              # ci-000???
use SML::PageReference;               # ci-000???
use SML::PathReference;               # ci-000???
use SML::StatusReference;             # ci-000???
use SML::Symbol;                      # ci-000???
use SML::URLReference;                # ci-000???
use SML::VariableReference;           # ci-000???
use SML::EmailAddress;                # ci-000???

# block classes
use SML::Block;                       # ci-000387
use SML::PreformattedBlock;           # ci-000427
use SML::Paragraph;                   # ci-000425
use SML::ListItem;                    # ci-000424
use SML::DefinitionListItem;          # ci-000432
use SML::Step;                        # ci-000???
use SML::Image;                       # ci-000???
use SML::Element;                     # ci-000386
use SML::Definition;                  # ci-000415
use SML::Note;                        # ci-000???
use SML::Outcome;                     # ci-000???
use SML::IndexEntry;                  # ci-000???

# division classes
use SML::Division;                    # ci-000381
use SML::Structure;                   # ci-000393
use SML::Entity;                      # ci-000416
use SML::Document;                    # ci-000005
use SML::Section;                     # ci-000392
use SML::TableRow;                    # ci-000429
use SML::TableCell;                   # ci-000428
use SML::Figure;                      # ci-000396
use SML::Listing;                     # ci-000397
use SML::Source;                      # ci-000400
use SML::Table;                       # ci-000401
use SML::BulletList;                  # ci-000???
use SML::EnumeratedList;              # ci-000???
use SML::Triple;                      # ci-000404

$OUTPUT_AUTOFLUSH = 1;

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

# NONE.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub parse {

  # Return a division object.  Create the divsion object by parsing
  # the divisions lines. Add the new division to the library.

  my $self = shift;                     # Parser
  my $id   = shift;                     # ID of division to parse

  unless ( $id )
    {
      $logger->error("CAN'T PARSE DIVISION, YOU MUST SPECIFY AN ID");
      return 0;
    }

  my $library = $self->_get_library;

  unless ( $library->has_division_id($id) )
    {
      my $msg = "CAN'T PARSE DIVISION, DIVISION NOT IN LIBRARY $id";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $number = $self->_get_number;

  $logger->info("{$number} parse \'$id\'");

  $self->_init;                         # initialize parser

  my $line_list = $self->_get_line_list_for_id($id);

  unless ( scalar @{ $line_list } )
    {
      $logger->error("DIVISION HAS NO LINE LIST \'$id\'");
      return 0;
    }

  $self->_set_line_list( $line_list );

  # line-oriented processing
  do
    {
      $self->_resolve_includes  if $self->_contains_include;
      $self->_resolve_plugins   if $self->_contains_plugin;
      $self->_resolve_scripts   if $self->_contains_script;
      # $self->_resolve_templates if $self->_contains_template;
    }

    while $self->_text_requires_line_processing;

  # parse lines into blocks and divisions
  $self->_parse_lines;

  # block-oriented processing
  do
    {
      # $self->_resolve_lookups      if $self->_contains_lookup;
      $self->_substitute_variables if $self->_contains_variable;
    }

      while $self->_text_requires_block_processing;

  my $division = $self->_get_division;

  unless ( $division )
    {
      $logger->logdie("PARSER FOUND NO DIVISION \'$id\'");
    }

  $self->_parse_division_blocks($division);

  return $division;
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

# This is the library to which this parser belongs.

######################################################################

has number =>
  (
   is       => 'ro',
   isa      => 'Int',
   reader   => '_get_number',
   required => 1,
  );

######################################################################

has division =>
  (
   is        => 'ro',
   isa       => 'SML::Division',
   reader    => '_get_division',
   writer    => '_set_division',
   predicate => '_has_division',
   clearer   => '_clear_division',
  );

# This is the division object being parsed by parse method, often a
# document.

######################################################################

has line_list =>
  (
   is        => 'ro',
   isa       => 'ArrayRef',
   reader    => '_get_line_list',
   writer    => '_set_line_list',
   clearer   => '_clear_line_list',
   default   => sub {[]},
  );

# This is the sequential array of lines that make up the file being
# parsed.

######################################################################

has block =>
  (
   is        => 'ro',
   isa       => 'SML::Block',
   reader    => '_get_block',
   writer    => '_set_block',
   predicate => '_has_block',
   clearer   => '_clear_block',
  );

# This is the current block at any given time during parsing. A block
# is a contiguous sequence of one or more whole lines of text.  Blocks
# end with either a blank line or the beginning of another
# block. Blocks cannot contain blank lines. Blocks may contain inline
# elements which span lines.

######################################################################

has string =>
  (
   is        => 'ro',
   isa       => 'SML::String',
   reader    => '_get_string',
   writer    => '_set_string',
   clearer   => '_clear_string',
  );

# This is the current string at any given time during parsing. A
# string is a sequence of one or more characters.  Strings can be
# nested.  This means a string can have a list of parts which
# themselves are strings.  A string must be contained withing a single
# block.  Strings cannot span blocks.

######################################################################

has division_stack =>
  (
   is        => 'ro',
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

has container_stack =>
  (
   is        => 'ro',
   isa       => 'ArrayRef',
   reader    => '_get_container_stack',
   writer    => '_set_container_stack',
   clearer   => '_clear_container_stack',
   predicate => '_has_container_stack',
   default   => sub {[]},
  );

# This is a stack of nested parts at any point during document
# parsing.  Divisions, blocks, and strings are parts. Divisions may
# contain other divisions and blocks.  Blocks may contain strings.
# Strings may contain other strings. A part has an unambiguous
# beginning and end. Sometimes the beginning and end are explicit and
# other times they are implicit.
#
#   $current_container = $container_stack->[-1];
#   $self->_push_container_stack($part);
#   my $part = $self->_pop_container_stack;

######################################################################

has list_stack =>
  (
   is        => 'ro',
   isa       => 'ArrayRef',
   reader    => '_get_list_stack',
   writer    => '_set_list_stack',
   clearer   => '_clear_list_stack',
   predicate => '_has_list_stack',
   default   => sub {[]},
  );

# This is a stack of bullet and enumerated lists.

######################################################################

has column =>
  (
   is        => 'ro',
   isa       => 'Int',
   reader    => '_get_column',
   writer    => '_set_column',
   default   => 0,
  );

# This is the current table column.

######################################################################

has count_method_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_count_method_hash',
   writer    => '_set_count_method_hash',
   clearer   => '_clear_count_method_hash',
   default   => sub {{}},
  );

# This is a count of the number of times a method has been invoked.

#   $count = $count_method->{$name};

######################################################################

has requires_processing =>
  (
   is        => 'ro',
   isa     => 'Bool',
   reader  => '_requires_processing',
   writer  => '_set_requires_processing',
   clearer => '_clear_requires_processing',
   default => 0,
  );

# Don't confuse this boolean value with the private method
# '_text_requires_processing' that determines whether or not the text
# requires further processing.

######################################################################

has section_counter_hash =>
  (
   is        => 'ro',
   isa       => 'HashRef',
   reader    => '_get_section_counter_hash',
   writer    => '_set_section_counter_hash',
   clearer   => '_clear_section_counter_hash',
   default   => sub {{}},
  );

# $section_counter->{$depth} = $count;
# $section_counter->{1}      = 3;         # third top-level section

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

# $division_counter->{$name}   = $count;
# $division_counter->{'table'} = 4;      # forth table in this top-level

######################################################################

has valid =>
  (
   is        => 'ro',
   isa       => 'Bool',
   reader    => '_is_valid',
   writer    => '_set_is_valid',
   clearer   => '_clear_is_valid',
   default   => 1,
  );

######################################################################

has string_type_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => '_get_string_type_list',
   lazy    => 1,
   builder => '_build_string_type_list',
  );

######################################################################

has single_string_type_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => '_get_single_string_type_list',
   lazy    => 1,
   builder => '_build_single_string_type_list',
  );

######################################################################

has step_count =>
  (
   is      => 'ro',
   isa     => 'Int',
   reader  => '_get_step_count',
   writer  => '_set_step_count',
   default => 1,
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _init {

  my $self = shift;

  my $library = $self->_get_library;
  my $util    = $library->get_util;
  my $options = $util->get_options;

  if ( not $options->use_svn )
    {
      $logger->trace("not using SVN, won't warn about uncommitted changes");
    }

  $self->_clear_count_method_hash;
  $self->_set_count_method_hash({});
  $self->_clear_line_list;
  $self->_set_line_list([]);
  $self->_clear_division;
  $self->_clear_block;
  $self->_clear_string;
  $self->_clear_division_stack;
  $self->_set_division_stack([]);
  $self->_clear_container_stack;
  $self->_set_container_stack([]);
  $self->_set_column(0);
  $self->_clear_requires_processing;
  $self->_set_requires_processing(0);
  $self->_clear_section_counter_hash;
  $self->_set_section_counter_hash({});
  $self->_clear_is_valid;

  return 1;
}

######################################################################

sub _create_string {

  # Return a string object. Create the string object by parsing text
  # into a whole/part hierarchy of strings.

  my $self = shift;
  my $text = shift;                     # i.e. !!my bold text!!

  # !!! BUG HERE !!!
  #
  # lookup_ref -> This method doesn't know what to do with a lookup
  # reference.  Is this a problem?  Perhaps lookups are all 'resolved'
  # before this code is invoked?

  unless ( $text )
    {
      $logger->logcluck("CAN'T CREATE STRING, MISSING ARGUMENT");
      return 0;
    }

  $logger->trace("_create_string $text");

  my $container;                        # containing part

  if ( $self->_has_current_container )
    {
      $container = $self->_get_current_container;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  my $string_type = $self->_get_string_type($text);

  if ( $string_type eq 'string' )
    {
      my $args = {};

      $args->{name}      = 'string';
      $args->{content}   = $text;
      $args->{library}   = $self->_get_library;
      $args->{container} = $container if $container;

      my $newstring = SML::String->new(%{$args});

      if ( $self->_text_contains_substring($text) )
	{
	  $self->_push_container_stack($newstring);
	  $self->_parse_string_text($newstring); # recurse
	  $self->_pop_container_stack;
	}

      return $newstring;
    }

  # elsif ( $string_type eq 'syntax_error' )
  #   {
  #     my $args = {};

  #     $args->{name}      = 'SYNTAX_ERROR_STRING';
  #     $args->{content}   = $text;
  #     $args->{library}   = $self->_get_library;
  #     $args->{container} = $container if $container;

  #     my $newstring = SML::String->new(%{$args});

  #     return $newstring;
  #   }

  elsif
    (
     $string_type eq 'underline_string'
     or
     $string_type eq 'superscript_string'
     or
     $string_type eq 'subscript_string'
     or
     $string_type eq 'italics_string'
     or
     $string_type eq 'bold_string'
     or
     $string_type eq 'fixedwidth_string'
     or
     $string_type eq 'keystroke_symbol'
     or
     $string_type eq 'sglquote_string'
     or
     $string_type eq 'dblquote_string'
    )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{name}      = $string_type;
	  $args->{content}   = $1;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  my $newstring = SML::String->new(%{$args});

	  if ( $self->_text_contains_substring($text) )
	    {
	      $self->_push_container_stack($newstring);
	      $self->_parse_string_text($newstring); # recurse
	      $self->_pop_container_stack;
	    }

	  return $newstring;
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  # elsif ( $string_type eq 'emdash_symbol' )
  #   {
  #     if ( $text =~ /$syntax->{$string_type}/ )
  # 	{
  # 	  my $args = {};

  # 	  $args->{name}      = $string_type;
  # 	  $args->{library}   = $self->_get_library;
  # 	  $args->{container} = $container if $container;

  # 	  $args->{preceding_character} = $1 || q{};
  # 	  $args->{following_character} = $2 || q{};

  # 	  return SML::Symbol->new(%{$args});
  # 	}

  #     else
  # 	{
  # 	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
  # 	  return 0;
  # 	}
  #   }

  elsif
    (
     $string_type eq 'take_note_symbol'
     or
     $string_type eq 'smiley_symbol'
     or
     $string_type eq 'frowny_symbol'
     or
     $string_type eq 'left_arrow_symbol'
     or
     $string_type eq 'right_arrow_symbol'
     or
     $string_type eq 'latex_symbol'
     or
     $string_type eq 'tex_symbol'
     or
     $string_type eq 'copyright_symbol'
     or
     $string_type eq 'trademark_symbol'
     or
     $string_type eq 'reg_trademark_symbol'
     or
     $string_type eq 'section_symbol'
     or
     $string_type eq 'thepage_ref'
     or
     $string_type eq 'theversion_ref'
     or
     $string_type eq 'therevision_ref'
     or
     $string_type eq 'thedate_ref'
     or
     $string_type eq 'pagecount_ref'
     or
     $string_type eq 'thesection_ref'
     or
     $string_type eq 'linebreak_symbol'
     or
     $string_type eq 'pagebreak_symbol'
     or
     $string_type eq 'clearpage_symbol'
    )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{name}      = $string_type;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::Symbol->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'cross_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{tag}       = $1;
	  $args->{target_id} = $2;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::CrossReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'lookup_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{target_property} = $2;
	  $args->{target_id}       = $3;
	  $args->{library}         = $self->_get_library;
	  $args->{container}       = $container if $container;

	  return SML::LookupReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'title_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{tag}       = $1;
	  $args->{target_id} = $2;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::TitleReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'url_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{url}       = $1;
	  $args->{content}   = $3    if $3;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::URLReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'footnote_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{section_id} = $1;
	  $args->{number}     = $2;
	  $args->{library}    = $self->_get_library;
	  $args->{container}  = $container if $container;

	  return SML::FootnoteReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'gloss_term_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{tag}       = $1;
	  $args->{namespace} = $3 || q{};
	  $args->{term}      = $4;
	  $args->{content}   = $4;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::GlossaryTermReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'gloss_def_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{term}      = $3;
	  $args->{namespace} = $2 || '';
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::GlossaryDefinitionReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'acronym_term_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{tag}       = $1;
	  $args->{namespace} = $3 || '';
	  $args->{acronym}   = $4;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::AcronymTermReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'index_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{tag}       = $1;
	  $args->{entry}     = $2;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::IndexReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'id_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{target_id} = $1;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::IDReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'page_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{tag}       = $1;
	  $args->{target_id} = $2;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::PageReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'status_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{entity_id} = $1;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::StatusReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'citation_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{tag}       = $1;
	  $args->{source_id} = $2;
	  $args->{details}   = $4 || '';
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::CitationReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'file_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{filespec}  = $1;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::FileReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'path_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{pathspec}  = $1;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::PathReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'variable_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{variable_name} = $1;
	  $args->{namespace}     = $3 || '';
	  $args->{library}       = $self->_get_library;
	  $args->{container}     = $container if $container;

	  return SML::VariableReference->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'user_entered_text' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{name}      = 'USER_ENTERED_TEXT';
	  $args->{tag}       = $1;
	  $args->{content}   = $2;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::String->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'command_ref' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{name}      = 'COMMAND_REF';
	  $args->{content}   = $1;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::String->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'xml_tag' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{name}      = 'XML_TAG',
	  $args->{content}   = $1;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::String->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'literal' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{name}      = 'LITERAL_STRING';
	  $args->{content}   = $1;
	  $args->{library}   = $self->_get_library;
	  $args->{container} = $container if $container;

	  return SML::String->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  elsif ( $string_type eq 'email_addr' )
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{email_addr} = $1;
	  $args->{content}    = $3 || '';
	  $args->{library}    = $self->_get_library;
	  $args->{container}  = $container if $container;

	  return SML::EmailAddress->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

  else
    {
      $logger->error("COULDN'T CREATE $string_type STRING FROM \'$text\'");
      return 0;
    }

}

######################################################################

sub _extract_title_text {

  # Extract the title from an array of lines and return it as a
  # string.

  my $self  = shift;
  my $lines = shift;

  my $library     = $self->_get_library;
  my $syntax      = $library->get_syntax;
  my $in_data_segment = 1;
  my $in_title    = 0;
  my $first_line  = 1;
  my $title_text  = '';

  # Ignore the first line if it begins a division.

 LINE:
  foreach my $line (@{ $lines })
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      # skip first line if it starts a division
      if ( $first_line and $text =~ /$syntax->{start_division}/ )
	{
	  next;
	}

      # begin title element
      elsif (
	     $in_data_segment
	     and
	     not $in_title
	     and
	     $text =~ /$syntax->{title_element}/
	    )
	{
	  $first_line = 0;
	  $in_title   = 1;
	  $title_text = $3;
	}

      # begin section title
      elsif (
	     $in_data_segment
	     and
	     not $in_title
	     and
	     $text =~ /$syntax->{start_section}/
	    )
	{
	  $first_line = 0;
	  $in_title   = 1;
	  $title_text = $4;
	}

      # blank line ends title
      elsif (
	     $in_title
	     and
	     $text =~ /$syntax->{blank_line}/
	    )
	{
	  return $title_text;
	}

      # new element ends title
      elsif (
	     $in_title
	     and
	     $text =~ /$syntax->{element}/
	    )
	{
	  return $title_text;
	}

      # data segment ending text?
      elsif ( $self->_line_ends_data_segment($text) )
	{
	  return $title_text;
	}

      # anything else continues the title
      elsif ( $in_title )
	{
	  $first_line = 0;
	  $title_text .= " $text";
	}

    }

  return $title_text;
}

######################################################################

sub _get_line_list_for_id {

  # Return the line list for the division with the specified ID.

  my $self = shift;
  my $id   = shift;

  if ( not $id )
    {
      $logger->logcluck("YOU MUST SPECIFY AN ID");
      return 0;
    }

  my $library = $self->_get_library;
  my $file    = $library->get_file_containing_id($id);

  if ( not $file )
    {
      $logger->error("NO FILE CONTAINS ID \'$id\'");
      return 0;
    }

  my $file_line_list = $file->get_line_list;

  return $self->_extract_div_line_list($file_line_list,$id);
}

######################################################################

sub _extract_div_line_list {

  # Extract a sequence of lines representing a division with target_id
  # from another sequence of lines.

  my $self      = shift;
  my $line_list = shift;                # lines from which to extract division
  my $target_id = shift;                # ID of division to be extracted

  my $library            = $self->_get_library;
  my $syntax             = $library->get_syntax;
  my $lines              = [];          # Extracted lines
  my $div_stack          = [];          # stack of division names
  my $in_comment         = 0;           # in a comment division?
  my $in_target_division = 0;           # in the division targeted for extraction?

  foreach my $line (@{ $line_list })
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      if ( $text =~ /$syntax->{start_division}/xms )
	{
	  my $division_name = $1;       # $1 = division name (see Syntax.pm)
	  my $division_id   = $3 || q{};

	  if ( $division_id eq $target_id )
	    {
	      # This is the beginning of the division we're looking for.
	      $in_target_division = 1;

	      push @{ $div_stack }, $division_name;

	      push @{ $lines }, $line;
	    }

	  elsif ( $in_target_division )
	    {
	      push @{ $div_stack }, $division_name;

	      push @{ $lines }, $line;
	    }

	  else
	    {
	      # This is not the division we're looking for and we're
	      # not yet inside the target division.
	    }
	}

      elsif ( $text =~ /$syntax->{start_section}/xms )
	{
	  my $division_id = $3 || q{};

	  if ( $division_id eq $target_id )
	    {
	      # This is the division we're looking for.
	      $in_target_division = 1;

	      push @{ $lines }, $line;
	    }

	  elsif ( $in_target_division )
	    {
	      push @{ $lines }, $line;
	    }

	  else
	    {
	      # This is NOT the division we're looking for.
	    }
	}

      elsif ( $text =~ /$syntax->{end_division}/xms )
	{
	  # If this is the end of the division being extracted...
	  if (
	      $in_target_division
	      and
	      scalar @{ $div_stack } == 1
	     )
	    {
	      $in_target_division = 0;

	      push @{ $lines }, $line;

	      return $lines;
	    }

	  elsif ( $in_target_division )
	    {
	      pop @{ $div_stack };

	      push @{ $lines }, $line;
	    }

	  else
	    {
	      pop @{ $div_stack };
	    }
	}

      elsif ( $in_target_division )
	{
	  push @{ $lines }, $line;
	}
    }

  return $lines;
}

######################################################################

sub _resolve_includes {

  my $self = shift;

  my $count_method   = $self->_get_count_method_hash;
  my $count          = ++ $count_method->{'_resolve_includes'};
  my $library        = $self->_get_library;
  my $syntax         = $library->get_syntax;
  my $util           = $library->get_util;
  my $options        = $util->get_options;
  my $max_iterations = $options->get_MAX_RESOLVE_INCLUDES;
  my $number         = $self->_get_number;

  $logger->trace("{$number} ($count) resolve includes");

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }

  my $in_comment     = 0;
  my $depth          = 1;
  my $old_line_list  = $self->_get_line_list;
  my $new_line_list  = [];

 LINE:
  foreach my $old_line (@{ $old_line_list })
    {
      my $text = $old_line->get_content;

      if ( $text =~ /$syntax->{start_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 1;
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{end_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 0;
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      elsif ( $in_comment )
	{
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{comment_line}/ )
	{
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      # resolve include line into replacement lines
      elsif ( $text =~ /$syntax->{include_element}/ )
	{
	  # $1 = leading asterisks
	  # $2 = args
	  # $3 = division ID
	  # $4
	  # $5 = comment text

	  my $leading_asterisks = $1 || q{};
	  my $args              = $2 || q{};
	  my $included_id       = $3;
	  my $ignore            = $4 || q{};
	  my $comment_text      = $5 || q{};

	  my $repl_line_list = $self->_resolve_include_line
	    (
	     $old_line,
	     $depth,
	     $leading_asterisks,
	     $args,
	     $included_id,
	     $ignore,
	     $comment_text,
	    );

	  foreach my $repl_line (@{ $repl_line_list })
	    {
	      push @{ $new_line_list }, $repl_line;
	    }

	  next LINE;
	}

      # track current section depth
      elsif ( $text =~ /$syntax->{start_section}/ )
	{
	  $depth = length($1);
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      # nothing special about this line
      else
	{
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}
    }

  $self->_set_line_list($new_line_list);

  return 1;
}

######################################################################

sub _resolve_plugins {

  my $self = shift;

  my $count_method   = $self->_get_count_method_hash;
  my $count          = ++ $count_method->{'_resolve_plugins'};
  my $library        = $self->_get_library;
  my $syntax         = $library->get_syntax;
  my $util           = $library->get_util;
  my $options        = $util->get_options;
  my $max_iterations = $options->get_MAX_RESOLVE_PLUGINS;
  my $number         = $self->_get_number;

  $logger->trace("{$number} ($count) resolve plugins");

  return if not $options->resolve_plugins;

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }

  my $in_comment     = 0;
  my $depth          = 1;
  my $new_line_list  = [];
  my $old_line_list  = $self->_get_line_list;

 LINE:
  foreach my $old_line (@{ $old_line_list })
    {
      my $text = $old_line->get_content;

      if ( $text =~ /$syntax->{start_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 1;
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{end_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 0;
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      elsif ( $in_comment )
	{
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{'comment_line'}/ )
	{
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      # !!! BUG HERE !!!
      #
      # Should the 'plugin' feature be subject to conditional text?
      # In other words, should the parser run a script if its in a
      # division that is conditionally ignored?

      # resolve plugin line into replacement lines
      elsif ( $text =~ /$syntax->{plugin_element}/ )
	{
	  # $1 = leading asterisks
	  # $2 = args
	  # $3 = plugin name
	  # $4 = plugin arguments

	  my $leading_asterisks = $1 || q{};
	  my $args              = $2 || q{};
	  my $plugin            = $3;
	  my $plugin_args       = $4 || q{};

	  my $plugin_line_list = $self->_run_plugin
	    (
	     $old_line,
	     $depth,
	     $leading_asterisks,
	     $args,
	     $plugin,
	     $plugin_args
	    );

	  foreach my $new_line (@{ $plugin_line_list })
	    {
	      push @{ $new_line_list }, $new_line;
	    }

	  next LINE;
	}

      # track current section depth
      elsif ( $text =~ /$syntax->{start_section}/ )
	{
	  $depth = length($1);
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      # nothing special about this line
      else
	{
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}
    }

  $self->_set_line_list($new_line_list);

  return 1;
}

######################################################################

sub _run_plugin {

  my $self              = shift;
  my $old_line          = shift;        # old line begin replaced
  my $depth             = shift;        # current section depth
  my $leading_asterisks = shift;        # desired section depth
  my $args              = shift;        # element arguments
  my $plugin            = shift;
  my $plugin_args       = shift;

  my $number = $self->_get_number;

  $logger->info("{$number} run plugin: $plugin $plugin_args");

  my $library     = $self->_get_library;
  my $plugins_dir = $library->get_plugins_dir;
  my $perl_module = "$plugins_dir/$plugin.pm";

  if ( not -f $perl_module )
    {
      $logger->error("NO PLUGIN CALLED $plugin");
      return 0;
    }

  require $perl_module;

  my $document;

  if ( $self->_has_current_document )
    {
      $document = $self->_get_current_document;
    }

  my $object = $plugin->new
    (
     library  => $library,
     document => $document,
     args     => $plugin_args,
    );

  my $raw_line_list = $object->render;  # list of raw text lines
  my $line_list     = [];               # list of line objects

  foreach my $raw_line (@{ $raw_line_list })
    {
      my $newline = SML::Line->new
	(
	 file    => $old_line->get_file,
	 num     => $old_line->get_num,
	 content => $raw_line,
	);

      push(@{$line_list},$newline);
    }

  return $line_list;
}

######################################################################

sub _run_script {

  my $self              = shift;
  my $old_line          = shift;        # old line being replaced
  my $depth             = shift;        # current section depth
  my $leading_asterisks = shift;        # desired section depth
  my $args              = shift;        # element arguments
  my $command           = shift;        # script command to execute

  if ($^O eq 'MSWin32')
    {
      $command =~ s/\//\\/g;
    }

  my $number = $self->_get_number;
  $logger->info("{$number} run script: $command");

  my $library       = $self->_get_library;
  my $library_path  = $library->get_directory_path;
  my $original_path = getcwd;

  chdir $library_path;

  my @output = eval { `"$command"` };

  chdir $original_path;

  my $line_list = [];

  foreach my $raw_line ( @output )
    {
      my $line = SML::Line->new
	(
	 file    => $old_line->get_file,
	 num     => $old_line->get_num,
	 content => $raw_line,
	);
      push @{ $line_list }, $line;
    }

  return $line_list;
}

######################################################################

sub _resolve_scripts {

  # Scan lines, replace 'script' requests with script outputs.

  my $self = shift;

  my $count_method   = $self->_get_count_method_hash;
  my $count          = ++ $count_method->{'_resolve_scripts'};
  my $library        = $self->_get_library;
  my $syntax         = $library->get_syntax;
  my $util           = $library->get_util;
  my $options        = $util->get_options;
  my $max_iterations = $options->get_MAX_RESOLVE_SCRIPTS;
  my $number         = $self->_get_number;

  $logger->trace("{$number} ($count) resolve scripts");

  return if not $options->resolve_scripts;

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }

  my $in_comment     = 0;
  my $depth          = 1;
  my $old_line_list  = $self->_get_line_list;
  my $new_line_list  = [];

 LINE:
  foreach my $old_line (@{ $old_line_list })
    {
      my $text = $old_line->get_content;

      if ( $text =~ /$syntax->{start_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 1;
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{end_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 0;
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      elsif ( $in_comment )
	{
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{'comment_line'}/ )
	{
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      # !!! BUG HERE !!!
      #
      # Should the 'script' feature be subject to conditional text?
      # In other words, should the parser run a script if its in a
      # division that is conditionally ignored?

      # resolve script line into replacement lines
      elsif ( $text =~ /$syntax->{script_element}/ )
	{
	  # $1 = leading asterisks
	  # $2 = args
	  # $3 = command

	  my $leading_asterisks = $1 || q{};
	  my $args              = $2 || q{};
	  my $command           = $3;

	  my $script_line_list = $self->_run_script
	    (
	     $old_line,
	     $depth,
	     $leading_asterisks,
	     $args,
	     $command,
	    );

	  foreach my $new_line (@{ $script_line_list })
	    {
	      push @{ $new_line_list }, $new_line;
	    }

	  next LINE;
	}

      # nothing special about this line
      else
	{
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}
    }

  $self->_set_line_list($new_line_list);

  return 1;
}

######################################################################

sub _parse_lines {

  # parse lines to gather data into blocks and divisions.

  my $self = shift;

  my $library        = $self->_get_library;
  my $syntax         = $library->get_syntax;
  my $util           = $library->get_util;
  my $options        = $util->get_options;
  my $count_method   = $self->_get_count_method_hash;
  my $max_iterations = $options->get_MAX_PARSE_LINES;
  my $count          = ++ $count_method->{'_parse_lines'};
  my $number         = $self->_get_number;

  $logger->trace("{$number} ($count) parse lines");

  # MAX interations exceeded?
  if ( $count > $max_iterations )
    {
      my $msg = "$count: EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
      return 0;
    }

  $self->_set_division_stack([]);
  $self->_set_container_stack([]);

  $self->_set_section_counter_hash({});

  $self->_clear_block;

  $self->_set_column(0);
  $self->_set_requires_processing(0);

  if ( $self->_has_division )
    {
      my $division = $self->_get_division;
      $division->init;
      $self->_begin_division($division);
    }

  # parse line-by-line
 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      $logger->trace("{$number} line: $text");

      # if (
      # 	  $self->_in_data_segment
      # 	  and
      # 	  $self->_line_ends_data_segment($text)
      # 	 )
      # 	{
      # 	  $self->_set_in_data_segment(0);
      # 	}

      if ( $text =~ /$syntax->{start_division}/ )
	{
	  # $1 = division name
	  # $2
	  # $3 = divisioin ID
	  $self->_process_start_division_marker($line,$1,$3);
	}

      elsif ( $text =~ /$syntax->{start_section}/ )
	{
	  # $1 = asterisks
	  # $2
	  # $3 = section ID
	  # $4 = section heading
	  $self->_process_start_section_heading($line,$1,$3);
	}

      elsif ( $text =~ /$syntax->{end_division}/ )
	{
	  # $1 = division name
	  $self->_process_end_division_marker($line,$1);
	}

      elsif ( $self->_in_comment_division )
	{
	  $self->_process_comment_division_line($line);
	}

      elsif ( $text =~ /$syntax->{comment_line}/ )
	{
	  $self->_process_comment_line($line);
	}

      elsif ( $text =~ /$syntax->{blank_line}/ )
	{
	  $self->_process_blank_line($line);
	}

      elsif ( $text =~ /$syntax->{end_table_row}/ )
	{
	  $self->_process_end_table_row($line);
	}

      elsif ( $text =~ /$syntax->{attr_element}/ )
	{
	  $self->_process_start_attr_definition($line);
	}

      elsif ( $text =~ /$syntax->{outcome_element}/ )
	{
	  $self->_process_start_outcome($line);
	}

      elsif ( $text =~ /$syntax->{review_element}/ )
	{
	  $self->_process_start_review($line);
	}

      elsif ( $text =~ /$syntax->{footnote_element}/ )
	{
	  $self->_process_start_footnote_element($line);
	}

      elsif ( $text =~ /$syntax->{glossary_element}/ )
	{
	  $self->_process_start_glossary_entry($line);
	}

      elsif ( $text =~ /$syntax->{acronym_element}/ )
	{
	  $self->_process_start_acronym_entry($line);
	}

      elsif ( $text =~ /$syntax->{variable_element}/ )
	{
	  $self->_process_start_variable_definition($line);
	}

      elsif ( $text =~ /$syntax->{step_element}/ )
	{
	  $self->_process_start_step_element($line);
	}

      elsif ( $text =~ /$syntax->{image_element}/ )
	{
	  # $1 = element name
	  $self->_process_start_image_element($line,$1);
	}

      elsif ( $text =~ /$syntax->{element}/ )
	{
	  # $1 = element name
	  $self->_process_start_element($line,$1);
	}

      elsif ( $text =~ /$syntax->{bull_list_item}/ )
	{
	  # $1 = leading whitespace
	  $self->_process_bull_list_item($line,$1);
	}

      elsif ( $text =~ /$syntax->{enum_list_item}/ )
	{
	  # $1 = leading whitespace
	  $self->_process_enum_list_item($line,$1);
	}

      elsif ( $text =~ /$syntax->{def_list_item}/ )
	{
	  $self->_process_start_def_list_item($line);
	}

      elsif ( $text =~ /$syntax->{table_cell}/ )
	{
	  # $1 = emphasis indicator
	  # $2 = arguments
	  $self->_process_start_table_cell($line,$1,$2);
	}

      elsif ( $text =~ /$syntax->{indented_text}/ )
	{
	  $self->_process_indented_text($line);
	}

      elsif ( $text =~ /$syntax->{paragraph_text}/ )
	{
	  $self->_process_paragraph_text($line);
	}

      elsif ( $text =~ /$syntax->{non_blank_line}/ )
	{
	  $self->_process_non_blank_line($line);
	}

      else
	{
	  my $msg = "SOMETHING UNEXPECTED HAPPENED";
	  my $location = $line->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $self->_set_is_valid(0);
	}
    }

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  $self->_generate_section_numbers;
  $self->_generate_division_numbers;

  return 1;
}

######################################################################

sub _begin_division {

  my $self     = shift;
  my $division = shift;

  if ( not $self->_has_division )
    {
      $self->_set_division($division);
    }

  my $name   = $division->get_name;
  my $number = $self->_get_number;

  $logger->trace("{$number} ..... begin division $name");

  my $library  = $self->_get_library;
  my $ontology = $library->get_ontology;

  $library->add_division($division);

  # add this division to the one it is part of
  my $containing_division = $self->_get_current_division;

  if ( defined $containing_division)
    {
      $containing_division->add_part($division);
    }

  $self->_push_division_stack($division);

  # manage container stack
  if ( $self->_has_current_container )
    {
      my $container = $self->_get_current_container;
      $division->set_container($container);
    }

  $self->_push_container_stack($division);

  if ( $name eq 'DOCUMENT' )
    {
      return 1;
    }

  elsif ( $ontology->is_entity($name) )
    {
      $library->add_entity($division);
      return 1;
    }

  elsif ( $name eq 'SOURCE' )
    {
      my $references = $library->get_references;
      $references->add_source($division);
      return 1;
    }

  elsif ( $name eq 'TABLE_CELL' )
    {
      return 1;
    }

  elsif ( $name eq 'TABLE_ROW' )
    {
      $self->_set_column(0);
      return 1;
    }

  elsif ( $name eq 'TABLE' )
    {
      return 1;
    }

  elsif ( $name eq 'BARE_TABLE' )
    {
      return 1;
    }

  elsif ( $name eq 'LISTING' )
    {
      return 1;
    }

  elsif ( $name eq 'FIGURE' )
    {
      return 1;
    }

  elsif ( $name eq 'SECTION' )
    {
      return 1;
    }

  elsif ( $name eq 'COMMENT' )
    {
      return 1;
    }

  elsif ( $name eq 'CONDITIONAL' )
    {
      return 1;
    }

  elsif ( $name eq 'REVISIONS' )
    {
      return 1;
    }

  elsif ( $name eq 'EPIGRAPH' )
    {
      return 1;
    }

  elsif ( $division->isa('SML::Division') )
    {
      return 1;
    }

  else
    {
      my $type = ref $division;
      my $msg  = "THIS SHOULD NEVER HAPPEN ($type)";

      $self->_handle_message('error',$msg);

      return 0;
    }
}

######################################################################

sub _end_division {

  # End the CURRENT division.

  my $self = shift;

  my $division      = $self->_get_current_division;
  my $division_name = $division->get_name;

  return 0 if not $division;

  $self->_validate_property_cardinality($division);
  $self->_validate_property_values($division);
  $self->_validate_infer_only_conformance($division);
  $self->_validate_required_properties($division);
  $self->_validate_composition($division);

  # manage container stack
  $self->_pop_container_stack;

  if ( $division->isa('SML::TableRow') )
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

  elsif ( $division_name eq 'EXERCISE' )
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

  elsif ( $division_name eq 'BARE_TABLE' )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Figure') )
    {
      # do nothing.
    }

  elsif ( $division_name eq 'COMMENT' )
    {
      # do nothing.
    }

  elsif ( $division_name eq 'CONDITIONAL' )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Listing') )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Source') )
    {
      # do nothing
    }

  elsif ( $division_name eq 'PREFORMATTED' )
    {
      # do nothing.
    }

  elsif ( $division_name eq 'REVISIONS' )
    {
      # do nothing.
    }

  elsif ( $division_name eq 'EPIGRAPH' )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Attachment') )
    {
      # do nothing.
    }

  elsif ( $division_name eq 'SLIDE' )
    {
      # do nothing.
    }

  elsif ( $division_name eq 'DEMO' )
    {
      # do nothing.
    }

  elsif ( $division->isa('SML::Division') )
    {
      # do nothing.
    }

  else
    {
      my $type = ref $division;
      my $name = $division->get_name;
      my $msg  = "WHAT JUST HAPPENED? $type $name";
      $self->_handle_message('warn',$msg);
      return 0;
    }

  my $olddiv  = $self->_pop_division_stack;
  my $oldname = $olddiv->get_name;
  my $oldtype = ref $olddiv;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ..... end division $oldtype");

  return 1;
}

######################################################################

sub _end_table_row {

  my $self = shift;

  return if not $self->_in_table_row;

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

sub _end_step_list {

  my $self = shift;

  return if not $self->_in_step_list;

  $self->_end_division;

  return 1;

}

######################################################################

sub _end_bullet_list {

  my $self = shift;

  return if not $self->_in_bullet_list;

  $self->_pop_list_stack;

  $self->_end_division;

  return 1;

}

######################################################################

sub _end_enumerated_list {

  my $self = shift;

  return if not $self->_in_enumerated_list;

  $self->_pop_list_stack;

  $self->_end_division;

  return 1;

}

######################################################################

sub _end_definition_list {

  my $self = shift;

  return if not $self->_in_definition_list;

  $self->_end_division;

  return 1;

}

######################################################################

# not used?

sub _begin_default_section {

  my $self = shift;

  return if $self->_in_section;

  my $number = $self->_get_number;

  $logger->trace("{$number} ..... begin default section");

  my $division = $self->_get_current_division;
  my $library  = $self->_get_library;
  my $util     = $library->get_util;
  my $section  = $util->get_default_section;

  $self->_begin_division($section);

  # the default section does not have a data segment
  # $self->_set_in_data_segment(0);

  return 1;
}

######################################################################

sub _substitute_variables {

  # Scan blocks, substitute inline variable tags with values.

  my $self = shift;

  my $library        = $self->_get_library;
  my $syntax         = $library->get_syntax;
  my $util           = $library->get_util;
  my $options        = $util->get_options;
  my $division       = $self->_get_division;
  my $block_list     = $division->get_block_list;
  my $count_method   = $self->_get_count_method_hash;
  my $max_iterations = $options->get_MAX_SUBSTITUTE_VARIABLES;
  my $count          = ++ $count_method->{'_substitute_variables'};
  my $document       = undef;
  my $docid          = '';
  my $number         = $self->_get_number;

  $logger->trace("{$number} ($count) substitute variables");

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }


 BLOCK:
  foreach my $block (@{ $block_list })
    {
      my $block_name = $block->get_name;

      next if $block_name eq 'COMMENT_BLOCK';
      next if $block->is_in_a('COMMENT');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('PREFORMATTED');

      my $text = $block->get_content;

      next if $text =~ /$syntax->{'comment_line'}/;

      while ( $text =~ /$syntax->{variable_ref}/ )
	{
	  my $name      = $1;
	  my $namespace = $3 || q{};

	  if ( $library->has_variable($name,$namespace) )
	    {
	      # substitute variable value
	      my $value = $library->get_variable_value($name,$namespace);

	      $text =~ s/$syntax->{variable_ref}/$value/;

	      $logger->trace("substituted $name $namespace variable with $value");
	    }

	  else
	    {
	      my $msg = "UNDEFINED VARIABLE $name";
	      my $location = $block->get_location;
	      $self->_handle_error('warn',$msg,$location);

	      $self->_set_is_valid(0);
	      $division->_set_is_valid(0);

	      $text =~ s/$syntax->{variable_ref}/$name/;
	    }
	}

      $block->set_content($text);
    }

  return 1;
}

######################################################################

# sub _resolve_lookups {

#   my $self = shift;

#   my $library        = $self->_get_library;
#   my $syntax         = $library->get_syntax;
#   my $util           = $library->get_util;
#   my $count_method   = $self->_get_count_method_hash;
#   my $division       = $self->_get_division;
#   my $block_list     = $division->get_block_list;
#   my $options        = $util->get_options;
#   my $max_iterations = $options->get_MAX_RESOLVE_LOOKUPS;
#   my $count          = ++ $count_method->{'_resolve_lookups'};
#   my $number         = $self->_get_number;

#   $logger->trace("{$number} ($count) resolve lookups");

#   if ( $count > $max_iterations )
#     {
#       my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
#       $logger->logcroak("$msg");
#     }


#  BLOCK:
#   foreach my $block (@{ $block_list })
#     {
#       my $block_name = $block->get_name;

#       next if $block_name eq 'COMMENT_BLOCK';
#       next if $block->is_in_a('COMMENT');
#       next if $block->isa('SML::PreformattedBlock');
#       next if $block->is_in_a('PREFORMATTED');

#       my $text = $block->get_content;

#       next if $text =~ /$syntax->{'comment_line'}/;

#       while ( $text =~ /$syntax->{lookup_ref}/ )
# 	{
# 	  my $name = $2;
# 	  my $id   = $3;

# 	  if ( $library->has_property($id,$name) )
# 	    {
# 	      $logger->trace("{$number} ..... $id $name is in library");

# 	      my $list = $library->get_property_value_list($id,$name);

# 	      # use the first value, ignore the rest
# 	      my $value = $list->[0];

# 	      $text =~ s/$syntax->{lookup_ref}/$value/;
# 	    }

# 	  else
# 	    {
# 	      my $location = $block->get_location;
# 	      my $msg      = "LOOKUP FAILED $id $name";
# 	      $self->_handle_error('warn',$msg,$location);
# 	      $self->_set_is_valid(0);

# 	      $text =~ s/$syntax->{lookup_ref}/($msg)/;
# 	    }
# 	}

#       $block->set_content($text);
#     }

#   return 1;
# }

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
  my $division        = $self->_get_division;

  if ( not $division )
    {
      my $msg = "CAN'T GENERATE SECTION NUMBERS, NO DIVISION";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $section_list = $division->get_list_of_divisions_with_name('SECTION');

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
  my $division_counter = $self->_get_division_counter_hash;

  $division_counter = {};

  my $previous_depth = 1;
  my $division       = $self->_get_division;

  if ( not $division )
    {
      my $msg = "CAN'T GENERATE DIVISION NUMBERS, NO DIVISION";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $division_list = $division->get_division_list;

  foreach my $division (@{ $division_list }) {

    next if $division->isa('SML::Document'); # skip document division
    next if $division->isa('SML::Section');  # skip section division

    my $section = $division->get_containing_section;

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

  if ( $self->_has_block )
    {
      $self->_end_block;
    }

  $self->_set_block($block);

  # manage container stack
  if ( $self->_has_current_container )
    {
      my $container = $self->_get_current_container;
      $block->set_container($container);
    }

  $self->_push_container_stack($block);

  return 1;
}

######################################################################

sub _end_block {

  # End the current block.

  my $self = shift;

  my $block = $self->_get_block;
  my $name  = $block->get_name;

  # validate block syntax
  $self->_validate_bold_markup_syntax($block);
  $self->_validate_italics_markup_syntax($block);
  $self->_validate_fixedwidth_markup_syntax($block);
  $self->_validate_underline_markup_syntax($block);
  $self->_validate_superscript_markup_syntax($block);
  $self->_validate_subscript_markup_syntax($block);
  $self->_validate_inline_tags($block);
  $self->_validate_cross_ref_syntax($block);
  $self->_validate_id_ref_syntax($block);
  $self->_validate_page_ref_syntax($block);
  $self->_validate_glossary_term_ref_syntax($block);
  $self->_validate_glossary_def_ref_syntax($block);
  $self->_validate_acronym_ref_syntax($block);
  $self->_validate_source_citation_syntax($block);

  # validate certain block semantics
  $self->_validate_cross_ref_semantics($block);
  $self->_validate_id_ref_semantics($block);
  $self->_validate_page_ref_semantics($block);

  if ( $block->isa('SML::Element') )
    {
      $self->_end_element($block);
    }

  elsif ( $name eq 'BULLET_LIST_ITEM' )
    {
      $self->_process_end_bullet_list_item($block);
    }

  elsif ( $name eq 'ENUM_LIST_ITEM' )
    {
      $self->_process_end_enum_list_item($block);
    }

  elsif ( $block->isa('SML::DefinitionListItem') )
    {
      $self->_process_end_def_list_item($block);
    }

  elsif ( $block->isa('SML::Paragraph') )
    {
      $self->_process_end_paragraph($block);
    }

  $self->_clear_block;

  # manage container stack
  $self->_pop_container_stack;

  return 1;
}

######################################################################

sub _end_element {

  my $self    = shift;
  my $element = shift;

  my $element_name = $element->get_name;

  if ( $element_name eq 'var' )
    {
      $self->_process_end_variable_definition($element);
    }

  elsif ( $element_name eq 'attr' )
    {
      $self->_process_end_attr_definition($element);
    }

  elsif ( $element_name eq 'footnote' )
    {
      $self->_process_end_footnote_element($element);
    }

  elsif ( $element_name eq 'step' )
    {
      $self->_process_end_step_element($element);
    }

  elsif ( $element_name eq 'glossary' )
    {
      $self->_process_end_glossary_entry($element);
    }

  elsif ( $element_name eq 'acronym' )
    {
      $self->_process_end_acronym_entry($element);
    }

  elsif ( $element_name eq 'outcome' )
    {
      $self->_process_end_outcome($element);
    }

  elsif ( $element_name eq 'review' )
    {
      $self->_process_end_review($element);
    }

  elsif ( $element_name eq 'image' )
    {
      $self->_process_end_element($element);
    }

  elsif ( $element_name eq 'index' )
    {
      $self->_process_end_index_element($element);
    }

  elsif ( $element_name eq 'author' )
    {
      $self->_process_end_author_element($element);
    }

  elsif ( $element_name eq 'date' )
    {
      $self->_process_end_date_element($element);
    }

  elsif ( $element_name eq 'revision' )
    {
      $self->_process_end_revision_element($element);
    }

  elsif ( $element_name eq 'use_formal_status' )
    {
      $self->_end_use_formal_status_element($element);
    }

  else
    {
      $self->_process_end_element($element);
    }

  my $element_value = $element->get_value;
  my $library       = $self->_get_library;
  my $ontology      = $library->get_ontology;
  my $reasoner      = $library->get_reasoner;

  if ( not $ontology->property_is_universal($element_name) )
    {

      my $division      = $element->get_containing_division;
      my $division_id   = $division->get_id;
      my $division_name = $division->get_name;

      $library->add_property_value
	(
	 $division_id,
	 $element_name,
	 $element_value,
	 $element,
	);

      if ( $library->has_division_id($element_value) )
	{
	  # parse the referenced division into memory
	  $library->get_division($element_value);

	  my $subject   = $division->get_id;  # rq-002
	  my $predicate = $element->get_name; # is_part_of
	  my $object    = $element_value;     # rq-001

	  if ( $ontology->allows_triple($subject,$predicate,$object) )
	    {
	      unless ( $library->has_triple($subject,$predicate,$object) )
		{
		  my $triple = SML::Triple->new
		    (
		     subject   => $subject,
		     predicate => $predicate,
		     object    => $object,
		     library   => $library,
		     origin    => $element,
		    );

		  $library->add_triple($triple);

		  my $inverse_triple = $reasoner->infer_inverse_triple($triple);

		  if ( $inverse_triple )
		    {
		      my $subject          = $inverse_triple->get_subject;
		      my $predicate        = $inverse_triple->get_predicate;
		      my $object           = $inverse_triple->get_object;
		      my $subject_division = $library->get_division($subject);

		      $library->add_property_value
			(
			 $subject,
			 $predicate,
			 $object,
			 1,
			);

		      $library->add_triple($inverse_triple);
		    }
		}
	    }

	  else
	    {
	      my $msg = "ONTOLOGY DOESN'T ALLOW TRIPLE $subject $predicate $object";
	      $self->_handle_error('error',$msg);
	    }
	}

      # Check to see whether this element value should be a division
      # ID but is non-existent.
      elsif ( $ontology->value_must_be_division_id_for_property($division_name,$element_name) )
	{
	  my $msg = "NON-EXISTENT DIVISION ID $element_value FOR $division_name $element_name";
	  my $location = $element->get_location;
	  $self->_handle_error('error',$msg,$location);
	}
    }

  return 1;
}

######################################################################

sub _contains_include {

  # Return 1 if text contains an 'include' statement.  Ignore
  # 'include' statements within comments.  This method MUST parse
  # line-by-line (rather than block-by-block or element-by-element)
  # because it is called BEFORE _parse_lines builds arrays of blocks
  # and elements.

  my $self = shift;

  my $library        = $self->_get_library;
  my $syntax         = $library->get_syntax;
  my $in_comment     = 0;
  my $in_conditional = '';

 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      if ( $text =~ /$syntax->{start_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 1;
	  next LINE;                    # ignore start of comment
	}

      elsif ( $text =~ /$syntax->{end_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 0;
	  next LINE;                    # ignore end of comment
	}

      elsif ( $in_comment )
	{
	  next LINE;                    # ignore comment line
	}

      elsif ( $text =~ /$syntax->{'comment_line'}/ )
	{
	  next LINE;                    # ignore comment line
	}

      elsif ( $text =~ /$syntax->{include_element}/ )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_script {

  # This method MUST parse line-by-line (rather than block-by-block or
  # element-by-element) because it is called BEFORE _parse_lines
  # builds arrays of blocks and elements.

  my $self = shift;

  my $library    = $self->_get_library;
  my $syntax     = $library->get_syntax;
  my $in_comment = 0;

 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      #---------------------------------------------------------------
      # Ignore comments
      #
      if ( $text =~ /$syntax->{start_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 1;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{end_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 0;
	  next LINE;
	}

      elsif ( $in_comment )
	{
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{'comment_line'}/ )
	{
	  next LINE;
	}

      #---------------------------------------------------------------
      # Script statement
      #
      elsif ( $text =~ /$syntax->{script_element}/ )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_plugin {

  # This method MUST parse line-by-line (rather than block-by-block or
  # element-by-element) because it is called BEFORE _parse_lines
  # builds arrays of blocks and elements.

  my $self = shift;

  my $library    = $self->_get_library;
  my $syntax     = $library->get_syntax;
  my $in_comment = 0;

 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      #---------------------------------------------------------------
      # Ignore comments
      #
      if ( $text =~ /$syntax->{start_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 1;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{end_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 0;
	  next LINE;
	}

      elsif ( $in_comment )
	{
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{comment_line}/ )
	{
	  next LINE;
	}

      #---------------------------------------------------------------
      # Plugin element
      #
      elsif ( $text =~ /$syntax->{plugin_element}/ )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_template {

  # This method MUST parse line-by-line (rather than block-by-block or
  # element-by-element) because it is called BEFORE _parse_lines
  # builds arrays of blocks and elements.

  my $self = shift;

  my $library    = $self->_get_library;
  my $syntax     = $library->get_syntax;
  my $in_comment = 0;

 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      #---------------------------------------------------------------
      # Ignore comments
      #
      if ( $text =~ /$syntax->{start_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 1;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{end_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 0;
	  next LINE;
	}

      elsif ( $in_comment )
	{
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{comment_line}/ )
	{
	  next LINE;
	}

      #---------------------------------------------------------------
      # template element
      #
      elsif ( $text =~ /$syntax->{template_element}/ )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_insert {

  my $self = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  my $division     = $self->_get_division;
  my $element_list = $division->get_element_list;

  foreach my $element ( @{ $element_list } )
    {
      my $text = $element->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      if (
	     $text =~ /$syntax->{'insert_element'}/
	  or $text =~ /$syntax->{'insert_ins_element'}/
	  or $text =~ /$syntax->{'insert_gen_element'}/
	 )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_variable {

  my $self = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  my $division   = $self->_get_division;
  my $block_list = $division->get_block_list;

  foreach my $block ( @{ $block_list } )
    {
      my $block_name = $block->get_name;

      next if $block_name eq 'COMMENT_BLOCK';
      next if $block->is_in_a('COMMENT');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('PREFORMATTED');

      my $text = $block->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      next if $text =~ /$syntax->{'comment_line'}/;

      if ( $text =~ /$syntax->{variable_ref}/ )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _contains_lookup {

  my $self = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  my $division   = $self->_get_division;
  my $block_list = $division->get_block_list;

  foreach my $block ( @{ $block_list } )
    {
      my $block_name = $block->get_name;

      next if $block_name eq 'COMMENT_BLOCK';
      next if $block->is_in_a('COMMENT');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('PREFORMATTED');

      my $text = $block->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      next if $text =~ /$syntax->{'comment_line'}/;

      if ( $text =~ /$syntax->{lookup_ref}/ )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _text_requires_line_processing {

  # This method MUST parse line-by-line (rather than block-by-block or
  # element-by-element) because it is called BEFORE _parse_lines
  # builds arrays of blocks and elements.

  my $self = shift;

  my $library    = $self->_get_library;
  my $syntax     = $library->get_syntax;
  my $in_comment = 0;

 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      #---------------------------------------------------------------
      # Ignore comments
      #
      if ( $text =~ /$syntax->{start_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 1;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{end_division}/ and $1 eq 'COMMENT' )
	{
	  $in_comment = 0;
	  next LINE;
	}

      elsif ( $in_comment )
	{
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{comment_line}/ )
	{
	  next LINE;
	}

      #---------------------------------------------------------------
      # resolvable element
      #
      elsif
	(
	 $text =~ /$syntax->{include_element}/
	 or
	 $text =~ /$syntax->{script_element}/
	 or
	 $text =~ /$syntax->{plugin_element}/
	 or
	 $text =~ /$syntax->{template_element}/
	)
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _text_requires_block_processing {

  # Return 1 if text contains anything that needs to be resolved.

  my $self = shift;

  my $library    = $self->_get_library;
  my $syntax     = $library->get_syntax;
  my $division   = $self->_get_division;
  my $block_list = $division->get_block_list;

  foreach my $block ( @{ $block_list } )
    {
      my $block_name = $block->get_name;

      next if $block_name eq 'COMMENT_BLOCK';
      next if $block->is_in_a('COMMENT');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('PREFORMATTED');

      my $text = $block->get_content;

      next if $text =~ /$syntax->{comment_line}/;

      if
	(
	 $text =~ /$syntax->{variable_ref}/
	 # or
	 # $text =~ /$syntax->{lookup_ref}/
	)
	{
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

  my $division      = $self->_get_division;
  my $division_list = $division->get_division_list;

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

  my $library = $self->_get_library;
  my $util    = $library->get_util;

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

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  my $content = $line->get_content;

  $content =~ s/$syntax->{title_element}/!!$3!!/;
  $content =~ s/$syntax->{'start_section'}/!!$4!!/;

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

sub _add_template {

  my $self     = shift;
  my $division = shift;

  my $id        = $division->get_id;
  my $template  = $self->template;

  $template->{$id} = $division;

  return 1;
}

######################################################################

sub _process_comment_line {

  my $self = shift;
  my $line = shift;

  my $library = $self->_get_library;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- comment line");

  if ( not $self->_in_comment_block )
    {
      $logger->trace("{$number} ..... begin comment block");

      my $block = SML::PreformattedBlock->new
	(
	 name    => 'COMMENT_BLOCK',
	 library => $library,
	);

      $block->add_line($line);
      $self->_begin_block($block);

      my $division = $self->_get_current_division;
      $division->add_part( $block );
    }

  else
    {
      $logger->trace("{$number} ..... continue comment block");

      my $block = $self->_get_block;
      $block->add_line($line);
    }

  return 1;
}

######################################################################

sub _process_comment_division_line {

  my $self = shift;
  my $line = shift;

  my $library = $self->_get_library;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- line in comment division");

  if ( not $self->_get_block )
    {
      my $block = SML::PreformattedBlock->new(library=>$library);
      $block->add_line($line);
      $self->_begin_block($block);

      my $division = $self->_get_current_division;
      $division->add_part( $block );
    }

  else
    {
      my $block = $self->_get_block;
      $block->add_line($line);
    }

  return 1;
}

######################################################################

sub _process_start_division_marker {

  my $self = shift;
  my $line = shift;                     # start division marker
  my $name = shift;                     # division name
  my $id   = shift || q{};              # division ID

  # return if $name eq 'RAW';

  my $number = $self->_get_number;

  $logger->trace("{$number} ----- start division ($name.$id)");

  my $library  = $self->_get_library;
  my $location = $line->get_location;
  my $ontology = $library->get_ontology;
  my $num      = $library->increment_division_count($name);

  unless ( $ontology->allows_division_name($name) )
    {
      my $msg = "UNDEFINED DIVISION at $location: \"$name\"";
      $logger->logdie("$msg");
    }

  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;
  $self->_end_baretable       if $self->_in_baretable;

  if ( $name eq 'SECTION' and $self->_in_section )
    {
      $self->_end_section;
    }

  if ( not $id )
    {
      $id = "$name-$num";
    }

  my $class = $ontology->get_class_for_division_name($name);

  my $division = $class->new
    (
     name    => $name,
     id      => $id,
     library => $library,
    );

  my $block = SML::PreformattedBlock->new
    (
     name    => 'BEGIN_DIVISION',
     library => $library,
    );

  $block->add_line($line);
  $self->_begin_block($block);
  $division->add_part($block);
  $self->_begin_division($division);

  if ( $name eq 'PREFORMATTED' )
    {
      my $block = SML::PreformattedBlock->new
	(
	 library => $library,
	);

      $self->_begin_block($block);
      $division->add_part($block);
    }

  return 1;
}

######################################################################

sub _process_end_division_marker {

  my $self = shift;
  my $line = shift;
  my $name = shift;

  my $library = $self->_get_library;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- end division ($name)");

  # $self->_set_in_data_segment(0);

  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;
  $self->_end_baretable       if $self->_in_baretable;

  if ( $self->_in_bullet_list or $self->_in_enumerated_list )
    {
      $self->_end_all_lists;
    }

  if ( $name eq 'DOCUMENT' and $self->_in_section )
    {
      $self->_end_section;
    }

  elsif ( $name eq 'TABLE' and $self->_in_table_row )
    {
      $self->_end_table_row;
    }

  elsif ( $name eq 'DEMO' and $self->_in_step_list )
    {
      $self->_end_step_list;
    }

  elsif ( $name eq 'EXERCISE' and $self->_in_step_list )
    {
      $self->_end_step_list;
    }

  my $division = $self->_get_current_division;

  if ( not $division )
    {
      my $location = $line->get_location;
      $logger->fatal("at location: $location");
      $logger->logcluck("THIS SHOULD NEVER HAPPEN");
    }

  if ( $name eq 'DOCUMENT' )
    {
      my $document = $division;

      $self->_build_document_index($document);
      $self->_parse_document_index_terms($document);
      $self->_validate_division_blocks($document);
      $self->_parse_division_blocks($document);
      $self->_build_document_glossary($document);
      $self->_build_document_acronym_list($document);
      $self->_build_document_references($document);
    }

  my $block = SML::PreformattedBlock->new
    (
     name    => 'END_DIVISION',
     library => $library,
    );

  $block->add_line($line);
  $self->_begin_block($block);
  $division->add_part($block);
  $self->_end_division;

  return 1;
}

######################################################################

sub _process_start_section_heading {

  my $self      = shift;
  my $line      = shift;
  my $asterisks = shift;
  my $id        = shift || q{};

  my $number   = $self->_get_number;

  $logger->trace("{$number} ----- start division (SECTION.$id)");

  my $library  = $self->_get_library;
  my $location = $line->get_location;
  my $ontology = $library->get_ontology;
  my $num      = $library->increment_division_count('SECTION');
  my $depth    = length($1);

  $self->_end_step_list       if $self->_in_step_list;
  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;
  $self->_end_baretable       if $self->_in_baretable;
  $self->_end_table           if $self->_in_table;
  $self->_end_section         if $self->_in_section;

  # $self->_set_in_data_segment(1);

  # new title element
  $logger->trace("{$number} ..... new title");

  my $element = SML::Element->new
    (
     name    => 'title',
     library => $library,
    );

  $element->add_line($line);
  $self->_begin_block($element);

  if ( not $id )
    {
      $id = "section-$num";
    }

  # new section
  my $section = SML::Section->new
    (
     depth    => $depth,
     id       => $id,
     library  => $library,
    );

  $section->add_part($element);

  $self->_begin_division($section);

  return 1;
}

######################################################################

sub _process_end_table_row {

  my $self = shift;
  my $line = shift;

  my $name     = 'END_TABLE_ROW';
  my $library  = $self->_get_library;
  my $location = $line->get_location;
  my $number   = $self->_get_number;

  $logger->trace("{$number} ----- end table row marker");

  if ( not $self->_in_table and not $self->_in_baretable )
    {
      $logger->logdie("TABLE ROW END MARKER NOT IN TABLE at $location");
    }

  if ( not $self->_in_table_row )
    {
      my $msg = "TABLE ROW END MARKER NOT IN TABLE ROW";
      $self->_handle_error('warn',$msg,$location);
      $self->_set_is_valid(0);
    }

  else
    {
      $self->_end_all_lists       if $self->_in_bullet_list;
      $self->_end_all_lists       if $self->_in_enumerated_list;
      $self->_end_definition_list if $self->_in_definition_list;

      $self->_end_table_row;
    }

  # new preformatted block
  my $block = SML::PreformattedBlock->new(name=>$name,library=>$library);
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

  my $number = $self->_get_number;

  $logger->trace("{$number} ----- blank line");

  if ( $self->_get_block )
    {
      my $block = $self->_get_block;

      $block->add_line($line);

      if ( not $block->isa('SML::PreformattedBlock') )
	{
	  $self->_end_block;
	}
    }

  else
    {
      $logger->trace("{$number} ..... blank line not in block?");
      return 0;
    }

  return 1;
}

######################################################################

sub _process_start_element {

  my $self = shift;
  my $line = shift;
  my $name = shift;

  my $library  = $self->_get_library;
  my $ontology = $library->get_ontology;
  my $location = $line->get_location;
  my $division = $self->_get_current_division;
  my $divname  = $division->get_name;

  my $element = SML::Element->new
    (
     name    => $name,
     library => $library,
    );

  my $number = $self->_get_number;

  $logger->trace("{$number} ----- element ($name) \'$element\'");

  $element->add_line($line);
  $self->_begin_block($element);

  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;
  $self->_end_baretable       if $self->_in_baretable;

  $division->add_part($element);

  return 1;
}

######################################################################

sub _process_end_element {

  my $self    = shift;
  my $element = shift;

  my $library  = $self->_get_library;
  my $syntax   = $library->get_syntax;
  my $text     = $element->get_content;

  if ( $text =~ /$syntax->{element}/ )
    {
      # $1 = element name
      # $2 = element args
      # $3 = element value
      # $4
      # $5 = comment text
      $element->set_value($3);
    }

  elsif ( $text =~ /$syntax->{start_section}/ )
    {
      # $1 = 1 or more '*'
      # $2 =
      # $3 = section ID
      # $4 = section heading
      $element->set_value($4);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN ELEMENT";
      my $location = $element->get_location;
      $self->_handle_error('error',$msg,$location);
    }

  return 1;
}

######################################################################

sub _process_start_footnote_element {

  my $self  = shift;
  my $line  = shift;

  my $library = $self->_get_library;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- element (note)");

  my $element = SML::Note->new(library=>$library);

  $element->add_line($line);

  $self->_begin_block($element);

  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;
  $self->_end_baretable       if $self->_in_baretable;

  my $division = $self->_get_current_division;

  $division->add_part($element);

  return 1;
}

######################################################################

sub _process_end_footnote_element {

  my $self     = shift;
  my $footnote = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $footnote->get_content;

  if ( $text =~ /$syntax->{footnote_element}/ )
    {
      # $1 = element name  (always 'footnote')
      # $2 = element args  (note number)
      # $3 = element value (note text)
      $footnote->set_number($2);
      $footnote->set_value($3);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN FOOTNOTE";
      my $location = $footnote->get_location;
      $self->_handle_error('error',$msg,$location);
    }

  if ( $self->_has_current_document )
    {
      my $document = $self->_get_current_document;

      $document->add_note($footnote);
    }

  return 1;
}

######################################################################

sub _process_start_glossary_entry {

  my $self      = shift;
  my $line      = shift;

  my $library   = $self->_get_library;
  my $util      = $library->get_util;
  my $number    = $self->_get_number;

  $logger->trace("{$number} ----- element (glossary)");

  my $definition = SML::Definition->new
    (
     name    => 'glossary',
     library => $library,
    );

  $definition->add_line($line);

  $self->_begin_block($definition);

  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;
  $self->_end_baretable       if $self->_in_baretable;

  my $division = $self->_get_current_division;

  $division->add_part($definition);

  return 1;
}

######################################################################

sub _process_end_glossary_entry {

  my $self       = shift;
  my $definition = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $definition->get_content;

  if ( $text =~ /$syntax->{glossary_element}/ )
    {
      # $1 = element name  (always 'glossary')
      # $2 = element args
      # $3 = element value (term {namespace} = definition)
      # $4 = glossary term
      # $5
      # $6 = namespace
      # $7 = definition text
      my $namespace = $6 || q{};

      $definition->set_value($3);
      $definition->set_term($4);
      $definition->set_namespace($namespace);
      $definition->set_definition($7);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN GLOSSARY DEFINITION";
      my $location = $definition->get_location;
      $self->_handle_error('error',$msg,$location);
    }


  my $library_glossary = $library->get_glossary;
  $library_glossary->add_entry($definition);

  return 1;
}

######################################################################

sub _process_start_acronym_entry {

  my $self      = shift;
  my $line      = shift;

  my $library   = $self->_get_library;
  my $util      = $library->get_util;
  my $number    = $self->_get_number;

  $logger->trace("{$number} ----- element (acronym)");

  my $definition = SML::Definition->new
    (
     name      => 'acronym',
     library   => $library,
    );

  $definition->add_line($line);

  $self->_begin_block($definition);

  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;
  $self->_end_baretable       if $self->_in_baretable;

  my $division = $self->_get_current_division;

  $division->add_part($definition);

  return 1;
}

######################################################################

sub _process_end_acronym_entry {

  my $self       = shift;
  my $definition = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $definition->get_content;

  if ( $text =~ /$syntax->{acronym_element}/ )
    {
      # $1 = element name (always 'acronym')
      # $2 = element args
      # $3 = element value (acronym {namespace} = definition)
      # $4 = acronym term
      # $5
      # $6 = namespace
      # $7 = acronym definition
      my $namespace = $6 || q{};

      $definition->set_value($3);
      $definition->set_term($4);
      $definition->set_namespace($namespace);
      $definition->set_definition($7);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN ACRONYM DEFINITION";
      my $location = $definition->get_location;
      $self->_handle_error('error',$msg,$location);
    }

  my $library_acronym_list = $library->get_acronym_list;
  $library_acronym_list->add_entry($definition);

  return 1;
}

######################################################################

sub _process_start_variable_definition {

  my $self      = shift;
  my $line      = shift;

  my $library  = $self->_get_library;
  my $number   = $self->_get_number;

  $logger->trace("{$number} ----- element (VARIABLE DEFINITION)");

  my $definition = SML::Definition->new
    (
     name      => 'var',
     library   => $library,
    );

  $definition->add_line($line);

  $self->_begin_block($definition);

  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;
  $self->_end_baretable       if $self->_in_baretable;

  my $division = $self->_get_current_division;

  $division->add_part($definition);

  return 1;
}

######################################################################

sub _process_end_variable_definition {

  my $self       = shift;
  my $definition = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $definition->get_content;

  if ( $text =~ /$syntax->{variable_element}/ )
    {
      # $1 = element name   (always 'var')
      # $2 = element args
      # $3 = element value  (term {namespace} = definition)
      # $4 = variable name  (term)
      # $5
      # $6 = namespace      (OPTIONAL)
      # $7 = variable value (definition)
      $definition->set_value($3);
      $definition->set_term($4);
      $definition->set_namespace($6);
      $definition->set_definition($7);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN VARIABLE DEFINITION";
      my $location = $definition->get_location;
      $self->_handle_error('error',$msg,$location);
    }


  $library->add_variable($definition);

  return 1;
}

######################################################################

sub _process_bull_list_item {

  my $self       = shift;
  my $line       = shift;
  my $whitespace = shift;

  my $indent  = length($whitespace);
  my $library = $self->_get_library;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- bullet list item (indent=$indent)");

  # What are all the possible actions the parser may need to take upon
  # encountering a bullet list item line?

  # CASE 1: preformatted bullet item
  #
  # if
  # (
  #   in pre-formatted division
  #   or
  #   (
  #     line is indented
  #     and
  #     (
  #       NOT currently in bullet list
  #       and
  #       NOT currently in enumerated list
  #     )
  #   )
  # )
  # {
  #   Create new preformatted block
  #   Add new preformatted block to current division
  # }

  if
    (
     $self->_in_preformatted_division
     or
     (
      $indent > 0
      and
      (
       not $self->_in_bullet_list
       and
       not $self->_in_enumerated_list
      )
     )
    )
    {
      if ( $self->_in_preformatted_block )
	{
	  $logger->trace("{$number} ..... continue preformatted block");

	  my $block = $self->_get_block;
	  $block->add_line($line);
	}

      else
	{
	  $logger->trace("{$number} ..... new preformatted block");

	  my $block = SML::PreformattedBlock->new(library=>$library);
	  $block->add_line($line);
	  $self->_begin_block($block);

	  my $division = $self->_get_current_division;
	  $division->add_part($block);
	}
    }

  # CASE 2: fatal improper bullet item indent
  #
  # elsif
  # (
  #   (
  #     currently in bullet list
  #     or
  #     currently in enumerated list
  #   )
  #   and
  #   (
  #     indent is less than current list level indent
  #     and
  #     no list exists at indent level
  #   )
  # )
  # {
  #   FATAL: improper indent at location
  # }

  elsif
    (
     (
      $self->_in_bullet_list
      or
      $self->_in_enumerated_list
     )
     and
     (
      $indent < $self->_get_current_list_indent
      and
      not $self->_has_list_at_indent($indent)
     )
    )
    {
      my $msg = "IMPROPER BULLET ITEM INDENT $indent";
      my $location = $line->get_location;
      $self->_handle_error('error',$msg,$location);
    }

  # CASE 3: new top level bullet item
  #
  # elsif
  # (
  #   line is not indented
  #   and
  #   NOT currently in bullet list
  # )
  # {
  #   End enumerated list if in enumerated list
  #   End step list if in step list
  #   End definition list if in definition list
  #   Create new bullet list
  #   Push new bullet list on list stack
  #   Create new bullet item
  #   Add new bullet item to new bullet list
  # }

  elsif
    (
     $indent == 0
     and
     not $self->_in_bullet_list
    )
    {
      $self->_end_all_lists       if $self->_in_enumerated_list;
      $self->_end_definition_list if $self->_in_definition_list;

      $logger->trace("{$number} ..... new top level bullet list");

      my $count = $library->get_bullet_list_count;

      my $list = SML::BulletList->new
	(
	 id                 => "BULLET_LIST-$count",
	 leading_whitespace => $whitespace,
	 library            => $library,
	);

      $self->_begin_division($list);
      $self->_push_list_stack($list);

      $logger->trace("{$number} ..... new top level bullet item");

      my $item = SML::ListItem->new
	(
	 name               => 'BULLET_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  # CASE 4: new bullet item at same indent as previous
  #
  # elsif
  # (
  #   currently in a bullet list
  #   and
  #   indent is equal to current list level indent
  # )
  # {
  #   Create new bullet
  #   Add new bullet to current bullet list
  # }
  #

  elsif
    (
     $self->_in_bullet_list
     and
     $indent == $self->_get_current_list_indent
    )
    {
      $logger->trace("{$number} ..... new bullet item");

      my $item = SML::ListItem->new
	(
	 name               => 'BULLET_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  # CASE 5: new bullet sub list
  #
  # elsif
  # (
  #   currently in a enumerated list
  #   and
  #   indent is equal to current list level indent
  # )
  # {
  #   End enumerated list
  #   Start a new bullet list
  #   Push new bullet list on list stack
  #   Create new bullet
  #   Add new bullet to current bullet list
  # }
  #

  elsif
    (
     $self->_in_enumerated_list
     and
     $indent == $self->_get_current_list_indent
    )
    {
      $self->_end_enumerated_list;

      $logger->trace("{$number} ..... new sub bullet list");

      my $count = $library->get_bullet_list_count;

      my $list = SML::BulletList->new
	(
	 id                 => "BULLET_LIST-$count",
	 leading_whitespace => $whitespace,
	 library            => $library,
	);

      $self->_begin_division($list);
      $self->_push_list_stack($list);

      $logger->trace("{$number} ..... new sub bullet item");

      my $item = SML::ListItem->new
	(
	 name               => 'BULLET_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  # CASE 6: resume previous higher level bullet list
  #
  # elsif
  # (
  #   (
  #     currently in bullet list
  #     or
  #     currently in enumerated list
  #   )
  #   and
  #   (
  #     indent is less than current list level indent
  #     and
  #     previous list at indent level is bullet list
  #   )
  # )
  # {
  #   End one or more sub-lists (and pop off list stack)
  #   Create new bullet
  #   Add new bullet to (now) current bullet list
  # }

  elsif
    (
     (
      $self->_in_bullet_list
      or
      $self->_in_enumerated_list
     )
     and
     (
      $indent < $self->_get_current_list_indent
      and
      $self->_has_bullet_list_at_indent($indent)
     )
    )
    {
      until
	(
	 $indent == $self->_get_current_list_indent
	)
	{
	  if ( $self->_in_bullet_list )
	    {
	      $logger->trace("{$number} ..... end bullet list");

	      $self->_end_bullet_list;
	    }

	  elsif ( $self->_in_enumerated_list )
	    {
	      $logger->trace("{$number} ..... end enumerated list");

	      $self->_end_enumerated_list;
	    }

	  else
	    {
	      my $msg = "THIS SHOULD NEVER HAPPEN";
	      $self->_handle_error('fatal',$msg);
	    }
	}

      $logger->trace("{$number} ..... new bullet item");

      my $item = SML::ListItem->new
	(
	 name               => 'BULLET_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  # CASE 7: new bull list at same level as a previous enum list
  #
  # elsif
  # (
  #   (
  #     currently in bullet list
  #     or
  #     currently in enumerated list
  #   )
  #   and
  #   (
  #     indent is less than current list level indent
  #     and
  #     list at indent level is enumerated list
  #   )
  # )
  # {
  #   End one or more sub-lists (and pop off list stack)
  #   Start a new bullet list
  #   Push new bullet list on list stack
  #   Create new bullet
  #   Add new bullet to current bullet list
  # }

  elsif
    (
     (
      $self->_in_bullet_list
      or
      $self->_in_enumerated_list
     )
     and
     (
      $indent < $self->_get_current_list_indent
      and
      $self->_get_current_list->isa('SML::EnumeratedList')
     )
    )
    {
      until
	(
	 $indent == $self->_get_current_list_indent
	)
	{
	  $logger->trace("{$number} ..... end previous list");

	  if ( $self->_in_bullet_list )
	    {
	      $logger->trace("{$number} ..... end bullet list");

	      $self->_end_bullet_list;
	    }

	  elsif ( $self->_in_enumerated_list )
	    {
	      $logger->trace("{$number} ..... end enumerated list");

	      $self->_end_enumerated_list;
	    }

	  else
	    {
	      my $msg = "THIS SHOULD NEVER HAPPEN";
	      $self->_handle_error('fatal',$msg);
	    }
	}

      $logger->trace("{$number} ..... new bullet list");

      my $count = $library->get_bullet_list_count;

      my $list = SML::BulletList->new
	(
	 id                 => "BULLET_LIST-$count",
	 leading_whitespace => $whitespace,
	 library            => $library,
	);

      $self->_begin_division($list);
      $self->_push_list_stack($list);

      $logger->trace("{$number} ..... new bullet item");

      my $item = SML::ListItem->new
	(
	 name               => 'BULLET_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  # CASE 8: new bullet sub list
  #
  # elsif
  # (
  #   (
  #     currently in bullet list
  #     or
  #     currently in enumerated list
  #   )
  #   and
  #   indent is greater than current list level indent
  # )
  # {
  #   Start a new bullet list
  #   Push new bullet list on list stack
  #   Create new bullet
  #   Add new bullet to new bullet list
  # }

  elsif
    (
     (
      $self->_in_bullet_list
      or
      $self->_in_enumerated_list
     )
     and
     $indent > $self->_get_current_list_indent
    )
    {
      $logger->trace("{$number} ..... new bullet list");

      my $count = $library->get_bullet_list_count;

      my $list = SML::BulletList->new
	(
	 id                 => "BULLET_LIST-$count",
	 leading_whitespace => $whitespace,
	 library            => $library,
	);

      $self->_begin_division($list);
      $self->_push_list_stack($list);

      $logger->trace("{$number} ..... new bullet item");

      my $item = SML::ListItem->new
	(
	 name               => 'BULLET_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  else
    {
      my $msg = "THIS SHOULD NEVER HAPPEN";
      my $location = $line->get_location;
      $self->_handle_error('fatal',$msg,$location);
    }

  return 1;
}

######################################################################

sub _process_start_step_element {

  my $self = shift;
  my $line = shift;

  my $library = $self->_get_library;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- step");

  if ( $self->_in_preformatted_division )
    {
      my $block = SML::PreformattedBlock->new(library=>$library);
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  else
    {
      $self->_end_all_lists       if $self->_in_bullet_list;
      $self->_end_all_lists       if $self->_in_enumerated_list;
      $self->_end_definition_list if $self->_in_definition_list;

      if ( not $self->_in_step_list )
	{
	  my $count = $library->get_step_list_count;

	  my $list = SML::Structure->new
	    (
	     name    => 'STEP_LIST',
	     id      => "STEP_LIST-$count",
	     library => $library,
	    );

	  $self->_set_step_count(1);
	  $self->_begin_division($list);
	}

      $logger->trace("{$number} ..... begin step element");

      my $step = SML::Step->new
	(
	 number  => $self->_get_step_count,
	 library => $library,
	);

      $self->_set_step_count( $self->_get_step_count + 1 );
      $step->add_line($line);
      $self->_begin_block($step);

      my $division = $self->_get_current_division;
      $division->add_part($step);
    }

  return 1;
}

######################################################################

sub _process_start_image_element {

  my $self = shift;
  my $line = shift;
  my $name = shift;

  my $library = $self->_get_library;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- image");

  if ( $self->_in_preformatted_division )
    {
      my $block = SML::PreformattedBlock->new
	(
	 library => $library,
	);

      $block->add_line($line);
      $self->_begin_block($block);

      my $division = $self->_get_current_division;
      $division->add_part($block);
    }

  else
    {
      $logger->trace("{$number} ..... begin image element");

      my $image = SML::Image->new
	(
	 name    => $name,
	 library => $library,
	);

      $image->add_line($line);
      $self->_begin_block($image);

      my $division = $self->_get_current_division;
      $division->add_part($image);
    }

  return 1;
}

######################################################################

sub _process_end_step_element {

  my $self    = shift;
  my $element = shift;                  # step element

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $element->get_content;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ..... end step element");

  if ( $text =~ /$syntax->{step_element}/ )
    {
      # $1 = element name (always 'step')
      # $2 = element args
      # $3 = element value (step description)
      $element->set_value($3);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN STEP";
      my $location = $element->get_location;
      $self->_handle_error('error',$msg,$location);
    }
}

######################################################################

sub _process_start_attr_definition {

  my $self = shift;
  my $line = shift;

  my $number = $self->_get_number;

  $logger->trace("{$number} ----- element (ATTR DEFINITION)");

  my $definition = SML::Definition->new
    (
     name      => 'attr',
     library   => $self->_get_library,
    );

  $definition->add_line($line);

  $self->_begin_block($definition);

  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;
  $self->_end_baretable       if $self->_in_baretable;

  my $division = $self->_get_current_division;

  $division->add_part($definition);

  return 1;
}

######################################################################

sub _process_end_attr_definition {

  my $self       = shift;
  my $definition = shift;               # attr definition

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $definition->get_content;

  if ( $text =~ /$syntax->{attr_element}/ )
    {
      # $1 = element name   (always 'attr')
      # $2 = element args
      # $3 = element value  (term {namespace} = definition)
      # $4 = variable name  (term)
      # $5
      # $6 = namespace      (OPTIONAL)
      # $7 = variable value (definition)
      $definition->set_value($3);
      $definition->set_term($4);
      $definition->set_namespace($6);
      $definition->set_definition($7);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN ATTR";
      my $location = $definition->get_location;
      $self->_handle_error('error',$msg,$location);
    }

  # add attr to library?

  my $division = $self->_get_current_division;
  $division->add_attribute($definition);

  return 1;
}

######################################################################

sub _process_start_outcome {

  my $self = shift;
  my $line = shift;

  my $library = $self->_get_library;

  my $outcome = SML::Outcome->new
    (
     name    => 'outcome',
     library => $library,
    );

  my $number = $self->_get_number;

  $logger->trace("{$number} ----- element (outcome)");

  $outcome->add_line($line);
  $self->_begin_block($outcome);

  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;
  $self->_end_baretable       if $self->_in_baretable;
  $self->_end_table           if $self->_in_table;

  my $division = $self->_get_current_division;

  $division->add_part($outcome);

  return 1;
}

######################################################################

sub _process_end_outcome {

  my $self    = shift;
  my $outcome = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $outcome->get_content;

  if ( $text =~ /$syntax->{outcome_element}/ )
    {
      # $1 = element name (always 'outcome')
      # $2 = date         (yyyy-mm-dd)
      # $3 = entity ID
      # $4 = status color (green, yellow, red, grey)
      # $5 = outcome description

      my $date        = $2;
      my $entity_id   = $3;
      my $status      = $4;
      my $description = $5;

      $outcome->set_date($date);
      $outcome->set_entity_id($entity_id);
      $outcome->set_status($status);
      $outcome->set_description($description);

      $library->add_outcome($outcome);

      my $outcome_value = "$date $status - $description";
      $library->add_property_value($entity_id,'outcome',$outcome_value,$outcome);

      my $reasoner = $library->get_reasoner;
      $reasoner->infer_status_from_outcome($outcome);

      return 1;
    }

  else
    {
      my $msg = "SYNTAX ERROR IN OUTCOME";
      my $location = $outcome->get_location;
      $self->_handle_error('error',$msg,$location);

      return 0;
    }
}

######################################################################

sub _process_start_review {

  my $self = shift;
  my $line = shift;

  my $library = $self->_get_library;

  my $review = SML::Outcome->new
    (
     name    => 'review',
     library => $library,
    );

  my $number = $self->_get_number;

  $logger->trace("{$number} ----- element (review)");

  $review->add_line($line);
  $self->_begin_block($review);

  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;
  $self->_end_baretable       if $self->_in_baretable;
  $self->_end_table           if $self->_in_table;

  my $division = $self->_get_current_division;

  $division->add_part($review);

  return 1;
}

######################################################################

sub _process_end_review {

  my $self    = shift;
  my $review = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $review->get_content;

  if ( $text =~ /$syntax->{review_element}/ )
    {
      # $1 = element name (always 'review')
      # $2 = date         (yyyy-mm-dd)
      # $3 = entity ID
      # $4 = status color (green, yellow, red, grey)
      # $5 = review description

      my $date        = $2;
      my $entity_id   = $3;
      my $status      = $4;
      my $description = $5;

      $review->set_date($date);
      $review->set_entity_id($entity_id);
      $review->set_status($status);
      $review->set_description($description);

      $library->add_review($review);

      my $review_value = "$date $status - $description";
      $library->add_property_value($entity_id,'review',$review_value,$review);

      return 1;
    }

  else
    {
      my $msg = "SYNTAX ERROR IN REVIEW";
      my $location = $review->get_location;
      $self->_handle_error('error',$msg,$location);

      return 0;
    }
}

######################################################################

sub _process_end_index_element {

  my $self    = shift;
  my $element = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $element->get_content;

  if ( $text =~ /$syntax->{index_element}/ )
    {
      # $1 = element name  (always 'index')
      # $2
      # $3 = element arg   ('begin' or 'end')
      # $4 = element value (index term)
      $element->set_value($4);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN INDEX ELEMENT";
      my $location = $element->get_location;
      $self->_handle_error('error',$msg,$location);
    }

  return 1;
}

######################################################################

sub _process_end_use_formal_status_element {

  my $self    = shift;
  my $element = shift;

  my $value   = $element->get_value;
  my $library = $self->_get_library;
  my $util    = $library->get_util;
  my $options = $util->get_options;

  $options->set_use_formal_status($value);

  return 1;
}

######################################################################

sub _process_enum_list_item {

  my $self       = shift;
  my $line       = shift;
  my $whitespace = shift;

  my $indent  = length($whitespace);
  my $library = $self->_get_library;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- enumerated list item (indent=$indent)");

  # What are all the possible actions the parser may need to take upon
  # encountering an enumerated list item line?

  # CASE 1: preformatted enumerated item
  #
  # if
  # (
  #   in pre-formatted division
  #   or
  #   (
  #     line is indented
  #     and
  #     (
  #       NOT currently in bullet list
  #       and
  #       NOT currently in enumerated list
  #     )
  #   )
  # )
  # {
  #   Create new preformatted block
  #   Add new preformatted block to current division
  # }

  if
    (
     $self->_in_preformatted_division
     or
     (
      $indent > 0
      and
      (
       not $self->_in_bullet_list
       and
       not $self->_in_enumerated_list
      )
     )
    )
    {
      if ( $self->_in_preformatted_block )
	{
	  $logger->trace("{$number} ..... continue preformatted block");

	  my $block = $self->_get_block;
	  $block->add_line($line);
	}

      else
	{
	  my $block = SML::PreformattedBlock->new(library=>$library);
	  $block->add_line($line);
	  $self->_begin_block($block);

	  my $division = $self->_get_current_division;
	  $division->add_part($block);
	}
    }

  # CASE 2: fatal improper enumerated item indent
  #
  # elsif
  # (
  #   (
  #     currently in bullet list
  #     or
  #     currently in enumerated list
  #   )
  #   and
  #   (
  #     indent is less than current list level indent
  #     and
  #     no list exists at indent level
  #   )
  # )
  # {
  #   FATAL: improper indent at location
  # }

  elsif
    (
     (
      $self->_in_bullet_list
      or
      $self->_in_enumerated_list
     )
     and
     (
      $indent < $self->_get_current_list_indent
      and
      not $self->_has_list_at_indent($indent)
     )
    )
    {
      my $msg = "IMPROPER ENUMERATED ITEM INDENT $indent";
      my $location = $line->get_location;
      $self->_handle_error('fatal',$msg,$location);
    }

  # CASE 3: new toplevel enumerated item
  #
  # elsif
  # (
  #   line is not indented
  #   and
  #   NOT currently in enumerated list
  # )
  # {
  #   End bullet list if in bullet list
  #   End step list if in step list
  #   End definition list if in definition list
  #   Create new enumerated list
  #   Push new enumerated list on list stack
  #   Create new enumerated item
  #   Add new enumerated item to new enumerated list
  # }

  elsif
    (
     $indent == 0
     and
     not $self->_in_enumerated_list
    )
    {
      $self->_end_all_lists       if $self->_in_bullet_list;
      $self->_end_definition_list if $self->_in_definition_list;

      my $count = $library->get_enumerated_list_count;

      my $list = SML::EnumeratedList->new
	(
	 id                 => "ENUMERATED_LIST-$count",
	 leading_whitespace => $whitespace,
	 library            => $library,
	);

      $self->_begin_division($list);
      $self->_push_list_stack($list);

      my $item = SML::ListItem->new
	(
	 name               => 'ENUM_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  # CASE 4: new enumerated item at same indent as previous
  #
  # elsif
  # (
  #   currently in an enumerated list
  #   and
  #   indent is equal to current list level indent
  # )
  # {
  #   Create new enumerated item
  #   Add new enumerated item to current enumerated list
  # }
  #

  elsif
    (
     $self->_in_enumerated_list
     and
     $indent == $self->_get_current_list_indent
    )
    {
      my $item = SML::ListItem->new
	(
	 name               => 'ENUM_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  # CASE 5: new enumerated sub list
  #
  # elsif
  # (
  #   currently in a bullet list
  #   and
  #   indent is equal to current list level indent
  # )
  # {
  #   End bullet list
  #   Start a new enumerated list
  #   Push new enumerated list on list stack
  #   Create new enumerated item
  #   Add new enumerated item to current enumerated list
  # }
  #

  elsif
    (
     $self->_in_bullet_list
     and
     $indent == $self->_get_current_list_indent
    )
    {
      $self->_end_bullet_list;

      my $count = $library->get_enumerated_list_count;

      my $list = SML::EnumeratedList->new
	(
	 id                 => "ENUMERATED_LIST-$count",
	 leading_whitespace => $whitespace,
	 library            => $library,
	);

      $self->_begin_division($list);
      $self->_push_list_stack($list);

      my $item = SML::ListItem->new
	(
	 name               => 'ENUM_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  # CASE 6: resume previous higher level enumerated list
  #
  # elsif
  # (
  #   (
  #     currently in bullet list
  #     or
  #     currently in enumerated list
  #   )
  #   and
  #   (
  #     indent is less than current list level indent
  #     and
  #     previous list at indent level is enumerated list
  #   )
  # )
  # {
  #   End one or more sub-lists (and pop off list stack)
  #   Create new enumerated item
  #   Add new enumerated item to (now) current enumerated list
  # }

  elsif
    (
     (
      $self->_in_bullet_list
      or
      $self->_in_enumerated_list
     )
     and
     (
      $indent < $self->_get_current_list_indent
      and
      $self->_has_enumerated_list_at_indent($indent)
     )
    )
    {
      until
	(
	 $indent == $self->_get_current_list_indent
	)
	{
	  if ( $self->_in_bullet_list )
	    {
	      $self->_end_bullet_list;
	    }

	  elsif ( $self->_in_enumerated_list )
	    {
	      $self->_end_enumerated_list;
	    }

	  else
	    {
	      my $msg = "THIS SHOULD NEVER HAPPEN";
	      $self->_handle_error('fatal',$msg);
	    }
	}

      my $item = SML::ListItem->new
	(
	 name               => 'ENUM_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  # CASE 7: new enum list at same level as a previous bull list
  #
  # elsif
  # (
  #   (
  #     currently in bullet list
  #     or
  #     currently in enumerated list
  #   )
  #   and
  #   (
  #     indent is less than current list level indent
  #     and
  #     list at indent level is bullet list
  #   )
  # )
  # {
  #   End one or more sub-lists (and pop off list stack)
  #   Start a new enumerated list
  #   Push new enumerated list on list stack
  #   Create new enumerated item
  #   Add new enumerated item to current enumerated list
  # }

  elsif
    (
     (
      $self->_in_bullet_list
      or
      $self->_in_enumerated_list
     )
     and
     (
      $indent < $self->_get_current_list_indent
      and
      $self->_get_current_list->isa('SML::BulletList')
     )
    )
    {
      until
	(
	 $indent == $self->_get_current_list_indent
	)
	{
	  if ( $self->_in_bullet_list )
	    {
	      $self->_end_bullet_list;
	    }

	  elsif ( $self->_in_enumerated_list )
	    {
	      $self->_end_enumerated_list;
	    }

	  else
	    {
	      my $msg = "THIS SHOULD NEVER HAPPEN";
	      $self->_handle_error('fatal',$msg);
	    }
	}

      my $count = $library->get_enumerated_list_count;

      my $list = SML::EnumeratedList->new
	(
	 id                 => "ENUMERATED_LIST-$count",
	 leading_whitespace => $whitespace,
	 library            => $library,
	);

      $self->_begin_division($list);
      $self->_push_list_stack($list);

      my $item = SML::ListItem->new
	(
	 name               => 'ENUM_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  # CASE 8: new enumerated sub list
  #
  # elsif
  # (
  #   (
  #     currently in bullet list
  #     or
  #     currently in enumerated list
  #   )
  #   and
  #   indent is greater than current list level indent
  # )
  # {
  #   Start a new enumerated list
  #   Push new enumerated list on list stack
  #   Create new enumerated item
  #   Add new enumerated item to new enumerated list
  # }

  elsif
    (
     (
      $self->_in_bullet_list
      or
      $self->_in_enumerated_list
     )
     and
     $indent > $self->_get_current_list_indent
    )
    {
      my $count = $library->get_enumerated_list_count;

      my $list = SML::EnumeratedList->new
	(
	 id                 => "ENUMERATED_LIST-$count",
	 leading_whitespace => $whitespace,
	 library            => $library,
	);

      $self->_begin_division($list);
      $self->_push_list_stack($list);

      my $item = SML::ListItem->new
	(
	 name               => 'ENUM_LIST_ITEM',
	 library            => $library,
	 leading_whitespace => $whitespace,
	);

      $item->add_line($line);
      $self->_begin_block($item);

      my $division = $self->_get_current_division;
      $division->add_part($item);
    }

  # else
  # {
  #   This should never happen.
  # }

  else
    {
      my $msg = "THIS SHOULD NEVER HAPPEN";
      my $location = $line->get_location;
      $self->_handle_error('fatal',$msg,$location);
    }

  return 1;
}

######################################################################

sub _process_start_def_list_item {

  my $self = shift;
  my $line = shift;

  my $library = $self->_get_library;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- definition list item");

  if ( $self->_in_preformatted_division )
    {
      my $block = SML::PreformattedBlock->new(library=>$library);
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  else
    {
      $self->_end_all_lists if $self->_in_bullet_list;
      $self->_end_all_lists if $self->_in_enumerated_list;

      if ( not $self->_in_definition_list )
	{
	  my $count = $library->get_definition_list_count;

	  my $list = SML::Structure->new
	    (
	     name    => 'DEFINITION_LIST',
	     id      => "DEFINITION_LIST-$count",
	     library => $library,
	    );

	  $self->_begin_division($list);
	}

      my $block = SML::DefinitionListItem->new(library=>$library);
      $block->add_line($line);
      $self->_begin_block($block);

      my $division = $self->_get_current_division;
      $division->add_part($block);
    }

  return 1;
}

######################################################################

sub _process_end_bullet_list_item {

  my $self = shift;
  my $item = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $item->get_content;

  if ( $text =~ /$syntax->{bull_list_item}/ )
    {
      # $1 = leading whitespace
      # $2 = value
      $item->set_value($2);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN BULLET LIST ITEM";
      my $location = $item->get_location;
      $self->_handle_error('error',$msg,$location);
    }

  return 1;
}

######################################################################

sub _process_end_enum_list_item {

  my $self = shift;
  my $item = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $item->get_content;

  if ( $text =~ /$syntax->{enum_list_item}/ )
    {
      # $1 = leading whitespace
      # $2 = value
      $item->set_value($2);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN ENUMERATED LIST ITEM";
      my $location = $item->get_location;
      $self->_handle_error('error',$msg,$location);
    }

  return 1;
}

######################################################################

sub _process_end_def_list_item {

  my $self = shift;
  my $item = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $item->get_content;

  if ( $text =~ /$syntax->{def_list_item}/ )
    {
      # $1 = term
      # $2 = definition
      $item->set_term($1);
      $item->set_definition($2);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN DEFINITION LIST ITEM";
      my $location = $item->get_location;
      $self->_handle_error('error',$msg,$location);
    }

  return 1;
}

######################################################################

sub _process_start_table_cell {

  my $self       = shift;
  my $line       = shift;
  my $emphasis   = shift;
  my $attributes = shift || q{};

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $line->get_content;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- table cell");

  $self->_end_all_lists       if $self->_in_bullet_list;
  $self->_end_all_lists       if $self->_in_enumerated_list;
  $self->_end_definition_list if $self->_in_definition_list;

  my $color;
  my $justification;
  my $fontsize;

  if ( $attributes =~ /$syntax->{valid_background_color}/ )
    {
      $color = '#ff6666' if $1 eq 'red';
      $color = '#ffff66' if $1 eq 'yellow';
      $color = '#4488ff' if $1 eq 'blue';
      $color = '#66ff66' if $1 eq 'green';
      $color = '#ffaa66' if $1 eq 'orange';
      $color = '#ff66ff' if $1 eq 'purple';
      $color = '#ffffff' if $1 eq 'white';
      $color = '#eeeeee' if $1 eq 'litegrey';
      $color = '#dddddd' if $1 eq 'grey';
      $color = '#cccccc' if $1 eq 'darkgrey';

      $color = $1 if not $color;
    }

  if ( $attributes =~ /$syntax->{valid_horizontal_justification} / )
    {
      $justification = $1;
    }

  if ( $attributes =~ /$syntax->{valid_fontsize}/ )
    {
      $fontsize = $1;
    }

  if ( not $self->_in_table and not $self->_in_baretable )
    {
      # new BARE_TABLE
      my $tnum = $self->_count_baretables + 1;
      my $tid  = "BARE_TABLE-$tnum";

      my $baretable = SML::Structure->new
	(
	 name    => 'BARE_TABLE',
	 id      => $tid,
	 library => $library,
	);

      $self->_begin_division($baretable);

      # new BARE_TABLE_ROW
      my $rnum = $self->_count_table_rows + 1;
      my $rid  = "BARE_TABLE_ROW-$tnum-$rnum";

      my $tablerow = SML::TableRow->new
	(
	 id      => $rid,
	 library => $library,
	);

      $self->_begin_division($tablerow);

      # new BARE_TABLE_CELL
      my $cnum = $self->_count_table_cells + 1;
      my $cid  = "BARE_TABLE_CELL-$tnum-$rnum-$cnum";
      my $args = {};

      $args->{id}       = $cid;
      $args->{library}  = $library;
      $args->{emphasis} = $emphasis              if $emphasis;
      $args->{background_color} = $color         if $color;
      $args->{justification}    = $justification if $justification;
      $args->{fontsize}         = $fontsize      if $fontsize;

      my $tablecell = SML::TableCell->new(%{$args});

      $self->_begin_division($tablecell);

      if ( $text =~ /$syntax->{table_cell}/ and $3 )
	{
	  my $paragraph = SML::Paragraph->new
	    (
	     name    => 'paragraph',
	     library => $library,
	    );

	  $paragraph->add_line($line);
	  $self->_begin_block($paragraph);
	  $tablecell->add_part($paragraph);
	}
    }

  elsif ( $self->_in_baretable and not $self->_in_table_row )
    {
      # new BARE_TABLE_ROW
      my $tnum = $self->_count_baretables;
      my $rnum = $self->_count_table_rows + 1;
      my $rid  = "BARE_TABLE_ROW-$tnum-$rnum";

      my $tablerow = SML::TableRow->new
	(
	 id      => $rid,
	 library => $library,
	);

      $self->_begin_division($tablerow);

      # new BARE_TABLE_CELL
      my $cnum = $self->_count_table_cells + 1;
      my $cid  = "BARE_TABLE_CELL-$tnum-$rnum-$cnum";
      my $args = {};

      $args->{id}       = $cid;
      $args->{library}  = $library;
      $args->{emphasis} = $emphasis if $emphasis;
      $args->{background_color} = $color         if $color;
      $args->{justification}    = $justification if $justification;
      $args->{fontsize}         = $fontsize      if $fontsize;

      my $tablecell = SML::TableCell->new(%{$args});

      $self->_begin_division($tablecell);

      if ( $text =~ /$syntax->{table_cell}/ and $3 )
	{
	  my $paragraph = SML::Paragraph->new
	    (
	     name    => 'paragraph',
	     library => $library,
	    );

	  $paragraph->add_line($line);
	  $self->_begin_block($paragraph);
	  $tablecell->add_part($paragraph);
	}
    }

  elsif ( $self->_in_table and not $self->_in_table_row	)
    {
      # new TABLE_ROW
      my $tnum = $self->_count_tables;
      my $rnum = $self->_count_table_rows + 1;
      my $rid  = "TABLE_ROW-$tnum-$rnum";

      my $tablerow = SML::TableRow->new
	(
	 id      => $rid,
	 library => $library,
	);

      $self->_begin_division($tablerow);

      # new TABLE_CELL
      my $cnum = $self->_count_table_cells + 1;
      my $cid  = "TABLE_CELL-$tnum-$rnum-$cnum";
      my $args = {};

      $args->{id}       = $cid;
      $args->{library}  = $library;
      $args->{emphasis} = $emphasis if $emphasis;
      $args->{background_color} = $color         if $color;
      $args->{justification}    = $justification if $justification;
      $args->{fontsize}         = $fontsize      if $fontsize;

      my $tablecell = SML::TableCell->new(%{$args});

      $self->_begin_division($tablecell);

      if ( $text =~ /$syntax->{table_cell}/ and $3 )
	{
	  my $paragraph = SML::Paragraph->new
	    (
	     name    => 'paragraph',
	     library => $library,
	    );

	  $paragraph->add_line($line);
	  $self->_begin_block($paragraph);
	  $tablecell->add_part($paragraph);
	}
    }

  elsif ( $self->_in_baretable )
    {
      # end previous TABLE_CELL
      $self->_end_division;

      # new TABLE_CELL
      my $tnum = $self->_count_baretables;
      my $rnum = $self->_count_table_rows;
      my $cnum = $self->_count_table_cells + 1;
      my $cid  = "BARE_TABLE_CELL-$tnum-$rnum-$cnum";
      my $args = {};

      $args->{id}       = $cid;
      $args->{library}  = $library;
      $args->{emphasis} = $emphasis if $emphasis;
      $args->{background_color} = $color         if $color;
      $args->{justification}    = $justification if $justification;
      $args->{fontsize}         = $fontsize      if $fontsize;

      my $tablecell = SML::TableCell->new(%{$args});

      $self->_begin_division($tablecell);

      if ( $text =~ /$syntax->{table_cell}/ and $3 )
	{
	  my $paragraph = SML::Paragraph->new
	    (
	     name    => 'paragraph',
	     library => $library,
	    );

	  $paragraph->add_line($line);
	  $self->_begin_block($paragraph);
	  $tablecell->add_part($paragraph);
	}
    }

  elsif ( $self->_in_table )
    {
      # end previous TABLE_CELL
      $self->_end_division;

      # new TABLE_CELL
      my $tnum = $self->_count_tables;
      my $rnum = $self->_count_table_rows;
      my $cnum = $self->_count_table_cells + 1;
      my $cid  = "TABLE_CELL-$tnum-$rnum-$cnum";
      my $args = {};

      $args->{id}       = $cid;
      $args->{library}  = $library;
      $args->{emphasis} = $emphasis if $emphasis;
      $args->{background_color} = $color         if $color;
      $args->{justification}    = $justification if $justification;
      $args->{fontsize}         = $fontsize      if $fontsize;

      my $tablecell = SML::TableCell->new(%{$args});

      $self->_begin_division($tablecell);

      if ( $text =~ /$syntax->{table_cell}/ and $3 )
	{
	  my $paragraph = SML::Paragraph->new
	    (
	     name    => 'paragraph',
	     library => $library,
	    );

	  $paragraph->add_line($line);
	  $self->_begin_block($paragraph);
	  $tablecell->add_part($paragraph);
	}
    }

  else
    {
      my $msg = "UNEXPECTED TABLE CELL";
      my $location = $line->get_location;
      $self->_handle_error('fatal',$msg,$location);
    }

  return 1;
}

######################################################################

sub _process_paragraph_text {

  my $self = shift;
  my $line = shift;

  my $library = $self->_get_library;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- paragraph text");

  if ( $self->_in_paragraph )
    {
      $logger->trace("{$number} ..... continue paragraph");
      $self->_get_block->add_line($line);
    }

  elsif ( $self->_in_element )
    {
      $logger->trace("{$number} ..... continue element");

      my $block = $self->_get_block;
      $block->add_line($line);
    }

  elsif ( $self->_in_preformatted_division )
    {
      if ( $self->_has_block )
	{
	  $logger->trace("{$number} ..... continue preformatted block");

	  my $block = $self->_get_block;
	  $block->add_line($line);
	}

      else
	{
	  $logger->trace("{$number} ..... new preformatted block");

	  my $block = SML::PreformattedBlock->new(library=>$library);
	  $block->add_line($line);
	  $self->_begin_block($block);
	  $self->_get_current_division->add_part($block);
	}
    }

  elsif ( $self->_in_table_cell )
    {
      $logger->trace("{$number} ..... adding to block in table cell");
      my $block = $self->_get_block;

      if ($block)
	{
	  $block->add_line( $line );
	}

      else
	{
	  my $msg = "CAN'T PROCESS PARAGRAPH TEXT, CAN'T ADD LINE TO BLOCK";
	  my $location = $line->get_location;
	  $self->_handle_error('warn',$msg,$location);
	}
    }

  elsif ( $self->_in_listitem )
    {
      $logger->trace("{$number} ..... adding to block in list item");

      my $block = $self->_get_block;
      $block->add_line( $line );
    }

  else
    {
      $logger->trace("{$number} ..... new paragraph");

      $self->_end_all_lists       if $self->_in_bullet_list;
      $self->_end_all_lists       if $self->_in_enumerated_list;
      $self->_end_definition_list if $self->_in_definition_list;
      $self->_end_baretable       if $self->_in_baretable;

      my $paragraph = SML::Paragraph->new(library=>$library);
      $paragraph->add_line($line);
      $self->_begin_block($paragraph);

      my $division = $self->_get_current_division;

      if ( $division )
	{
	  $division->add_part($paragraph);
	}

      else
	{
	  my $msg = "CAN'T ADD NEW PARAGRAPH, NO CURRENT DIVISION";
	  my $location = $line->get_location;
	  $self->_handle_error('error',$msg,$location);
	  return 0;
	}
    }

  return 1;
}

######################################################################

sub _process_end_date_element {

  my $self    = shift;
  my $element = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $element->get_content;

  if ( $text =~ /$syntax->{svn_date_field}/ )
    {
      # $1 = value           (2013-07-07 11:42:01 -0600 (Sun, 07 Jul 2013))
      # $2 = date            (2013-07-07)
      # $3 = time            (11:42:01)
      # $4 = timezone offset (-0600)
      # $5 = daydate         (Sun, 07 Jul 2013)
      $element->set_value($5);
    }

  elsif ( $text =~ /$syntax->{element}/ )
    {
      # $3 = element value
      $element->set_value($3);
    }

  else
    {
      $element->set_value($text);
    }

  return 1;
}

######################################################################

sub _process_end_author_element {

  my $self    = shift;
  my $element = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $element->get_content;

  if ( $text =~ /$syntax->{svn_author_field}/ )
    {
      # $1 = value (i.e. don.johnson)
      $element->set_value($1);
    }

  elsif ( $text =~ /$syntax->{element}/ )
    {
      # $3 = element value
      $element->set_value($3);
    }

  else
    {
      $element->set_value($text);
    }

  return 1;
}

######################################################################

sub _process_end_revision_element {

  my $self    = shift;
  my $element = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $element->get_content;

  if ( $text =~ /$syntax->{svn_revision_field}/ )
    {
      # $1 = value
      $element->set_value($1);
    }

  elsif ( $text =~ /$syntax->{element}/ )
    {
      # $3 = element value
      $element->set_value($3);
    }

  else
    {
      $element->set_value($text);
    }

  return 1;
}

######################################################################

sub _process_end_paragraph {

  my $self = shift;
  my $item = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $item->get_content;

  if ( $text =~ /$syntax->{paragraph_text}/ )
    {
      # $1 = leading colon(s) (begin table cell)
      # $2 = paragraph text
      $item->set_value($2);
    }

  else
    {
      my $msg = "SYNTAX ERROR IN PARAGRAPH";
      my $location = $item->get_location;
      $self->_handle_error('error',$msg,$location);
    }

  return 1;
}

######################################################################

sub _process_indented_text {

  my $self = shift;
  my $line = shift;

  my $library = $self->_get_library;
  my $number  = $self->_get_number;

  $logger->trace("{$number} ----- indented text");

  if ( $self->_in_preformatted_block )
    {
      $logger->trace("{$number} ..... continue preformatted block");

      my $block = $self->_get_block;

      $block->add_line($line);
    }

  elsif ( $self->_in_listitem )
    {
      $logger->trace("{$number} ..... continue list item");

      my $block = $self->_get_block;

      $block->add_line($line);
    }

  else
    {
      $logger->trace("{$number} ..... new preformatted block");

      my $block = SML::PreformattedBlock->new(library=>$library);
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

  my $library       = $self->_get_library;
  my $location      = $line->get_location;
  my $number        = $self->_get_number;
  my $division      = $self->_get_current_division;
  my $division_name = $division->get_name;

  $logger->trace("{$number} ----- non-blank line");

  if (
      $division_name eq 'BARE_TABLE'
      and
      $self->_get_column == 0
     )
    {
      $self->_end_division;
    }

  if ( not $self->_get_block )
    {
      my $block = SML::PreformattedBlock->new(library=>$library);
      $block->add_line($line);
      $self->_begin_block($block);
      $self->environment->add_part($block);
    }

  elsif ( not $self->_get_block )
    {
      my $msg = "UNRECOGNIZED BLOCK";
      $self->_handle_error('fatal',$msg,$location);
    }

  else
    {
      $logger->trace("{$number} ..... add non-blank line to block");
      $self->_get_block->add_line($line);
    }

  return 1;
}

######################################################################

sub _push_container_stack {

  my $self = shift;
  my $part = shift;

  push @{ $self->_get_container_stack }, $part;

  return 1;
}

######################################################################

sub _pop_container_stack {

  my $self = shift;

  return pop @{ $self->_get_container_stack };
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

  return pop @{ $self->_get_division_stack };
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

  my $block = $self->_get_block;

  if ( $block )
    {
      my $name = $block->get_name;

      if ( $name eq 'COMMENT_BLOCK' )
	{
	  return 1;
	}
    }

  return 0;
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

  unless ( ref $division )
    {
      return 0;
    }

  my $name = $division->get_name;

  if (
      $division->isa('SML::Listing')
      or
      $name eq 'PREFORMATTED'
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
      $self->_get_block->isa('SML::ListItem')
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

  if ( $division and $division->is_in_a('TABLE_CELL') )
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

  if ( $division->is_in_a('TABLE_ROW') )
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

  if ( ref $division and $division->is_in_a('BARE_TABLE') )
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

  if ( ref $division and $division->is_in_a('TABLE') )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub _in_step_list {

  my $self = shift;

  my $division = $self->_get_current_division;

  if (
      defined $division
      and
      $division->is_in_a('STEP_LIST')
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

sub _in_bullet_list {

  my $self = shift;

  my $division = $self->_get_current_division;

  if (
      defined $division
      and
      $division->isa('SML::BulletList')
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

sub _in_enumerated_list {

  my $self = shift;

  my $division = $self->_get_current_division;

  if (
      defined $division
      and
      $division->isa('SML::EnumeratedList')
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

sub _in_definition_list {

  my $self = shift;

  my $division = $self->_get_current_division;

  if (
      defined $division
      and
      $division->is_in_a('DEFINITION_LIST')
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

sub _in_comment_division {

  my $self = shift;

  my $division = $self->_get_current_division;

  if ( $division )
    {
      my $name = $division->get_name;

      if ( $name eq 'COMMENT' )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _in_conditional {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( ref $division )
    {
      my $name = $division->get_name;

      if ( $name eq 'CONDITIONAL' )
	{
	  return 1;
	}

      $division = $division->get_containing_division;
    }

  return 0;
}

######################################################################

sub _current_conditional {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( ref $division )
    {
      my $name = $division->get_name;

      if ( $name eq 'CONDITIONAL' )
	{
	  return $division;
	}

      $division = $division->get_containing_division;
    }

  return 0;
}

######################################################################

sub _count_comment_divisions {

  my $self = shift;

  my $count = 0;

  my $division      = $self->_get_division;
  my $division_list = $division->get_division_list;

  foreach my $division (@{ $division_list })
    {
      my $name = $division->get_name;

      if ( $name eq 'COMMENT' )
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

  unless ( ref $division )
    {
      return 0;
    }

  unless ( $division->is_in_a('TABLE') or $division->is_in_a('BARE_TABLE') )
    {
      return 0;
    }

  my $table = $self->_current_table;

  if ( ref $table )
    {
      my $count = 0;

      foreach my $part (@{ $table->get_division_list })
	{
	  my $part_name = $part->get_name;

	  if ( $part_name eq 'TABLE_ROW' )
	    {
	      ++ $count;
	    }
	}

      return $count;
    }

  return 0;
}

######################################################################

sub _count_table_cells {

  # Return the number of cells in the current table row.  Return 0 if
  # not currently in a table row.

  my $self = shift;

  my $division = $self->_get_current_division;

  if ( not $division->is_in_a('TABLE_ROW') )
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

  if ( ref $division )
    {
      my $division_name = $division->get_name;

      while ( ref $division )
	{
	  if (
	      $division_name eq 'TABLE'
	      or
	      $division_name eq 'BARE_TABLE'
	     )
	    {
	      return $division;
	    }

	  else
	    {
	      $division = $division->get_containing_division;
	    }
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

  my $division      = $self->_get_division;
  my $division_list = $division->get_division_list;

  foreach my $division (@{ $division_list })
    {
      my $name = $division->get_name;

      if ( $name eq 'CONDITIONAL' )
	{
	  ++ $count;
	}
    }

  return $count;
}

######################################################################

sub _count_divisions {

  my $self = shift;
  my $name = shift;                     # division name (i.e. COMMENT)

  my $division_counter = $self->_get_division_counter;

  my $division      = $self->_get_division;
  my $division_list = $division->get_division_list;

  return scalar @{ $division_list };
}

######################################################################

sub _get_division_count {

  my $self = shift;
  my $name = shift;                     # division name (i.d. COMMENT)

  my $counter = $self->_get_division_counter_hash;

  return $counter->{$name};
}

######################################################################

sub _count_tables {

  my $self = shift;

  my $count = 0;

  my $division      = $self->_get_division;
  my $division_list = $division->get_division_list;

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

  my $division          = $self->_get_division;
  my $sub_division_list = $division->get_division_list;

  foreach my $sub_division (@{ $sub_division_list })
    {
      my $sub_division_name = $sub_division->get_name;

      if ( $sub_division_name eq 'BARE_TABLE' )
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

  if ( $self->_has_division )
    {
      my $division      = $self->_get_division;
      my $division_list = $division->get_division_list;

      foreach my $division (@{ $division_list })
	{
	  if ( $division->isa('SML::Section') )
	    {
	      ++ $count;
	    }
	}
    }

  return $count;
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

sub _has_current_document {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( $division )
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

sub _get_current_document {

  my $self = shift;

  my $division = $self->_get_current_division;

  while ( $division )
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

sub _line_ends_data_segment {

  my $self = shift;
  my $text = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  if (
         $text =~ /$syntax->{segment_separator}/xms
      or $text =~ /$syntax->{start_division}/xms
      or $text =~ /$syntax->{start_section}/xms
      or $text =~ /$syntax->{generate_element}/xms
      or $text =~ /$syntax->{insert_element}/xms
      or $text =~ /$syntax->{template_element}/xms
      or $text =~ /$syntax->{include_element}/xms
      or $text =~ /$syntax->{script_element}/xms
      or $text =~ /$syntax->{outcome_element}/xms
      or $text =~ /$syntax->{review_element}/xms
      or $text =~ /$syntax->{index_element}/xms
      or $text =~ /$syntax->{glossary_element}/xms
      or $text =~ /$syntax->{list_item}/xms
      or
      (
       $text =~ /$syntax->{paragraph_text}/xms
       and
       not $text =~ /$syntax->{element}/xms
      )
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

sub _text_contains_substring {

  # Given a string, detect whether it contains ANY substring.

  my $self = shift;
  my $text = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  if ( $self->_is_single_string($text) )
    {
      return 0;
    }

  foreach my $string_type (@{ $self->_get_string_type_list })
    {
      if ( not exists $syntax->{$string_type} )
	{
	  my $msg = "THIS SHOULD NEVER HAPPEN $string_type";
	  $self->_handle_error('error',$msg);
	  return 0;
	}

      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _get_next_substring_type {

  # Given a string that is being gobbled up by the parser, detect the
  # NEXT substring in the string and return that substring's type.
  # Note that the string may contain several substrings.  This method
  # must return the string type of the FIRST (i.e. NEXT) substring in
  # the text.

  my $self = shift;
  my $text = shift;

  unless ( $text )
    {
      my $msg = "CAN'T GET NEXT SUBSTRING TYPE, MISSING ARGUMENT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $href    = {};                     # result hash

  foreach my $string_type (@{ $self->_get_string_type_list })
    {
      if ( not exists $syntax->{$string_type} )
	{
	  my $msg = "THIS SHOULD NEVER HAPPEN $string_type";
	  $self->_handle_error('error',$msg);
	  return 0;
	}

      if ( $text =~ /$syntax->{$string_type}/p )
	{
	  my $prematch_length = length(${^PREMATCH});
	  $href->{$prematch_length} = $string_type;
	}
    }

  if ( not keys %{$href} )
    {
      return 0;
    }

  else
    {
      my $list = [ sort {$a <=> $b} keys %{$href} ];
      my $next_substring_type = $list->[0];

      return $href->{$next_substring_type};
    }
}

######################################################################

sub _build_string_type_list {

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
     'sglquote_string',
     'dblquote_string',

     # substrings that form references
     'cross_ref',
     'lookup_ref',
     'title_ref',
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
     'section_symbol',
     # 'emdash_symbol',
     'thepage_ref',
     'theversion_ref',
     'therevision_ref',
     'thedate_ref',
     'pagecount_ref',
     'thesection_ref',
     'linebreak_symbol',
     'pagebreak_symbol',
     'clearpage_symbol',

     # substrings that represent special meaning
     'user_entered_text',
     'command_ref',
     'xml_tag',
     'literal',
     'email_addr',
    ];
}

######################################################################

sub _build_single_string_type_list {

  # Each symbol is an attribute in the syntax object.

  return
    [
     'keystroke_symbol',
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
     'section_symbol',
     # 'emdash_symbol',
     'thepage_ref',
     'theversion_ref',
     'therevision_ref',
     'thedate_ref',
     'pagecount_ref',
     'thesection_ref',
     'linebreak_symbol',
     'pagebreak_symbol',
     'clearpage_symbol',
     'literal',
     'email_addr',
    ];
}

######################################################################

sub _parse_block {

  # Parse a block into a list of strings.  This list of strings is the
  # block's 'part_list'.

  my $self  = shift;
  my $block = shift;

  unless ( ref $block and $block->isa('SML::Block') )
    {
      my $msg = "CAN'T PARSE NON-BLOCK $block";
      $self->_handle_error('error',$msg);
      return 0;
    }

  if ( $block->has_been_parsed )
    {
      return 0;
    }

  my $name = $block->get_name;

  $logger->trace("_parse_block $name");

  $self->_set_block($block);

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = q{};

  if ( $name eq 'COMMENT_BLOCK' or $name eq 'PREFORMATTED_BLOCK' )
    {
      $self->_clear_block;

      $block->set_has_been_parsed(1);

      return 1;
    }

  elsif
    (
     $name eq 'glossary'
     or
     $name eq 'acronym'
     or
     $name eq 'var'
     or
     $name eq 'attr'
     or
     $name eq 'DEFINITION_LIST_ITEM'
    )
    {
      my $term = $block->get_term;
      my $term_string = $self->_create_string($term);

      $block->add_part($term_string);
      $block->set_term_string($term_string);

      my $definition = $block->get_definition;
      my $definition_string = $self->_create_string($definition);

      $block->add_part($definition_string);
      $block->set_definition_string($definition_string);

      $self->_clear_block;

      $block->set_has_been_parsed(1);

      return 1;
    }

  elsif
    (
     $name eq 'BULLET_LIST_ITEM'
     or
     $name eq 'ENUM_LIST_ITEM'
     or
     $block->isa('SML::Element')
     or
     $block->isa('SML::Paragraph')
    )
    {
      $text = $block->get_value;
    }

  else
    {
      $text = $block->get_content;
    }

  if ( not $text )
    {
      $self->_clear_block;

      $block->set_has_been_parsed(1);

      return 0;
    }

  my $string = $self->_create_string($text);

  $block->add_part($string);

  $self->_clear_block;

  $block->set_has_been_parsed(1);

  return 1;
}

######################################################################

sub _parse_string_text {

  # Parse a string into a list of strings.  This list of strings is
  # the string's 'part_list'.

  my $self   = shift;
  my $string = shift;

  unless ( ref $string and $string->isa('SML::String') )
    {
      my $msg = "CAN'T PARSE NON-STRING $string";
      $self->_handle_error('error',$msg);
      return 0;
    }

  while ( $string->get_remaining )
    {
      $self->_parse_next_substring($string);
    }

  return 1;
}

######################################################################

sub _parse_next_substring {

  my $self   = shift;
  my $string = shift;                   # string to which this text belongs

  my $text = $string->get_remaining;    # text to parse

  unless ( $text )
    {
      my $msg = "THERE IS NO TEXT LEFT TO PARSE IN $string";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $library     = $self->_get_library;
  my $syntax      = $library->get_syntax;
  my $string_type = $self->_get_next_substring_type($text);

  if ( $string_type )
    {
      if ( $text =~ /$syntax->{$string_type}/p )
	{
	  my $preceding_text = ${^PREMATCH};
	  my $substring      = ${^MATCH};
	  my $remaining_text = ${^POSTMATCH};

	  if ( $preceding_text )
	    {
	      my $newstring1 = $self->_create_string($preceding_text);
	      $string->add_part($newstring1);
	    }

	  my $newstring2 = $self->_create_string($substring);
	  $string->add_part($newstring2);

	  $string->set_remaining($remaining_text);

	  return $remaining_text;
	}

      else
	{
	  my $msg = "THIS SHOULD NEVER HAPPEN (5)";
	  $self->_handle_error('error',$msg);
	}
    }

  else
    {
      my $newstring = $self->_create_string($text);
      $string->add_part($newstring);

      $text = q{};
      $string->set_remaining($text);

      return $text;
    }
}

######################################################################

sub _get_string_type {

  # Given a string of text, return the type of string it is.  For
  # example return 'italics_text' if the WHOLE string is marked up as
  # italics.

  my $self = shift;
  my $text = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  foreach my $string_type (@{ $self->_get_string_type_list })
    {
      if ( $text =~ /^$syntax->{$string_type}$/ )
	{
	  return $string_type;
	}

      elsif ( not exists $syntax->{$string_type} )
	{
	  my $msg = "THIS SHOULD NEVER HAPPEN $string_type";
	  $self->_handle_error('error',$msg);
	  return 0;
	}
    }

  return 'string';
}

######################################################################

sub _has_current_container {

  my $self = shift;

  my $container_stack = $self->_get_container_stack;

  if ( defined $container_stack->[-1] )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub _get_current_container {

  my $self = shift;

  my $container_stack = $self->_get_container_stack;

  return $container_stack->[-1];
}

######################################################################

sub _is_single_string {

  # Return 1 if the text represents a symbol.

  my $self = shift;
  my $text = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  foreach my $symbol (@{ $self->_get_single_string_type_list })
    {
      if ( $text =~ /^$syntax->{$symbol}$/ )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _is_single_string_type {

  # Return 1 if string type is a single string type.

  my $self        = shift;
  my $string_type = shift;

  foreach my $type (@{ $self->_get_single_string_type_list })
    {
      if ( $string_type eq $type )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _toggle_boolean {

  my $self    = shift;
  my $boolean = shift;

  if ( $boolean )
    {
      return 0;
    }

  else
    {
      return 1;
    }
}

######################################################################

sub _resolve_include_line {

  my $self         = shift;
  my $line         = shift;             # include line being resolved
  my $depth        = shift;             # current section depth
  my $asterisks    = shift;             # leading asterisks
  my $args         = shift;             # args
  my $included_id  = shift;             # included ID
  my $ignore       = shift;             # not used
  my $comment_text = shift;             # comment text

  my $library = $self->_get_library;

  unless ( $library->has_division_id($included_id) )
    {
      my $msg = "CAN'T RESOLVE INCLUDE LINE, LIBRARY DOESN'T HAVE ID $included_id";
      my $location = $line->get_location;
      $self->_handle_error('fatal',$msg,$location);
      return 0;
    }

  my $line_list = $self->_get_line_list_for_id($included_id);

  # flatten (i.e. include::flat: my-division)
  if ( $args =~ /flat:/ )
    {
      $logger->trace("including flattened line list");
      return $self->_flatten_line_list($line_list);
    }

  # hide (i.e. include::hide: my-division)
  elsif ( $args =~ /hide:/ )
    {
      $logger->trace("including hidden line list");
      return $self->_hide_line_list($line_list);
    }

  # as section at specified depth (i.e. ** include:: my-division)
  elsif ( $asterisks =~ /(\*+)/ or $args =~ /(\*+)/ )
    {
      my $depth = length($1);

      $logger->trace("including line list converted to section (depth: $depth)");
      return $self->_convert_to_section_line_list($line_list,$depth);
    }

  # raw (i.e. include::raw: my-division)
  elsif ( $args =~ /raw:/ )
    {
      $logger->trace("including raw line list");
      return $line_list;
    }

  # raw (default behavior)
  else
    {
      $logger->trace("including raw line list (default)");
      return $line_list;
    }
}

######################################################################

sub _flatten_line_list {

  my $self = shift;
  my $oll  = shift;                     # old line list

  my $nll = [];                         # new line list

  foreach my $line (@{ $oll })
    {
      my $content = $line->get_content;
      if ($content =~ /^(title::\s|\*+\s)/)
	{
	  $line = $self->_flatten($line);
	}
      push( @{ $nll }, $line );
    }

  return $nll;
}

######################################################################

sub _hide_line_list {

  my $self = shift;
  my $oll  = shift;                     # old line list

  my $nll = [];                         # new line list

  my $begin_line = $self->_hide_tag;
  my $end_line   = $self->_hide_tag;

  push @{ $nll }, $begin_line;

  foreach my $line (@{ $oll })
    {
      push @{ $nll }, $line;
    }

  push @{ $nll }, $end_line;

  return $nll;
}

######################################################################

sub _convert_to_section_line_list {

  my $self  = shift;
  my $oll   = shift;                    # old line list
  my $depth = shift || 1;               # section depth

  my $library = $self->_get_library;
  my $util    = $library->get_util;
  my $nll     = [];                     # new line list

  my $title     = $self->_extract_title_text($oll);
  my $asterisks = q{};

  $asterisks .= '*' until length($asterisks) == $depth;

  my $sechead = $self->_sechead_line($asterisks,$title);

  push @{ $nll }, $sechead;
  push @{ $nll }, $util->get_blank_line;

  foreach my $line (@{ $oll })
    {
      push @{ $nll }, $line;
    }

  return $nll;
}

######################################################################

sub _push_list_stack {

  my $self = shift;
  my $list = shift;

  push @{ $self->_get_list_stack }, $list;

  return 1;
}

######################################################################

sub _pop_list_stack {

  my $self = shift;

  return pop @{ $self->_get_list_stack };
}

######################################################################

sub _has_current_list {

  # Return 1 if there is a current bullet or enumerated list.

  my $self = shift;

  if (
      $self->_has_list_stack
      and
      exists $self->_get_list_stack->[-1]
     )
    {
      my $list = $self->_get_list_stack->[-1];

      if (
	  $list->isa('SML::BulletList')
	  or
	  $list->isa('SML::EnumeratedList')
	 )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

sub _get_current_list {

  # Return the current bullet or enumerated list.

  my $self = shift;

  if (
      $self->_has_list_stack
      and
      exists $self->_get_list_stack->[-1]
     )
    {
      return $self->_get_list_stack->[-1];
    }

  else
    {
      my $msg = "THERE IS NO CURRENT LIST";
      $self->_handle_error('error',$msg);
      return 0;
    }
}

######################################################################

sub _get_current_list_indent {

  # Return an integer, the number of white spaces the current list is
  # indented.  Return 0 if there is no current list.

  my $self = shift;

  if (
      $self->_has_list_stack
      and
      exists $self->_get_list_stack->[-1]
     )
    {
      my $current_list = $self->_get_list_stack->[-1];

      return $current_list->get_indent;
    }

  else
    {
      my $msg = "CAN'T GET INDENT, THERE IS NO CURRENT LIST";
      $self->_handle_error('error',$msg);
    }
}

######################################################################

sub _has_list_at_indent {

  # Return 1 of list stack contains a list at the specified indent.

  my $self   = shift;
  my $indent = shift;

  if ( $self->_has_list_stack )
    {
      foreach my $list (@{ $self->_get_list_stack })
	{
	  if ( $list->get_indent == $indent )
	    {
	      return 1;
	    }
	}

      return 0;
    }

  else
    {
      my $msg = "NO LIST STACK DEFINED";
      $self->_handle_error('error',$msg);
      return 0;
    }
}

######################################################################

sub _end_all_lists {

  my $self = shift;

  until
    (
     not $self->_has_current_list
    )
    {
      if ( $self->_in_bullet_list )
	{
	  $self->_end_bullet_list;
	}

      elsif ( $self->_in_enumerated_list )
	{
	  $self->_end_enumerated_list;
	}

      else
	{
	  my $msg = "CAN'T END ALL LISTS, THIS SHOULD NEVER HAPPEN";
	  $self->_handle_error('fatal',$msg);
	}
    }

  return 1;
}

######################################################################

sub _end_use_formal_status_element {

  my $self    = shift;
  my $element = shift;

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $element->get_content;

  if ( $text =~ /$syntax->{element}/ )
    {
      $element->set_value($3);

      return 1;
    }

  else
    {
      my $msg = "SYNTAX ERROR IN use_formal_status ELEMENT";
      my $location = $element->get_location;
      $self->_handle_error('error',$msg,$location);
      return 0;
    }
}

######################################################################

sub _has_bullet_list_at_indent {

  # Return 1 if list stack has a bullet list at the specified indent.

  my $self   = shift;
  my $indent = shift;

  if ( $self->_has_list_stack )
    {
      foreach my $list (@{ $self->_get_list_stack })
	{
	  if (
	      $list->isa('SML::BulletList')
	      and
	      $list->get_indent == $indent
	     )
	    {
	      return 1;
	    }
	}
    }

  return 0;
}

######################################################################

sub _has_enumerated_list_at_indent {

  # Return 1 if list stack has a enumerated list at the specified indent.

  my $self   = shift;
  my $indent = shift;

  if ( $self->_has_list_stack )
    {
      foreach my $list (@{ $self->_get_list_stack })
	{
	  if (
	      $list->isa('SML::EnumeratedList')
	      and
	      $list->get_indent == $indent
	     )
	    {
	      return 1;
	    }
	}
    }

  return 0;
}

######################################################################

sub _validate_bold_markup_syntax {

  # Return 1 if valid, 0 if not. Validate this block contains no
  # unbalanced bold markup.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $count   = 0;
  my $text    = $block->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{bold}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $msg = "INVALID BOLD MARKUP";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      return 0;
    }

  else
    {
      return 1;
    }
}

######################################################################

sub _validate_italics_markup_syntax {

  # Return 1 if valid, 0 if not. Validate this block contains no
  # unbalanced italics markup.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $count   = 0;
  my $text    = $block->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{italics}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $msg = "INVALID ITALICS MARKUP";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      return 0;
    }

  else
    {
      return 1;
    }
}

######################################################################

sub _validate_fixedwidth_markup_syntax {

  # Return 1 if valid, 0 if not. Validate this block contains no
  # unbalanced fixed-width markup.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $count   = 0;
  my $text    = $block->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{fixedwidth}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $msg = "INVALID FIXED-WIDTH MARKUP";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      return 0;
    }

  else
    {
      return 1;
    }
}

######################################################################

sub _validate_underline_markup_syntax {

  # Return 1 if valid, 0 if not. Validate this block contains no
  # unbalanced underline markup.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $count   = 0;
  my $text    = $block->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{underline}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $msg = "INVALID UNDERLINE MARKUP";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      return 0;
    }

  else
    {
      return 1;
    }
}

######################################################################

sub _validate_superscript_markup_syntax {

  # Return 1 if valid, 0 if not. Validate this block contains no
  # unbalanced superscript markup.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $count   = 0;
  my $text    = $block->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{superscript}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $msg = "INVALID SUPERSCRIPT MARKUP";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      return 0;
    }

  else
    {
      return 1;
    }
}

######################################################################

sub _validate_subscript_markup_syntax {

  # Return 1 if valid, 0 if not. Validate this block contains no
  # unbalanced subscript markup.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $count   = 0;
  my $text    = $block->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{subscript}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $msg = "INVALID SUBSCRIPT MARKUP";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      return 0;
    }

  else
    {
      return 1;
    }
}

######################################################################

sub _validate_inline_tags {

  # Return 1 if valid, 0 if not.  Validate this block contains only
  # valid inline tags.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $valid   = 1;
  my $text    = $block->get_content;

  $text = $util->remove_literals($text);
  $text = $util->remove_keystroke_symbols($text);

  while ( $text =~ /$syntax->{inline_tag}/xms )
    {
      my $tag  = $1;
      my $name = $2;

      if ( $name !~ /$syntax->{valid_inline_tags}/xms )
	{
	  my $msg = "INVALID INLINE TAG $tag";
	  my $location = $block->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}

      $text =~ s/$syntax->{inline_tag}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_cross_ref_syntax {

  # Validate this block's cross reference syntax.  Return 1 if valid,
  # 0 if not.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{cross_ref}/xms
       or
       $text =~ /$syntax->{begin_cross_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  while ( $text =~ /$syntax->{cross_ref}/xms )
    {
      $text =~ s/$syntax->{cross_ref}//xms;
    }

  # After gobbling through all the valid cross references in the while
  # loop, check for any remaining 'begin cross reference' instances in
  # which the author forgot to complete the cross reference.

  if ( $text =~ /$syntax->{begin_cross_ref}/xms )
    {
      my $msg = "INVALID CROSS REFERENCE SYNTAX";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_cross_ref_semantics {

  # Validate this block's cross references.  Return 1 if valid, 0 if
  # not.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{cross_ref}/xms
       or
       $text =~ /$syntax->{begin_cross_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  while ( $text =~ /$syntax->{cross_ref}/xms )
    {
      my $id = $2;

      if ( $library->has_division_id($id) )
	{
	  $logger->trace("cross reference to \'$id\' is valid");
	}

      else
	{
	  my $msg = "INVALID CROSS REFERENCE $id NOT DEFINED";
	  my $location = $block->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}

      # IMPORTANT: remove THIS cross reference from the matching space
      # to prevent an infinite while loop.

      $text =~ s/$syntax->{cross_ref}//xms;
    }

  # After gobbling through all the valid cross references in the while
  # loop, check for any remaining 'begin cross reference' instances in
  # which the author forgot to complete the cross reference.

  return $valid;
}

######################################################################

sub _validate_id_ref_syntax {

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{id_ref}/xms
       or
       $text =~ /$syntax->{begin_id_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  while ( $text =~ /$syntax->{id_ref}/xms )
    {
      $text =~ s/$syntax->{id_ref}//xms;
    }

  if ( $text =~ /$syntax->{begin_id_ref}/xms )
    {
      my $msg = "INVALID ID REFERENCE SYNTAX";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_id_ref_semantics {

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{id_ref}/xms
       or
       $text =~ /$syntax->{begin_id_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  while ( $text =~ /$syntax->{id_ref}/xms )
    {
      my $id = $1;

      if ( $library->has_division_id($id) )
	{
	  $logger->trace("id reference to \'$id\' is valid");
	}

      else
	{
	  my $msg = "INVALID ID REFERENCE $id";
	  my $location = $block->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}

      $text =~ s/$syntax->{id_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_page_ref_syntax {

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{page_ref}/xms
       or
       $text =~ /$syntax->{begin_page_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  while ( $text =~ /$syntax->{page_ref}/xms )
    {
      $text =~ s/$syntax->{page_ref}//xms;
    }

  if ( $text =~ /$syntax->{begin_page_ref}/xms )
    {
      my $msg = "INVALID PAGE REFERENCE SYNTAX";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_page_ref_semantics {

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{page_ref}/xms
       or
       $text =~ /$syntax->{begin_page_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  while ( $text =~ /$syntax->{page_ref}/xms )
    {
      my $id = $2;

      if ( $library->has_division_id($id) )
	{
	  $logger->trace("page reference to \'$id\' is valid");
	}

      else
	{
	  my $msg = "INVALID PAGE REFERENCE $id";
	  my $location = $block->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}

      $text =~ s/$syntax->{page_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_glossary_term_ref_syntax {

  # Validate that each glossary term reference has a valid glossary
  # entry.  Glossary term references are inline tags like '[g:term]'
  # or '[g:namespace:term]'.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{gloss_term_ref}/xms
       or
       $text =~ /$syntax->{begin_gloss_term_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  while ( $text =~ /$syntax->{gloss_term_ref}/xms )
    {
      $text =~ s/$syntax->{gloss_term_ref}//xms;
    }

  if ( $text =~ /$syntax->{begin_gloss_term_ref}/xms )
    {
      my $msg = "INVALID GLOSSARY TERM REFERENCE SYNTAX";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_glossary_def_ref_syntax {

  # Validate that each glossary definition reference has a valid
  # glossary entry.  Glossary definition references are inline tags
  # like '[def:term]'.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{gloss_def_ref}/xms
       or
       $text =~ /$syntax->{begin_gloss_def_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  while ( $text =~ /$syntax->{gloss_def_ref}/xms )
    {
      $text =~ s/$syntax->{gloss_def_ref}//xms;
    }

  if ( $text =~ /$syntax->{begin_gloss_def_ref}/xms )
    {
      my $msg = "INVALID GLOSSARY DEFINITION REFERENCE SYNTAX";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_acronym_ref_syntax {

  # Validate that each acronym reference has a valid acronym list
  # entry.  Acronym references are inline tags like '[ac:term]'
  # or '[ac:namespace:term]'.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{acronym_term_ref}/xms
       or
       $text =~ /$syntax->{begin_acronym_term_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  while ( $text =~ /$syntax->{acronym_term_ref}/xms )
    {
      $text =~ s/$syntax->{acronym_term_ref}//xms;
    }

  if ( $text =~ /$syntax->{begin_acronym_term_ref}/xms )
    {
      my $msg = "INVALID ACRONYM REFERENCE SYNTAX";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_source_citation_syntax {

  # Validate that each source citation has a valid source in the
  # library's list of references.  Source citations are inline tags
  # like '[cite:cms15]'

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{citation_ref}/xms
       or
       $text =~ /$syntax->{begin_citation_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  while ( $text =~ /$syntax->{citation_ref}/xms )
    {
      $text =~ s/$syntax->{citation_ref}//xms;
    }

  if ( $text =~ /$syntax->{begin_citation_ref}/xms )
    {
      my $msg = "INVALID SOURCE CITATION SYNTAX";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_theversion_ref_semantics {

  # The version refers to the version of the containing document.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if ( not $text =~ /$syntax->{theversion_ref}/xms )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid  = 1;
  my $doc    = $block->get_containing_document;
  my $doc_id = $doc->get_id;

  unless ( $doc )
    {
      my $msg = "NOT IN DOCUMENT CONTEXT can't validate version references";
      $self->_handle_error('error',$msg);
      return 0;
    }

  while ( $text =~ /$syntax->{theversion_ref}/xms )
    {
      if ( $library->has_property($doc_id,'version') )
	{
	  $logger->trace("version reference is valid");
	}

      else
	{
	  my $msg = "INVALID VERSION REFERENCE, DOCUMENT HAS NO VERSION PROPERTY";
	  my $location = $block->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}

      $text =~ s/$syntax->{theversion_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_therevision_ref_semantics {

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if ( not $text =~ /$syntax->{therevision_ref}/xms )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid  = 1;
  my $doc    = $block->get_containing_document;
  my $doc_id = $doc->get_id;

  if ( not $doc )
    {
      my $msg = "CAN'T VALIDATE REVISION REFERENCES, NOT IN DOCUMENT CONTEXT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  while ( $text =~ /$syntax->{therevision_ref}/xms )
    {
      if ( $library->has_property($doc_id,'revision') )
	{
	  $logger->trace("revision reference is valid");
	}

      else
	{
	  my $msg = "CAN'T VALIDATE REVISION REFERENCES, INVALID REVISION REFERENCE";
	  my $location = $block->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}

      $text =~ s/$syntax->{therevision_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_thedate_ref_semantics {

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if ( not $text =~ /$syntax->{thedate_ref}/xms )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid  = 1;
  my $doc    = $block->get_containing_document;
  my $doc_id = $doc->get_id;

  unless ( $doc )
    {
      my $msg = "CAN'T VALIDATE DATE REFERENCES, NOT IN DOCUMENT CONTEXT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  while ( $text=~ /$syntax->{thedate_ref}/xms )
    {
      if ( $library->has_property($doc_id,'date') )
	{
	  $logger->trace("date reference is valid");
	}

      else
	{
	  my $msg = "INVALID DATE REFERENCE, DOCUMENT HAS NO DATE PROPERTY";
	  my $location = $block->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}

      $text =~ s/$syntax->{thedate_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_status_ref_semantics {

  # [status:td-000020]
  # [status:green]
  # [status:yellow]
  # [status:red]
  # [status:grey]

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $valid   = 1;
  my $text    = $block->get_content;

  if ( not $text =~ /$syntax->{status_ref}/xms )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{status_ref}/xms )
    {
      my $id_or_color = $1;

      if ( $id_or_color =~ $syntax->{valid_status} )
	{
	  my $color = $id_or_color;
	}

      else
	{
	  my $id = $id_or_color;

	  if ( not $block->get_containing_document )
	    {
	      my $msg = "CAN'T VALIDATE STATUS REFERENCE SEMANTICS, NOT IN DOCUMENT CONTEXT";
	      $self->_handle_error('error',$msg);
	      return 0;
	    }

	  if ( $library->has_division($id) )
	    {
	      my $division = $library->get_division($id);

	      if ( not $library->has_property($id,'status') )
		{
		  my $msg = "INVALID STATUS REFERENCE";
		  my $location = $block->get_location;
		  $self->_handle_error('warn',$msg,$location);
		  $valid = 0;
		}
	    }

	  else
	    {
	      my $msg = "INVALID STATUS REFERENCE $id";
	      my $location = $block->get_location;
	      $self->_handle_error('warn',$msg,$location);
	      $valid = 0;
	    }
	}

      $text =~ s/$syntax->{status_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_glossary_term_ref_semantics {

  # Validate that each glossary term reference has a valid glossary
  # entry.  Glossary term references are inline tags like '[g:term]'
  # or '[g:namespace:term]'.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library  = $self->_get_library;
  my $syntax   = $library->get_syntax;
  my $text     = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{gloss_term_ref}/xms
       or
       $text =~ /$syntax->{begin_gloss_term_ref}/xms
      )
     )
    {
      return 1;
    }

  my $util = $library->get_util;

  $text = $util->remove_literals($text);

  my $valid = 1;

  my $glossary = $library->get_glossary;

  while ( $text =~ /$syntax->{gloss_term_ref}/xms )
    {
      my $namespace = $3 || q{};
      my $term      = $4;

      unless ( $glossary->has_entry($term,$namespace) )
	{
	  my $msg = "TERM NOT IN LIBRARY GLOSSARY $term {$namespace}";
	  my $location = $block->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}

      $text =~ s/$syntax->{gloss_term_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_glossary_def_ref_semantics {

  # Validate that each glossary definition reference has a valid
  # glossary entry.  Glossary definition references are inline tags
  # like '[def:term]'.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{gloss_def_ref}/xms
       or
       $text =~ /$syntax->{begin_gloss_def_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  if ( not $block->get_containing_document )
    {
      my $msg = "CAN'T VALIDATE GLOSSARY DEFINITION REFERENCES, NOT IN DOCUMENT CONTEXT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  while ( $text =~ /$syntax->{gloss_def_ref}/xms )
    {
      my $namespace = $2 || q{};
      my $term      = $3;

      unless ( $library->get_glossary->has_entry($term,$namespace) )
	{
	  my $msg = "DEFINITION NOT IN GLOSSARY $namespace $term";
	  my $location = $block->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}

      $text =~ s/$syntax->{gloss_def_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_acronym_ref_semantics {

  # Validate that each acronym reference has a valid acronym list
  # entry.  Acronym references are inline tags like '[ac:term]'
  # or '[ac:namespace:term]'.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{acronym_term_ref}/xms
       or
       $text =~ /$syntax->{begin_acronym_term_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  if ( not $block->get_containing_document )
    {
      my $msg = "CAN'T VALIDATE ACRONYM REFERENCES, NOT IN DOCUMENT CONTEXT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  while ( $text =~ /$syntax->{acronym_term_ref}/xms )
    {
      my $namespace = $3 || q{};
      my $acronym   = $4;

      my $acronym_list = $library->get_acronym_list;

      unless ( $acronym_list->has_entry($acronym,$namespace) )
	{
	  my $msg = "ACRONYM NOT IN LIBRARY ACRONYM LIST $acronym $namespace";
	  my $location = $block->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}

      $text =~ s/$syntax->{acronym_term_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_source_citation_semantics {

  # Validate that each source citation has a valid source in the
  # library's list of references.  Source citations are inline tags
  # like '[cite:cms15]'

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{citation_ref}/xms
       or
       $text =~ /$syntax->{begin_citation_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  if ( not $block->get_containing_document )
    {
      my $msg = "CAN'T VALIDATE SOURCE CITATIONS, NOT IN DOCUMENT CONTEXT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  while ( $text =~ /$syntax->{citation_ref}/xms )
    {
      my $source = $2;
      my $note   = $3;

      if ( not $library->get_references->has_source($source) )
	{
	  my $msg = "CAN'T VALIDATE SOURCE CITATION SEMANTICS, INVALID SOURCE CITATION $source";
	  my $location = $block->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}

      $text =~ s/$syntax->{citation_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_file_ref_semantics {

  # Validate that each file reference ('file:: file.txt' or 'image::
  # image.png') points to a valid file.

  my $self  = shift;
  my $block = shift;

  if ( $block->isa('SML::PreformattedBlock') )
    {
      return 1;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $block->get_content;

  if (
      not
      (
       $text =~ /$syntax->{file_element}/xms
       or
       $text =~ /$syntax->{image_element}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $directory_path = $library->get_directory_path;
  my $valid          = 1;
  my $found_file     = 0;
  my $resource_spec;

  if ( $text =~ /$syntax->{file_element}/xms )
    {
      $resource_spec = $1;
    }

  if ( $text =~ /$syntax->{image_element}/xms )
    {
      $resource_spec = $3;
    }

  if ( -f "$directory_path/$resource_spec" )
    {
      $found_file = 1;
    }

  foreach my $path (@{ $library->get_include_path })
    {
      if ( -f "$directory_path/$path/$resource_spec" )
	{
	  $found_file = 1;
	}
    }

  unless ( $found_file )
    {
      my $msg = "FILE NOT FOUND $resource_spec";
      my $location = $block->get_location;
      $self->_handle_error('warn',$msg,$location);
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_property_cardinality {

  my $self     = shift;
  my $division = shift;

  my $valid    = 1;
  my $library  = $self->_get_library;
  my $divname  = $division->get_name;
  my $divid    = $division->get_id;
  my $ontology = $library->get_ontology;

  foreach my $property_name (@{ $library->get_property_name_list($divid) })
    {
      my $cardinality;

      if ( $property_name eq 'id' )
	{
	  $cardinality = 1;
	}

      else
	{
	  $cardinality = $ontology->property_allows_cardinality($divname,$property_name);
	}

      # Validate property cardinality
      if ( $ontology->property_is_universal($property_name) )
	{
	  # OK, all universal properties have cardinality = many
	}

      elsif ( not defined $cardinality )
	{
	  my $msg = "NO CARDINALITY FOR $divname $property_name";
	  my $location = $division->get_location;
	  $self->_handle_error('error',$msg,$location);
	  $valid = 0;
	}

      else
	{
	  my $list  = $library->get_property_value_list($divid,$property_name);
	  my $count = scalar(@{ $list });

	  if ( $cardinality eq '1' and $count > 1 )
	    {
	      my $msg = "INVALID PROPERTY CARDINALITY $divname ALLOWS ONLY 1 $property_name";
	      my $location = $division->get_location;
	      $self->_handle_error('warn',$msg,$location);
	      $valid = 0;
	    }
	}
    }

  return $valid;
}

######################################################################

sub _validate_property_values {

  my $self     = shift;
  my $division = shift;

  my $valid    = 1;
  my $seen     = {};
  my $library  = $self->_get_library;
  my $ontology = $library->get_ontology;
  my $divname  = $division->get_name;
  my $divid    = $division->get_id;

  foreach my $property_name (@{ $library->get_property_name_list($divid) })
    {
      $seen->{$property_name} = 1;

      my $imply_only  = $ontology->property_is_imply_only($divname,$property_name);
      my $list        = $library->get_property_value_list($divid,$property_name);
      my $cardinality = $ontology->property_allows_cardinality($divname,$property_name);

      foreach my $value (@{ $list })
	{
	  # validate property value is allowed
	  unless ( $ontology->allows_property_value($divname,$property_name,$value) )
	    {
	      my $list = $ontology->get_allowed_property_value_list($divname,$property_name);
	      my $valid_property_values = join(', ', @{ $list });
	      my $msg = "INVALID PROPERTY VALUE $value, $divname $property_name MUST BE ONE OF: $valid_property_values";
	      $self->_handle_error('warn',$msg);
	      $valid = 0;
	    }
	}
    }

  return $valid;
}

######################################################################

sub _validate_infer_only_conformance {

  my $self     = shift;
  my $division = shift;

  my $valid    = 1;
  my $seen     = {};
  my $library  = $self->_get_library;
  my $ontology = $library->get_ontology;
  my $divname  = $division->get_name;
  my $divid    = $division->get_id;

  foreach my $property_name (@{ $library->get_property_name_list($divid) })
    {
      $seen->{$property_name} = 1;

      my $imply_only  = $ontology->property_is_imply_only($divname,$property_name);
      my $list        = $library->get_property_value_list($divid,$property_name);
      my $cardinality = $ontology->property_allows_cardinality($divname,$property_name);

      foreach my $property_value (@{ $list })
	{
	  my $value = $library->get_property_value_object($divid,$property_name,$property_value);

	  # Validate infer-only conformance
	  if ( $imply_only and $value->is_from_manuscript )
	    {
	      my $msg = "INVALID EXPLICIT DECLARATION OF INFER-ONLY PROPERTY $property_name, $divname $divid";
	      $self->_handle_error('warn',$msg);
	      $valid = 0;
	    }

	}

    }

  return $valid;
}

######################################################################

sub _validate_required_properties {

  my $self     = shift;
  my $division = shift;

  my $valid    = 1;
  my $seen     = {};
  my $library  = $self->_get_library;
  my $ontology = $library->get_ontology;
  my $divname  = $division->get_name;
  my $divid    = $division->get_id;

  foreach my $property_name (@{ $library->get_property_name_list($divid) })
    {
      $seen->{$property_name} = 1;
    }

  # Validate that all required properties are defined

  my $required_property_name_list = $ontology->get_list_of_required_property_names_for_division_name($divname);

  foreach my $required_property_name (@{ $required_property_name_list })
    {
      if ( not $seen->{$required_property_name} )
	{
	  my $msg = "MISSING REQUIRED PROPERTY $divname; $divid requires $required_property_name";
	  my $location = $division->get_location;
	  $self->_handle_error('warn',$msg,$location);
	  $valid = 0;
	}
    }

  return $valid;
}

######################################################################

sub _validate_composition {

  # Validate conformance with division composition rules. If this
  # division is contained by another division, validate that a
  # composition rule allows this relationship.
  #
  # This means check wether THIS division is allowed to be inside the
  # one that contains it.

  my $self     = shift;
  my $division = shift;

  my $valid     = 1;
  my $library   = $self->_get_library;
  my $libname   = $library->get_name;
  my $ontology  = $library->get_ontology;
  my $container = $division->get_containing_division;

  if ( $container )
    {
      my $name           = $division->get_name;
      my $container_name = $container->get_name;

      if ( $ontology->allows_composition($name,$container_name) )
	{
	  return 1;
	}

      else
	{
	  my $location   = $division->get_location;
	  my $first_line = $division->get_first_line;

	  if ( $division->has_origin_line )
	    {
	      my $origin_line = $division->get_origin_line;
	      my $include_location = $origin_line->get_location;
	      my $msg = "INVALID COMPOSITION $name IN $container_name (INCLUDED AT $include_location)";
	      $self->_handle_error('warn',$msg,$location);
	    }

	  else
	    {
	      my $msg = "INVALID COMPOSITION $name IN $container_name";
	      $self->_handle_error('warn',$msg);
	    }

	  return 0;
	}
    }

  return $valid;
}

######################################################################

sub _process_index_string {

  # Process an index string.  An index string is part of an index
  # element value. The syntax for an index element is a little
  # complicated. Consider this index element:
  #
  #   index:: font family!Computer Modern; font family!Times; font
  #   family!Bookman; font family!Chancery; font family!Charter; font
  #   family!New Century; font family!Palatino
  #
  # Strings are separated by semi-colons. This index element value has
  # 7 strings.  Terms and subterms are separated by exclamation
  # marks. Each string may consist of a term, subterm, and subsubterm.
  #
  # Validate the syntax.

  my $self    = shift;
  my $string  = shift;                  # an index value (string)
  my $element = shift;                  # index element

  unless ( $string and $element )
    {
      my $msg = "CAN'T PROCESS INDEX STRING, MISSING ARGUMENTS";
      $self->_handle_error('error',$msg);
      return 0;
    }

  unless ( $element->has_containing_division )
    {
      my $msg = "INDEX ELEMENT HAS NO CONTAINING DIVISION";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  unless ( $string =~ /$syntax->{index_entry}/ )
    {
      my $msg = "SYNTAX ERROR IN INDEX ELEMENT";
      my $location = $element->get_location;
      $self->_handle_error('error',$msg,$location);
      return 0;
    }

  my $term       = $1;
  my $subterm    = $3 || q{};
  my $subsubterm = $5 || q{};

  my $util = $library->get_util;

  $term       = $util->strip_string_markup($term);
  $subterm    = $util->strip_string_markup($subterm);
  $subsubterm = $util->strip_string_markup($subsubterm);

  my $division    = $element->get_containing_division;
  my $division_id = $division->get_id;
  my $document    = $division->get_containing_document;

  unless ( $document )
    {
      my $msg = "CAN'T PROCESS INDEX STRING, NO CONTAINING DOCUMENT";
      my $location = $element->get_location;
      $self->_handle_error('error',$msg,$location);
      return 0;
    }

  my $index = $document->get_index;

  my ( $entry, $subentry, $subsubentry );

  if ( not $index->has_entry($term) )
    {
      $entry = SML::IndexEntry->new
	(
	 term     => $term,
	 document => $document,
	);

      $index->add_entry($entry);
    }

  $entry = $index->get_entry($term);
  $entry->add_locator($division_id);

  if ( $subterm )
    {
      if ( not $entry->has_subentry($subterm) )
	{
	  $subentry = SML::IndexEntry->new
	    (
	     term     => $subterm,
	     document => $document,
	    );

	  $entry->add_subentry($subentry);
	}

      $subentry = $entry->get_subentry($subterm);
      $subentry->add_locator($division_id);

      if ( $subsubterm )
	{
	  if ( not $subentry->has_subentry($subterm) )
	    {
	      $subsubentry = SML::IndexEntry->new
		(
		 term     => $subsubterm,
		 document => $document,
		);

	      $subentry->add_subentry($subsubentry);
	    }

	  $subsubentry = $subentry->get_subentry($subsubterm);
	  $subsubentry->add_locator($division_id);
	}
    }

  return 1;
}

######################################################################

sub _build_document_index {

  # Process all document 'index' elements to build a document index.

  my $self     = shift;
  my $document = shift;

  unless ( ref $document )
    {
      my $msg = "CAN'T BUILD DOCUMENT INDEX, MISSING ARGUMENT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $name = $document->get_name;

  unless ( $name eq 'DOCUMENT' )
    {
      my $msg = "CAN'T BUILD DOCUMENT INDEX, NOT A DOCUMENT $document";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $index_element_list = $document->get_list_of_elements_with_name('index');

  foreach my $index_element (@{ $index_element_list })
    {
      my $value       = $index_element->get_value;
      my $string_list = [ split(/\s*;\s*/,$value) ];

      foreach my $string (@{ $string_list })
	{
	  $self->_process_index_string($string,$index_element);
	}
    }

  return 1;
}

######################################################################

sub _parse_document_index_terms {

  # Parse each plain text index term into an SML::String object.

  my $self     = shift;
  my $document = shift;

  unless ( ref $document )
    {
      my $msg = "CAN'T PARSE DOCUMENT INDEX TERMS, MISSING ARGUMENT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $name = $document->get_name;

  unless ( $name eq 'DOCUMENT' )
    {
      my $msg = "CAN'T PARSE DOCUMENT INDEX TERMS, NOT A DOCUMENT $document";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $index = $document->get_index;

  foreach my $entry (@{ $index->get_entry_list })
    {
      $self->_parse_index_term($entry);
    }

  return 1;
}

######################################################################

sub _parse_index_term {

  # Parse a plain text index term into an SML::String object.

  my $self  = shift;
  my $entry = shift;

  unless ( ref $entry )
    {
      my $msg = "CAN'T PARSE INDEX TERM, MISSING ARGUMENT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $term   = $entry->get_term;
  my $string = $self->_create_string($term);

  $entry->set_term_string($string);

  if ( $entry->has_subentries )
    {
      foreach my $subentry (@{ $entry->get_subentry_list })
	{
	  $self->_parse_index_term($subentry);
	}
    }

  return 1;
}

######################################################################

sub _validate_division_blocks {

  # Validate all blocks in the specified division.

  my $self     = shift;
  my $division = shift;

  unless ( ref $division )
    {
      my $msg = "CAN'T VALIDATE DIVISION BLOCKS, MISSING ARGUMENT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  foreach my $block (@{ $division->get_block_list })
    {
      $self->_validate_theversion_ref_semantics($block);
      $self->_validate_therevision_ref_semantics($block);
      $self->_validate_thedate_ref_semantics($block);
      $self->_validate_status_ref_semantics($block);
      $self->_validate_glossary_term_ref_semantics($block);
      $self->_validate_glossary_def_ref_semantics($block);
      $self->_validate_acronym_ref_semantics($block);
      $self->_validate_source_citation_semantics($block);
      $self->_validate_file_ref_semantics($block);
    }

  return 1;
}

######################################################################

sub _build_document_glossary {

  # Add entries to the document glossary for each glossary reference.

  my $self     = shift;
  my $document = shift;

  unless ( ref $document )
    {
      my $msg = "CAN'T BUILD DOCUMENT GLOSSARY, MISSING ARGUMENT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $name = $document->get_name;

  unless ( $name eq 'DOCUMENT' )
    {
      my $msg = "CAN'T BUILD DOCUMENT GLOSSARY, NOT A DOCUMENT $document";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $document_glossary = $document->get_glossary;
  my $library           = $document->get_library;
  my $library_glossary  = $library->get_glossary;

  foreach my $string (@{ $document->get_string_list })
    {
      my $name = $string->get_name;

      next unless $name eq 'GLOSS_TERM_REF';

      my $term      = $string->get_term;
      my $namespace = $string->get_namespace || q{};

      if ( $library_glossary->has_entry($term,$namespace) )
	{
	  my $entry = $library_glossary->get_entry($term,$namespace);

	  $document_glossary->add_entry($entry);
	}

      else
	{
	  my $msg = "CAN'T ADD TERM TO DOCUMENT GLOSSARY, NOT IN LIBRARY GLOSSARY $term {$namespace}";
	  $self->_handle_error('error',$msg);
	}
    }

  return 1;
}

######################################################################

sub _build_document_acronym_list {

  # Add entries to the document acronym list for each acronym
  # reference.

  my $self     = shift;
  my $document = shift;

  unless ( ref $document )
    {
      my $msg = "CAN'T BUILD DOCUMENT ACRONYM LIST, MISSING ARGUMENT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $name = $document->get_name;

  unless ( $name eq 'DOCUMENT' )
    {
      my $msg = "CAN'T BUILD DOCUMENT ACRONYM LIST, NOT A DOCUMENT $document";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $document_acronym_list = $document->get_acronym_list;
  my $library               = $document->get_library;
  my $library_acronym_list  = $library->get_acronym_list;

  foreach my $string (@{ $document->get_string_list })
    {
      my $name = $string->get_name;

      next unless $name eq 'ACRONYM_TERM_REF';

      my $acronym   = $string->get_acronym;
      my $namespace = $string->get_namespace || q{};

      if ( $library_acronym_list->has_entry($acronym,$namespace) )
	{
	  my $entry = $library_acronym_list->get_entry($acronym,$namespace);

	  $document_acronym_list->add_entry($entry);
	}

      else
	{
	  my $msg = "CAN'T ADD ACRONYM TO DOCUMENT ACRONYM LIST, NOT IN LIBRARY ACRONYM LIST $acronym $namespace";
	  $self->_handle_error('error',$msg);
	}
    }

  return 1;
}

######################################################################

sub _build_document_references {

  # Add a 'source' to the document references list for each source
  # citation.

  my $self     = shift;
  my $document = shift;

  unless ( ref $document )
    {
      my $msg = "CAN'T BUILD DOCUMENT REFERENCES, MISSING ARGUMENT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $name = $document->get_name;

  unless ( $name eq 'DOCUMENT' )
    {
      my $msg = "CAN'T BUILD DOCUMENT REFERENCES, NOT A DOCUMENT $document";
      $self->_handle_error('error',$msg);
      return 0;
    }

  my $document_references = $document->get_references;
  my $library             = $document->get_library;
  my $library_references  = $library->get_references;

  foreach my $string (@{ $document->get_string_list })
    {
      my $name = $string->get_name;

      next unless $name eq 'CITATION_REF';

      my $source_id = $string->get_source_id;

      if ( $library_references->has_source($source_id) )
	{
	  my $source = $library_references->get_source($source_id);

	  unless ( $document_references->has_source($source_id) )
	    {
	      $document_references->add_source($source);
	    }
	}

      else
	{
	  my $msg = "CAN'T ADD SOURCE TO DOCUMENT REFERENCES, NOT IN LIBRARY SOURCE $source_id";
	  $self->_handle_error('error',$msg);
	}
    }

  return 1;
}

######################################################################

sub _parse_division_blocks {

  # Parse each block in the specified division into strings.

  my $self     = shift;
  my $division = shift;

  unless ( $division )
    {
      my $msg = "CAN'T PARSE DIVISION BLOCKS, MISSING ARGUMENT";
      $self->_handle_error('error',$msg);
      return 0;
    }

  unless ( ref $division and $division->isa('SML::Division') )
    {
      my $msg = "CAN'T PARSE DIVISION BLOCKS, NOT A DIVISION $division";
      $self->_handle_error('error',$msg);
    }

  foreach my $block (@{ $division->get_block_list })
    {
      $self->_parse_block($block);
    }

  return 1;
}

######################################################################

sub _handle_error {

  my $self     = shift;
  my $level    = shift;
  my $message  = shift;
  my $location = shift || q{};

  unless ( $level and $message )
    {
      $logger->error("CAN'T HANDLE ERROR, MISSING ARGUMENTS");
      return 0;
    }

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  unless ( $level =~ /$syntax->{valid_error_level}/ )
    {
      $logger->error("INVALID ERROR LEVEL $level");
      return 0;
    }

  my $error = SML::Error->new
    (
     level    => $level,
     message  => $message,
     location => $location,
    );

  $library->add_error($error);

  if ( $self->_has_current_document )
    {
      my $document = $self->_get_current_document;
      $document->add_error($error);
    }

  $logger->$level($message);

  return 1;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Parser> - create fragment objects from raw SML text stored in
files; create string objects from blocks of text; extract data from
text

=head1 VERSION

2.0.0.

=head1 SYNOPSIS

  my $parser = SML::Parser->new(library=>$library);

  my $library  = $parser->get_library;
  my $division = $parser->parse($id);

=head1 DESCRIPTION

A parser creates fragment objects from raw SML text stored in files,
creates string objects from blocks of text, and extracts data from
sequences of line objects.

=head1 METHODS

=head2 get_library

=head2 create_fragment($filename)

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
