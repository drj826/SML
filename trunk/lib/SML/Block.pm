#!/usr/bin/perl

# $Id$

package SML::Block;

use Moose;

extends 'SML::Part';

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use lib "..";

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Block');

use Cwd;

use SML;                 # ci-000002

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has 'name_path' =>
  (
   isa       => 'Str',
   reader    => 'get_name_path',
   lazy      => 1,
   builder   => '_build_name_path',
  );

######################################################################

has 'line_list' =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_line_list',
   writer    => 'set_line_list',
   clearer   => 'clear_line_list',
   predicate => 'has_line_list',
   default   => sub {[]},
  );

######################################################################

has 'containing_division' =>
  (
   isa       => 'SML::Division',
   reader    => 'get_containing_division',
   writer    => 'set_containing_division',
   clearer   => 'clear_containing_division',
   predicate => 'has_containing_division',
  );

# The division that contains this block.

after 'set_containing_division' => sub {
  my $self = shift;
  my $cd = $self->get_containing_division;
  $logger->trace("..... containing division for \'$self\' now: \'$cd\'");
};

######################################################################

has 'valid_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_syntax',
   lazy      => 1,
   builder   => '_validate_syntax',
  );

######################################################################

has 'valid_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_semantics',
   lazy      => 1,
   builder   => '_validate_semantics',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_line {

  # Add a line to this block.

  my $self = shift;
  my $line = shift;

  if ( $line->isa('SML::Line') )
    {
      push @{ $self->get_line_list }, $line;
      return 1;
    }

  else
    {
      $logger->("CAN'T ADD LINE \'$line\' is not a line");
      return 0;
    }

}

######################################################################

sub add_part {

  # Only a string can be part of a block.

  my $self = shift;
  my $part = shift;

  if (
      not
      (
       ref $part
       or
       $part->isa('SML::String')
      )
     )
    {
      $logger->error("CAN'T ADD PART \'$part\' is not a string");
      return 0;
    }

  $part->set_containing_block( $self );

  push @{ $self->get_part_list }, $part;

  $logger->trace("add part $part");

  return 1;
}

######################################################################

sub get_first_line {

  # Return the first line of this block.

  my $self = shift;

  if ( defined $self->get_line_list->[0] )
    {
      return $self->get_line_list->[0];
    }

  else
    {
      # $logger->error("FIRST LINE DOESN'T EXIST");
      return 0;
    }
}

######################################################################

sub get_location {

  # Return the location (filespec + line number) of the first line of
  # this block.

  my $self = shift;

  my $line = $self->get_first_line;

  if ( ref $line and $line->isa('SML::Line') )
    {
      return $line->get_location;
    }

  else
    {
      return 'UNKNOWN LOCATION';
    }

}

######################################################################

sub is_in_a {

  # Return 1 if this block is "in a" division of "type" (even if it is
  # buried several divisions deep).

  my $self = shift;
  my $type = shift;

  my $division = $self->get_containing_division || q{};

  while ( $division )
    {
      if ( $division->isa($type) )
	{
	  return 1;
	}

      elsif ( $division->has_containing_division )
	{
	  $division = $division->get_containing_division;
	}

      else
	{
	  return 0;
	}
    }

  return 0;
}

######################################################################

