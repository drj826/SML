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
use SML;                        # ci-000002
use SML::Options;               # ci-000382
use SML::File;                  # ci-000384
use SML::Line;                  # ci-000385
use SML::Fragment;              # ci-000nnn

# string classes
use SML::String;                # ci-000???
use SML::AcronymTermReference;  # ci-000???
use SML::CitationReference;     # ci-000???
use SML::CommandReference;      # ci-000???
use SML::XMLTag;                # ci-000???
use SML::LiteralString;         # ci-000???
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
use SML::Document;              # ci-000005
use SML::CommentDivision;       # ci-000388
use SML::Conditional;           # ci-000389
use SML::Section;               # ci-000392
use SML::TableRow;              # ci-000429
use SML::TableCell;             # ci-000428
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

  # Create a division object by parsing a sequence of lines. Add the
  # new division to library. Return the division object.

  my $self = shift;
  my $id   = shift;

  $self->_init;

  my $library = $self->get_library;
  my $file    = $library->get_file_containing($id);

  my $file_line_list = $file->get_line_list;
  my $division_line_list = $self->_extract_division_lines($file_line_list,$id);

  $self->_set_line_list( $division_line_list );

  my $division = $self->_create_empty_division($division_line_list);
  $self->_set_division( $division );

  do
    {
      $self->_resolve_includes  while $self->_contains_include;
      $self->_run_scripts       while $self->_contains_script;

      $self->_parse_lines;

      $self->_insert_content       if $self->_contains_insert;
      $self->_resolve_templates    if $self->_contains_template;
      $self->_resolve_lookups      if $self->_contains_lookup;
      $self->_substitute_variables if $self->_contains_variable;
      $self->_generate_content     if $self->_contains_generate;
    }

      while $self->_text_requires_processing;

  foreach my $block (@{ $division->get_block_list })
    {
      $self->_parse_block($block);
    }

  $library->add_division($division);

  return $division;
}

######################################################################

sub create_string {

  my $self = shift;
  my $text = shift;                     # i.e. !!my bold text!!

  # !!! BUG HERE !!!
  #
  # lookup_ref -> This method doesn't know what to do with a lookup
  # reference.  Is this a problem?  Perhaps lookups are all 'resolved'
  # before this code is invoked?

  my $part;                             # containing part

  if ( $self->_has_part )
    {
      $part = $self->_get_part;
    }

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  my $string_type = $self->_get_string_type($text);

  if ( $string_type eq 'string' )
    {
      my $args = {};

      $args->{name}            = 'string';
      $args->{content}         = $text;
      $args->{library}         = $self->get_library;
      $args->{containing_part} = $part if $part;

      my $newstring = SML::String->new(%{$args});

      if ( $self->_text_contains_substring($text) )
	{
	  $self->_parse_text($newstring); # recurse
	}

      return $newstring;
    }

  elsif ( $string_type eq 'syntax_error' )
    {
      my $args = {};

      $args->{content}         = $text;
      $args->{library}         = $self->get_library;
      $args->{containing_part} = $part if $part;

      my $newstring = SML::SyntaxErrorString->new(%{$args});

      return $newstring;
    }

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

	    $args->{name}            = $string_type;
	    $args->{content}         = $1;
	    $args->{library}         = $self->get_library;
	    $args->{containing_part} = $part if $part;

	    my $newstring = SML::String->new(%{$args});

	    $self->_parse_text($newstring); # recurse

	    return $newstring;
	  }

	else
	  {
	    $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	    return 0;
	  }
      }

  elsif (
	 $string_type eq 'emdash_symbol'
	 # or
	 # $string_type eq 'open_sglquote_symbol'
	 # or
	 # $string_type eq 'close_sglquote_symbol'
	)
    {
      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  my $args = {};

	  $args->{name}                = $string_type;
	  $args->{library}             = $self->get_library;
	  $args->{containing_part}     = $part if $part;
	  $args->{preceding_character} = $1 || q{};
	  $args->{following_character} = $2 || q{};

	  return SML::Symbol->new(%{$args});
	}

      else
	{
	  $logger->error("DOESN'T LOOK LIKE A $string_type: $text");
	  return 0;
	}
    }

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
     # or
     # $string_type eq 'open_dblquote_symbol'
     # or
     # $string_type eq 'close_dblquote_symbol'
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

	    $args->{name}            = $string_type;
	    $args->{library}         = $self->get_library;
	    $args->{containing_part} = $part if $part;

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

	  $args->{tag}             = $1;
	  $args->{target_id}       = $2;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

	  return SML::CrossReference->new(%{$args});
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

	  $args->{url}             = $1;
	  $args->{content}         = $3    if $3;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{section_id}      = $1;
	  $args->{number}          = $2;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{tag}             = $1;
	  $args->{term}            = $4;
	  $args->{namespace}       = $3 || '';
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{term}            = $3;
	  $args->{namespace}       = $2 || '';
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{tag}             = $1;
	  $args->{acronym}         = $4;
	  $args->{namespace}       = $3 || '';
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{tag}             = $1;
	  $args->{entry}           = $2;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{target_id}       = $1;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{tag}             = $1;
	  $args->{target_id}       = $2;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{entity_id}       = $1;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{tag}             = $1;
	  $args->{source_id}       = $2;
	  $args->{details}         = $4 || '';
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{filespec}        = $1;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{pathspec}        = $1;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{variable_name}   = $1;
	  $args->{namespace}       = $3 || '';
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

	  $args->{tag}             = $1;
	  $args->{content}         = $2;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

	  return SML::UserEnteredText->new(%{$args});
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

	  $args->{content}         = $1;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

	  return SML::CommandReference->new(%{$args});
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

	  $args->{content}         = $1;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

	  return SML::XMLTag->new(%{$args});
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

	  $args->{content}         = $1;
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

	  return SML::LiteralString->new(%{$args});
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

	  $args->{email_addr}      = $1;
	  $args->{content}         = $3 || '';
	  $args->{library}         = $self->get_library;
	  $args->{containing_part} = $part if $part;

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

sub extract_division_name {

  # Extract a division name string from a sequence of lines.

  # NOTE: This ONLY works for a sequence of lines that represents a
  # division.  In other words, the first line must be a division
  # starting line.

  my $self  = shift;
  my $lines = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $text   = $lines->[0]->get_content;

  if ( $text =~ /$syntax->{start_division}/ )
    {
      return $1;                        # $1 = name (see Syntax.pm)
    }

  elsif ( $text =~ /$syntax->{start_section}/ )
    {
      return 'SECTION';
    }

  else
    {
      # $logger->warn("DIVISION NAME NOT FOUND IN...");

      # foreach my $line (@{$lines})
      # 	{
      # 	  my $text = $line->get_content;
      # 	  $logger->warn($text);
      # 	}
      # return '';

    }

}

######################################################################

