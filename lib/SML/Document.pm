#!/usr/bin/perl

package SML::Document;                  # ci-000005

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';               # ci-000466

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Document');

use SML::Library;                       # ci-000410
use SML::Glossary;                      # ci-000435
use SML::AcronymList;                   # ci-000439
use SML::References;                    # ci-000463
use SML::Index;                         # ci-000453

######################################################################

=head1 NAME

SML::Document - a written work about a topic

=head1 SYNOPSIS

  SML::Document->new
    (
      id      => $id,
      library => $library,
    );

  $document->get_glossary;                            # SML::Glossary
  $document->get_acronym_list;                        # SML::AcronymList
  $document->get_references;                          # SML::References
  $document->get_index;                               # SML::Index
  $document->get_change_list;                         # ArrayRef
  $document->get_add_count;                           # Int
  $document->get_delete_count;                        # Int
  $document->get_update_count;                        # Int

  $document->add_note($note);                         # Bool
  $document->has_note($division_id,$number);          # Bool
  $document->contains_header;                         # Bool
  $document->contains_footer;                         # Bool
  $document->add_error($error);                       # Bool
  $document->get_error_list;                          # ArrayRef
  $document->get_error_count;                         # Int
  $document->contains_error;                          # Bool
  $document->add_verion($version,$date,$string);      # Bool
  $document->contains_version_history;                # Bool
  $document->get_version_history_list;                # ArrayRef
  $document->contains_changes;                        # Bool
  $document->get_page_after;                          # Str
  $document->get_page_before;                         # Str

  # methods inherited from SML::Structure...

  NONE

  # methods inherited from SML::Division...

  $division->get_number;                              # Str
  $division->set_number;                              # Bool
  $division->get_previous_number;                     # Str
  $division->set_previous_number($number);            # Bool
  $division->get_next_number;                         # Str
  $division->set_next_number($number);                # Bool
  $division->get_containing_division;                 # SML::Division
  $division->set_containing_division($division);      # Bool
  $division->has_containing_division;                 # Bool
  $division->get_origin_line;                         # SML::Line
  $division->has_origin_line;                         # Bool
  $division->get_sha_digest;                          # Str

  $division->add_part($part);                         # Bool
  $division->add_attribute($element);                 # Bool
  $division->contains_division_with_id($id);          # Bool
  $division->contains_division_with_name($name);      # Bool
  $division->contains_element_with_name($name);       # Bool
  $division->get_list_of_divisions_with_name($name);  # ArrayRef
  $division->get_list_of_elements_with_name($name);   # ArrayRef
  $division->get_division_list;                       # ArrayRef
  $division->get_block_list;                          # ArrayRef
  $division->get_string_list;                         # ArrayRef
  $division->get_element_list;                        # ArrayRef
  $division->get_line_list;                           # ArrayRef
  $division->get_first_part;                          # SML::Part
  $division->get_first_line;                          # SML::Line
  $division->get_containing_document;                 # SML::Document
  $division->get_location;                            # Str
  $division->get_containing_section;                  # SML::Section
  $division->is_in_a($name);                          # Bool
  $division->get_content;                             # Str

  # methods inherited from SML::Part...

  $part->get_name;                                    # Str
  $part->get_library;                                 # SML::Library
  $part->get_id;                                      # Str
  $part->set_id;                                      # Bool
  $part->set_content;                                 # Bool
  $part->get_content;                                 # Str
  $part->has_content;                                 # Bool
  $part->get_container;                               # SML::Part
  $part->set_container;                               # Bool
  $part->has_container;                               # Bool
  $part->get_part_list;                               # ArrayRef
  $part->is_narrative_part;                           # Bool

  $part->init;                                        # Bool
  $part->contains_parts;                              # Bool
  $part->has_part($id);                               # Bool
  $part->get_part($id);                               # SML::Part
  $part->add_part($part);                             # Bool
  $part->get_narrative_part_list                      # ArrayRef
  $part->get_containing_document;                     # SML::Document
  $part->is_in_section;                               # Bool
  $part->get_containing_section;                      # SML::Section
  $part->render($rendition,$style);                   # Str
  $part->dump_part_structure($indent);                # Str