sub _validate_bold_markup_syntax {

  # Return 1 if valid, 0 if not. Validate this block contains no
  # unbalanced bold markup.

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $count  = 0;
  my $text   = $self->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{bold}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $location = $self->get_location;
      $logger->warn("INVALID BOLD MARKUP at $location");
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

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $count  = 0;
  my $text   = $self->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{italics}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $location = $self->get_location;
      $logger->warn("INVALID ITALICS MARKUP at $location");
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

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $count  = 0;
  my $text   = $self->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{fixedwidth}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $location = $self->get_location;
      $logger->warn("INVALID FIXED-WIDTH MARKUP at $location");
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

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $count  = 0;
  my $text   = $self->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{underline}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $location = $self->get_location;
      $logger->warn("INVALID UNDERLINE MARKUP at $location");
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

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $count  = 0;
  my $text   = $self->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{superscript}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $location = $self->get_location;
      $logger->warn("INVALID SUPERSCRIPT MARKUP at $location");
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

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $count  = 0;
  my $text   = $self->get_content;

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{subscript}/gxms )
    {
      ++ $count;
    }

  if ( $count % 2 == 1 )
    {
      my $location = $self->get_location;
      $logger->warn("INVALID SUBSCRIPT MARKUP at $location");
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

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $valid  = 1;
  my $text   = $self->get_content;

  $text = $util->remove_literals($text);
  $text = $util->remove_keystroke_symbols($text);

  while ( $text =~ /$syntax->{inline_tag}/xms )
    {
      my $tag  = $1;
      my $name = $2;

      if ( $name !~ /$syntax->{valid_inline_tags}/xms )
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID INLINE TAG \'$tag\' at $location");
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

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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
      my $location = $self->get_location;
      $logger->warn("INVALID CROSS REFERENCE SYNTAX at $location");
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_cross_ref_semantics {

  # Validate this block's cross references.  Return 1 if valid, 0 if
  # not.

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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
  my $doc   = $self->get_containing_document;

  if ( not $doc )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate cross references");
      return 0;
    }

  while ( $text =~ /$syntax->{cross_ref}/xms )
    {
      my $id = $2;

      if ( $doc->contains_division($id) )
	{
	  $logger->trace("cross reference to \'$id\' is valid");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID CROSS REFERENCE \'$id\' not defined at $location");
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

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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
      my $location = $self->get_location;
      $logger->warn("INVALID ID REFERENCE SYNTAX at $location");
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_id_ref_semantics {

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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
  my $doc   = $self->get_containing_document;

  if ( not $doc )
    {
      $logger->error("CAN'T VALIDATE ID REFERENCES not in document context");
      return 0;
    }

  while ( $text =~ /$syntax->{id_ref}/xms )
    {
      my $id = $1;

      if ( $doc->contains_division($id) )
	{
	  $logger->trace("id reference to \'$id\' is valid");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID ID REFERENCE \'$id\' not defined at $location");
	  $valid = 0;
	}

      $text =~ s/$syntax->{id_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_page_ref_syntax {

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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
      my $location = $self->get_location;
      $logger->warn("INVALID PAGE REFERENCE SYNTAX at $location");
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_page_ref_semantics {

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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
  my $doc   = $self->get_containing_document;

  if ( not $doc )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate page references");
      return 0;
    }

  while ( $text =~ /$syntax->{page_ref}/xms )
    {
      my $id = $2;

      if ( $doc->contains_division($id) )
	{
	  $logger->trace("page reference to \'$id\' is valid");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID PAGE REFERENCE \'$id\' not defined at $location");
	  $valid = 0;
	}

      $text =~ s/$syntax->{page_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_theversion_ref_semantics {

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

  if ( not $text =~ /$syntax->{theversion_ref}/xms )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;
  my $doc   = $self->get_containing_document;

  if ( not $doc )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate version references");
      return 0;
    }

  while ( $text =~ /$syntax->{theversion_ref}/xms )
    {
      if ( $doc->has_property('version') )
	{
	  $logger->trace("version reference is valid");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID VERSION REFERENCE at $location document has no version property");
	  $valid = 0;
	}

      $text =~ s/$syntax->{theversion_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_therevision_ref_semantics {

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

  if ( not $text =~ /$syntax->{therevision_ref}/xms )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;
  my $doc   = $self->get_containing_document;

  if ( not $doc )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate revision references");
      return 0;
    }

  while ( $text =~ /$syntax->{therevision_ref}/xms )
    {
      if ( $doc->has_property('revision') )
	{
	  $logger->trace("revision reference is valid");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID REVISION REFERENCE at $location document has no revision property");
	  $valid = 0;
	}

      $text =~ s/$syntax->{therevision_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_thedate_ref_semantics {

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

  if ( not $text =~ /$syntax->{thedate_ref}/xms )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;
  my $doc   = $self->get_containing_document;

  if ( not $doc )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate date references");
      return 0;
    }

  while ( $text=~ /$syntax->{thedate_ref}/xms )
    {
      if ( $doc->has_property('date') )
	{
	  $logger->trace("date reference is valid");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID DATE REFERENCE at $location document has no date property");
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

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $valid  = 1;
  my $text   = $self->get_content;

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

	  if ( not $self->get_containing_document )
	    {
	      $logger->error("NOT IN DOCUMENT CONTEXT can't validate status references");
	      return 0;
	    }

	  my $library = $util->get_library;

	  if ( $library->has_division($id) )
	    {
	      my $division = $library->get_division($id);

	      if ( not $division->has_property('status') )
		{
		  my $location = $self->get_location;
		  $logger->warn("INVALID STATUS REFERENCE at $location \'$id\' has no status property");
		  $valid = 0;
		}
	    }

	  else
	    {
	      my $location = $self->get_location;
	      $logger->warn("INVALID STATUS REFERENCE at $location \'$id\' not defined");
	      $valid = 0;
	    }
	}

      $text =~ s/$syntax->{status_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_glossary_term_ref_syntax {

  # Validate that each glossary term reference has a valid glossary
  # entry.  Glossary term references are inline tags like '[g:term]'
  # or '[g:alt:term]'.

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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
      my $location = $self->get_location;
      $logger->warn("INVALID GLOSSARY TERM REFERENCE SYNTAX at $location");
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_glossary_term_ref_semantics {

  # Validate that each glossary term reference has a valid glossary
  # entry.  Glossary term references are inline tags like '[g:term]'
  # or '[g:alt:term]'.

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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

  if ( not $self->get_containing_document )
    {
      $logger->error("CAN'T VALIDATE GLOSSARY TERM REFERENCES not in document context");
      return 0;
    }

  my $library = $util->get_library;

  while ( $text =~ /$syntax->{gloss_term_ref}/xms )
    {
      my $alt  = $3 || q{};
      my $term = $4;

      if ( $library->get_glossary->has_entry($term,$alt) )
	{
	  $logger->trace("term \'$term\' alt \'$alt\' is in glossary");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("TERM NOT IN GLOSSARY \'$alt\' \'$term\' at $location");
	  $valid = 0;
	}

      $text =~ s/$syntax->{gloss_term_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_glossary_def_ref_syntax {

  # Validate that each glossary definition reference has a valid
  # glossary entry.  Glossary definition references are inline tags
  # like '[def:term]'.

  my $self = shift;

  my $sml     = SML->instance;
  my $syntax  = $sml->get_syntax;
  my $util    = $sml->get_util;
  my $text    = $self->get_content;

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
      my $location = $self->get_location;
      $logger->warn("INVALID GLOSSARY DEFINITION REFERENCE SYNTAX at $location");
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_glossary_def_ref_semantics {

  # Validate that each glossary definition reference has a valid
  # glossary entry.  Glossary definition references are inline tags
  # like '[def:term]'.

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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

  if ( not $self->get_containing_document )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate glossary definition references");
      return 0;
    }

  my $library = $util->get_library;

  while ( $text =~ /$syntax->{gloss_def_ref}/xms )
    {
      my $alt  = $2 || q{};
      my $term = $3;

      if ( $library->get_glossary->has_entry($term,$alt) )
	{
	  $logger->trace("definition \'$term\' alt \'$alt\' is in glossary");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("DEFINITION NOT IN GLOSSARY \'$alt\' \'$term\' at $location");
	  $valid = 0;
	}

      $text =~ s/$syntax->{gloss_def_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_acronym_ref_syntax {

  # Validate that each acronym reference has a valid acronym list
  # entry.  Acronym references are inline tags like '[ac:term]'
  # or '[ac:alt:term]'.

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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
      my $location = $self->get_location;
      $logger->warn("INVALID ACRONYM REFERENCE SYNTAX: at $location");
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_acronym_ref_semantics {

  # Validate that each acronym reference has a valid acronym list
  # entry.  Acronym references are inline tags like '[ac:term]'
  # or '[ac:alt:term]'.

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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

  if ( not $self->get_containing_document )
    {
      $logger->error("CAN'T VALIDATE ACRONYM REFERENCES: not in document context");
      return 0;
    }

  my $library = $util->get_library;

  while ( $text =~ /$syntax->{acronym_term_ref}/xms )
    {
      my $alt     = $3 || q{};
      my $acronym = $4;

      if ( $library->get_acronym_list->has_acronym($acronym,$alt) )
	{
	  $logger->trace("acronym \'$acronym\' alt \'$alt\' is in acronym list");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("ACRONYM NOT IN ACRONYM LIST: \'$acronym\' \'$alt\' at $location");
	  $valid = 0;
	}

      $text =~ s/$syntax->{acronym_term_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_source_citation_syntax {

  # Validate that each source citation has a valid source in the
  # library's list of references.  Source citations are inline tags
  # like '[cite:cms15]'

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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
      my $location = $self->get_location;
      $logger->warn("INVALID SOURCE CITATION SYNTAX at $location");
      $valid = 0;
    }

  return $valid;
}

######################################################################

sub _validate_source_citation_semantics {

  # Validate that each source citation has a valid source in the
  # library's list of references.  Source citations are inline tags
  # like '[cite:cms15]'

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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

  if ( not $self->get_containing_document )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate source citations");
      return 0;
    }

  my $library = $util->get_library;

  while ( $text =~ /$syntax->{citation_ref}/xms )
    {
      my $source = $2;
      my $note   = $3;

      if ( not $library->get_references->has_source($source) )
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID SOURCE CITATION source \'$source\' not defined at $location");
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

  my $self = shift;

  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;
  my $text   = $self->get_content;

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

  my $library        = $self->get_library;
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

  if ( not $found_file )
    {
      $valid = 0;
      my $location = $self->get_location;
      $logger->warn("FILE NOT FOUND \'$resource_spec\' at $location");
    }

  return $valid;
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has 'valid_bold_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_bold_markup_syntax',
   lazy      => 1,
   builder   => '_validate_bold_markup_syntax',
  );

######################################################################

has 'valid_italics_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_italics_markup_syntax',
   lazy      => 1,
   builder   => '_validate_italics_markup_syntax',
  );

######################################################################

has 'valid_fixedwidth_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_fixedwidth_markup_syntax',
   lazy      => 1,
   builder   => '_validate_fixedwidth_markup_syntax',
  );

######################################################################

has 'valid_underline_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_underline_markup_syntax',
   lazy      => 1,
   builder   => '_validate_underline_markup_syntax',
  );

######################################################################

has 'valid_superscript_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_superscript_markup_syntax',
   lazy      => 1,
   builder   => '_validate_superscript_markup_syntax',
  );

######################################################################

has 'valid_subscript_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_subscript_markup_syntax',
   lazy      => 1,
   builder   => '_validate_subscript_markup_syntax',
  );

######################################################################

has 'valid_cross_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_cross_ref_syntax',
   lazy      => 1,
   builder   => '_validate_cross_ref_syntax',
  );

######################################################################

has 'valid_id_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_id_ref_syntax',
   lazy      => 1,
   builder   => '_validate_id_ref_syntax',
  );

######################################################################

has 'valid_page_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_page_ref_syntax',
   lazy      => 1,
   builder   => '_validate_page_ref_syntax',
  );

######################################################################

has 'valid_glossary_term_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_glossary_term_ref_syntax',
   lazy      => 1,
   builder   => '_validate_glossary_term_ref_syntax',
  );

######################################################################

has 'valid_glossary_def_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_glossary_def_ref_syntax',
   lazy      => 1,
   builder   => '_validate_glossary_def_ref_syntax',
  );

######################################################################

has 'valid_acronym_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_acronym_ref_syntax',
   lazy      => 1,
   builder   => '_validate_acronym_ref_syntax',
  );

######################################################################

has 'valid_source_citation_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_source_citation_syntax',
   lazy      => 1,
   builder   => '_validate_source_citation_syntax',
  );

######################################################################

has 'valid_cross_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_cross_ref_semantics',
   lazy      => 1,
   builder   => '_validate_cross_ref_semantics',
  );

######################################################################

has 'valid_id_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_id_ref_semantics',
   lazy      => 1,
   builder   => '_validate_id_ref_semantics',
  );

######################################################################

has 'valid_page_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_page_ref_semantics',
   lazy      => 1,
   builder   => '_validate_page_ref_semantics',
  );

######################################################################

has 'valid_theversion_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_theversion_ref_semantics',
   lazy      => 1,
   builder   => '_validate_theversion_ref_semantics',
  );

######################################################################

has 'valid_therevision_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_therevision_ref_semantics',
   lazy      => 1,
   builder   => '_validate_therevision_ref_semantics',
  );

######################################################################

has 'valid_thedate_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_thedate_ref_semantics',
   lazy      => 1,
   builder   => '_validate_thedate_ref_semantics',
  );

######################################################################

has 'valid_status_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_status_ref_semantics',
   lazy      => 1,
   builder   => '_validate_status_ref_semantics',
  );

######################################################################

has 'valid_glossary_term_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_glossary_term_ref_semantics',
   lazy      => 1,
   builder   => '_validate_glossary_term_ref_semantics',
  );

######################################################################

has 'valid_glossary_def_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_glossary_def_ref_semantics',
   lazy      => 1,
   builder   => '_validate_glossary_def_ref_semantics',
  );

######################################################################

has 'valid_acronym_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_acronym_ref_semantics',
   lazy      => 1,
   builder   => '_validate_acronym_ref_semantics',
  );

######################################################################

has 'valid_source_citation_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_source_citation_semantics',
   lazy      => 1,
   builder   => '_validate_source_citation_semantics',
  );

######################################################################

has 'valid_file_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_file_ref_semantics',
   lazy      => 1,
   builder   => '_validate_file_ref_semantics',
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _build_content {

  my $self  = shift;
  my $lines = [];

  if ( $self->get_name eq 'empty_block' )
    {
      return q{};
    }

  foreach my $line (@{ $self->get_line_list })
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp

      push @{ $lines }, $text;
    }

  my $content = join(q{ }, @{ $lines });

  return $content;
}

######################################################################

sub _build_name_path {

  my $self       = shift;
  my $containers = [];
  my $name       = $self->get_name;
  my $container  = $self->get_containing_division;

  push @{ $containers }, $name;

  while ( ref $container )
    {
      my $container_name = $container->get_name;
      push @{ $containers }, $container_name;

      $container = $container->get_containing_division;
    }

  my $name_path = join('.', reverse @{ $containers });

  return $name_path;
}

######################################################################

sub _render_html_internal_references {

  # [ref:fig-drawing] ==> <a href="figure-1-2">Figure 1.2</a>
  #   [r:fig-drawing] ==> <a href="figure-1-2">Figure 1.2</a>

  my $self   = shift;
  my $html   = shift;
  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;
  my $util   = $sml->get_util;

  return $html if not $html =~ $syntax->{cross_ref};

  my $doc = $self->get_containing_document;

  if ( not $doc )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't resolve internal cross references");

      while ( $html =~ $syntax->{cross_ref} )
	{
	  my $id     = $2;
	  my $string = "(broken ref to \'$id\')";
	  $html =~ s/$syntax->{cross_ref}/$string/xms;
	}

      return $html;
    }

  my $library = $util->get_library;

  while ( $html =~ $syntax->{cross_ref} ) {

    my $id     = $2;
    my $string = q{};

    if ( $library->has_division($id) )
      {
	my $division = $library->get_division($id);
	my $name     = $division->get_name;   # i.e. SECTION

	$name = lc( $name );
	$name = ucfirst ( $name );

	my $number   = $division->get_number; # i.e. 1-2
	my $outfile  = $doc->get_html_outfile_for($id);
	my $target   = "$outfile#$name.$number";

	$string = "<a href=\"$target\">$name $number<\/a>";
      }

    else
      {
	my $location = $self->get_location;
	$logger->warn("REFERENCED ID DOESN'T EXIST \'$id\' at $location");

	$string = "<font color=\"red\">(broken cross ref to $id)<\/font>";
      }

    $html =~ s/$syntax->{cross_ref}/$string/xms;
  }

  return $html;
}

######################################################################

sub _render_html_url_references {

  my $self   = shift;
  my $html   = shift;
  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  if ( not $html =~ $syntax->{url_ref} )
    {
      return $html;
    }

  while ( $html =~ $syntax->{url_ref} )
    {
      my $url    = $1;
      my $string = "<a href=\"$url\">$url<\/a>";

      $html =~ s/$syntax->{url_ref}/$string/xms;
    }

  return $html;
}

######################################################################

sub _render_html_footnote_references {

  my $self   = shift;
  my $html   = shift;
  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  return $html if not $html =~ $syntax->{footnote_ref};

  my $doc = $self->get_containing_document;

  if ( not $doc )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't resolve footnote references");
      return $html;
    }

  while ( $html =~ $syntax->{footnote_ref} )
    {
      my $id     = $1;
      my $tag    = $2;
      my $string = q{};

      if ( $doc->has_note($id,$tag) )
	{
	  $string = "<span style=\"font-size: 8pt;\"><sup><a href=\"#footnote.$id.$tag\">$tag<\/a><\/sup><\/span>";
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("NOTE NOT FOUND: \'$id\' \'$tag\'");
	  $string = "(note not found \'$id\' \'$tag\')";
	}

      $html =~ s/$syntax->{footnote_ref}/$string/xms;
  }

  return $html;
}

