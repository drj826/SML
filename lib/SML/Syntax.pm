#!/usr/bin/perl

# $Id: Syntax.pm 280 2015-07-11 12:52:43Z drj826@gmail.com $

package SML::Syntax;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Syntax');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

#---------------------------------------------------------------------
# NON-REFERENCE STRINGS
#---------------------------------------------------------------------

has 'bold' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^!]?)!!([^!]?)',
  );

# $1 = prechar
# $2 = postchar

######################################################################

has 'bold_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '!!([^!]+?)!!',
  );

# $1 = text

######################################################################

has 'italics' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^~]?)~~([^~]?)',
  );

# $1 = prechar
# $2 = postchar

######################################################################

has 'italics_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '~~([^~]+?)~~',
  );

# $1 = text

######################################################################

has 'fixedwidth' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^\|]?)\|\|([^\|]?)',
  );

# $1 = prechar
# $2 = postchar

######################################################################

has 'fixedwidth_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\|\|([^\|]+?)\|\|',
  );

# $1 = text

######################################################################

has 'underline' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^_]?)__([^_]?)',
  );

# $1 = prechar
# $2 = postchar

######################################################################

has 'underline_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '__([^_]+?)__',
  );

# $1 = text

######################################################################

has 'superscript' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^\^]?)\^\^([^\^]?)',
  );

# $1 = prechar
# $2 = postchar

######################################################################

has 'superscript_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\^\^([^\^]+?)\^\^',
  );

# $1 = text

######################################################################

has 'subscript' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^\,]?)\,\,([^\,]?)',
  );

# $1 = prechar
# $2 = postchar

######################################################################

has 'subscript_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\,\,([^\,]+?)\,\,',
  );

# $1 = text

######################################################################

has 'keystroke_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[\[([^\]]+?)\]\]',
  );

# $1 = text

######################################################################

has 'user_entered_text' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(enter|en):\s*([^\]]+?)\s*\]',
  );

# $1 = tag (not significant)
# $2 = user entered text

######################################################################

has 'xml_tag' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '<([^>]+)>',
  );

######################################################################