=head1 DESCRIPTION

A document is an C<SML::Structure> that represents a written work
about a topic.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'DOCUMENT',
  );

######################################################################

has glossary =>
  (
   isa      => 'SML::Glossary',
   reader   => 'get_glossary',
   lazy     => 1,
   builder  => '_build_glossary',
  );

=head2 get_glossary

Return the C<SML::Glossary> object that belongs to the document.

  my $glossary = $document->get_glossary;

=cut

######################################################################

has acronym_list =>
  (
   isa      => 'SML::AcronymList',
   reader   => 'get_acronym_list',
   lazy     => 1,
   builder  => '_build_acronym_list',
  );

=head2 get_acronym_list

Return the C<SML::AcronymList> object that belongs to the document.

  my $acronym_list = $document->get_acronym_list;

=cut

######################################################################

has references =>
  (
   isa      => 'SML::References',
   reader   => 'get_references',
   lazy     => 1,
   builder  => '_build_references',
  );

=head2 get_references

Return the C<SML::References> object that belongs to the document.

  my $references = $document->get_references;

=cut

######################################################################

has index =>
  (
   isa      => 'SML::Index',
   reader   => 'get_index',
   lazy     => 1,
   builder  => '_build_index',
  );

=head2 get_index

Return the C<SML::Index> object that belongs to the document.

  my $index = $document->get_index;

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

Return an ArrayRef to a list of changes made to the document since the
previous (library) version.

  my $aref = $document->get_change_list;

Each change in the list is a 2-element anonymous array. The first
element is the change action (ADDED, UPDATED, or DELETED) and the
second element is the ID of the division changed.

If you wanted to do something with each change in the document you
might write a loop like this:

  foreach my $change (@{ $document->get_change_list })
    {
      my $action      = $change->[0];
      my $division_id = $change->[1];

      # do something...
    }

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

Return an integer which is the number of divisions that have been
ADDED since the previous version.

  my $count = $document->get_add_count;

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

=head2 get_add_count

Return an integer which is the number of divisions that have been
DELETED since the previous version.

  my $count = $document->get_delete_count;

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

=head2 get_add_count

Return an integer which is the number of divisions that have been
UPDATED since the previous version.

  my $count = $document->get_update_count;

=cut

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

  unless ( $note )
    {
      $logger->error("CAN'T ADD NOTE, MISSING ARGUMENT");
      return 0;
    }

  unless ( ref $note and $note->isa('SML::Note') )
    {
      $logger->error("CAN'T ADD NOTE, NOT A NOTE $note");
      return 0;
    }

  my $divid = q{};

  if ( $note->has_containing_division )
    {
      my $division = $note->get_containing_division;
      $divid = $division->get_id;
    }

  else
    {
      my $location = $note->get_location;
      $logger->error("FOOTNOTE HAS NO CONTAINING DIVISION at $location");
    }

  my $number = $note->get_number;

  if ( exists $self->_get_note_hash->{$divid}{$number} )
    {
      $logger->warn("NOTE ALREADY EXISTS: \'$divid\' \'$number\'");
    }

  $self->_get_note_hash->{$divid}{$number} = $note;

  return 1;
}

=head2 add_note($note)

Add a C<SML::Note> (i.e. a footnote) to the document.

  my $result = $document->add_note($note);

=cut

######################################################################

sub has_note {

  my $self   = shift;
  my $divid  = shift;
  my $number = shift;

  my $nh = $self->_get_note_hash;

  if ( exists $nh->{$divid}{$number} )
    {
      return 1;
    }

  return 0;
}

=head2 has_note($id,$number)

Return 1 if the document contains a note with the specified division
ID and number.

  my $result = $document->has_note;

=cut

######################################################################