######################################################################

# sub _render_html_glossary_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   if ( $html !~ $syntax->{gloss_term_ref} )
#     {
#       return $html;
#     }

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT: can't resolve glossary references");
#       return $html;
#     }

#   my $util     = $sml->get_util;
#   my $library  = $util->get_library;
#   my $glossary = $library->get_glossary;

#   while ( $html =~ $syntax->{gloss_term_ref} )
#     {
#       my $type   = $1;
#       my $alt    = $3;
#       my $term   = $4;
#       my $string = q{};

#     if ( $glossary->has_entry($term,$alt) )
#       {
# 	my $filename = $doc->get_html_glossary_filename;
# 	my $target_term = lc($term);
# 	$target_term =~ s/\s+/_/gxms;
# 	my $target  = "$filename#$target_term:$alt";
# 	my $displayed_term = $term;

# 	if ( $type eq 'Gls' or $type eq 'G' ) {
# 	  $displayed_term = ucfirst($term);
# 	}

# 	$string = "<a href=\"$target\">$displayed_term</a>";
#       }

#     else
#       {
# 	$logger->warn("CAN'T RENDER GLOSSARY REFERENCE: \'$term\' \'$alt\'");

# 	my $displayed_term = $term;

# 	if ( $type eq 'Gls' or $type eq 'G' ) {
# 	  $displayed_term = ucfirst($term);
# 	}