has 'sglquote_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => q{`([^'`]*?)'},
  );

# $1 = quoted string

######################################################################

has 'dblquote_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => q{``([^']*)''},
  );

# $1 = quoted string

#---------------------------------------------------------------------
# EXTERNAL REFERENCE STRINGS
#---------------------------------------------------------------------

has 'file_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[file:\s*([^\]]+?)\s*\]',
  );

# $1 => filespec

######################################################################

has 'path_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[path:\s*([^\]]+?)\s*\]',
  );

######################################################################

has 'url_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[url:\s*([^\s\|\]]+?)(\|(.*))?\s*\]',
  );

# $1 = URL
# $3 = link text

######################################################################

has 'command_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[cmd:\s*([^\]]+?)\s*\]',
  );

######################################################################

has 'email_addr' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[email:\s*([^\s\|\]]+?)(\|(.*))?\s*\]',
   # default => '\b([a-zA-Z0-9._]+@[a-zA-Z0-9._]+\.[a-zA-Z0-9._]+)\b',
  );

# $1 = email_addr
# $2
# $3 = content

#---------------------------------------------------------------------
# INTERNAL REFERENCE STRINGS
#---------------------------------------------------------------------

has 'lookup_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(lookup|l):([^\]]+?):([\w\-\.]+)\]',
  );

# $1
# $2 = property_name
# $3 = division_id

######################################################################

has 'cross_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(ref|r):\s*([^\s\]]+?)\s*\]',
  );

# $1 = tag
# $2 = target_id

######################################################################

has 'begin_cross_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(ref|r):',
  );

######################################################################

has 'id_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[id:\s*([^\s\]]+?)\s*\]',
  );

# $1 = id

######################################################################

has 'begin_id_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[id:',
  );

######################################################################

has 'page_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(page|pg):\s*([^\s\]]+?)\s*\]',
  );

# $1 = tag
# $2 = target_id

######################################################################

has 'begin_page_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(page|pg):',
  );

######################################################################

has 'footnote_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[f:(\S+):(\S+)\]',
  );

# $1 = section ID
# $2 = footnote number

######################################################################

has 'index_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(index|i):\s*([^\]]+?)\s*\]',
  );

# $1 = tag (not significant)
# $2 = index entry text

######################################################################

has 'citation_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(cite|c):\s*([^\s\]]+?)\s*(,\s*(.*))?\s*\]',
  );

# $1 = tag
# $2 = source_id
# $3 =
# $4 = details (usually citation location details)

######################################################################

has 'begin_citation_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(cite|c):',
  );

# $1 = tag

######################################################################

has 'variable_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[var:([^\]]+)(:([^\]]+))?\]',
  );

# $1 = variable name
# $2
# $3 = alt namespace

######################################################################

has 'gloss_term_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(g|G|gls|Gls):(([^\s\]]+?):)?([^\]]+?)\]',
  );

# $1 = tag (used as capitalization indicator)
# $2 = namespace
# $3 =
# $4 = glossary term

######################################################################

has 'begin_gloss_term_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(g|G|gls|Gls):',
  );

# $1 = tag (used as capitalization indicator)

######################################################################

has 'gloss_def_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[def:(([^\s\]]+?):)?([^\]]+?)\]',
  );

# $1 =
# $2 = namespace
# $3 = term

######################################################################

has 'begin_gloss_def_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[def:',
  );

######################################################################

has 'acronym_term_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(a|ac|acs|acl):(([^\s\]]+?):)?([^\]]+?)\]',
  );

# $1 = tag
# $2
# $3 = namespace
# $4 = acronym

######################################################################

has 'begin_acronym_term_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(a|ac|acs|acl):',
  );

######################################################################

has 'status_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[status:\s*([^\s\]]+?)\s*\]',
  );


# $1 = entity_id (or color)

#---------------------------------------------------------------------
# OTHER STRINGS
#---------------------------------------------------------------------

has 'literal' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\{lit:(.*?)\}',
  );

#---------------------------------------------------------------------
# REPLACEMENT SYMBOLS
#---------------------------------------------------------------------

has 'thepage_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[thepage\]',
  );

######################################################################

has 'thedate_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[thedate\]',
  );

# NOTE: This is the current date (i.e. today's date) and not the value
# of the document's date property.

######################################################################

has 'pagecount_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[pagecount\]',
  );

######################################################################

has 'thesection_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[thesection\]',
  );

######################################################################

has 'theversion_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[theversion\]',
  );

######################################################################

has 'therevision_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[therevision\]',
  );

#---------------------------------------------------------------------
# OTHER SYMBOLS
#---------------------------------------------------------------------

has 'linebreak_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[linebreak\]',
  );

######################################################################

has 'pagebreak_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[pagebreak\]',
  );

######################################################################

has 'clearpage_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[clearpage\]',
  );

######################################################################

has 'take_note_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[take_note\]',
  );

######################################################################

has 'smiley_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => ':-\)',
  );

######################################################################

has 'frowny_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => ':-\(',
  );

######################################################################

has 'left_arrow_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '<-([^-]?)',
  );

# $1 = postchar

# !!! BUG HERE !!!
#
# Won't this regular expression capture the character to the right of
# the left arrow symbol and that character will be lost?  The code
# that uses this regular expression needs to do something with the
# captured character to the right of the symbol.

######################################################################

has 'right_arrow_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^-]?)->',
  );

# $1 = prechar

# !!! BUG HERE !!!
#
# Won't this regular expression capture the character to the left of
# the right arrow symbol and that character will be lost?  The code
# that uses this regular expression needs to do something with the
# captured character to the left of the symbol.

######################################################################

has 'latex_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\bLaTeX\b',
  );

######################################################################

has 'tex_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\bTeX\b',
  );

######################################################################

has 'copyright_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[c\]',
  );

######################################################################

has 'trademark_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[tm\]',
  );

######################################################################

has 'reg_trademark_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[rtm\]',
  );

######################################################################

# has 'open_dblquote_symbol' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => q{``},
#   );

######################################################################

# has 'close_dblquote_symbol' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => q{''},
#   );

######################################################################

# has 'open_sglquote_symbol' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => q{([^`])`([^`])},
#   );

# $1 = preceding character
# $2 = following character

######################################################################

# has 'close_sglquote_symbol' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => q{([^'])'([^'])},
#   );

# $1 = preceding character
# $2 = following character

######################################################################