sub contains_header {

  my $self = shift;

  my $id      = $self->get_id;
  my $library = $self->get_library;
  my $ps      = $library->get_property_store;

  if
    (
        $ps->has_property($id,'header_left')
     or $ps->has_property($id,'header_center')
     or $ps->has_property($id,'header_right')
     or $ps->has_property($id,'header_left_even')
     or $ps->has_property($id,'header_center_even')
     or $ps->has_property($id,'header_right_even')
     or $ps->has_property($id,'header_left_odd')
     or $ps->has_property($id,'header_center_odd')
     or $ps->has_property($id,'header_right_odd')
    )
    {
      return 1;
    }

  return 0;
}

=head2 contains_header

Return 1 if the document contains any header elements.

  my $result = $document->contains_header;

=cut

######################################################################

sub contains_footer {

  my $self = shift;

  my $id      = $self->get_id;
  my $library = $self->get_library;
  my $ps      = $library->get_property_store;

  if
    (
        $ps->has_property($id,'footer_left')
     or $ps->has_property($id,'footer_center')
     or $ps->has_property($id,'footer_right')
     or $ps->has_property($id,'footer_left_even')
     or $ps->has_property($id,'footer_center_even')
     or $ps->has_property($id,'footer_right_even')
     or $ps->has_property($id,'footer_left_odd')
     or $ps->has_property($id,'footer_center_odd')
     or $ps->has_property($id,'footer_right_odd')
    )
    {
      return 1;
    }

  return 0;
}

=head2 contains_footer

Return 1 if the document contains any footer elements.

  my $result = $document->contains_footer;

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

=head2 add_error($error)

Add the specified C<SML::Error> to the document. Return 1 if
successful.

  my $result = $document->add_error($error);

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

Return an ArrayRef to a list of errors in the document.

  my $aref = $document->get_error_list;

=cut

######################################################################

sub get_error_count {

  my $self = shift;

  return scalar @{ $self->get_error_list };
}

=head2 get_error_count

Return an integer count of the number of errors in the document.

  my $count = $document->get_error_count;

=cut

######################################################################

sub contains_error {

  # Return 1 if the library contains an error.

  my $self = shift;

  my $href = $self->_get_error_hash;

  if ( scalar keys %{$href} )
    {
      return 1;
    }

  return 0;
}

=head2 contains_error

Return 1 if the document contains one or more errors.

  my $result = $document->contains_error;

=cut

######################################################################

sub add_version {

  # Add a version to the version history.

  my $self = shift;

  my $version = shift;                  # 2.0
  my $date    = shift;                  # 2015-12-31
  my $string  = shift;                  # SML::String

  unless ( $version and $date and $string )
    {
      $logger->error("CAN'T ADD VERSION, MISSING ARGUMENTS");
      return 0;
    }

  my $href = $self->_get_version_history_hash;

  if ( exists $href->{$version}{$date} )
    {
      $logger->error("VERSION ALREADY EXISTS $version $date");
      return 0;
    }

  $href->{$version}{$date} = $string;

  return 1;
}

=head2 add_version($version,$date,$string)

Add the specified version information to the document.  Return 1 if
successful.

  my $result = $document->add_version($version,$date,$string);

=cut

######################################################################

sub contains_version_history {

  # Return 1 if this document contains version history information.

  my $self = shift;

  my $href = $self->_get_version_history_hash;

  if ( scalar keys %{$href} )
    {
      return 1;
    }

  return 0;
}

=head2 contains_version_history

Return 1 if this document contains version history information.

  my $result = $document->contains_version_history;

=cut

######################################################################

sub get_version_history_list {

  # Return a list of document versions in the version history.

  my $self = shift;

  my $href = $self->_get_version_history_hash;

  my $aref = [];                        # version history list

  foreach my $version ( reverse sort keys %{ $href } )
    {
      foreach my $date ( sort keys %{ $href->{$version} } )
	{
	  my $string = $href->{$version}{$date};
	  push @{$aref}, [$version,$date,$string];
	}
    }

  return $aref;
}

