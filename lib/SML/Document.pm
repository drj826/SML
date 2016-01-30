#!/usr/bin/perl

package SML::Document;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Document');

use SML::Library;        # ci-000410
use SML::Glossary;
use SML::AcronymList;
use SML::References;
use SML::Index;

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

######################################################################

has acronym_list =>
  (
   isa      => 'SML::AcronymList',
   reader   => 'get_acronym_list',
   lazy     => 1,
   builder  => '_build_acronym_list',
  );

######################################################################

has references =>
  (
   isa      => 'SML::References',
   reader   => 'get_references',
   lazy     => 1,
   builder  => '_build_references',
  );

######################################################################

has index =>
  (
   isa      => 'SML::Index',
   reader   => 'get_index',
   lazy     => 1,
   builder  => '_build_index',
  );

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

  my $hash = $self->_get_version_history_hash;

  if ( exists $hash->{$version}{$date} )
    {
      $logger->error("VERSION ALREADY EXISTS $version $date");
      return 0;
    }

  $hash->{$version}{$date} = $string;

  return 1;
}

######################################################################

sub contains_version_history {

  # Return 1 if this document contains version history information.

  my $self = shift;

  my $hash = $self->_get_version_history_hash;

  if ( scalar keys %{$hash} )
    {
      return 1;
    }

  return 0;
}

######################################################################

sub get_version_history_list {

  # Return a list of document versions in the version history.

  my $self = shift;

  my $hash = $self->_get_version_history_hash;

  my $list = [];                        # version history list

  foreach my $version ( reverse sort keys %{ $hash } )
    {
      foreach my $date ( sort keys %{ $hash->{$version} } )
	{
	  my $string = $hash->{$version}{$date};
	  push @{$list}, [$version,$date,$string];
	}
    }

  return $list;
}

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

######################################################################

sub get_page_after {

  # Return the page name of the page that should come AFTER the one
  # specified.  This works for front matter pages, section pages, and
  # back matter pages.
  #
  # Front matter pages should appear in the following default order:
  #
  #   1.  titlepage
  #   2.  contents
  #   3.  tables
  #   4.  figures
  #   5.  attachments
  #   6.  listings
  #   7.  demos
  #   8.  exercises
  #   9.  slides
  #   10. history
  #   11. change
  #
  #   ...pages by section number...
  #
  #   12. glossary
  #   13. acronyms
  #   14. references
  #   15. index

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

######################################################################

sub get_page_before {

  # Return the page name of the page that should come BEFORE the one
  # specified.  This works for front matter pages, section pages, and
  # back matter pages.
  #
  # Front matter pages should appear in the following default order:
  #
  #   1.  titlepage
  #   2.  contents
  #   3.  tables
  #   4.  figures
  #   5.  attachments
  #   6.  listings
  #   7.  demos
  #   8.  exercises
  #   9.  slides
  #   10. history
  #   11. change
  #
  #   ...pages by section number...
  #
  #   12. glossary
  #   13. acronyms
  #   14. references
  #   15. index

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

# $hash->{$version}{$date} = $string;

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

# $hash->{$level}{$location}{$message} = $error;

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
  my $list    = [];

  foreach my $change (@{ $library->get_change_list })
    {
      my $division_id = $change->[1];

      if ( $self->contains_division_with_id($division_id) )
	{
	  push @{$list}, $change;
	}
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

C<SML::Document> - a written work about a topic

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Division

  my $document = SML::Document->new
                   (
                     id      => $id,
                     library => $library,
                   );

  my $glossary     = $document->get_glossary;
  my $acronym_list = $document->get_acronym_list;
  my $references   = $document->get_references;
  my $string       = $document->get_author;
  my $string       = $document->get_date;
  my $string       = $document->get_revision;
  my $boolean      = $document->is_valid;

  my $boolean      = $document->add_note($note);
  my $boolean      = $document->add_index_term($term,$division_id);
  my $boolean      = $document->has_note($division_id,$number);
  my $boolean      = $document->has_index_term($term);
  my $note         = $document->get_note($division_id,$number);
  my $term         = $document->get_index_term($term);

=head1 DESCRIPTION

A document is a written work about a topic.  Documents have types:
book, report, or article. An SML document is composed of a DATA
SEGMENT followed by a NARRATIVE SEGMENT.

=head1 METHODS

=head2 get_glossary

=head2 get_acronym_list

=head2 get_references

=head2 get_author

=head2 get_date

=head2 get_revision

=head2 is_valid

=head2 add_note($note)

=head2 add_index_term($term,$division_id)

=head2 has_note($division_id,$number)

=head2 has_index_term($term)

=head2 has_glossary_term($term,$namespace)

=head2 has_acronym($term,$namespace)

=head2 has_source($id)

=head2 get_acronym_definition($acronym,$namespace)

=head2 get_note($division_id,$number)

=head2 get_index_term($term)

=head2 replace_division_id($division,$id)

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