has 'section_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[section\]',
  );

######################################################################

has 'emdash_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^\-])?--([^\-])?',
  );

# $1 = preceding character
# $2 = following character

# !!! BUG HERE !!!
#
# Won't this regular expression capture the characters to the left and
# right the emdash symbol and those characters will be lost?  The code
# that uses this regular expression needs to do something with the
# captured characters to the left and right of the symbol.

#---------------------------------------------------------------------
# BLOCKS
#---------------------------------------------------------------------

has 'paragraph_text' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^[^\s#]',
  );

# A paragraph can be just about any block of text.  The two main
# exceptions are (1) a block of text that begins with one or more
# white spaces is pre-formatted text, and (2) a block of text that
# begins with a '#' is a comment.  The default regular expression
# above represents these two exceptions.

# There are other exceptions not represented by the default regular
# expression above.  For instance a block of text that begins with a
# '-', '+', or '=' (followed by one or more spaces) is a list item and
# a block of text that begins with a '*' (followed by one or more
# spaces) is a section heading. Parser logic is used to distinguish
# these blocks from paragraph text.  The parser will detect that a
# block is one of these before detecting that a block is a just a
# plain paragraph.

######################################################################

has 'list_item' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\s*)([\-\+\=])\s+(.*)',
  );

# $1 = indent
# $2 = bullet character
# $3 = item text

######################################################################

has 'bull_list_item' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\s*)\-\s+(.*)',
  );

# $1 = indent
# $2 = text

######################################################################

has 'enum_list_item' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\s*)\+\s+(.*)',
  );

# $1 = indent
# $2 = text

######################################################################

has 'def_list_item' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^\=\s+(.*?)\s+\=\s+(.*?)\s*$',
  );

# $1 = term
# $2 = definition

######################################################################

has 'indented_text' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^\s+\S+',
  );

######################################################################

has 'comment_line' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^#',
  );

# !!! BUG HERE !!!
#
# Improve comment line syntax to allow leading whitespace.

#---------------------------------------------------------------------
# ELEMENTS
#---------------------------------------------------------------------

has 'element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^([a-zA-Z_]+)::(\S+:)?\s*(.*?)\s*(\#(.*))?$',
  );

# $1 = element name
# $2 = args
# $3 = element value
# $4
# $5 = comment text

######################################################################

has 'title_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^title::\s*(.*?)\s*(\#(.*))?$',
  );

# $1 = title text
# $2
# $3 = comment text

# NOTE: This syntax means you can't put a '#' in title text.

######################################################################

# has 'id_element' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^(id|label)::\s*(.*?)\s*(\#(.*))?$',
#   );

# $1 = id or label
# $2 = id value
# $3 = comment
# $4 = comment content

######################################################################

# has 'author_element' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^author::\s*(.*?)\s*(\#(.*))?$',
#   );

# # $1 = author value
# # $2
# # $3 = comment text

######################################################################

# has 'date_element' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^date::\s*(.*?)\s*(\#(.*))?$',
#   );

# # $1 = date value
# # $2
# # $3 = comment text

######################################################################

# has 'revision_element' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^revision::\s*(.*?)\s*(\#(.*))?$',
#   );

# # $1 = revision value
# # $2
# # $3 = comment text

######################################################################

# has 'document_file_element' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^document_file::\s*(.*?)\s*(\#(.*))?$',
#   );

# # $1 = filespec
# # $2
# # $3 = comment text

######################################################################

# has 'fragment_file_element' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^fragment_file::\s*(.*?)\s*(\#(.*))?$',
#   );

# # $1 = filespec
# # $2
# # $3 = comment text

######################################################################

# has 'entity_file_element' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^entity_file::\s*(.*?)\s*(\#(.*))?$',
#   );

# # $1 = filespec
# # $2
# # $3 = comment text

######################################################################

# has 'reference_file_element' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^reference_file::\s*(.*?)\s*(\#(.*))?$',
#   );

# # $1 = filespec
# # $2
# # $3 = comment text

######################################################################

# has 'script_file_element' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^script_file::\s*(.*?)\s*(\#(.*))?$',
#   );

# # $1 = filespec
# # $2
# # $3 = comment text

######################################################################

has 'insert_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^insert::\s*(.*?)(\((.*)\))?\s*(\#(.*))?$',
  );