=head2 get_version_history_list

Return an ArrayRef to a list of versions of this document.

  my $aref = $document->get_version_history_list;

=cut

######################################################################

sub contains_changes {

  # Return 1 if this document contains changes since the previous
  # (library) version.

  my $self = shift;

  my $change_list = $self->get_change_list;

  if ( scalar @{ $change_list } )
    {
      return 1;
    }

  return 0;
}

=head2 contains_changes

Return 1 if changes have been made to this document since the previous
(library) version.

  my $result = $document->contains_changes;

=cut

######################################################################

sub get_page_after {

  my $self     = shift;
  my $pagename = shift;

  my $library = $self->get_library;
  my $id      = $self->get_id;

  if ( $pagename eq 'titlepage' )
    {
      return 'contents'    if $self->contains_division_with_name('SECTION');
      return 'tables'      if $self->contains_division_with_name('TABLE');
      return 'figures'     if $self->contains_division_with_name('FIGURE');
      return 'attachments' if $self->contains_division_with_name('ATTACHMENT');
      return 'listings'    if $self->contains_division_with_name('LISTING');
      return 'demos'       if $self->contains_division_with_name('DEMO');
      return 'exercises'   if $self->contains_division_with_name('EXERCISE');
      return 'slides'      if $self->contains_division_with_name('SLIDE');
      return 'history'     if $self->contains_version_history;
      return 'change'      if $self->contains_changes;
      return "1";
    }

  elsif ( $pagename eq 'contents' )
    {
      return 'tables'      if $self->contains_division_with_name('TABLE');
      return 'figures'     if $self->contains_division_with_name('FIGURE');
      return 'attachments' if $self->contains_division_with_name('ATTACHMENT');
      return 'listings'    if $self->contains_division_with_name('LISTING');
      return 'demos'       if $self->contains_division_with_name('DEMO');
      return 'exercises'   if $self->contains_division_with_name('EXERCISE');
      return 'slides'      if $self->contains_division_with_name('SLIDE');
      return 'history'     if $self->contains_version_history;
      return 'change'      if $self->contains_changes;
      return "1";
    }

  elsif ( $pagename eq 'tables' )
    {
      return 'figures'     if $self->contains_division_with_name('FIGURE');
      return 'attachments' if $self->contains_division_with_name('ATTACHMENT');
      return 'listings'    if $self->contains_division_with_name('LISTING');
      return 'demos'       if $self->contains_division_with_name('DEMO');
      return 'exercises'   if $self->contains_division_with_name('EXERCISE');
      return 'slides'      if $self->contains_division_with_name('SLIDE');
      return 'history'     if $self->contains_version_history;
      return 'change'      if $self->contains_changes;
      return "1";
    }

  elsif ( $pagename eq 'figures' )
    {
      return 'attachments' if $self->contains_division_with_name('ATTACHMENT');
      return 'listings'    if $self->contains_division_with_name('LISTING');
      return 'demos'       if $self->contains_division_with_name('DEMO');
      return 'exercises'   if $self->contains_division_with_name('EXERCISE');
      return 'slides'      if $self->contains_division_with_name('SLIDE');
      return 'history'     if $self->contains_version_history;
      return 'change'      if $self->contains_changes;
      return "1";
    }

  elsif ( $pagename eq 'attachments' )
    {
      return 'listings'    if $self->contains_division_with_name('LISTING');
      return 'demos'       if $self->contains_division_with_name('DEMO');
      return 'exercises'   if $self->contains_division_with_name('EXERCISE');
      return 'slides'      if $self->contains_division_with_name('SLIDE');
      return 'history'     if $self->contains_version_history;
      return 'change'      if $self->contains_changes;
      return "1";
    }

  elsif ( $pagename eq 'listings' )
    {
      return 'demos'       if $self->contains_division_with_name('DEMO');
      return 'exercises'   if $self->contains_division_with_name('EXERCISE');
      return 'slides'      if $self->contains_division_with_name('SLIDE');
      return 'history'     if $self->contains_version_history;
      return 'change'      if $self->contains_changes;
      return "1";
    }

  elsif ( $pagename eq 'demos' )
    {
      return 'exercises'   if $self->contains_division_with_name('EXERCISE');
      return 'slides'      if $self->contains_division_with_name('SLIDE');
      return 'history'     if $self->contains_version_history;
      return 'change'      if $self->contains_changes;
      return "1";
    }

  elsif ( $pagename eq 'exercises' )
    {
      return 'slides'      if $self->contains_division_with_name('SLIDE');
      return 'history'     if $self->contains_version_history;
      return 'change'      if $self->contains_changes;
      return "1";
    }

  elsif ( $pagename eq 'slides' )
    {
      return 'history'     if $self->contains_version_history;
      return 'change'      if $self->contains_changes;
      return "1";
    }

  elsif ( $pagename eq 'history' )
    {
      return 'change'      if $self->contains_changes;
      return "1";
    }

  elsif ( $pagename eq 'change' )
    {
      return "1";
    }

  elsif ( $pagename =~ /^([\d\.]+)$/ )
    {
      my $section_number = $1;
      my $section_list   = $self->get_list_of_divisions_with_name('SECTION');

      foreach my $section (@{ $section_list })
	{
	  my $number = $section->get_number;

	  if ( $number eq $section_number )
	    {
	      my $next_number = $section->get_next_number;

	      return "$next_number";
	    }
	}

      $logger->error("THIS SHOULD NEVER HAPPEN, BAD PAGE NAME $pagename");
    }

  elsif ( $pagename eq 'glossary' )
    {
      return 'acronyms'   if $self->get_acronym_list->contains_entries;
      return 'references' if $self->get_references->contains_entries;
      return 'index'      if $self->get_index->contains_entries;
      return 'titlepage';
    }

  elsif ( $pagename eq 'acronyms' )
    {
      return 'references' if $self->get_references->contains_entries;
      return 'index'      if $self->get_index->contains_entries;
      return 'titlepage';
    }

  elsif ( $pagename eq 'references' )
    {
      return 'index'      if $self->get_index->contains_entries;
      return 'titlepage';
    }

  elsif ( $pagename eq 'index' )
    {
      return 'titlepage';
    }

  else
    {
      $logger->error("THIS SHOULD NEVER HAPPEN, BAD PAGE NAME $pagename");
    }
}