# 	$string = "$displayed_term";
#       }

#       $html =~ s/$syntax->{gloss_term_ref}/$string/xms;
#   }

#   return $html;
# }

######################################################################

# sub _render_html_acronym_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $html if not $html =~ $syntax->{acronym_term_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve acronym references");
#       return $html;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $html =~ $syntax->{acronym_term_ref} )
#     {
#       my $type   = $1;
#       my $alt    = $3;
#       my $term   = $4;
#       my $string = q{};

#       if ( $library->get_acronym_list->has_acronym($term,$alt) )
# 	{
# 	  my $filename = $doc->get_html_acronyms_filename;
# 	  my $target_term = lc($term);
# 	  $target_term =~ s/\s+/_/gxms;
# 	  my $target  = "$filename#$target_term:$alt";
# 	  my $displayed_term = $term;

# 	  if ( $type eq 'acl' ) {
# 	    my $definition = $library->get_acronym_list->get_acronym($term,$alt);
# 	    $displayed_term = $definition->get_value;
# 	  }

# 	  $string = "<a href=\"$target\">$displayed_term</a>";

# 	}
#       else
# 	{
# 	  $string = $term;
# 	}

#       $html =~ s/$syntax->{acronym_term_ref}/$string/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_index_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $html =~ $syntax->{index_ref} )
#     {
#       my $term = $2;
#       $html =~ s/$syntax->{index_ref}/$term/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_id_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $html if not $html =~ $syntax->{id_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve ID references");
#       return $html;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $html =~ $syntax->{id_ref} )
#     {
#       my $id     = $1;
#       my $string = q{};

#       if ( $library->has_division($id) )
# 	{
# 	  my $division = $library->get_division($id);
# 	  my $name     = $division->get_name;        # i.e. TABLE

# 	  $name = lc( $name );
# 	  $name = ucfirst( $name );

# 	  my $number   = $division->get_number;      # i.e. 1-2
# 	  my $outfile  = $doc->get_html_outfile_for($id);
# 	  my $target   = "$outfile#$name.$number";

# 	  $string   = "<a href=\"$target\">$name $number<\/a>";
# 	}

#       else
# 	{
# 	  my $location = $self->get_location;
# 	  $logger->warn("REFERENCED ID DOESN'T EXIST \'$id\' at $location");
# 	  $string = "<font color=\"red\">(broken ID ref to $id)<\/font>";
# 	}

#       $html =~ s/$syntax->{id_ref}/$string/xms;
#     }

#   return $html;

# }

######################################################################

# sub _render_html_thepage_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $html =~ $syntax->{thepage_ref} )
#     {
#       $html =~ s/$syntax->{thepage_ref}//xms;
#     }

#   return $html;

# }

######################################################################

# sub _render_html_page_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $html if not $html =~ $syntax->{page_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve PAGE references");
#       return $html;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $html =~ $syntax->{page_ref} )
#     {
#       my $id     = $2;
#       my $string = q{};

#       if ( $library->has_division($id) )
# 	{
# 	  my $division = $library->get_division($id);
# 	  my $name     = $division->get_name;        # i.e. TABLE

# 	  $name = lc( $name );
# 	  $name = ucfirst( $name );

# 	  my $number   = $division->get_number;      # i.e. 1-2
# 	  my $outfile  = $doc->get_html_outfile_for($id);
# 	  my $target   = "$outfile#$name.$number";

# 	  $string = "<a href=\"$target\">link<\/a>";
# 	}

#       else
# 	{
# 	  my $location = $self->get_location;
# 	  $logger->warn("BROKEN PAGE REF, REFERENCED ID DOESN'T EXIST \'$id\' at $location");
# 	  $string = "<font color=\"red\">(broken page ref to $id)<\/font>";
# 	}

#       $html =~ s/$syntax->{page_ref}/$string/xms;
#   }

#   return $html;
# }

######################################################################

# sub _render_html_theversion_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $html if not $html =~ $syntax->{theversion_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve version references");
#       return $html;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;
#   my $id      = $doc->get_id;
#   my $version = q{};

#   if ( $doc->has_property('version') )
#     {
#       $version = $doc->get_property_value('version');
#     }

#   else
#     {
#       my $location = $self->get_location;
#       logger->warn("DOCUMENT HAS NO VERSION at $location");
#       $version = '(no document version)';
#     }

#   while ( $html =~ $syntax->{theversion_ref} )
#     {
#       $html =~ s/$syntax->{theversion_ref}/$version/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_therevision_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $html if not $html =~ $syntax->{therevision_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve revision references");
#       return $html;
#     }

#   my $util     = $sml->get_util;
#   my $library  = $util->get_library;
#   my $id       = $doc->get_id;
#   my $revision = q{};

#   if ( $doc->has_property('revision') )
#     {
#       $revision = $doc->get_property_value('revision');
#     }

#   else
#     {
#       my $location = $self->get_location;
#       logger->warn("DOCUMENT HAS NO REVISION at $location");
#       $revision = '(no document revision)';
#     }

#   while ( $html =~ $syntax->{therevision_ref} )
#     {
#       $html =~ s/$syntax->{therevision_ref}/$revision/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_thedate_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $html if not $html =~ $syntax->{thedate_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve date references");
#       return $html;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;
#   my $id      = $doc->get_id;
#   my $date    = q{};

#   if ( $doc->has_property('date') )
#     {
#       $date = $doc->get_property_value('date');
#     }

#   else
#     {
#       my $location = $self->get_location;
#       logger->warn("DOCUMENT HAS NO DATE at $location");
#       $date = '(no document date)';
#     }

