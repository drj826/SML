#!/usr/bin/perl

# $Id: Util.pm 255 2015-04-01 16:07:27Z drj826@gmail.com $

package SML::Util;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Util');

use SML::Options;
use SML::Line;
use SML::Block;
use SML::File;
use SML::Document;
# use SML::Library;

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has options =>
  (
   is        => 'ro',
   isa       => 'SML::Options',
   reader    => 'get_options',
   writer    => 'set_options',
   clearer   => 'clear_options',
   predicate => 'has_options',
   default   => sub { SML::Options->new },
  );

# An SML::Options object that remembers the runtime options such as:
# (1) whether the program is being run in GUI or command line mode,
# (2) whether or not to generate verbose messages, (3) whether or not
# to run scripts, (4) the location of the SVN executable,(5) the
# location of the pdflatex executable, etc.

######################################################################

has library =>
  (
   is       => 'ro',
   isa      => 'SML::Library',
   reader   => 'get_library',
   required => 1,
  );

######################################################################

has blank_line =>
  (
   is       => 'ro',
   isa      => 'SML::Line',
   reader   => 'get_blank_line',
   lazy     => 1,
   builder  => '_build_blank_line',
  );

######################################################################

has empty_block =>
  (
   is       => 'ro',
   isa      => 'SML::Block',
   reader   => 'get_empty_block',
   lazy     => 1,
   builder  => '_build_empty_block',
  );

######################################################################

has empty_file =>
  (
   is       => 'ro',
   isa      => 'SML::File',
   reader   => 'get_empty_file',
   lazy     => 1,
   builder  => '_build_empty_file',
  );

######################################################################

has empty_document =>
  (
   is       => 'ro',
   isa      => 'SML::Document',
   reader   => 'get_empty_document',
   lazy     => 1,
   builder  => '_build_empty_document',
  );

######################################################################

has default_section =>
  (
   is       => 'ro',
   isa      => 'SML::Section',
   reader   => 'get_default_section',
   lazy     => 1,
   builder  => '_build_default_section',
  );

# Some documents have no explicit section structure.  However, section
# numbers are used in all hyperlinks.  To avoid errors, therefore,
# every document has a default section.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub trim_whitespace {

  # Trim leading and trailing whitespace from a line of text.

  my $self = shift;
  my $text = shift || '';

  $text =~ s/^\s*//m;            # ignore leading whitespace
  $text =~ s/\s*$//m;            # ignore trailing whitespace

  return $text;
}

######################################################################

sub compress_whitespace {

  # Compress multiple whitespaces within a string into a single
  # whitespace.

  my $self = shift;
  my $text = shift || '';

  $text =~ s/\s+/ /g;

  return $text;

}

######################################################################

sub remove_newlines {

  my $self = shift;
  my $text = shift || '';

  $text =~ s/\r?\n/ /g;

  return $text;
}

######################################################################

sub wrap {

  my $self = shift;

  # Wrap text to 70 columns.

  local($Text::Wrap::columns) = 70;
  local($Text::Wrap::huge)    = 'overflow';

  my $string = shift || '';

  my $result = Text::Wrap::wrap(
        '',
        '',
        "$string"
  );

  return $result;
}

######################################################################

sub hyphenate {

  # Convert periods to hyphens.

  my $self   = shift;
  my $string = shift;

  if ( $string )
    {
      $string =~ s/\./\-/g;
    }

  else
    {
      $logger->warn("NO STRING PASSED to 'hyphenate' method");
    }

  return $string;

}

######################################################################

sub remove_literals {

  my $self   = shift;
  my $string = shift;

  $string =~ s/\{lit:(.*?)\}//g;

  return $string;
}

######################################################################

sub remove_keystroke_symbols {

  my $self = shift;
  my $text = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;

  $text =~ s/$syntax->{keystroke_symbol}//g;

  return $text;
}

######################################################################

sub walk_directory {

  my $self     = shift;
  my $filespec = shift;
  my $callback = shift;

  my $DIR;

  $callback->($filespec);

  if ( -d $filespec )
    {
      my $file;

      if ( not opendir $DIR, $filespec )
	{
	  $logger->warn("Couldn't open directory $filespec: $!; skipping.");
	  return 0;
	}

      while ( $file = readdir $DIR )
	{
	  next if $file eq '.';
	  next if $file eq '..';

	  $self->walk_directory("$filespec/$file", $callback);
	}
    }

  return 1;
}

######################################################################

sub strip_string_markup {

  my $self = shift;
  my $text = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;

  $text =~ s/$syntax->{bold_string}/$1/g;
  $text =~ s/$syntax->{italics_string}/$1/g;
  $text =~ s/$syntax->{fixedwidth_string}/$1/g;
  $text =~ s/$syntax->{underline_string}/$1/g;
  $text =~ s/$syntax->{superscript_string}/$1/g;
  $text =~ s/$syntax->{subscript_string}/$1/g;
  $text =~ s/$syntax->{user_entered_text}/$2/g;
  $text =~ s/$syntax->{sglquote_string}/$1/g;
  $text =~ s/$syntax->{dblquote_string}/$1/g;

  $text =~ s/$syntax->{linebreak_symbol}/ /g;

  return $text;
}

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _build_blank_line {

  my $self = shift;

  my $line = SML::Line->new(content=>"\n");

  return $line;
}

######################################################################

sub _build_default_section {

  my $self = shift;

  use SML::Section;

  my $section = SML::Section->new
    (
     depth       => 0,
     id          => 'SECTION-0',
     number      => '0',
     top_number  => '0',
    );

  return $section;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Util> - an object that can perform string manipulations and
other amazing feats.

=head1 VERSION

This documentation refers to L<"SML::Util"> version 2.0.0.

=head1 SYNOPSIS

  my $opt = SML::Options->new();

=head1 DESCRIPTION

A SML options object can perform string manipulations and other
amazing feats.

=head1 METHODS

=head2 get_options

=head2 get_blank_line

=head2 get_empty_block

=head2 get_empty_file

=head2 get_empty_document

=head2 get_default_section

=head2 trim_whitespace

=head2 compress_whitespace

=head2 remove_newlines

=head2 wrap

=head2 hyphenate

=head2 remove_literals

=head2 remove_keystroke_symbols

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
