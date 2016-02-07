#!/usr/bin/perl

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

has library =>
  (
   is       => 'ro',
   isa      => 'SML::Library',
   reader   => 'get_library',
   required => 1,
  );

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
  my $text = shift || '';

  # Wrap text to 70 columns.

  local($Text::Wrap::columns) = 70;
  local($Text::Wrap::huge)    = 'overflow';

  my $result = Text::Wrap::wrap('','',"$text");

  return $result;
}

######################################################################

sub hyphenate {

  # Convert periods to hyphens.

  my $self = shift;
  my $text = shift;

  unless ( $text )
    {
      $logger->warn("CAN'T HYPHENATE, MISSING ARGUMENT");
      return 0;
    }

  $text =~ s/\./\-/g;

  return $text;
}

######################################################################

sub remove_literals {

  my $self = shift;
  my $text = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;

  $text =~ s/$syntax->{literal}//g;

  return $text;
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

  $text =~ s/$syntax->{id_ref}/$1/g;
  $text =~ s/$syntax->{file_ref}/$1/g;
  $text =~ s/$syntax->{path_ref}/$1/g;
  $text =~ s/$syntax->{url_ref}/$1/g;
  $text =~ s/$syntax->{command_ref}/$1/g;
  $text =~ s/$syntax->{email_addr}/$1/g;
  $text =~ s/$syntax->{literal}/$1/g;

  $text =~ s/$syntax->{linebreak_symbol}/ /g;

  return $text;
}

######################################################################

sub commify_series {

  # Return a scalar which is a comma separated series of elements
  # joined with an "and" before the last element.
  #
  # Cite: Perl Cookbook section 4.2 pg 93.

  my $self = shift;

  ( @_ == 0 ) ? ''                :
  ( @_ == 1 ) ? $_[0]             :
  ( @_ == 2 ) ? join(" and ", @_) :
                join(", ", @_[ 0 .. ($#_-1)], "and $_[-1]");
 }

######################################################################

sub syntax_highlight_perl {

  my $self = shift;
  my $code = shift;

  use Syntax::Highlight::Perl::Improved ':FULL';

  my $format_table =
    {
     'Variable_Scalar'   => 'color:#FFFFFF;',
     'Variable_Array'    => 'color:#FFFFFF;',
     'Variable_Hash'     => 'color:#FFFFFF;',
     'Variable_Typeglob' => 'color:#f03;',
     'Subroutine'        => 'color:#FFFFFF;',
     'Quote'             => 'color:#DEDE73;',
     'String'            => 'color:#DEDE73;',
     'Comment_Normal'    => 'color:#ACAEAC;font-style:italic;',
     'Comment_POD'       => 'color:#ACAEAC;font-family:garamond,serif;font-size:11pt;',
     'Bareword'          => 'color:#FFFFFF;',
     'Package'           => 'color:#FFFFFF;',
     'Number'            => 'color:#4AAEAC;',
     'Operator'          => 'color:#7BE283;',
     'Symbol'            => 'color:#7BE283;',
     'Keyword'           => 'color:#7BE283;',
     'Builtin_Operator'  => 'color:#7BE283;',
     'Builtin_Function'  => 'color:#7BE283;',
     'Character'         => 'color:#DEDE73;',
     'Directive'         => 'color:#ACAEAC;font-style:italic;',
     'Label'             => 'color:#939;font-style:italic;',
     'Line'              => 'color:#000;',
     'Print'             => 'color:#7BE283;',
     'Hash'              => 'color:#FFFFFF;',
     'Translation_Operation' => 'color=#3199FF;',
    };

  my $formatter = Syntax::Highlight::Perl::Improved->new();

  $formatter->define_substitution
    (
     '<' => '&lt;',
     '>' => '&gt;',
     '&' => '&amp;',
    );

  while ( my ( $type, $style ) = each %{ $format_table } )
    {
      $formatter->set_format($type, [ qq|<span style="$style">|,'</span>' ] );
    }

  return $formatter->format_string($code);
}

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

# NONE

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