#   while ( $html =~ $syntax->{thedate_ref} )
#     {
#       $html =~ s/$syntax->{thedate_ref}/$date/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_status_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $html if not $html =~ $syntax->{status_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve status references");
#       return $html;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $html =~ $syntax->{status_ref} )
#     {
#       my $id     = $1;
#       my $string = q{};

#       if ( $library->has_division($id) )
# 	{
# 	  my $division = $library->get_division($id);
# 	  my $status   = $division->get_property_value('status');

# 	  if ( $status =~ $syntax->{valid_status} )
# 	    {
# 	      $string = $doc->get_html_status_icon($status);
# 	    }

# 	  elsif ( $status =~ $syntax->{blank_line} )
# 	    {
# 	      $string = "<font color=\"red\">(no status assigned to $id)<\/font>";
# 	    }

# 	  else
# 	    {
# 	      $string = $doc->get_html_status_icon('invalid');
# 	    }
# 	}

#       elsif ( $id =~ $syntax->{valid_status} )
# 	{
# 	  my $status = $id;
# 	  $string = $doc->get_html_status_icon($status);
# 	}

#       else
# 	{
# 	  my $location = $self->get_location;
# 	  logger->warn("DIVISION HAS NO STATUS \'$id\' at $location");
# 	  $string = "<font color=\"red\">(broken status reference to $id)<\/font>";
# 	}

#       $html =~ s/$syntax->{status_ref}/$string/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_citation_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $html if not $html =~ $syntax->{citation_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve citation references");
#       return $html;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $html =~ $syntax->{citation_ref} )
#     {
#       my $source = $2;
#       my $other  = $4;
#       my $string = q{};

#       if ( $library->get_references->has_source($source) )
# 	{
# 	  my $filename = $doc->get_html_sources_filename;
# 	  my $target   = "$filename#$source";

# 	  if ($other)
# 	    {
# 	      $string = "[<a href=\"$target\">$source, $other</a>]";
# 	    }
# 	  else
# 	    {
# 	      $string = "[<a href=\"$target\">$source</a>]";
# 	    }
# 	}

#       else
# 	{
# 	  my $location = $self->get_location;
# 	  $logger->warn("BROKEN SOURCE CITATION to \'$source\' at $location");
# 	  $string = "<font color=\"red\">(broken citation to $source)<\/font>";
# 	}

#       $html =~ s/$syntax->{citation_ref}/$string/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_latex_internal_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{cross_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("CAN'T RESOLVE INTERNAL CROSS REFERENCES not in document context");

#       while ( $latex =~ $syntax->{cross_ref} )
# 	{
# 	  my $id     = $2;
# 	  my $string = "(broken ref to \'$id\')";
# 	  $latex =~ s/$syntax->{cross_ref}/$string/xms;
# 	}

#       return $latex;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $latex =~ $syntax->{cross_ref} )
#     {
#       my $id     = $2;
#       my $string = q{};

#       if ( $library->has_division($id) )
# 	{
# 	  my $division = $library->get_division($id);
# 	  my $name     = $division->get_name;

# 	  $name = lc( $name );
# 	  $name = ucfirst( $name );

# 	  $string = "$name~\\vref{$id}";
# 	}

#     else
#       {
# 	my $location = $self->get_location;
# 	$logger->warn("REFERENCED ID DOESN'T EXIST \'$id\' at $location");

# 	$string = "(broken ref to \'$id\')";
#       }

#       $latex =~ s/$syntax->{cross_ref}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_url_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{url_ref};

#   while ( $latex =~ $syntax->{url_ref} )
#     {
#       my $url    = $1;
#       my $string = "\\urlstyle{sf}\\url{$url}";

#       $latex =~ s/$syntax->{url_ref}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_footnote_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{footnote_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("CAN'T RESOLVE NOTE REFERENCES: not in document context");

#       while ( $latex =~ $syntax->{footnote_ref} )
# 	{
# 	  my $id     = $1;
# 	  my $tag    = $2;
# 	  my $string = "(broken note ref to \'$id\' \'$tag\')";

# 	  $latex =~ s/$syntax->{footnote_ref}/$string/xms;
# 	}

#       return $latex;
#     }

#   while ( $latex =~ $syntax->{footnote_ref} )
#     {
#       my $id     = $1;
#       my $tag    = $2;
#       my $string = q{};

#       if ( $doc->has_note($id,$tag) )
# 	{
# 	  my $note = $doc->get_note($id,$tag);
# 	  my $text = $note->get_value;

# 	  $string = "\\footnote{$text}";
# 	}

#       else
# 	{
# 	  my $location = $self->get_location;
# 	  $logger->warn("BROKEN NOTE REFERENCE: to \'$id\' \'$tag\' at $location");
# 	  $string = "(broken note ref to \'$id\' \'$tag\')";
# 	}

#       $latex =~ s/$syntax->{footnote_ref}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_glossary_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{gloss_term_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("CAN'T RESOLVE GLOSSARY REFERENCES not in document context");

#       while ( $latex =~ $syntax->{gloss_term_ref} )
# 	{
# 	  my $type   = $1;
# 	  my $alt    = $3;
# 	  my $term   = $4;
# 	  my $string = "(broken glossary ref to \'$type\' \'$alt\' \'$term\')";

# 	  $latex =~ s/$syntax->{gloss_term_ref}/$string/xms;
# 	}

#       return $latex;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $latex =~ $syntax->{gloss_term_ref} )
#     {
#       my $type           = $1;
#       my $alt            = $3;
#       my $term           = $4;
#       my $displayed_term = $term;
#       my $string         = q{};

#       if ( $library->get_glossary->has_entry($term,$alt) )
# 	{

# 	  if ( $type eq 'Gls' or $type eq 'G' )
# 	    {
# 	      $string = "\\Gls{$term:$alt}";
# 	    }

# 	  else
# 	    {
# 	      $string = "\\gls{$term:$alt}";
# 	    }
# 	}

#       else
# 	{
# 	  $string = $term;
# 	}

#       $latex =~ s/$syntax->{gloss_term_ref}/$string/xms;
#   }

#   return $latex;
# }

######################################################################

# sub _render_latex_acronym_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{acronym_term_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve acronym references");

#       while ( $latex =~ $syntax->{acronym_term_ref} )
# 	{
# 	  my $type   = $1;
# 	  my $alt    = $3;
# 	  my $term   = $4;
# 	  my $string = "(broken acronym ref to \'$type\' \'$alt\' \'$term\')";

# 	  $latex =~ s/$syntax->{acronym_term_ref}/$string/xms;
# 	}

#       return $latex;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $latex =~ $syntax->{acronym_term_ref} )
#     {
#       my $type    = $1;
#       my $alt     = $3;
#       my $acronym = $4;
#       my $string  = q{};

#       if ( $library->get_acronym_list->has_acronym($acronym,$alt) )
# 	{
# 	  $string = "\\${type}{$acronym:$alt}";
# 	}

#       else
# 	{
# 	  $string = $acronym;
# 	}

#       $latex =~ s/$syntax->{acronym_term_ref}/$string/xms;
#   }

#   return $latex;
# }

######################################################################