=head2 get_page_after($pagename)

Return the page name of the page that should come AFTER the one
specified.  This works for front matter pages, section pages, and back
matter pages.

  my $next_pagename = $document->get_page_after($this_pagename);

Document pages should appear in the following default order:

  1.  titlepage
  2.  contents
  3.  tables
  4.  figures
  5.  attachments
  6.  listings
  7.  demos
  8.  exercises
  9.  slides
  10. history
  11. change

  ...pages by section number...

  12. glossary
  13. acronyms
  14. references
  15. index

=cut

######################################################################

sub get_page_before {

  my $self     = shift;
  my $pagename = shift;

  my $library = $self->get_library;
  my $id      = $self->get_id;

  if ( $pagename eq 'titlepage' )
    {
      return 'index'       if $self->get_index->contains_entries;
      return 'references'  if $self->get_references->contains_entries;
      return 'acronyms'    if $self->get_acronym_list->contains_entries;
      return 'glossary'    if $self->get_glossary->contains_entries;
      return "1";
    }

  elsif ( $pagename eq 'contents' )
    {
      return 'titlepage';
    }

  elsif ( $pagename eq 'tables' )
    {
      return 'contents'    if $self->contains_division_with_name('SECTION');
      return 'titlepage';
    }

  elsif ( $pagename eq 'figures' )
    {
      return 'tables'      if $self->contains_division_with_name('TABLE');
      return 'contents'    if $self->contains_division_with_name('SECTION');
      return 'titlepage';
    }

  elsif ( $pagename eq 'attachments' )
    {
      return 'figures'     if $self->contains_division_with_name('FIGURE');
      return 'tables'      if $self->contains_division_with_name('TABLE');
      return 'contents'    if $self->contains_division_with_name('SECTION');
      return 'titlepage';
    }

  elsif ( $pagename eq 'listings' )
    {
      return 'attachments' if $self->contains_division_with_name('ATTACHMENT');
      return 'figures'     if $self->contains_division_with_name('FIGURE');
      return 'tables'      if $self->contains_division_with_name('TABLE');
      return 'contents'    if $self->contains_division_with_name('SECTION');
      return 'titlepage';
    }

  elsif ( $pagename eq 'demos' )
    {
      return 'listings'    if $self->contains_division_with_name('LISTING');
      return 'attachments' if $self->contains_division_with_name('ATTACHMENT');
      return 'figures'     if $self->contains_division_with_name('FIGURE');
      return 'tables'      if $self->contains_division_with_name('TABLE');
      return 'contents'    if $self->contains_division_with_name('SECTION');
      return 'titlepage';
    }

  elsif ( $pagename eq 'exercises' )
    {
      return 'demos'       if $self->contains_division_with_name('DEMO');
      return 'listings'    if $self->contains_division_with_name('LISTING');
      return 'attachments' if $self->contains_division_with_name('ATTACHMENT');
      return 'figures'     if $self->contains_division_with_name('FIGURE');
      return 'tables'      if $self->contains_division_with_name('TABLE');
      return 'contents'    if $self->contains_division_with_name('SECTION');
      return 'titlepage';
    }

  elsif ( $pagename eq 'slides' )
    {
      return 'exercises'   if $self->contains_division_with_name('EXERCISE');
      return 'demos'       if $self->contains_division_with_name('DEMO');
      return 'listings'    if $self->contains_division_with_name('LISTING');
      return 'attachments' if $self->contains_division_with_name('ATTACHMENT');
      return 'figures'     if $self->contains_division_with_name('FIGURE');
      return 'tables'      if $self->contains_division_with_name('TABLE');
      return 'contents'    if $self->contains_division_with_name('SECTION');
      return 'titlepage';
    }

  elsif ( $pagename eq 'history' )
    {
      return 'slides'      if $self->contains_division_with_name('SLIDE');
      return 'exercises'   if $self->contains_division_with_name('EXERCISE');
      return 'demos'       if $self->contains_division_with_name('DEMO');
      return 'listings'    if $self->contains_division_with_name('LISTING');
      return 'attachments' if $self->contains_division_with_name('ATTACHMENT');
      return 'figures'     if $self->contains_division_with_name('FIGURE');
      return 'tables'      if $self->contains_division_with_name('TABLE');
      return 'contents'    if $self->contains_division_with_name('SECTION');
      return 'titlepage';
    }

  elsif ( $pagename eq 'change' )
    {
      return 'history'     if $self->contains_version_history;
      return 'slides'      if $self->contains_division_with_name('SLIDE');
      return 'exercises'   if $self->contains_division_with_name('EXERCISE');
      return 'demos'       if $self->contains_division_with_name('DEMO');
      return 'listings'    if $self->contains_division_with_name('LISTING');
      return 'attachments' if $self->contains_division_with_name('ATTACHMENT');
      return 'figures'     if $self->contains_division_with_name('FIGURE');
      return 'tables'      if $self->contains_division_with_name('TABLE');
      return 'contents'    if $self->contains_division_with_name('SECTION');
      return 'titlepage';
    }

  elsif ( $pagename =~ /^([\d\.]+)$/ )
    {
      my $section_number = $1;
      my $section_list   = $self->get_list_of_divisions_with_name('SECTION');

      if ( $pagename eq '1' )
	{
	  return 'change'      if $self->contains_changes;
	  return 'history'     if $self->contains_version_history;
	  return 'slides'      if $self->contains_division_with_name('SLIDE');
	  return 'exercises'   if $self->contains_division_with_name('EXERCISE');
	  return 'demos'       if $self->contains_division_with_name('DEMO');
	  return 'listings'    if $self->contains_division_with_name('LISTING');
	  return 'attachments' if $self->contains_division_with_name('ATTACHMENT');
	  return 'figures'     if $self->contains_division_with_name('FIGURE');
	  return 'tables'      if $self->contains_division_with_name('TABLE');
	  return 'contents'    if $self->contains_division_with_name('SECTION');
	  return 'titlepage';
	}

      foreach my $section (@{ $section_list })
	{
	  my $number = $section->get_number;

	  if ( $number eq $section_number )
	    {
	      my $previous_number = $section->get_previous_number;

	      return "$previous_number";
	    }
	}

      $logger->error("THIS SHOULD NEVER HAPPEN, BAD PAGE NAME $pagename");
    }

  elsif ( $pagename eq 'glossary' )
    {
      return "contents";
    }

  elsif ( $pagename eq 'acronyms' )
    {
      return 'glossary'   if $self->get_glossary->contains_entries;
      return "contents";
    }

  elsif ( $pagename eq 'references' )
    {
      return 'acronyms'   if $self->get_acronym_list->contains_entries;
      return 'glossary'   if $self->get_glossary->contains_entries;
      return "contents";
    }

  elsif ( $pagename eq 'index' )
    {
      return 'references' if $self->get_references->contains_entries;
      return 'acronyms'   if $self->get_acronym_list->contains_entries;
      return 'glossary'   if $self->get_glossary->contains_entries;
      return "contents";
    }

  else
    {
      $logger->error("THIS SHOULD NEVER HAPPEN, BAD PAGE NAME $pagename");
    }
}

