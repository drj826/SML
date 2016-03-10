#!/usr/bin/perl

package SML::Util;                      # ci-000383

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Util');

######################################################################

=head1 NAME

SML::Util - SML utility methods

=head1 SYNOPSIS

  SML::Util->new(library=>$library);

=head1 DESCRIPTION

An C<SML::Util> object provides various utility methods.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub trim_whitespace {

  my $self = shift;

  my $text = shift || '';

  $text =~ s/^\s*//m;            # ignore leading whitespace
  $text =~ s/\s*$//m;            # ignore trailing whitespace

  return $text;
}

=head2 trim_whitespace($text)

Remove the leading and trailing whitespace from a string.

  my $text = $util->trim_whitespace($text);

=cut

######################################################################

sub compress_whitespace {

  my $self = shift;

  my $text = shift || '';

  $text =~ s/\s+/ /g;

  return $text;
}

=head2 compress_whitespace($text)

Compress multiple whitespaces within a string into a single
whitespace.

  my $text = $util->compress_whitespace($text);

=cut

######################################################################

sub remove_newlines {

  my $self = shift;

  my $text = shift || '';

  $text =~ s/\r?\n/ /g;

  return $text;
}

=head2 remove_newlines($text)

Remove newlines from a string of text.

  my $text = $util->remove_newlines($text);

=cut

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

=head2 wrap($text)

Wrap a block of text to 70 columns.

  my $text = $util->wrap($text);

=cut

######################################################################

sub hyphenate {

  my $self = shift;

  my $text = shift || '';

  unless ( $text )
    {
      $logger->warn("CAN'T HYPHENATE, MISSING ARGUMENT");
      return 0;
    }

  $text =~ s/\./\-/g;

  return $text;
}

=head2 hyphenate($text)

Convert periods to hyphens within a string.

  my $text = $util->hyphenate($text);

=cut

######################################################################

sub remove_literals {

  my $self = shift;

  my $text = shift || '';

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  $text =~ s/$syntax->{literal_string}//g;

  return $text;
}

=head2 remove_literals($text)

Remove all SML literal strings from a text string.

  my $text = $util->remove_literals($text);

=cut

######################################################################

sub remove_keystroke_symbols {

  my $self = shift;

  my $text = shift || '';

  my $library = $self->_get_library;
  my $syntax  = $library->get_syntax;

  $text =~ s/$syntax->{keystroke_symbol}//g;

  return $text;
}

=head2 remove_keystroke_symbols($text)

Remove all SML keystroke symbols from a text string.

  my $text = $util->remove_keystroke_symbols($text);

=cut

######################################################################

sub walk_directory {

  my $self = shift;

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

=head2 walk_directory($filespec,$callback)

Recursively walk a directory and execute a callback.  Return 1 if
successful.

  my $result = $util->walk_directory($filespec,$callback);

=cut

######################################################################

sub strip_string_markup {

  my $self = shift;

  my $text = shift || '';

  my $library = $self->_get_library;
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
  $text =~ s/$syntax->{literal_string}/$1/g;

  $text =~ s/$syntax->{linebreak_symbol}/ /g;

  return $text;
}

=head2 strip_string_markup($text)

Strip all string markup out of a text string.

  my $text = $util->strip_string_markup($text);

=cut

######################################################################

sub commify_series {

  my $self = shift;

  ( @_ == 0 ) ? ''                :
  ( @_ == 1 ) ? $_[0]             :
  ( @_ == 2 ) ? join(" and ", @_) :
                join(", ", @_[ 0 .. ($#_-1)], "and $_[-1]");
}

=head2 commify_series

Return a scalar which is a comma separated series of elements joined
with an "and" before the last element. Cite: Perl Cookbook section 4.2
pg 93.

  my $text = $util->commify_series(@list);

=cut

######################################################################

sub syntax_highlight_perl {

  my $self = shift;
  my $code = shift;

  use Syntax::Highlight::Perl::Improved ':FULL';

  my $format_table =
    {
     'Variable_Scalar'       => 'syntax_highlight_perl_Variable_Scalar',
     'Variable_Array'        => 'syntax_highlight_perl_Variable_Array',
     'Variable_Hash'         => 'syntax_highlight_perl_Variable_Hash',
     'Variable_Typeglob'     => 'syntax_highlight_perl_Variable_Typeglob',
     'Subroutine'            => 'syntax_highlight_perl_Subroutine',
     'Quote'                 => 'syntax_highlight_perl_Quote',
     'String'                => 'syntax_highlight_perl_String',
     'Comment_Normal'        => 'syntax_highlight_perl_Comment_Normal',
     'Comment_POD'           => 'syntax_highlight_perl_Comment_POD',
     'Bareword'              => 'syntax_highlight_perl_Bareword',
     'Package'               => 'syntax_highlight_perl_Package',
     'Number'                => 'syntax_highlight_perl_Number',
     'Operator'              => 'syntax_highlight_perl_Operator',
     'Symbol'                => 'syntax_highlight_perl_Symbol',
     'Keyword'               => 'syntax_highlight_perl_Keyword',
     'Builtin_Operator'      => 'syntax_highlight_perl_Builtin_Operator',
     'Builtin_Function'      => 'syntax_highlight_perl_Builtin_Function',
     'Character'             => 'syntax_highlight_perl_Character',
     'Directive'             => 'syntax_highlight_perl_Directive',
     'Label'                 => 'syntax_highlight_perl_Label',
     'Line'                  => 'syntax_highlight_perl_Line',
     'Print'                 => 'syntax_highlight_perl_Print',
     'Hash'                  => 'syntax_highlight_perl_Hash',
     'Translation_Operation' => 'syntax_highlight_perl_Translation_Operation',
    };

  my $formatter = Syntax::Highlight::Perl::Improved->new();

  $formatter->define_substitution
    (
     '<' => '&lt;',
     '>' => '&gt;',
     '&' => '&amp;',
    );

  while ( my ( $type, $class ) = each %{ $format_table } )
    {
      $formatter->set_format($type, [ qq|<span class="$class">|,'</span>' ] );
    }

  return $formatter->format_string($code);
}

=head2 syntax_highlight_perl($code)

Given a block of Perl code, return a scalar text value which is Perl
code syntax highlighted using HTML.

  my $highlighted_code = $util->syntax_highlight_perl($code);

=cut

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has library =>
  (
   is       => 'ro',
   isa      => 'SML::Library',
   reader   => '_get_library',
   required => 1,
  );

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