# sub _render_latex_index_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $latex =~ $syntax->{index_ref} )
#     {
#       my $term   = $2;
#       my $string = "$term \\index{$term}";

#       $latex =~ s/$syntax->{index_ref}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_id_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{id_ref};

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $latex =~ $syntax->{id_ref} )
#     {
#       my $id     = $1;
#       my $string = q{};

#       if ( $library->has_division($id) )
# 	{
# 	  $string = "\\hyperref[$id]{$id}";
# 	}

#       else
# 	{
# 	  my $location = $self->get_location;
# 	  $logger->warn("BROKEN ID REFERENCE to \'$id\' at $location");
# 	  $string = "(broken id ref to \'$id\')";
# 	}

#       $latex =~ s/$syntax->{id_ref}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_thepage_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '\thepage';

#   $latex =~ s/$syntax->{thepage_ref}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_page_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{page_ref};

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $latex =~ $syntax->{page_ref} )
#     {
#       my $id     = $2;
#       my $string = q{};

#       if ( $library->has_division($id) )
# 	{
# 	  $string = "p. \\pageref{$id}";
# 	}

#       else
# 	{
# 	  $string = "(broken page ref to \'$id\')";
# 	}

#       $latex =~ s/$syntax->{page_ref}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_theversion_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{theversion_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve version references");
#       return $latex;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;
#   my $id      = $doc->get_id;
#   my $version = q{};

#   if ( $doc->has_property('version') )
#     {
#       $version = $doc->get_property_value('version');
#     }

#   else
#     {
#       my $location = $self->get_location;
#       logger->warn("DOCUMENT HAS NO VERSION at $location");
#       $version = '(no document version)';
#     }

#   while ( $latex =~ $syntax->{theversion_ref} )
#     {
#       $latex =~ s/$syntax->{theversion_ref}/$version/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_therevision_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{therevision_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve revision references");
#       return $latex;
#     }

#   my $util     = $sml->get_util;
#   my $library  = $util->get_library;
#   my $id       = $doc->get_id;
#   my $revision = q{};

#   if ( $doc->has_property('revision') )
#     {
#       $revision = $doc->get_property_value('revision');
#     }

#   else
#     {
#       my $location = $self->get_location;
#       logger->warn("DOCUMENT HAS NO REVISION at $location");
#       $revision = '(no document revision)';
#     }

#   while ( $latex =~ $syntax->{therevision_ref} )
#     {
#       $latex =~ s/$syntax->{therevision_ref}/$revision/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_thedate_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{thedate_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve date references");
#       return $latex;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;
#   my $id      = $doc->get_id;
#   my $date    = q{};

#   if ( $doc->has_property('date') )
#     {
#       $date = $doc->get_property_value('date');
#     }

#   else
#     {
#       my $location = $self->get_location;
#       logger->warn("DOCUMENT HAS NO DATE at $location");
#       $date = '(no document date)';
#     }

#   while ( $latex =~ $syntax->{thedate_ref} )
#     {
#       $latex =~ s/$syntax->{thedate_ref}/$date/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_status_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{status_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve status references");
#       return $latex;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $latex =~ $syntax->{status_ref} )
#     {
#       my $id     = $1;
#       my $string = q{};

#       if ( $library->has_division($id) )
# 	{
# 	  my $division = $library->get_division($id);
# 	  my $status   = $division->get_property_value('status');

# 	  if ( $status =~ $syntax->{valid_status} )
# 	    {
# 	      $string = $doc->get_latex_status_icon($status);
# 	    }

# 	  elsif ( $status =~ $syntax->{blank_line} )
# 	    {
# 	      $string = "(no status assigned to $id)";
# 	    }

# 	  else
# 	    {
# 	      $string = $doc->get_latex_status_icon('invalid');
# 	    }
# 	}

#       elsif ( $id =~ $syntax->{valid_status} )
# 	{
# 	  my $status = $id;
# 	  $string = $doc->get_latex_status_icon($status);
# 	}

#       else
# 	{
# 	  $string = "(broken status reference to $id)";
# 	}

#       $latex =~ s/$syntax->{status_ref}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_citations {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   return $latex if not $latex =~ $syntax->{citation_ref};

#   my $doc = $self->get_containing_document;

#   if ( not $doc )
#     {
#       $logger->error("NOT IN DOCUMENT CONTEXT can't resolve source citations");
#       return $latex;
#     }

#   my $util    = $sml->get_util;
#   my $library = $util->get_library;

#   while ( $latex =~ $syntax->{citation_ref} )
#     {
#       my $source = $2;
#       my $other  = $4;
#       my $string = q{};

#       if ( $library->get_references->has_source($source) )
# 	{
# 	  if ($other)
# 	    {
# 	      $string = "\\cite[$other]{$source}";
# 	    }

# 	  else
# 	    {
# 	      $string = "\\cite{$source}";
# 	    }
# 	}

#       else
# 	{
# 	  $string = "(broken citation to $source)";
# 	}

#       $latex =~ s/$syntax->{citation_ref}/$string/xms;
#   }

#   return $latex;
# }

######################################################################

# sub _render_html_take_note_symbols {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '<b>(take note!)</b>';

#   $html =~ s/$syntax->{take_note_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_smiley_symbols {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '(smiley)';

#   $html =~ s/$syntax->{smiley_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_frowny_symbols {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '(frowny)';

#   $html =~ s/$syntax->{frowny_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_keystroke_symbols {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $html =~ $syntax->{keystroke_symbol} )
#     {
#       my $keystroke = $1;
#       my $string    = "<span class=\"keystroke\">$keystroke<\/span>";

#       $html =~ s/$syntax->{keystroke_symbol}/$string/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_left_arrow_symbols {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '&larr;';

#   $html =~ s/$syntax->{left_arrow_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_right_arrow_symbols {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '&rarr;';

#   $html =~ s/$syntax->{right_arrow_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_latex_symbols {

#   my $self = shift;
#   my $html = shift;

#   # Don't replace (HTML only)

#   return $html;
# }

######################################################################

# sub _render_html_tex_symbols {

#   my $self = shift;
#   my $html = shift;

#   # Don't replace (HTML only)

#   return $html;
# }

######################################################################

# sub _render_html_copyright_symbols {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '&copy;';

#   $html =~ s/$syntax->{copyright_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_trademark_symbols {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '&trade;';

#   $html =~ s/$syntax->{trademark_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_reg_trademark_symbols {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '&reg;';

#   $html =~ s/$syntax->{reg_trademark_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_open_double_quote {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '&ldquo;';

#   $html =~ s/$syntax->{open_dblquote_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_close_double_quote {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '&rdquo;';

#   $html =~ s/$syntax->{close_dblquote_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_open_single_quote {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '&lsquo;';

#   $html =~ s/$syntax->{open_sglquote_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_close_single_quote {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '&rsquo;';

#   $html =~ s/$syntax->{close_sglquote_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_section_symbols {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '&sect;';

#   $html =~ s/$syntax->{section_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_html_emdash {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '&mdash;';

#   $html =~ s/$syntax->{emdash_symbol}/$string/gxms;

#   return $html;
# }

######################################################################

# sub _render_latex_take_note_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '\marginpar{\Huge\Writinghand}';