# $1 = value
# $2
# $3 = args
# $4
# $5 = comment text

######################################################################

has 'insert_ins_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^insert_ins::\s*(.*)',
  );

# $1 = value

######################################################################

has 'insert_gen_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^insert_gen::\s*(.*)',
  );

# $1 = value

######################################################################

# has 'insert_string' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '(.*?)\((.*)\)',
#   );

# # $1 = value
# # $2 = division ID

######################################################################

has 'template_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^include::((.*?)=(.*?):)+\s+(.*?)\s*(\#(.*))?$',
  );

# $1
# $2 = variable name
# $3 = variable value
# $4 = template filespec
# $5 =
# $6 = comment text

######################################################################

has 'generate_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^generate::\s*([\w\-]+)(\([\w\-]+\))?\s*(\#(.*))?$',
   #                         1        2                3  4
  );

# $1 = generated content type
# $2
# $3 = division ID
# $4
# $5 = comment text

######################################################################

has 'include_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\*+\s+)?include::([\w\-\*\$]+:)*\s+(.+?)\s*(\#(.*))?$',
   #            1                 2                 3       4  5
  );

# $1 = leading asterisks
# $2 = args
# $3 = division ID
# $4
# $5 = comment text

######################################################################

has 'csvfile_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^csvfile::\s+(.*?)\s*$',
  );

# $1 = csv filename

# !!! BUG HERE !!!
#
# SML::Parser doesn't yet know what to do with a csvfile element.

######################################################################

has 'script_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^script::(\S+?:)?\s*(.*?)\s*(\#(.*))?$',
  );

# $1 = option
# $2 = filespec
# $3
# $4 = comment text

######################################################################

has 'outcome_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^outcome::(.*?):(.*?):(.*?):\s*(.+)\s*(\#(.*))?$',
  );

# $1 = date (yyyy-mm-dd)
# $2 = entity ID
# $3 = status color (green, yellow, red, grey)
# $4 = outcome description
# $5
# $6 = comment text

######################################################################

has 'review_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^review::(.*?):(.*?):(.*?):\s*(.+)\s*(\#(.*))?$',
  );

# $1 = date (yyyy-mm-dd)
# $2 = entity ID
# $3 = status color (green, yellow, red, grey)
# $4 = review description
# $5
# $6 = comment text

######################################################################

has 'index_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^index::(\S+:)?\s*(.*?)\s*(\#(.*))?$',
  );

# $1 = begin or end
# $2 = index term
# $3
# $4 = comment text

######################################################################

has 'file_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^file::\s*(.+?)\s*(\#(.*))?\s*$',
  );

# $1 = filespec
# $2
# $3 = comment text

######################################################################

has 'image_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(image|logo_image_(left|center|right|small))::\s*(.*?)\s*(\#(.*))?\s*$',
  );

# $1 = image type
# $2
# $3 = filespec
# $4
# $5 = comment text

######################################################################

has 'definition_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^([a-zA-Z_]+)::\s*(.*?)\s*(\{(.*?)\})?\s*=\s*(.*?)\s*(\#(.*))?\s*$',
  );

# $1 = element name
# $2 = defined term
# $3
# $4 = alt namespace
# $5 = definition text
# $6
# $7 = comment text

######################################################################

has 'glossary_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(glossary)::\s*(.*?)\s*(\{(.*?)\})?\s*=\s*(.*?)\s*(\#(.*))?$',
  );

# $1 = tag name
# $2 = glossary term
# $3
# $4 = alt namespace
# $5 = definition text
# $6
# $7 = comment text

######################################################################

has 'variable_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(var)::\s*(.*?)\s*(\{(.*?)\})?\s*=\s*(.*?)\s*(\#(.*))?$',
  );

# $1 = tag name
# $2 = variable name
# $3
# $4 = alt namespace
# $5= variable value
# $6
# $7 = comment text

######################################################################

has 'acronym_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(acronym)::\s*(.*?)\s*(\{(.*?)\})?\s*=\s*(.*?)\s*(\#(.*))?$',
  );

# $1 = tag name
# $2 = acronym
# $3
# $4 = alt namespace
# $5 = acronym definition
# $6
# $7 = comment text

######################################################################