sub extract_division_id {

  # Extract a division ID string from a sequence of lines.

  # NOTE: This ONLY works for a sequence of lines that represents a
  # division.  In other words, the first line must be a division
  # starting line.

  my $self  = shift;
  my $lines = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $text   = $lines->[0]->get_content;

  # !!! BUG HERE !!!
  #
  # What happens if a division marker lacks an ID?

  if ( $text =~ /$syntax->{start_division}/ )
    {
      return $3;                        # $3 = ID (see Syntax.pm)
    }

  elsif ( $text =~ /$syntax->{start_section}/ )
    {
      return $3;                        # $3 = ID (see Syntax.pm)
    }

  else
    {
      # $logger->warn("DIVISION NAME NOT FOUND IN...");

      # foreach my $line (@{$lines})
      # 	{
      # 	  my $text = $line->get_content;
      # 	  $logger->warn($text);
      # 	}
      # return '';
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
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      # skip first line if it starts a division
      if (
	  $first_line
	  and
	  (
	   $text =~ /$syntax->{start_region}/
	   or
	   $text =~ /$syntax->{start_environment}/
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
	     $text =~ /$syntax->{title_element}/
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
	     $text =~ /$syntax->{start_element}/
	    )
	{
	  return $title_text;
	}

      # preamble ending text?
      elsif ( _line_ends_preamble($text) )
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

sub extract_preamble_lines {

  # Extract preamble lines from a sequence of division lines.

  # !!! BUG HERE !!!
  #
  #   This method doesn't work for sections.

  my $self  = shift;
  my $lines = shift;

  my $sml                 = SML->instance;
  my $syntax              = $sml->get_syntax;
  my $library             = $self->get_library;
  my $ontology            = $library->get_ontology;
  my $preamble_lines      = [];
  my $divname             = $self->extract_division_name($lines);
  my $in_preamble         = 1;
  my $in_preamble_element = 0;
  my $i                   = 0;
  my $last                = scalar @{ $lines };

  foreach my $line (@{ $lines })
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      ++ $i;

      next if $i == 1;                  # skip first line
      last if $i == $last;              # skip last line

      if ( _line_ends_preamble($text) )
	{
	  return $preamble_lines;
	}

      elsif (
	     $in_preamble
	     and
	     $text =~ /$syntax->{start_element}/
	     and
	     not $ontology->allows_property($divname,$1)
	    )
	{
	  return $preamble_lines;
	}

      elsif (
	     $in_preamble
	     and
	     $text =~ /$syntax->{start_element}/
	     and
	     $ontology->allows_property($divname,$1)
	    )
	{
	  $in_preamble_element = 1;
	  push @{ $preamble_lines }, $line;
	}

      elsif (
	     $text =~ /$syntax->{paragraph_text}/
	     and
	     not $in_preamble_element
	    )
	{
	  return $preamble_lines;
	}

      elsif ( $text =~ /$syntax->{blank_line}/ )
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
  my $library             = $self->get_library;
  my $ontology            = $library->get_ontology;
  my $narrative_lines     = [];
  my $divname             = $self->extract_division_name($lines);
  my $in_preamble         = 1;
  my $in_preamble_element = 0;
  my $i                   = 0;
  my $last                = scalar @{ $lines };

  foreach my $line (@{ $lines })
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      ++ $i;

      next if $i == 1;                  # skip first line
      last if $i == $last;              # skip last line

      if ( _line_ends_preamble($text) )
	{
	  $in_preamble = 0;
	  push @{ $narrative_lines }, $line;
	}

      elsif (
	     $text =~ /$syntax->{start_element}/
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
	     $text =~ /$syntax->{start_element}/
	     and
	     $in_preamble
	     and
	     $ontology->allows_property($divname,$1)
	    )
	{
	  $in_preamble_element = 1;
	}

      elsif (
	     $text =~ /$syntax->{paragraph_text}/
	     and
	     $in_preamble_element
	    )
	{
	  # do nothing
	}

      elsif (
	     $text =~ /$syntax->{paragraph_text}/
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
	     $text =~ /$syntax->{blank_line}/
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

# has 'fragment' =>
#   (
#    isa       => 'SML::Fragment',
#    reader    => '_get_fragment',
#    writer    => '_set_fragment',
#   );

# This is the object returned by parse method, usually a document or
# an entity.

######################################################################

has 'division' =>
  (
   isa       => 'SML::Division',
   reader    => '_get_division',
   writer    => '_set_division',
  );

# This is the division object being parsed by parse method, often a
# document.

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
   predicate => '_has_block',
   clearer   => '_clear_block',
  );

# This is the current block at any given time during parsing. A block
# is a contiguous sequence of one or more whole lines of text.  Blocks
# end with either a blank line or the beginning of another
# block. Blocks cannot contain blank lines. Blocks may contain inline
# elements which span lines.

######################################################################

has 'string' =>
  (
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

has 'part_stack' =>
  (
   isa       => 'ArrayRef',
   reader    => '_get_part_stack',
   writer    => '_set_part_stack',
   clearer   => '_clear_part_stack',
   predicate => '_has_part_stack',
   default   => sub {[]},
  );

# This is a stack of nested parts at any point during document
# parsing.  A part is a contiguous sequence of blocks.  Parts may be
# nested within one another. A part has an unambiguous beginning and
# end. Sometimes the beginning and end are explicit and other times
# they are implicit.
#
#   $current_part = $part_stack->[-1];
#   $self->_push_part_stack($part);
#   my $part = $self->_pop_part_stack;

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
      $logger->debug("not using SVN, won't warn about uncommitted changes");
    }

  $self->_clear_line_list;
  $self->_set_line_list([]);

  $self->_clear_count_method_hash;
  $self->_set_count_method_hash({});

  return 1;
}

######################################################################

sub _create_empty_division {

  # Return a division object.

  my $self      = shift;
  my $line_list = shift;

  my $library  = $self->get_library;
  my $name     = $self->extract_division_name($line_list);
  my $id       = $self->extract_division_id($line_list);
  my $ontology = $library->get_ontology;
  my $class    = $ontology->get_class_for_entity_name($name);

  return $class->new(id=>$id,library=>$library);
}

######################################################################

sub _extract_division_lines {

  # Extract a sequence of lines representing a division with target_id
  # from another sequence of lines.

  my $self      = shift;
  my $line_list = shift;                # lines from which to extract division
  my $target_id = shift;                # ID of division to be extracted

  my $sml                = SML->instance;
  my $syntax             = $sml->get_syntax;
  my $lines              = [];  # Extracted lines
  my $div_stack          = [];  # stack of division names
  my $in_comment         = 0;   # in a comment division?
  my $in_target_division = 0;   # in the division targeted for extraction?

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

	  else
	    {
	      pop @{ $div_stack };

	      push @{ $lines }, $line;
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

# sub _old_resolve_includes {

#   # Scan lines, replace 'include' requests with 'included' lines.

#   my $self = shift;

#   my $sml            = SML->instance;
#   my $syntax         = $sml->get_syntax;
#   my $util           = $sml->get_util;
#   my $library        = $self->get_library;
#   my $count_method   = $self->_get_count_method_hash;
#   my $options        = $util->get_options;
#   my $max_iterations = $options->get_MAX_RESOLVE_INCLUDES;
#   my $count          = ++ $count_method->{'_resolve_includes'};
#   my $newlines       = [];
#   my $oldlines       = $self->_get_line_list;
#   my $in_comment     = 0;
#   my $depth          = 1;

#   $logger->info("($count) resolve includes");

#   if ( $count > $max_iterations )
#     {
#       my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
#       $logger->logcroak("$msg");
#     }

#  LINE:
#   foreach my $oldline (@{ $oldlines })
#     {
#       my $text     = $oldline->get_content;
#       my $location = $oldline->get_location;

#       $text =~ s/[\r\n]*$//;            # chomp;

#       #---------------------------------------------------------------
#       # Ignore comments in containing document
#       #
#       if ( $text =~ /$syntax->{comment_marker}/ )
# 	{
# 	  if ( $in_comment )
# 	    {
# 	      $in_comment = 0;
# 	    }

# 	  else
# 	    {
# 	      $in_comment = 1;
# 	    }

# 	push @{ $newlines }, $oldline;
# 	next LINE;

#       }

#       elsif ( $in_comment )
# 	{
# 	  push @{ $newlines }, $oldline;
# 	  next LINE;
# 	}

#       elsif ( $text =~ /$syntax->{'comment_line'}/ )
# 	{
# 	  push @{ $newlines }, $oldline;
# 	  next LINE;
# 	}

#       #---------------------------------------------------------------
#       # ELSIF include statement
#       #
#       elsif ( $text =~ /$syntax->{include_element}/ )
# 	{
# 	  my $asterisks         = $1 || '';
# 	  my $args              = $2 || '';
# 	  my $incl_id           = '';
# 	  my $included_filespec = '';
# 	  my $included_lines    = undef;
# 	  my $fragment          = undef;
# 	  my $division          = undef;

# 	  $logger->trace("  include element 1:$1 2:$2 3:$3 4:$4 5:$5");

# 	  #-----------------------------------------------------------
# 	  # Determine Division ID and Filespec
# 	  #
# 	  #   If the include statement syntax has BOTH a division ID
# 	  #   AND a filespec the author's intent is to extract the
# 	  #   division from the fragment.
# 	  #
# 	  if ( $3 and $5 )
# 	    {
# 	      $incl_id           = $3;
# 	      $included_filespec = $5;
# 	    }

# 	  elsif ( $3 )
# 	    {
# 	      $included_filespec = $3;
# 	    }

# 	  #-----------------------------------------------------------
# 	  # Get Fragment From Library Or Die
# 	  #
# 	  #   The fragment object should have been created by the
# 	  #   SML::Fragment::_read_file method and added to the
# 	  #   library when the fragment was created.
# 	  #
# 	  if ( $library->has_fragment( $included_filespec ) )
# 	    {
# 	      $fragment = $library->get_fragment( $included_filespec );
# 	    }

# 	  else
# 	    {
# 	      $logger->logcroak("RESOURCE DETECTED BY _resolve_includes: \'$included_filespec\'");
# 	    }

# 	  #-----------------------------------------------------------
# 	  # Get Division (If Necessary)
# 	  #
# 	  if ( $incl_id and not $library->has_division( $incl_id ) )
# 	    {
# 	      $logger->trace("  library DOESN'T have division $incl_id, extracting it from fragment...");
# 	      $included_lines = $fragment->extract_division_lines( $incl_id );
# 	    }

# 	  elsif ( $incl_id and $library->has_division( $incl_id ) )
# 	    {
# 	      $logger->trace("  library HAS division $incl_id");
# 	      $division = $library->get_division($incl_id);
# 	      $included_lines = $division->get_line_list;
# 	    }

# 	  #-----------------------------------------------------------
# 	  # IF (1) division is in the library AND (2) one or more
# 	  # asterisks are present in arguments, THEN include parsed
# 	  # division as section
# 	  #
# 	  if (
# 	      $division
# 	      and
# 	      (
# 	       $asterisks =~ /(\*+)/
# 	       or
# 	       $args =~ /(\*+):/
# 	      )
# 	     )
# 	    {
# 	      my $asterisks  = $1;
# 	      my $level      = length($asterisks);
# 	      my $title      = $division->get_property_value('title');
# 	      my $narrative  = $division->get_narrative_line_list;
# 	      my $sechead    = $self->_sechead_line($asterisks,$title);

# 	      push @{ $included_lines }, $sechead;
# 	      push @{ $included_lines }, $util->get_blank_line;

# 	      foreach my $line (@{ $narrative })
# 		{
# 		  push @{ $included_lines }, $line;
# 		}
# 	    }

# 	  #-----------------------------------------------------------
# 	  # IF (1) we have included lines AND (2) one or more
# 	  # asterisks are present in arguments, THEN include narrative
# 	  # part of extracted division lines as section
# 	  #
# 	  elsif (
# 	      $included_lines
# 	      and
# 	      (
# 	       $asterisks =~ /(\*+)/
# 	       or
# 	       $args =~ /(\*+):/
# 	      )
# 	     )
# 	    {
# 	      my $asterisks = $1;
# 	      my $level     = length($asterisks);
# 	      my $title     = $self->extract_title_text($included_lines);
# 	      my $narrative = $self->extract_narrative_lines($included_lines);
# 	      my $sechead   = $self->_sechead_line($asterisks,$title);
# 	      my $replacement_lines = [];

# 	      push @{ $replacement_lines }, $sechead;
# 	      push @{ $replacement_lines }, $util->get_blank_line;

# 	      foreach my $line (@{ $narrative })
# 		{
# 		  push @{ $replacement_lines }, $line;
# 		}

# 	      $included_lines = $replacement_lines;
# 	    }

# 	  #-----------------------------------------------------------
# 	  # include flat
# 	  #
# 	  elsif (
# 		 $division
# 		 and
# 		 $args =~ /flat:/
# 		)
# 	    {
# 	      foreach my $line (@{ $division->get_line_list }) {
# 		my $content = $line->get_content;
# 		if ($content =~ /^(title::\s|\*+\s)/)
# 		  {
# 		    $line = $self->_flatten($line);
# 		  }
# 		push( @{ $included_lines }, $line );
# 	      }
# 	    }

# 	  #-----------------------------------------------------------
# 	  # include hide
# 	  #
# 	  elsif (
# 		 $division
# 		 and
# 		 $args =~ /hide:/
# 		)
# 	    {
# 	      my $begin_line = $self->_hide_tag;
# 	      my $end_line   = $self->_hide_tag;

# 	      push @{ $included_lines }, $begin_line;

# 	      foreach my $line (@{ $division->get_line_list })
# 		{
# 		  push @{ $included_lines }, $line;
# 		}

# 	      push @{ $included_lines }, $end_line;
# 	    }

# 	  #-----------------------------------------------------------
# 	  # include raw
# 	  #
# 	  elsif (
# 		 $division
# 		 and
# 		 $args =~ /raw:/
# 		)
# 	    {
# 	      foreach my $line (@{ $division->get_line_list })
# 		{
# 		  push @{ $included_lines }, $line;
# 		}
# 	    }

# 	  #-----------------------------------------------------------
# 	  # default
# 	  #
# 	  elsif ( $division )
# 	    {
# 	      my $asterisks  = '';
# 	      $asterisks .= '*' until length($asterisks) == $depth;

# 	      my $title      = $division->get_property_value('title');
# 	      my $narrative  = $division->get_narrative_line_list;
# 	      my $sechead    = $self->_sechead_line($asterisks,$title);

# 	      push @{ $included_lines }, $sechead;
# 	      push @{ $included_lines }, $util->get_blank_line;

# 	      foreach my $line (@{ $narrative })
# 		{
# 		  push @{ $included_lines }, $line;
# 		}
# 	    }

# 	  else # NOT $incl_id
# 	    {
# 	      my $fragment = undef;

# 	      if ( $library->has_fragment($included_filespec) )
# 		{
# 		  $fragment = $library->get_fragment($included_filespec);

# 		  foreach my $line (@{ $fragment->get_line_list })
# 		    {
# 		      push @{ $included_lines }, $line;
# 		    }
# 		}

# 	      else
# 		{
# 		  $logger->warn("LIBRARY DOESN'T HAVE FRAGMENT: \'$included_filespec\' at $location");
# 		}
# 	    }

# 	  foreach my $line (@{ $included_lines })
# 	    {
# 	      push @{ $newlines }, $line;
# 	    }
# 	}

#       #---------------------------------------------------------------
#       # Section headings (to track current depth)
#       #
#       elsif ( $text =~ /^(\*+)/ )
# 	{
# 	  $depth = length($1);
# 	  push @{ $newlines }, $oldline;
# 	  next LINE;
# 	}

#       # no include statement on this line
#       else
# 	{
# 	  push @{ $newlines }, $oldline;
# 	}
#     }

#   $self->_set_line_list($newlines);

#   return 1;
# }

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
#       In other words, don't convert the title to a section, and
#       also don't convert the title to a bold string.
#
#         include::raw: my-table.txt
#
#---------------------------------------------------------------------

######################################################################

sub _resolve_includes {

  my $self = shift;

  my $count_method   = $self->_get_count_method_hash;
  my $count          = ++ $count_method->{'_resolve_includes'};
  my $sml            = SML->instance;
  my $util           = $sml->get_util;
  my $options        = $util->get_options;
  my $max_iterations = $options->get_MAX_RESOLVE_INCLUDES;

  $logger->info("($count) resolve includes");

  if ( $count > $max_iterations )
    {
      my $msg = "EXCEEDED MAX ITERATIONS ($max_iterations)";
      $logger->logcroak("$msg");
    }

  my $syntax         = $sml->get_syntax;
  my $in_comment     = 0;
  my $depth          = 1;
  my $old_line_list  = $self->_get_line_list;
  my $new_line_list  = [];

 LINE:
  foreach my $old_line (@{ $old_line_list })
    {
      my $text = $old_line->get_content;

      # process comment markers
      if ( $text =~ /$syntax->{start_comment}/ )
	{
	  $in_comment = 1;
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{end_comment}/ )
	{
	  $in_comment = 0;
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      # keep lines in comments as-is
      elsif ( $in_comment )
	{
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      # keep comment lines as-is
      elsif ( $text =~ /$syntax->{comment_line}/ )
	{
	  push @{ $new_line_list }, $old_line;
	  next LINE;
	}

      # resolve include line into replacement lines
      elsif ( $text =~ /$syntax->{include_element}/ )
	{
	  my $repl_line_list = $self->_resolve_include_line($depth,$1,$2,$3,$4,$5);
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

  # TRACE
  $logger->trace("NEW LINE LIST after resolving includes...");
  foreach my $line (@{ $new_line_list })
    {
      my $text = $line->get_content;
      chomp $text;
      $logger->trace("-> $text");
    }

  return 1;
}

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
      my $text = $line->get_content;

      #---------------------------------------------------------------
      # Ignore comments
      #
      if ( $text =~ /$syntax->{start_comment}/ )
	{
	  $in_comment = 1;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{end_comment}/ )
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

      # !!! BUG HERE !!!
      #
      # Should the 'script' feature be subject to conditional text?
      # In other words, should the parser run a script if its in a
      # division that is conditionally ignored?

      #---------------------------------------------------------------
      # script:
      #
      elsif ( $text =~ /$syntax->{script_element}/ )
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

sub _parse_lines {

  # parse lines to gather data into blocks and divisions.

  my $self = shift;

  my $sml            = SML->instance;
  my $syntax         = $sml->get_syntax;
  my $util           = $sml->get_util;
  my $options        = $util->get_options;
  my $count_method   = $self->_get_count_method_hash;
  my $max_iterations = $options->get_MAX_PARSE_LINES;
  my $count          = ++ $count_method->{'_parse_lines'};

  $logger->info("($count) parse lines");

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

  my $division    = $self->_get_division;
  my $acronyms    = $self->_get_acronym_hash;
  my $sources     = $self->_get_source_hash;
  my $index       = $self->_get_index_hash;
  my $outcome     = $self->_get_outcome_hash;
  my $review      = $self->_get_review_hash;

  my $to_be_gen   = $self->_get_to_be_gen_hash;
  my $count_total = $self->_get_count_total_hash;

  $division->init;

  $self->_begin_division($division);

  #-------------------------------------------------------------------
  # parse line-by-line
  #
 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      my $text     = $line->get_content;
      my $location = $line->get_location;

      $text =~ s/[\r\n]*$//;            # chomp;

      $logger->trace("line: $text");

      if ( $text =~ /$syntax->{start_comment}/ )
	{
	  $self->_process_start_comment_division($line);
	}

      elsif ( $text =~ /$syntax->{end_comment}/ )
	{
	  $self->_process_end_comment_division($line);
	}

      elsif ( $self->_in_comment_division )
	{
	  $self->_process_comment_division_line($line);
	}

      elsif ( $text =~ /$syntax->{blank_line}/ )
	{
	  $self->_process_blank_line($line);
	}

      elsif ( $text =~ /$syntax->{comment_line}/ )
	{
	  $self->_process_comment_line($line);
	}

      elsif ( $text =~ /$syntax->{start_conditional}/ )
	{
	  # $1 = token
	  $self->_process_start_conditional_division($line,$1);
	}

      elsif ( $text =~ /$syntax->{end_conditional}/ )
	{
	  $self->_process_end_conditional_division($line);
	}

      elsif ( $text =~ /$syntax->{start_division}/ )
	{
	  # $1 = division name
	  # $3 = divisioin ID
	  $self->_process_start_division_marker($line,$1,$3);
	}

      elsif ( $text =~ /$syntax->{end_division}/ )
	{
	  # $1 = division name
	  $self->_process_end_division_marker($line,$1);
	}

      # elsif ( $text =~ /$syntax->{start_region}/ )
      # 	{
      # 	  $self->_process_start_region_marker($line,$2);
      # 	}

      # elsif ( $text =~ /$syntax->{end_region}/ )
      # 	{
      # 	  $self->_process_end_region_marker($line,$2);
      # 	}

      # elsif ( $text =~ /$syntax->{start_environment}/ )
      # 	{
      # 	  $self->_process_environment_marker($line,$2);
      # 	}

      elsif ( $text =~ /$syntax->{start_section}/ )
	{
	  $self->_process_section_heading($line,length($1));
	}

      elsif ( $text =~ /$syntax->{end_table_row}/ )
	{
	  $self->_process_end_table_row($line);
	}

      elsif ( $text =~ /$syntax->{id_element}/ )
	{
	  $self->_process_id_element($line,$2);
	}

      elsif ( $text =~ /$syntax->{note_element}/ )
	{
	  $self->_process_start_note($line,$2);
	}

      elsif ( $text =~ /$syntax->{glossary_element}/ )
	{
	  $self->_process_start_glossary_entry($line,$1,$3);
	}

      elsif ( $text =~ /$syntax->{acronym_element}/ )
	{
	  $self->_process_start_acronym_entry($line,$1,$3);
	}

      elsif ( $text =~ /$syntax->{variable_element}/ )
	{
	  $self->_process_start_variable_definition($line,$1,$3);
	}

      elsif ( $text =~ /$syntax->{start_element}/ )
	{
	  $self->_process_start_element($line,$1);
	}

      elsif ( $text =~ /$syntax->{bull_list_item}/ )
	{
	  $self->_process_bull_list_item($line);
	}

      elsif ( $text =~ /$syntax->{enum_list_item}/ )
	{
	  $self->_process_enum_list_item($line);
	}

      elsif ( $text =~ /$syntax->{def_list_item}/ )
	{
	  $self->_process_def_list_item($line);
	}

      elsif ( $text =~ /$syntax->{table_cell}/ )
	{
	  $self->_process_start_table_cell($line);
	}

      elsif ( $text =~ /$syntax->{paragraph_text}/ )
	{
	  $self->_process_paragraph_text($line);
	}

      elsif ( $text =~ /$syntax->{indented_text}/ )
	{
	  $self->_process_indented_text($line);
	}

      elsif ( $text =~ /$syntax->{non_blank_line}/ )
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

  # $self->_end_division;

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

  elsif ( $division->isa('SML::Baretable') )
    {
      return 1;
    }

  elsif ( $division->isa('SML::Listing') )
    {
      return 1;
    }

  elsif ( $division->isa('SML::Figure') )
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

  elsif ( $division->isa('SML::Revisions') )
    {
      return 1;
    }

  elsif ( $division->isa('SML::Epigraph') )
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

  # if ( $division->isa('SML::Fragment') )
  #   {
  #     while ( $self->_in_region )
  # 	{
  # 	  $self->_end_division;
  # 	}

  #     if ( $self->_in_environment )
  # 	{
  # 	  $self->_end_division;
  # 	}
  #   }

  # if ( $division->isa('SML::Document') )
  #   {
  #     while (
  # 	     $self->_in_region
  # 	     and
  # 	     $self->_in_document
  # 	     and
  # 	     $self->_current_region ne $self->_current_document
  # 	    )
  # 	{
  # 	  $self->_end_division;
  # 	}

  #     if ( $self->_in_environment )
  # 	{
  # 	  $self->_end_division;
  # 	}
  #   }

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

  elsif ( $division->isa('SML::Division') )
    {
      # do nothing.
    }

  else
    {
      my $name = $division->get_name;
      $logger->warn("WHAT JUST HAPPENED? ($type $name)");
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
      my $text     = $line->get_content;
      my $location = $line->get_location;

      #----------------------------------------------------------------
      # insert::
      #
      if ( $text =~ /$syntax->{insert_element}/ )
	{
	  my $string = $1;
	  my $name   = $string;
	  my $args   = $3 || '';

	  $logger->trace("$name $args");

	  if ( not $sml->allows_insert($name) )
	    {
	      $logger->error("UNKNOWN INSERT NAME at $location: \"$name\"");
	      $fragment->_set_is_valid(0);

	      $text =~ s/^(.*)/# $1/;

	      my $newline = SML::Line->new
		(
		 included_from => $line,
		 content       => $text,
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
    elsif ( $text =~ /$syntax->{'insert_ins_element'}/ )
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
    elsif ( $text =~ /$syntax->{'insert_gen_element'}/ )
      {
	my $request = $1;
	my @parts   = split(';',$request);
	my $name    = $parts[0];
	my $divid   = $parts[1] || '';
	my $args    = $parts[2] || '';

	my $replacement_text = $gen_content->{$name}{$divid}{$args};

	my @new = split(/\n/s,"$replacement_text");

	foreach my $newtext (@new)
	  {
	    my $newline = SML::Line->new
	      (
	       included_from => $line,
	       content       => "$newtext\n",
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

      my $text = $block->get_content;

      next if $text =~ /$syntax->{'comment_line'}/;

      while ( $text =~ /$syntax->{variable_ref}/ )
	{
	  my $name = $1;
	  my $alt  = $3 || '';

	  if ( $library->has_variable($name,$alt) )
	    {
	      # substitute variable value
	      my $value = $library->get_variable_value($name,$alt);

	      $text =~ s/$syntax->{variable_ref}/$value/;

	      $logger->trace("substituted $name $alt variable with $value");
	    }

	  else
	    {
	      # error handling
	      my $location = $block->get_location;
	      $logger->warn("UNDEFINED VARIABLE: \'$name\' at $location");
	      $self->_set_is_valid(0);
	      $fragment->_set_is_valid(0);

	      $text =~ s/$syntax->{variable_ref}/$name/;
	    }
	}

      $block->set_content($text);
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

      my $text = $block->get_content;

      next if $text =~ /$syntax->{'comment_line'}/;

      while ( $text =~ /$syntax->{lookup_ref}/ )
	{
	  my $name = $2;
	  my $id   = $3;

	  if ( $library->has_property($id,$name) )
	    {
	      $logger->trace("..... $id $name is in library");
	      my $value = $library->get_property_value($id,$name);

	      $text =~ s/$syntax->{lookup_ref}/$value/;
	    }

	  else
	    {
	      my $location = $block->get_location;
	      my $msg = "LOOKUP FAILED: at $location: \'$id\' \'$name\'";
	      $logger->warn($msg);
	      $self->_set_is_valid(0);
	      # $fragment->_set_is_valid(0);

	      $text =~ s/$syntax->{lookup_ref}/($msg)/;
	    }
	}

      $block->set_content($text);
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
      my $num  = $line->get_num;        # line number in file
      my $text = $line->get_content;    # line content

      #---------------------------------------------------------------
      # Ignore comments
      #
      if ( $text =~ /$syntax->{start_comment}/ )
	{
	  $in_comment = 1;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{end_comment}/ )
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
      # Process template element
      #
      elsif ( $text =~ /$syntax->{template_element}/ )
	{
	  my $attrs     = $1;
	  my $template  = $4;
	  my $comment   = $6;
	  my $variables = {};
	  my $tmpltext  = '';

	  if ( not -f $template )
	    {
	      my $cwd = getcwd;
	      $logger->logcroak("NO TEMPLATE FILE \"$template\" (from \"$cwd\")");
	    }

	  elsif ( exists $self->_get_template_hash->{$template} )
	    {
	      $tmpltext = $self->_get_template_hash->{$template};
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
	      $tmpltext = $file->get_text;
	      $self->_get_template_hash->{$template} = $tmpltext;
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
	      $tmpltext =~ s/\[var:$key\]/$value/g;
	    }

	  for my $newlinetext ( split(/\n/s, $tmpltext) )
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
      my $text = $line->get_content;    # line content

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
      $docid = '' if $text =~ /$syntax->{start_document}/;
      $docid = '' if $text =~ /$syntax->{end_document}/;
      $docid = $2 if $text =~ /$syntax->{id_element}/ and not $docid;

      #----------------------------------------------------------------
      # generate::
      #
      if ( $text =~ /$syntax->{generate_element}/ )
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
  my $division        = $self->_get_division;
  my $section_list    = $division->get_section_list;

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
  my $division       = $self->_get_division;
  my $division_list  = $division->get_division_list;

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
  my $divname  = $division->get_name;
  my $divid    = $division->get_id;
  my $document = $self->_current_document;
  my $reasoner = $library->get_reasoner;

  $reasoner->infer_inverse_property($element);

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
  # because it is called BEFORE _parse_lines builds arrays of blocks
  # and elements.

  my $self = shift;

  my $sml            = SML->instance;
  my $syntax         = $sml->get_syntax;
  my $in_comment     = 0;
  my $in_conditional = '';

 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      if ( $text =~ /$syntax->{start_comment}/ )
	{
	  $in_comment = 1;
	  next LINE;                    # ignore start of comment
	}

      elsif ( $text =~ /$syntax->{end_comment}/ )
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
	  $logger->debug("$text");
	  $logger->debug("unresolved include: $&");
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

  my $sml        = SML->instance;
  my $syntax     = $sml->get_syntax;
  my $in_comment = 0;

 LINE:
  foreach my $line ( @{ $self->_get_line_list } )
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      #---------------------------------------------------------------
      # Ignore comments
      #
      if ( $text =~ /$syntax->{start_comment}/ )
	{
	  $in_comment = 1;
	  next LINE;
	}

      elsif ( $text =~ /$syntax->{end_comment}/ )
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
	  $logger->debug("$text");
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
	  $logger->debug("$text");
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

  my $division   = $self->_get_division;
  my $block_list = $division->get_block_list;

  foreach my $block ( @{ $block_list } )
    {
      next if $block->isa('SML::CommentBlock');
      next if $block->is_in_a('SML::CommentDivision');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('SML::PreformattedDivision');

      my $text = $block->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      next if $text =~ /$syntax->{'comment_line'}/;

      if ( $text =~ /$syntax->{variable_ref}/ )
	{
	  $logger->debug("$text");
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

  my $division   = $self->_get_division;
  my $block_list = $division->get_block_list;

  foreach my $block ( @{ $block_list } )
    {
      next if $block->isa('SML::CommentBlock');
      next if $block->is_in_a('SML::CommentDivision');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('SML::PreformattedDivision');

      my $text = $block->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      next if $text =~ /$syntax->{'comment_line'}/;

      if ( $text =~ /$syntax->{lookup_ref}/ )
	{
	  $logger->debug("$text");
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

  my $division   = $self->_get_division;
  my $block_list = $division->get_block_list;

  foreach my $block ( @{ $block_list } )
    {
      next if $block->isa('CommentBlock');
      next if $block->is_in_a('SML::CommentDivision');

      my $text = $block->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      if (    $text =~ /^template::/                   # deprecate someday
	   or $text =~ /^(-){3,}template/              # deprecate someday
	   or $text =~ /^(\.){3,}template/             # deprecate someday
	   or $text =~ /$syntax->{template_element}/
	 )
	{
	  $logger->debug("$text");
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

  my $division     = $self->_get_division;
  my $element_list = $division->get_element_list;

  # check for unresolved elements
  foreach my $element ( @{ $element_list } )
    {
      my $text = $element->get_content;

      if ( $text =~ /$syntax->{include_element}/ )
	{
	  $logger->debug("$text");
	  $logger->debug("unresolved include: $&");
	  return 1;
	}

      elsif ( $text =~ /$syntax->{script_element}/ )
	{
	  $logger->debug("$text");
	  $logger->debug("unresolved script: $&");
	  return 1;
	}

      elsif (   $text =~ /$syntax->{'insert_element'}/
	     or $text =~ /$syntax->{'insert_ins_element'}/
	     or $text =~ /$syntax->{'insert_gen_element'}/
	    )
	{
	  $logger->debug("$text");
	  $logger->debug("unresolved insert: $&");
	  return 1;
	}

      elsif ( $text =~ /^template::/ )
	{
	  $logger->debug("$text");
	  $logger->debug("unresolved template: $&");
	  return 1;
	}

      elsif ( $text =~ /$syntax->{generate_element}/ )
	{
	  $logger->debug("$text");
	  $logger->debug("unresolved generate: $&");
	  return 1;
	}
    }

  # check for unresolved inline text
  my $block_list = $division->get_block_list;

  foreach my $block ( @{ $block_list } )
    {
      next if $block->isa('SML::CommentBlock');
      next if $block->is_in_a('SML::CommentDivision');
      next if $block->isa('SML::PreformattedBlock');
      next if $block->is_in_a('SML::PreformattedDivision');

      my $text = $block->get_content;

      next if $text =~ /$syntax->{'comment_line'}/;

      if ( $text =~ /$syntax->{variable_ref}/ )
	{
	  $logger->debug("$text");
	  $logger->debug("unresolved variable: $&");
	  return 1;
	}

      elsif ( $text =~ /$syntax->{lookup_ref}/ )
	{
	  $logger->debug("$text");
	  $logger->debug("unresolved lookup: $&");
	  return 1;
	}

      elsif (   $text =~ /^(-){3,}template/
	     or $text =~ /^(\.){3,}template/
	 )
	{
	  $logger->debug("$text");
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
	my $name = $division->get_name;
	my $id   = $division->get_id;
	$logger->warn("NO CHILD PROPERTY ($name $id)");
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
  my $text     = $element->get_content;

  $text =~ s/[\r\n]*$//;                # chomp;

  if ( $text =~ /$syntax->{review_element}/ )
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
      $logger->error("INVALID REVIEW SYNTAX at $location ($text)");
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

# sub _process_comment_division_marker {

#   my $self = shift;
#   my $line = shift;

#   $logger->trace("----- comment division marker");

#   my $library = $self->get_library;

#   # new preformatted block
#   my $block = SML::PreformattedBlock->new(library=>$library);
#   $block->add_line($line);
#   $self->_begin_block($block);

#   if ( not $self->_in_comment_division )
#     {
#       # new comment division
#       my $name    = 'comment';
#       my $num     = $self->_count_comment_divisions;
#       my $id      = "$name-$num";
#       my $comment = SML::CommentDivision->new(id=>$id,library=>$library);

#       $comment->add_part($block);

#       $self->_begin_division($comment);
#     }

#   else
#     {
#       # end comment division
#       my $division = $self->_get_current_division;

#       $division->add_part( $block );

#       $self->_end_division;
#     }

#   return 1;
# }

######################################################################

sub _process_start_comment_division {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- start comment division");

  my $library = $self->get_library;

  # new preformatted block
  my $block = SML::PreformattedBlock->new(library=>$library);
  $block->add_line($line);
  $self->_begin_block($block);

  # new comment division
  my $name    = 'comment';
  my $num     = $self->_count_comment_divisions;
  my $id      = "$name-$num";
  my $comment = SML::CommentDivision->new(id=>$id,library=>$library);

  $comment->add_part($block);

  $self->_begin_division($comment);

  return 1;
}

######################################################################

sub _process_end_comment_division {

  my $self = shift;
  my $line = shift;

  $logger->trace("----- end comment division");

  my $library = $self->get_library;

  # new preformatted block
  my $block = SML::PreformattedBlock->new(library=>$library);
  $block->add_line($line);
  $self->_begin_block($block);

  # end comment division
  my $division = $self->_get_current_division;

  $division->add_part( $block );

  $self->_end_division;

  return 1;
}

######################################################################

sub _process_comment_line {

  my $self = shift;
  my $line = shift;

  my $library = $self->get_library;

  $logger->trace("----- comment line");

  if ( not $self->_in_comment_block )
    {
      $logger->trace("..... begin comment block");

      my $block = SML::CommentBlock->new(library=>$library);
      $block->add_line($line);
      $self->_begin_block($block);

      my $division = $self->_get_current_division;
      $division->add_part( $block );
    }

  else
    {
      $logger->trace("..... continue comment block");

      my $block = $self->_get_block;
      $block->add_line($line);
    }

  return 1;
}

######################################################################

sub _process_comment_division_line {

  my $self = shift;
  my $line = shift;

  my $library = $self->get_library;

  $logger->trace("----- line in comment division");

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

# sub _process_conditional_division_marker {

#   my $self  = shift;
#   my $line  = shift;
#   my $token = shift;

#   my $library   = $self->get_library;
#   my $blockname = '';

#   $logger->trace("----- conditional marker ($token)");

#   if ( $self->_in_conditional )
#     {
#       $blockname = 'END_CONDITIONAL';
#     }

#   else
#     {
#       $blockname = 'BEGIN_CONDITIONAL';
#     }

#   my $block = SML::PreformattedBlock->new(name=>$blockname,library=>$library);
#   $block->add_line($line);
#   $self->_begin_block($block);

#   if ( $self->_in_conditional )
#     {
#       my $conditional = $self->_current_conditional;

#       if ( not $conditional->get_token eq $token )
# 	{
# 	  my $location = $line->get_location;

# 	  $logger->trace("..... ERROR: not in conditional ($token)");
# 	  my $msg = "INVALID END OF CONDITIONAL at $location not in conditional \"$token\"";
# 	  $logger->logcroak("$msg");
# 	}

#       $conditional->add_part($block);
#       $self->_end_division;
#     }

#   else
#     {
#       my $name        = 'conditional';
#       my $num         = $self->_count_conditionals;
#       my $id          = "$name-$num";
#       my $conditional = SML::Conditional->new
# 	(
# 	 id          => $id,
# 	 token       => $token,
# 	 library     => $library,
# 	);

#       $conditional->add_part($block);

#       $self->_begin_division($conditional);
#     }

#   return 1;
# }

######################################################################

sub _process_start_conditional_division {

  my $self  = shift;
  my $line  = shift;
  my $token = shift;

  $logger->trace("----- start conditional division ($token)");

  my $library   = $self->get_library;
  my $blockname = 'BEGIN_CONDITIONAL';

  my $block = SML::PreformattedBlock->new(name=>$blockname,library=>$library);
  $block->add_line($line);
  $self->_begin_block($block);

  my $name        = 'conditional';
  my $num         = $self->_count_conditionals;
  my $id          = "$name-$num";
  my $conditional = SML::Conditional->new
    (
     id          => $id,
     token       => $token,
     library     => $library,
    );

  $conditional->add_part($block);

  $self->_begin_division($conditional);

  return 1;
}

######################################################################

sub _process_end_conditional_division {

  my $self  = shift;
  my $line  = shift;

  $logger->trace("----- end conditional");

  my $library   = $self->get_library;
  my $blockname = 'END_CONDITIONAL';

  my $block = SML::PreformattedBlock->new(name=>$blockname,library=>$library);
  $block->add_line($line);
  $self->_begin_block($block);

  my $conditional = $self->_current_conditional;

  $conditional->add_part($block);
  $self->_end_division;

  return 1;
}

######################################################################

# sub _process_start_region_marker {

#   my $self = shift;
#   my $line = shift;
#   my $name = shift;

#   my $location = $line->get_location;
#   my $library  = $self->get_library;
#   my $ontology = $library->get_ontology;

#   $logger->trace("----- region begin marker ($name)");

#   if ( not $ontology->allows_region($name) )
#     {
#       my $msg      = "UNDEFINED REGION at $location: \"$name\"";

#       $logger->logdie("$msg");
#     }

#   if ( $self->_in_baretable )
#     {
#       $self->_end_baretable;
#     }

#   # can't have a region inside an environment
#   if ( $self->_in_environment )
#     {
#       my $environment = $self->_current_environment;
#       my $envname  = $environment->get_name;
#       $logger->fatal("INVALID BEGIN REGION at $location: $name inside $envname");
#     }

#   # new preformatted BEGIN block
#   my $block = SML::PreformattedBlock->new
#     (
#      name    => 'BEGIN_REGION',
#      library => $library,
#     );

#   $block->add_line($line);
#   $self->_begin_block($block);

#   my $region = undef;

#   if ( $name eq 'DOCUMENT' )
#     {
#       # new document region
#       my $num   = $self->_count_regions;
#       my $id    = "$name-$num";
#       my $class = $ontology->get_class_for_entity_name($name);

#       $region = $class->new(id=>$id,library=>$library);

#       $region->add_part($block);
#     }

#   else
#     {
#       # new non-document region
#       my $num   = $self->_count_regions;
#       my $id    = "$name-$num";
#       my $class = $ontology->get_class_for_entity_name($name);

#       $region = $class->new
# 	(
# 	 name    => $name,
# 	 id      => $id,
# 	 library => $library,
# 	);

#       $region->add_part($block);
#     }

#   $self->_begin_division($region);

#   return 1;
# }

######################################################################

sub _process_start_division_marker {

  my $self = shift;
  my $line = shift;                     # start division marker
  my $name = shift;                     # division name
  my $id   = shift || q{};              # division ID

  my $location = $line->get_location;
  my $library  = $self->get_library;
  my $ontology = $library->get_ontology;

  $logger->trace("----- start division ($name.$id)");

  if ( not $ontology->allows_division($name) )
    {
      my $msg = "UNDEFINED DIVISION at $location: \"$name\"";
      $logger->logdie("$msg");
    }

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  # new preformatted BEGIN block
  my $block = SML::PreformattedBlock->new
    (
     name    => 'BEGIN_DIVISION',
     library => $library,
    );

  $block->add_line($line);
  $self->_begin_block($block);

  my $division = undef;

  if ( $name eq 'DOCUMENT' )
    {
      # new document division
      $division = SML::Document->new(id=>$id,library=>$library);

      $division->add_part($block);
    }

  else
    {
      if ( not $id )
	{
	  my $num = $self->_count_divisions;
	  $id = "$name-$num";
	}

      # new non-document division
      my $class = $ontology->get_class_for_entity_name($name);

      $division = $class->new
	(
	 name    => $name,
	 id      => $id,
	 library => $library,
	);

      $division->add_part($block);
    }

  $self->_begin_division($division);

  return 1;
}

######################################################################

# sub _process_end_region_marker {

#   my $self = shift;
#   my $line = shift;
#   my $name = shift;

#   my $library  = $self->get_library;
#   my $location = $line->get_location;

#   $logger->trace("----- region end marker ($name)");

#   if ( not $self->_in_region )
#     {
#       my $msg = "INVALID END REGION at $location: not in region";
#       $logger->logdie("$msg");
#     }

#   if (
#       $self->_in_region
#       and
#       not $self->_current_region->get_name eq $name
#      )
#     {
#       my $msg = "INVALID END REGION at $location: not in $name region";
#       $logger->logdie("$msg");
#     }

#   if ( $self->_in_baretable )
#     {
#       $self->_end_baretable;
#     }

#   if ( $self->_in_environment )
#     {
#       my $envname = $self->_current_environment->get_name;
#       my $msg = "INVALID END REGION at $location: $name end inside $envname";
#       $logger->logdie("$msg");
#     }

#   if ( $name eq 'DOCUMENT' )
#     {
#       my $division = $self->_get_current_division;
#       while ( not $division->isa('SML::Document') )
# 	{
# 	  $self->_end_division;
# 	  $division = $self->_get_current_division;
# 	}
#     }

#   # new preformatted block
#   my $block = SML::PreformattedBlock->new
#     (
#      name    => 'END_REGION',
#      library => $library,
#     );

#   $block->add_line($line);
#   $self->_begin_block($block);
#   $self->_get_current_division->add_part($block);
#   $self->_end_division;

#   return 1;
# }

######################################################################

sub _process_end_division_marker {

  my $self = shift;
  my $line = shift;
  my $name = shift;

  my $library  = $self->get_library;
  my $location = $line->get_location;

  $logger->trace("----- end division ($name)");

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  # new preformatted block
  my $block = SML::PreformattedBlock->new
    (
     name    => 'END_DIVISION',
     library => $library,
    );

  $block->add_line($line);
  $self->_begin_block($block);
  $self->_get_current_division->add_part($block);
  $self->_end_division;

  return 1;
}

######################################################################

# sub _process_environment_marker {

#   my $self = shift;
#   my $line = shift;
#   my $name = shift;

#   my $location  = $line->get_location;
#   my $library   = $self->get_library;
#   my $ontology  = $library->get_ontology;
#   my $blockname = '';

#   $logger->trace("----- environment marker ($name)");

#   if ( not $ontology->allows_environment($name) )
#     {
#       my $msg = "UNKNOWN ENVIRONMENT at $location: \"$name\"";
#       $logger->logcroak("$msg");
#     }

#   if (
#       $self->_in_environment
#       and
#       not $self->_current_environment->get_name eq $name
#      )
#     {
#       my $msg = "INVALID END ENVIRONMENT: can't end \"$name\" environment at $location";
#       $logger->logcroak("$msg");
#     }

#   if ( $self->_in_baretable )
#     {
#       $self->_end_baretable;
#     }


#   if (
#       $self->_in_environment
#       and
#       $self->_current_environment->get_name eq $name
#      )
#     {
#       $blockname = 'END_ENVIRONMENT';
#     }

#   else
#     {
#       $blockname = 'BEGIN_ENVIRONMENT';
#     }

#   my $block = SML::PreformattedBlock->new(name=>$blockname,library=>$library);
#   $block->add_line($line);
#   $self->_begin_block($block);

#   my $division = $self->_get_current_division;

#   if ( $self->_in_table )
#     {
#       $division->add_part($block);
#       $self->_end_table;
#     }

#   elsif ( not $self->_in_environment )
#     {
#       my $num         = $self->_count_environments;
#       my $id          = "$name-$num";
#       my $class       = $ontology->get_class_for_entity_name($name);
#       my $environment = $class->new
# 	(
# 	 name    => $name,
# 	 id      => $id,
# 	 library => $library,
# 	);

#       $environment->add_part($block);

#       $self->_begin_division($environment);
#     }

#   else
#     {
#       $division->add_part($block);
#       $self->_end_division;
#     }

#   return 1;
# }

######################################################################

sub _process_section_heading {

  my $self  = shift;
  my $line  = shift;
  my $depth = shift;

  my $library  = $self->get_library;
  my $location = $line->get_location;

  $logger->trace("----- section heading");

  if ( $self->_in_baretable )
    {
      $self->_end_baretable;
    }

  # if ( $self->_in_environment )
  #   {
  #     my $name = $self->_current_environment->get_name;
  #     my $msg = "INVALID SECTION HEADING IN ENVIRONMENT at $location: $name";
  #     $logger->logdie("$msg");
  #   }

  # if (
  #     $self->_in_region
  #     and
  #     not $self->_current_region eq $self->_current_document
  #    )
  #   {
  #     my $name = $self->_current_region->get_name;
  #     my $msg = "INVALID SECTION HEADING IN REGION at $location: $name";
  #     $logger->logdie("$msg");
  #   }

  # end previous section
  if ( $self->_in_section )
    {
      $self->_end_section;
    }

  # new title element
  $logger->trace("..... new title");
  my $element = SML::Element->new(name=>'title',library=>$library);
  $element->add_line($line);
  $self->_begin_block($element);

  # new section
  my $num     = $self->_count_sections;
  my $id      = "section-$num";
  my $section = SML::Section->new
    (
     depth    => $depth,
     id       => $id,
     library  => $library,
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

  my $name     = 'END_TABLE_ROW';
  my $library  = $self->get_library;
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

  $logger->trace("----- blank line");

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
  my $element = SML::Element->new(name=>'id',library=>$library);
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

  my $library  = $self->get_library;
  my $ontology = $library->get_ontology;
  my $location = $line->get_location;
  my $division = $self->_get_current_division;
  my $divname  = $division->get_name;

  my $element = SML::Element->new(name=>$name,library=>$library);

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

  my $library  = $self->get_library;
  my $division = $self->_get_current_division;
  my $divname  = $division->get_name;

  $logger->trace("----- element (NOTE)");

  my $element = SML::Note->new
    (
     tag      => $tag,
     division => $division,
     library  => $library,
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

  my $definition = SML::Definition->new
    (
     name    => 'glossary',
     library => $library,
    );

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

  my $sml       = SML->instance;
  my $util      = $sml->get_util;
  my $library   = $self->get_library;
  my $document  = $self->_current_document || undef;

  my $division = $self->_get_current_division;
  my $divname  = $division->get_name;

  $logger->trace("----- element (ACRONYM DEFINITION)");

  my $definition = SML::Definition->new
    (
     name    => 'acronym',
     term    => $term,
     alt     => $alt,
     library => $library,
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

  my $sml      = SML->instance;
  my $util     = $sml->get_util;
  my $library  = $self->get_library;
  my $division = $self->_get_current_division;
  my $divname  = $division->get_name;

  $logger->trace("----- element (VARIABLE DEFINITION)");

  my $definition = SML::Definition->new
    (
     name    => 'var',
     term    => $term,
     alt     => $alt,
     library => $library,
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

  my $library = $self->get_library;

  $logger->trace("----- bullet list item");

  $self->_end_preamble if $self->_in_preamble;

  if ( $self->_in_preformatted_division )
    {
      my $block = SML::PreformattedBlock->new(library=>$library);
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  else
    {
      my $block = SML::BulletListItem->new(library=>$library);
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

  my $library = $self->get_library;

  $logger->trace("----- enumerated list item");

  $self->_end_preamble if $self->_in_preamble;

  if ( $self->_in_preformatted_division )
    {
      my $block = SML::PreformattedBlock->new(library=>$library);
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  else
    {
      my $block = SML::EnumeratedListItem->new(library=>$library);
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

  my $library = $self->get_library;

  $logger->trace("----- definition list item");

  $self->_end_preamble if $self->_in_preamble;

  if ( $self->_in_preformatted_division )
    {
      my $block = SML::PreformattedBlock->new(library=>$library);
      $block->add_line($line);
      $self->_begin_block($block);
      $self->_get_current_division->add_part($block);
    }

  else
    {
      my $block = SML::DefinitionListItem->new(library=>$library);
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

  my $library = $self->get_library;

  $logger->trace("----- table cell");

  $self->_end_preamble if $self->_in_preamble;

  # new block
  my $block = SML::Paragraph->new(name=>'paragraph',library=>$library);
  $block->add_line($line);
  $self->_begin_block($block);

  if (
      not $self->_in_table
      and
      not $self->_in_baretable
     )
    {
      # new BARE_TABLE
      my $tnum      = $self->_count_baretables + 1;
      my $tid       = "BARE_TABLE-$tnum";
      my $baretable = SML::Baretable->new(id=>$tid,library=>$library);

      $self->_begin_division($baretable);

      # new BARE_TABLE_ROW
      my $rnum     = $self->_count_table_rows + 1;
      my $rid      = "BARE_TABLE_ROW-$tnum-$rnum";
      my $tablerow = SML::TableRow->new(id=>$rid,library=>$library);

      $self->_begin_division($tablerow);

      # new BARE_TABLE_CELL
      my $cnum      = $self->_count_table_cells + 1;
      my $cid       = "BARE_TABLE_CELL-$tnum-$rnum-$cnum";
      my $tablecell = SML::TableCell->new(id=>$cid,library=>$library);

      $tablecell->add_part($block);
      $self->_begin_division($tablecell);
    }

  elsif (
	 $self->_in_baretable
	 and
	 not $self->_in_table_row
	)
    {
      # new BARE_TABLE_ROW
      my $tnum     = $self->_count_baretables;
      my $rnum     = $self->_count_table_rows + 1;
      my $rid      = "BARE_TABLE_ROW-$tnum-$rnum";
      my $tablerow = SML::TableRow->new(id=>$rid,library=>$library);

      $self->_begin_division($tablerow);

      # new BARE_TABLE_CELL
      my $cnum      = $self->_count_table_cells + 1;
      my $cid       = "BARE_TABLE_CELL-$tnum-$rnum-$cnum";
      my $tablecell = SML::TableCell->new(id=>$cid,library=>$library);

      $tablecell->add_part($block);
      $self->_begin_division($tablecell);
    }

  elsif (
	 $self->_in_table
	 and
	 not $self->_in_table_row
	)
    {
      # new TABLE_ROW
      my $tnum     = $self->_count_tables;
      my $rnum     = $self->_count_table_rows + 1;
      my $rid      = "TABLE_ROW-$tnum-$rnum";
      my $tablerow = SML::TableRow->new(id=>$rid,library=>$library);

      $self->_begin_division($tablerow);

      # new TABLE_CELL
      my $cnum      = $self->_count_table_cells + 1;
      my $cid       = "TABLE_CELL-$tnum-$rnum-$cnum";
      my $tablecell = SML::TableCell->new(id=>$cid,library=>$library);

      $tablecell->add_part($block);
      $self->_begin_division($tablecell);
    }

  elsif ( $self->_in_baretable )
    {
      # end previous TABLE_CELL
      $self->_end_division;

      # new TABLE_CELL
      my $tnum      = $self->_count_baretables;
      my $rnum      = $self->_count_table_rows;
      my $cnum      = $self->_count_table_cells + 1;
      my $cid       = "BARE_TABLE_CELL-$tnum-$rnum-$cnum";
      my $tablecell = SML::TableCell->new(id=>$cid,library=>$library);

      $tablecell->add_part($block);
      $self->_begin_division($tablecell);
    }

  elsif ( $self->_in_table )
    {
      # end previous TABLE_CELL
      $self->_end_division;

      # new TABLE_CELL
      my $tnum      = $self->_count_tables;
      my $rnum      = $self->_count_table_rows;
      my $cnum      = $self->_count_table_cells + 1;
      my $cid       = "TABLE_CELL-$tnum-$rnum-$cnum";
      my $tablecell = SML::TableCell->new(id=>$cid,library=>$library);

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

  my $library = $self->get_library;

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
      if ( $self->_has_block )
	{
	  my $block = $self->_get_block;
	  $block->add_line($line);
	}

      else
	{
	  $logger->trace("..... new preformatted block");

	  my $block = SML::PreformattedBlock->new(library=>$library);
	  $block->add_line($line);
	  $self->_begin_block($block);
	  $self->_get_current_division->add_part($block);
	}
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

      my $paragraph = SML::Paragraph->new(library=>$library);
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

  my $library = $self->get_library;

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

  my $library  = $self->get_library;
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
      my $block = SML::PreformattedBlock->new(library=>$library);
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

sub _push_part_stack {

  my $self = shift;
  my $part = shift;

  push @{ $self->_get_part_stack }, $part;

  return 1;
}

######################################################################

sub _pop_part_stack {

  my $self = shift;

  return pop @{ $self->_get_part_stack };
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

  my $division      = $self->_get_division;
  my $division_list = $division->get_division_list;

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

  my $division      = $self->_get_division;
  my $division_list = $division->get_division_list;

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

# sub _count_regions {

#   my $self = shift;

#   my $count = 0;

#   my $fragment      = $self->_get_fragment;
#   my $division_list = $fragment->get_division_list;

#   foreach my $division (@{ $division_list })
#     {
#       if ( $division->isa('SML::Region') )
# 	{
# 	  ++ $count;
# 	}
#     }

#   return $count;
# }

######################################################################

# sub _count_environments {

#   my $self = shift;

#   my $count = 0;

#   my $fragment      = $self->_get_fragment;
#   my $division_list = $fragment->get_division_list;

#   foreach my $division (@{ $division_list })
#     {
#       if ( $division->isa('SML::Environment') )
# 	{
# 	  ++ $count;
# 	}
#     }

#   return $count;
# }

######################################################################

sub _count_divisions {

  my $self = shift;

  my $count = 0;

  my $division      = $self->_get_division;
  my $division_list = $division->get_division_list;

  return scalar @{ $division_list };
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

  my $division      = $self->_get_division;
  my $division_list = $division->get_division_list;

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

  my $division      = $self->_get_division;
  my $division_list = $division->get_division_list;

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

# sub _in_region {

#   my $self = shift;

#   my $division = $self->_get_current_division;

#   while ( $division and not $division->isa('SML::Fragment') )
#     {
#       if ( $division->isa('SML::Region') )
# 	{
# 	  return 1;
# 	}

#       else
# 	{
# 	  $division = $division->get_containing_division;
# 	}
#     }

#   return 0;
# }

######################################################################

# sub _in_environment {

#   my $self = shift;

#   my $division = $self->_get_current_division;

#   while ( $division and not $division->isa('SML::Fragment') )
#     {
#       if ( $division->isa('SML::Environment') )
# 	{
# 	  return 1;
# 	}

#       else
# 	{
# 	  $division = $division->get_containing_division;
# 	}
#     }

#   return 0;
# }

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

# sub _current_environment {

#   my $self = shift;

#   my $division = $self->_get_current_division;

#   while ( $division and not $division->isa('SML::Fragment') )
#     {
#       if ( $division->isa('SML::Environment') )
# 	{
# 	  return $division;
# 	}

#       else
# 	{
# 	  $division = $division->get_containing_division;
# 	}
#     }

#   return 0;
# }

######################################################################

# sub _current_region {

#   my $self = shift;

#   my $division = $self->_get_current_division;

#   while ( $division and not $division->isa('SML::Fragment') )
#     {
#       if ( $division->isa('SML::Region') )
# 	{
# 	  return $division;
# 	}

#       else
# 	{
# 	  $division = $division->get_containing_division;
# 	}
#     }

#   return 0;
# }

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

  my $text = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  if (
         $text =~ /$syntax->{start_region}/
      or $text =~ /$syntax->{start_environment}/
      or $text =~ /$syntax->{start_section}/
      or $text =~ /$syntax->{generate_element}/
      or $text =~ /$syntax->{insert_element}/
      or $text =~ /$syntax->{template_element}/
      or $text =~ /$syntax->{include_element}/
      or $text =~ /$syntax->{script_element}/
      or $text =~ /$syntax->{outcome_element}/
      or $text =~ /$syntax->{review_element}/
      or $text =~ /$syntax->{index_element}/
      or $text =~ /$syntax->{glossary_element}/
      or $text =~ /$syntax->{list_item}/
      # or $text =~ /$syntax->{paragraph_text}/
      # or $text =~ /$syntax->{indented_text}/
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

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  if ( $self->_is_single_string($text) )
    {
      $logger->warn("text DOES NOT contain substring: $text");
      return 0;
    }

  foreach my $string_type (@{ $self->_get_string_type_list })
    {
      if ( not exists $syntax->{$string_type} )
	{
	  $logger->error("THIS SHOULD NEVER HAPPEN \'$string_type\'");
	  return 0;
	}

      if ( $text =~ /$syntax->{$string_type}/ )
	{
	  return $string_type;
	}
    }

  return 0;
}

######################################################################

sub _get_next_substring_type {

  # Given a string that is being gobbled up by the parser, detect the
  # NEXT substring in the string and return the string type.  Note
  # that the string may contain several substrings.  This method must
  # return the string type of the FIRST (i.e. NEXT) substring in the
  # text.

  my $self = shift;
  my $text = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $href   = {};                      # result hash

  foreach my $string_type (@{ $self->_get_string_type_list })
    {
      if ( not exists $syntax->{$string_type} )
	{
	  $logger->error("THIS SHOULD NEVER HAPPEN \'$string_type\'");
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
     'dblquote_string',
     'sglquote_string',

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
     # 'open_dblquote_symbol',
     # 'close_dblquote_symbol',
     # 'open_sglquote_symbol',
     # 'close_sglquote_symbol',
     'section_symbol',
     'emdash_symbol',
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
     # 'open_dblquote_symbol',
     # 'close_dblquote_symbol',
     # 'open_sglquote_symbol',
     # 'close_sglquote_symbol',
     'section_symbol',
     'emdash_symbol',
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

  if (
      not ref $block
      or
      not $block->isa('SML::Block')
     )
    {
      $logger->error("CAN'T PARSE NON-BLOCK \'$block\'");
      return 0;
    }

  $self->_set_block($block);

  # If this is a comment block, don't parse it into parts.
  if ( $block->isa('SML::CommentBlock') )
    {
      $self->_clear_block;
      return 1;
    }

  # If this is a pre-formatted block, don't parse it into parts.
  if ( $block->isa('SML::PreformattedBlock') )
    {
      $self->_clear_block;
      return 1;
    }

  my $text = $block->get_content;

  while ( $text )
    {
      $text = $self->_parse_next_substring($block,$text);
    }

  $self->_clear_block;

  return 1;
}

######################################################################

sub _parse_text {

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
  my $part = shift;                     # part to which this text belongs
  my $text = shift;                     # text to parse

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $block;

  if ( ref $part and $part->isa('SML::Block') )
    {
      $block = $part;
    }

  elsif ( ref $part and $part->isa('SML::String') )
    {
      $block = $part->get_containing_block;
    }

  else
    {
      $logger->error("THIS SHOULD NEVER HAPPEN (3) \'$part\'");
    }

  if ( my $string_type = $self->_get_next_substring_type($text) )
    {
      if ( $text =~ /$syntax->{$string_type}/p )
	{
	  my $preceding_text = ${^PREMATCH};
	  my $substring      = ${^MATCH};

	  if ( $preceding_text )
	    {
	      my $newstring1 = $self->create_string($preceding_text);
	      $part->add_part($newstring1);
	    }

	  my $newstring2 = $self->create_string($substring);
	  $part->add_part($newstring2);

	  $text = ${^POSTMATCH};

	  return $text;
	}

      else
	{
	  $logger->error("THIS SHOULD NEVER HAPPEN (5)");
	}
    }

  else
    {
      my $newstring = $self->create_string($text);
      $part->add_part($newstring);

      $text = q{};

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

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  foreach my $string_type (@{ $self->_get_string_type_list })
    {
      if ( not exists $syntax->{$string_type} )
	{
	  $logger->error("THIS SHOULD NEVER HAPPEN \'$string_type\'");
	  return 0;
	}

      if ( $text =~ /^$syntax->{$string_type}$/ )
	{
	  return $string_type;
	}
    }

  return 'string';
}

######################################################################

sub _has_part {

  my $self = shift;

  my $part_stack   = $self->_get_part_stack;
  my $current_part = $part_stack->[-1];

  if ( defined $current_part )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub _get_part {

  my $self = shift;

  my $part_stack = $self->_get_part_stack;

  return $part_stack->[-1];
}

######################################################################

sub _is_single_string {

  # Return 1 if the text represents a symbol.

  my $self = shift;
  my $text = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

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

  my $self  = shift;
  my $depth = shift;                    # current section depth
  my $one   = shift;                    # leading asterisks
  my $two   = shift;                    # args
  my $three = shift;                    # included ID
  my $four  = shift;                    # not used
  my $five  = shift;                    # comment text

  my $library = $self->get_library;

  my $asterisks      = $one || '';      # desired section depth
  my $args           = $two || '';      # arguments
  my $included_id    = $three;          # ID of included division
  my $repl_line_list = [];              # replacement line list

  # get list of lines to include
  my $line_list;

  if ( $included_id )
    {
      my $file = $library->get_file_containing($included_id);
      $line_list = $file->get_line_list;
    }

  else
    {
      $logger->logcroak("THIS SHOULD NEVER HAPPEN");
    }

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

  my $sml  = SML->instance;
  my $util = $sml->get_util;
  my $nll  = [];                        # new line list

  my $title     = $self->extract_title_text($oll);
  my $narrative = $self->extract_narrative_lines($oll);
  my $asterisks = q{};

  $asterisks .= '*' until length($asterisks) == $depth;

  my $sechead = $self->_sechead_line($asterisks,$title);

  push @{ $nll }, $sechead;
  push @{ $nll }, $util->get_blank_line;

  foreach my $line (@{ $narrative })
    {
      push @{ $nll }, $line;
    }

  return $nll;
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
  my $fragment = $parser->create_fragment($filename);
  my $object   = $parser->create_string($text);
  my $string   = $parser->extract_division_name($lines);
  my $string   = $parser->extract_title_text($lines);
  my $lines    = $parser->extract_preamble_lines($lines);
  my $lines    = $parser->extract_narrative_lines($lines);

=head1 DESCRIPTION

A parser creates fragment objects from raw SML text stored in files,
creates string objects from blocks of text, and extracts data from
sequences of line objects.

=head1 METHODS

=head2 get_library

=head2 create_fragment($filename)

=head2 create_string($text)

=head2 extract_division_name($lines)

=head2 extract_title_text($lines)

=head2 extract_preamble_lines($lines)

=head2 extract_narrative_lines($lines)

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