=head2 get_page_before($pagename)

Return the page name of the page that should come BEFORE the one
specified.  This works for front matter pages, section pages, and back
matter pages.

  my $previous_pagename = $document-get_page_before($this_pagename);

Document pages should appear in the following default order:

  1.  titlepage
  2.  contents
  3.  tables
  4.  figures
  5.  attachments
  6.  listings
  7.  demos
  8.  exercises
  9.  slides
  10. history
  11. change

  ...pages by section number...

  12. glossary
  13. acronyms
  14. references
  15. index

=cut

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has note_hash =>
  (
   isa       => 'HashRef',
   reader    => '_get_note_hash',
   default   => sub {{}},
  );

# This data structure contains note text indexed by division ID and
# note number.

#   my $note = $nh->{section-2}{a};

######################################################################

has version_history_hash =>
  (
   is      => 'ro',
   isa     => 'HashRef',
   reader  => '_get_version_history_hash',
   default => sub {{}},
  );

# $href->{$version}{$date} = $string;

######################################################################

has table_data_hash =>
  (
   isa       => 'HashRef',
   reader    => '_get_table_data_hash',
   default   => sub {{}},
  );

######################################################################

has baretable_data_hash =>
  (
   isa       => 'HashRef',
   reader    => '_get_baretable_data_hash',
   default   => sub {{}},
  );

######################################################################

has source_hash =>
  (
   isa       => 'HashRef',
   reader    => '_get_source_hash',
   writer    => '_set_source_hash',
   clearer   => '_clear_source_hash',
   predicate => '_has_source_hash',
  );

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
######################################################################
##
## Private Methods
##
######################################################################
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

  my $library = $self->get_library;

  return SML::Index->new( library => $library );
}

######################################################################

sub _build_change_list {

  # Return a list of changes since the previous (library) version.

  my $self = shift;

  my $library = $self->get_library;
  my $aref    = [];

  foreach my $change (@{ $library->get_change_list })
    {
      my $division_id = $change->[1];

      if ( $self->contains_division_with_id($division_id) )
	{
	  push @{$aref}, $change;
	}
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

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012-2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