#   $latex =~ s/$syntax->{take_note_symbol}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_smiley_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '\large\Smiley';

#   $latex =~ s/$syntax->{smiley_symbol}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_frowny_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '\large\Frowny';

#   $latex =~ s/$syntax->{frowny_symbol}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_keystroke_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $latex =~ $syntax->{keystroke_symbol} )
#     {
#       my $keystroke = $1;
#       my $string    = "\\keystroke{$keystroke}";

#       $latex =~ s/$syntax->{keystroke_symbol}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_left_arrow_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '$\leftarrow$';

#   $latex =~ s/$syntax->{left_arrow_symbol}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_right_arrow_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '$\rightarrow$';

#   $latex =~ s/$syntax->{right_arrow_symbol}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_latex_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '\LaTeX{}';

#   $latex =~ s/$syntax->{latex_symbol}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_tex_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '\TeX{}';

#   $latex =~ s/$syntax->{tex_symbol}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_copyright_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '\tiny$^{\copyright}$\normalsize';

#   $latex =~ s/$syntax->{copyright_symbol}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_trademark_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '\tiny$^{\texttrademark}$\normalsize';

#   $latex =~ s/$syntax->{trademark_symbol}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_reg_trademark_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '\tiny$^{\textregistered}$\normalsize';

#   $latex =~ s/$syntax->{reg_trademark_symbol}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_open_double_quote {

#   my $self  = shift;
#   my $latex = shift;

#   # Do nothing (LaTeX only).

#   return $latex;
# }

######################################################################

# sub _render_latex_close_double_quote {

#   my $self  = shift;
#   my $latex = shift;

#   # Do nothing (LaTeX only).

#   return $latex;
# }

######################################################################

# sub _render_latex_open_single_quote {

#   my $self  = shift;
#   my $latex = shift;

#   # Do nothing.

#   return $latex;
# }

######################################################################

# sub _render_latex_close_single_quote {

#   my $self  = shift;
#   my $latex = shift;

#   # Do nothing.

#   return $latex;
# }

######################################################################

# sub _render_latex_section_symbols {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;
#   my $string = '{\S}';

#   $latex =~ s/$syntax->{section_symbol}/$string/gxms;

#   return $latex;
# }

######################################################################

# sub _render_latex_emdash {

#   my $self  = shift;
#   my $latex = shift;

#   # Do nothing (LaTeX only).

#   return $latex;
# }

######################################################################

# sub _render_html_underlined_text {

#   my $self     = shift;
#   my $html     = shift;
#   my $sml      = SML->instance;
#   my $syntax   = $sml->get_syntax;
#   my $in_span  = 0;

#   while ( $html =~ /$syntax->{underline}/xms )
#     {
#       if (not $in_span)
# 	{
# 	  $html =~ s/$syntax->{underline}/$1<u>$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $html =~ s/$syntax->{underline}/$1<\/u>$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $html;
# }

######################################################################

# sub _render_html_superscripted_text {

#   my $self    = shift;
#   my $html    = shift;
#   my $sml     = SML->instance;
#   my $syntax  = $sml->get_syntax;
#   my $in_span = 0;

#   while ($html =~ /$syntax->{superscript}/xms)
#     {
#       if (not $in_span)
# 	{
# 	  $html =~ s/$syntax->{superscript}/$1<sup>$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $html =~ s/$syntax->{superscript}/$1<\/sup>$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $html;
# }

######################################################################

# sub _render_html_subscripted_text {

#   my $self    = shift;
#   my $html    = shift;
#   my $sml     = SML->instance;
#   my $syntax  = $sml->get_syntax;
#   my $in_span = 0;

#   while ($html =~ /$syntax->{subscript}/xms)
#     {
#       if (not $in_span)
# 	{
# 	  $html =~ s/$syntax->{subscript}/$1<sub>$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $html =~ s/$syntax->{subscript}/$1<\/sub>$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $html;
# }

######################################################################

# sub _render_html_italicized_text {

#   my $self    = shift;
#   my $html    = shift;
#   my $sml     = SML->instance;
#   my $syntax  = $sml->get_syntax;
#   my $in_span = 0;

#   while ($html =~ /$syntax->{italics}/xms)
#     {
#       if (not $in_span)
# 	{
# 	  $html =~ s/$syntax->{italics}/$1<i>$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $html =~ s/$syntax->{italics}/$1<\/i>$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $html;
# }

######################################################################

# sub _render_html_bold_text {

#   my $self    = shift;
#   my $html    = shift;
#   my $sml     = SML->instance;
#   my $syntax  = $sml->get_syntax;
#   my $in_span = 0;

#   while ($html =~ /$syntax->{bold}/xms)
#     {
#       if (not $in_span)
# 	{
# 	  $html =~ s/$syntax->{bold}/$1<b>$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $html =~ s/$syntax->{bold}/$1<\/b>$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $html;
# }

######################################################################

# sub _render_html_fixed_width_text {

#   my $self    = shift;
#   my $html    = shift;
#   my $sml     = SML->instance;
#   my $syntax  = $sml->get_syntax;
#   my $in_span = 0;

#   while ($html =~ /$syntax->{fixedwidth}/xms)
#     {
#       if (not $in_span)
# 	{
# 	  $html =~ s/$syntax->{fixedwidth}/$1<tt>$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $html =~ s/$syntax->{fixedwidth}/$1<\/tt>$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $html;
# }

######################################################################

# sub _render_html_file_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $html =~ $syntax->{file_ref} )
#     {
#       my $file   = $1;
#       my $string = "<tt>$file<\/tt>";

#       $html =~ s/$syntax->{file_ref}/$string/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_path_references {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $html =~ $syntax->{path_ref} )
#     {
#       my $path   = $1;
#       my $string = "<tt>$path<\/tt>";

#       $html =~ s/$syntax->{path_ref}/$string/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_user_entered_text {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $html =~ $syntax->{user_entered_text} )
#     {
#       my $text   = $2;
#       my $string = "<b><tt>$text<\/tt><\/b>";

#       $html =~ s/$syntax->{user_entered_text}/$string/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_commands {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $html =~ $syntax->{command_ref} )
#     {
#       my $cmd    = $1;
#       my $string = "<tt>$cmd<\/tt>";

#       $html =~ s/$syntax->{command_ref}/$string/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_literal_xml_tags {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $html =~ $syntax->{xml_tag} )
#     {
#       my $element = $1;
#       my $string  = "\&lt\;$element\&gt\;";

#       $html =~ s/$syntax->{xml_tag}/$string/xms;
#     }

#   return $html;
# }

######################################################################

# sub _render_html_email_addresses {

#   my $self   = shift;
#   my $html   = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   $html =~ s/$syntax->{email_addr}/<a href=\"mailto:$1\">$1<\/a>/gxms;

#   return $html;
# }

######################################################################

# sub _render_latex_underlined_text {

#   my $self     = shift;
#   my $latex    = shift;
#   my $sml      = SML->instance;
#   my $syntax   = $sml->get_syntax;
#   my $in_span  = 0;