has 'note_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(note|footnote)::([^\s\:]+):(([^\s\:]+):)?\s*(.*?)\s*(\#(.*))?$',
  );

# $1 = note type (note or footnote)
# $2 = tag
# $3
# $4 = division ID (optional)
# $5 = note text
# $6
# $7 = comment text

######################################################################

has 'step_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^step::\s*(.+?)\s*(\#(.*))?\s*$',
  );

# $1 = text
# $2
# $3 = comment text

#---------------------------------------------------------------------
# DIVISIONS
#---------------------------------------------------------------------

has 'start_division' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^>{3}(\w+)(\.([\w\-]+))?',
  );

# $1 = division name
# $2 =
# $3 = division ID

######################################################################

has 'end_division' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^<{3}(\w+)',
  );

# $1 = division name

######################################################################

has 'start_section' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\*+)(\.([-\w]+))?\s+(.*?)\s*$',
  );

# $1 = 1 or more '*'
# $2 =
# $3 = section ID
# $4 = section heading

######################################################################

# has 'start_comment' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^>{3}COMMENT',
#   );

######################################################################

# has 'end_comment' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^<{3}COMMENT',
#   );

######################################################################

# has 'start_conditional' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^>{3}CONDITIONAL.([\w\-]+)',
#   );

# $1 = conditional token

######################################################################

# has 'end_conditional' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '^<{3}CONDITIONAL',
#   );

######################################################################

has 'table_cell' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(:{1,2})(\w+:)?\s*(.*)?',
  );

# $1 = one or two colons (1 = table cell, 2 = table header cell)
# $2 = arguments
# $3 = paragraph content

######################################################################

has 'end_table_row' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^-{3}',
  );

#---------------------------------------------------------------------
# OTHER REGEXS
#---------------------------------------------------------------------

has 'segment_separator' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^={3}$',
  );

######################################################################

has 'blank_line' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^\s*$',
  );

######################################################################

has 'non_blank_line' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\S+',
  );

######################################################################

has 'inline_tag' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '(\[(\w+)\])',
  );

#---------------------------------------------------------------------
# VALIDATION REGULAR EXPRESSIONS
#---------------------------------------------------------------------

has 'valid_inline_tags' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '(linebreak|pagebreak|clearpage|section|theversion|thepage|pagecount|thesection|therevision|copyright|thedate|tm|c|rtm|email)',
  );

######################################################################

has 'valid_date' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\d\d\d\d)-(\d\d)-(\d\d)$',
  );

######################################################################

has 'valid_status' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(green|yellow|red|grey)$',
  );

######################################################################

has 'valid_description' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\S',
  );

######################################################################

has 'valid_ontology_rule_type' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '(cls|prp|enu|cmp)',
  );

######################################################################

has 'valid_cardinality_value' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '(1|many)',
  );

######################################################################

has 'key_value_pair' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^\s*(.*?)\s*=\s*(.*?)\s*$',
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Syntax> - the SML data format rules used to express document
structure and content.

=head1 VERSION

This documentation refers to L<"SML::Syntax"> version 2.0.0.

=head1 SYNOPSIS

  my $syntax = SML::Syntax->new();

=head1 DESCRIPTION

Syntax represents the SML data format rules used to express document
structure and content.  These rules are expressed as a collection of
regular expressions used to parse document text.

The syntax is organized by parts.  Here is the part class hierarchy
showing associated regular expressions defined by SML::Syntax:

  SML::Part
   |
   #------------------------------------------------------------------
   # STRINGS
   #------------------------------------------------------------------
   |
   +-- SML::String
   |    |
   |    #-------------------------------------------------------------
   |    # NON-REFERENCE STRINGS
   |    #-------------------------------------------------------------
   |    |
   |    +-- regex: bold
   |    +-- regex: bold_string
   |    +-- regex: italics
   |    +-- regex: italics_string
   |    +-- regex: fixedwidth
   |    +-- regex: fixedwidth_string
   |    +-- regex: underline
   |    +-- regex: underline_string
   |    +-- regex: superscript
   |    +-- regex: superscript_string
   |    +-- regex: subscript
   |    +-- regex: subscript_string
   |    +-- regex: keystroke_symbol
   |    |
   |    +-- SML::UserEnteredText
   |    |    |
   |    |    +-- regex: user_entered_text
   |    |
   |    +-- SML::XMLTag
   |    |    |
   |    |    +-- regex: xml_tag
   |    |
   |    #-------------------------------------------------------------
   |    # EXTERNAL REFERENCE STRINGS
   |    #-------------------------------------------------------------
   |    |
   |    +-- SML::FileReference
   |    |    |
   |    |    +-- regex: file_ref
   |    |
   |    +-- SML::PathReference
   |    |    |
   |    |    +-- regex: path_ref
   |    |
   |    +-- SML::URLReference
   |    |    |
   |    |    +-- regex: url_ref
   |    |
   |    +-- SML::CommandReference
   |    |    |
   |    |    +-- regex: command_ref
   |    |
   |    +-- SML::EmailAddress
   |    |    |
   |    |    +-- regex: email_addr
   |    |
   |    #-------------------------------------------------------------
   |    # INTERNAL REFERENCE STRINGS
   |    #-------------------------------------------------------------
   |    |
   |    +-- regex: lookup_ref
   |    |
   |    +-- SML::CrossReference
   |    |    |
   |    |    +-- regex: cross_ref
   |    |    +-- regex: begin_cross_ref
   |    |
   |    +-- SML::IDReference
   |    |    |
   |    |    +-- regex: id_ref
   |    |    +-- regex: begin_id_ref
   |    |
   |    +-- SML::PageReference
   |    |    |
   |    |    +-- regex: page_ref
   |    |    +-- regex: begin_page_ref
   |    |
   |    +-- SML::FootnoteReference
   |    |    |
   |    |    +-- regex: footnote_ref
   |    |
   |    +-- SML::IndexReference
   |    |    |
   |    |    +-- regex: index_ref
   |    |
   |    +-- SML::CitationReference
   |    |    |
   |    |    +-- regex: citation_ref
   |    |    +-- regex: begin_citation_ref
   |    |
   |    +-- SML::VariableReference
   |    |    |
   |    |    +-- regex: variable_ref
   |    |
   |    +-- SML::GlossaryTermReference
   |    |    |
   |    |    +-- regex: gloss_term_ref
   |    |    +-- regex: begin_gloss_term_ref
   |    |
   |    +-- SML::GlossaryDefinitionReference
   |    |    |
   |    |    +-- regex: gloss_def_ref
   |    |    +-- regex: begin_gloss_def_ref
   |    |
   |    +-- SML::AcronymTermReference
   |    |    |
   |    |    +-- regex: acronym_term_ref
   |    |    +-- regex: begin_acronym_term_ref
   |    |
   |    +-- SML::StatusReference
   |    |    |
   |    |    +-- regex: status_ref
   |    |
   |    #-------------------------------------------------------------
   |    # OTHER STRINGS
   |    #-------------------------------------------------------------
   |    |
   |    +-- SML::LiteralString
   |    |    |
   |    |    +-- regex: literal
   |    |
   |    +-- SML::SyntaxErrorString
   |    |
   |    #-------------------------------------------------------------
   |    # SYMBOLS
   |    #-------------------------------------------------------------
   |    |
   |    +-- SML::Symbol
   |    |    |
   |    |    #--------------------------------------------------------
   |    |    # REPLACEMENT SYMBOLS
   |    |    #--------------------------------------------------------
   |    |    |
   |    |    +-- regex: thepage_ref
   |    |    +-- regex: thedate_ref
   |    |    +-- regex: pagecount_ref
   |    |    +-- regex: thesection_ref
   |    |    +-- regex: theversion_ref
   |    |    +-- regex: therevision_ref
   |    |    |
   |    |    #--------------------------------------------------------
   |    |    # OTHER SYMBOLS
   |    |    #--------------------------------------------------------
   |    |    |
   |    |    +-- regex: linebreak_symbol
   |    |    +-- regex: pagebreak_symbol
   |    |    +-- regex: clearpage_symbol
   |    |    +-- regex: take_note_symbol
   |    |    +-- regex: smiley_symbol
   |    |    +-- regex: frowny_symbol
   |    |    +-- regex: left_arrow_symbol
   |    |    +-- regex: right_arrow_symbol
   |    |    +-- regex: latex_symbol
   |    |    +-- regex: tex_symbol
   |    |    +-- regex: copyright_symbol
   |    |    +-- regex: trademark_symbol
   |    |    +-- regex: reg_trademark_symbol
   |    |    +-- regex: open_dblquote_symbol
   |    |    +-- regex: close_dblquote_symbol
   |    |    +-- regex: open_sglquote_symbol
   |    |    +-- regex: close_sglquote_symbol
   |    |    +-- regex: section_symbol
   |    |    +-- regex: emdash_symbol
   |
   #------------------------------------------------------------------
   # BLOCKS
   #------------------------------------------------------------------
   |
   +-- SML::Block
   |    |
   |    +-- SML::Paragraph
   |    |    |
   |    |    +-- regex: paragraph_text
   |    |
   |    +-- SML::ListItem
   |    |    |
   |    |    +-- regex: list_item
   |    |    |
   |    |    +-- SML::BulletListItem
   |    |    |    |
   |    |    |    +-- regex: bull_list_item
   |    |    |
   |    |    +-- SML::EnumeratedListItem
   |    |    |    |
   |    |    |    +-- regex: enum_list_item
   |    |    |
   |    |    +-- SML::DefinitionListItem
   |    |    |    |
   |    |    |    +-- regex: def_list_item
   |    |
   |    +-- SML::PreformattedBlock
   |    |    |
   |    |    +-- regex: indented_text
   |    |    |
   |    |    +-- SML::CommentBlock
   |    |    |    |
   |    |    |    +-- regex: comment_line
   |    |
   |    #-------------------------------------------------------------
   |    # ELEMENTS
   |    #-------------------------------------------------------------
   |    |
   |    +-- SML::Element
   |    |    |
   |    |    +-- regex: element
   |    |    +-- regex: title_element
   |    |    +-- regex: id_element
   |    |    +-- regex: insert_element
   |    |    +-- regex: insert_ins_element
   |    |    +-- regex: insert_gen_element
   |    |    +-- regex: template_element
   |    |    +-- regex: generate_element
   |    |    +-- regex: include_element
   |    |    +-- regex: csvfile_element
   |    |    +-- regex: script_element
   |    |    +-- regex: outcome_element
   |    |    +-- regex: review_element
   |    |    +-- regex: index_element
   |    |    +-- regex: file_element
   |    |    +-- regex: image_element
   |    |    |
   |    |    +-- SML::Definition
   |    |    |    |
   |    |    |    +-- regex: definition_element
   |    |    |    +-- regex: glossary_element
   |    |    |    +-- regex: variable_element
   |    |    |    +-- regex: acronym_element
   |    |    |
   |    |    +-- SML::Note
   |    |    |    |
   |    |    |    +-- regex: note_element
   |
   #------------------------------------------------------------------
   # DIVISIONS
   #------------------------------------------------------------------
   |
   +-- SML::Division
   |    |
   |    +-- SML::Fragment
   |    |
   |    +-- SML::Section
   |    |    |    |
   |    |    |    +-- regex: start_section
   |    |
   |    +-- SML::CommentDivision
   |    |    |
   |    |    +-- regex: comment_marker
   |    |
   |    +-- SML::Conditional
   |    |    |
   |    |    +-- regex: start_conditional
   |    |    +-- regex: end_conditional
   |    |
   |    +-- SML::TableCell
   |    |    |    |
   |    |    |    +-- regex: table_cell
   |    |
   |    +-- SML::TableRow
   |    |    |    |
   |    |    |    +-- regex: end_table_row
   |    |
   |    +-- SML::Assertion
   |    +-- SML::Attachment
   |    +-- SML::Audio
   |    +-- SML::Baretable
   |    +-- SML::Epigraph
   |    +-- SML::Figure
   |    +-- SML::Keypoints
   |    +-- SML::Listing
   |    +-- SML::PreformattedDivision
   |    +-- SML::Revisions
   |    +-- SML::Sidebar
   |    +-- SML::Source
   |    +-- SML::Table
   |    +-- SML::Video
   |
   |    +-- SML::Demo
   |    +-- SML::Entity
   |    +-- SML::Exercise
   |    +-- SML::Quotation
   |    +-- SML::RESOURCES
   |    +-- SML::Slide
   |    +-- SML::Document
   |    |    |
   |    |    +-- regex: start_document
   |    |    +-- regex: end_document

=head1 METHODS

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