#   while ($latex =~ /$syntax->{underline}/xms)
#     {
#       if (not $in_span)
# 	{
# 	  $latex =~ s/$syntax->{underline}/$1\\underline\{$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $latex =~ s/$syntax->{underline}/$1\}$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_superscripted_text {

#   my $self    = shift;
#   my $latex   = shift;
#   my $sml     = SML->instance;
#   my $syntax  = $sml->get_syntax;
#   my $in_span = 0;

#   while ($latex =~ /$syntax->{superscript}/xms)
#     {
#       if (not $in_span)
# 	{
# 	  $latex =~ s/$syntax->{superscript}/$1\\textsuperscript\{$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $latex =~ s/$syntax->{superscript}/$1\}$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_subscripted_text {

#   my $self    = shift;
#   my $latex   = shift;
#   my $sml     = SML->instance;
#   my $syntax  = $sml->get_syntax;
#   my $in_span = 0;

#   while ($latex =~ /$syntax->{subscript}/xms)
#     {
#       if (not $in_span)
# 	{
# 	  $latex =~ s/$syntax->{subscript}/$1\\subscript\{$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $latex =~ s/$syntax->{subscript}/$1\}$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_italicized_text {

#   my $self    = shift;
#   my $latex   = shift;
#   my $sml     = SML->instance;
#   my $syntax  = $sml->get_syntax;
#   my $in_span = 0;

#   while ($latex =~ /$syntax->{italics}/xms)
#     {
#       if (not $in_span)
# 	{
# 	  $latex =~ s/$syntax->{italics}/$1\\textit\{$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $latex =~ s/$syntax->{italics}/$1\}$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_bold_text {

#   my $self    = shift;
#   my $latex   = shift;
#   my $sml     = SML->instance;
#   my $syntax  = $sml->get_syntax;
#   my $in_span = 0;

#   while ($latex =~ /$syntax->{bold}/xms)
#     {
#       if (not $in_span)
# 	{
# 	  $latex =~ s/$syntax->{bold}/$1\\textbf\{$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $latex =~ s/$syntax->{bold}/$1\}$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_fixed_width_text {

#   my $self    = shift;
#   my $latex   = shift;
#   my $sml     = SML->instance;
#   my $syntax  = $sml->get_syntax;
#   my $in_span = 0;

#   while ($latex =~ /$syntax->{fixedwidth}/xms)
#     {
#       if (not $in_span)
# 	{
# 	  $latex =~ s/$syntax->{fixedwidth}/$1\\texttt\{$2/xms;
# 	  $in_span = 1;
# 	}
#       else
# 	{
# 	  $latex =~ s/$syntax->{fixedwidth}/$1\}$2/xms;
# 	  $in_span = 0;
# 	}
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_file_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $latex =~ $syntax->{file_ref} )
#     {
#       my $file   = $1;
#       my $string = "\\path{$file}";

#       $latex =~ s/$syntax->{file_ref}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_path_references {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $latex =~ $syntax->{path_ref} )
#     {
#       my $path   = $1;
#       my $string = q{};

#       # handle trailing backslashes
#       #
#       my $trailing_backslash = 0;
#       if ($path =~ /\\$/xms)
# 	{
# 	  $trailing_backslash = 1;
# 	  $path =~ s/\\$//xms;
# 	}

#       if ($trailing_backslash)
# 	{
# 	  $string = "\\path{$path}\$\\backslash\$";
# 	}
#       else
# 	{
# 	  $string = "\\path{$path}";
# 	}

#       $latex =~ s/$syntax->{path_ref}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_user_entered_text {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $latex =~ $syntax->{user_entered_text} )
#     {
#       my $text   = $2;
#       my $string = "\\textbf{\\texttt{$text}}";

#       $latex =~ s/$syntax->{user_entered_text}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_commands {

#   my $self   = shift;
#   my $latex  = shift;
#   my $sml    = SML->instance;
#   my $syntax = $sml->get_syntax;

#   while ( $latex =~ $syntax->{command_ref} )
#     {
#       my $cmd    = $1;
#       my $string = "\\path{$cmd}";

#       $latex =~ s/$syntax->{command_ref}/$string/xms;
#     }

#   return $latex;
# }

######################################################################

# sub _render_latex_literal_xml_tags {

#   my $self  = shift;
#   my $latex = shift;

#   # Do nothing.

#   return $latex;
# }

######################################################################

# sub _render_latex_email_addresses {

#   my $self  = shift;
#   my $latex = shift;

#   # Do nothing.

#   return $latex;
# }

######################################################################

sub _validate_syntax {

  # Validate the syntax of this block.  Syntax validation is possible
  # even if the block is not in a document or library context.

  my $self  = shift;
  my $valid = 1;

  $valid = 0 if not $self->has_valid_bold_markup_syntax;
  $valid = 0 if not $self->has_valid_italics_markup_syntax;
  $valid = 0 if not $self->has_valid_fixedwidth_markup_syntax;
  $valid = 0 if not $self->has_valid_underline_markup_syntax;
  $valid = 0 if not $self->has_valid_superscript_markup_syntax;
  $valid = 0 if not $self->has_valid_subscript_markup_syntax;
  $valid = 0 if not $self->has_valid_cross_ref_syntax;
  $valid = 0 if not $self->has_valid_id_ref_syntax;
  $valid = 0 if not $self->has_valid_page_ref_syntax;
  $valid = 0 if not $self->has_valid_glossary_term_ref_syntax;
  $valid = 0 if not $self->has_valid_glossary_def_ref_syntax;
  $valid = 0 if not $self->has_valid_acronym_ref_syntax;
  $valid = 0 if not $self->has_valid_source_citation_syntax;

  return $valid;
}

######################################################################

sub _validate_semantics {

  # Validate the semantics of this block.

  my $self  = shift;
  my $valid = 1;

  $valid = 0 if not $self->has_valid_cross_ref_semantics;
  $valid = 0 if not $self->has_valid_id_ref_semantics;
  $valid = 0 if not $self->has_valid_page_ref_semantics;
  $valid = 0 if not $self->has_valid_theversion_ref_semantics;
  $valid = 0 if not $self->has_valid_therevision_ref_semantics;
  $valid = 0 if not $self->has_valid_thedate_ref_semantics;
  $valid = 0 if not $self->has_valid_status_ref_semantics;
  $valid = 0 if not $self->has_valid_glossary_term_ref_semantics;
  $valid = 0 if not $self->has_valid_glossary_def_ref_semantics;
  $valid = 0 if not $self->has_valid_acronym_ref_semantics;
  $valid = 0 if not $self->has_valid_source_citation_semantics;
  $valid = 0 if not $self->has_valid_file_ref_semantics;

  return $valid;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Block> - one or more contiguous L<"SML::Line">s.

=head1 VERSION

This documentation refers to L<"SML::Block"> version 2.0.0.

=head1 SYNOPSIS

  my $block = SML::Block->new();

=head1 DESCRIPTION

A block is one or more contiguous whole lines of text.  Blocks are
separated by blank lines and therefore cannot contain blank lines.
Blocks may contain inline text elements

=head1 METHODS

=head2 get_type

=head2 get_name

=head2 get_content

=head2 get_lines

=head2 get_division

=head2 has_valid_syntax

=head2 has_valid_semantics

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
