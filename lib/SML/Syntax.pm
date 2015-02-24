#!/usr/bin/perl

# $Id$

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

has 'start_document' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(>){3,}DOCUMENT',
  );

######################################################################

has 'end_document' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(<){3,}DOCUMENT',
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
# Change comment line syntax to allow leading whitespace.

######################################################################

has 'comment_marker' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(#){3,}COMMENT',
  );

######################################################################

has 'start_conditional' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\?){3,}([\w\-]+)',
  );

######################################################################

has 'end_conditional' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\?){3,}([\w\-]+)',
  );

######################################################################

has 'end_table_row' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(-){3,}',
  );

######################################################################

has 'start_region' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(>){3,}([\w\-]+)',

   # $1 = 3 or more '>'
   # $2 = region name
  );

######################################################################

has 'end_region' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(<){3,}([\w\-]+)',

   # $1 = 3 or more '<'
   # $2 = region name
  );

######################################################################

has 'start_environment' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(-){3,}([^\-][\w\-]+)',

   # $1 = 3 or more '-'
   # $2 = environment name
  );

######################################################################

has 'end_environmnent' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(-){3,}([^\-][\w\-]+)',

   # $1 = 3 or more '-'
   # $2 = environment name
  );

######################################################################

has 'start_section' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\*+)\s+(.*?)\s*$',

   # $1 = 1 or more '*'
   # $2 = section heading
  );

######################################################################

has 'list_item' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^\s*([\-\+\=])\s+(.*)',

   # $1 = bullet character
   # $2 = item text
  );

######################################################################

has 'bull_list_item' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\s*)\-\s+(.*)',
  );

######################################################################

has 'enum_list_item' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\s*)\+\s+(.*)',
  );

######################################################################

has 'def_list_item' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^\=\s+(.*?)\s+\=\s+(.*?)\s*$',
  );

######################################################################

has 'paragraph_text' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^[^\s#]',
  );

# A paragraph can be just about any block of text.  The two main
# exceptions are (1) a block of text that begins with a space is a
# pre-formatted text, and (2) a block of text that begins with a '#'
# is a comment.  The default regular expression above represents these
# two exceptions.

# There are other exceptions not represented by the default regular
# expression above.  For instance a block of text that begins with a
# '-', '+', or '=' (followed by one or more spaces) is a list item and
# a block of text that begins with a '*' (followed by one or more
# spaces) is a section heading. Parser logic is used to distinguish
# these blocks from paragraph text.  The parser will detect that a
# block is one of these before detecting that a block is a just a
# plain paragraph.

######################################################################

has 'indented_text' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^\s+\S+',
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

has 'table_cell' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^:',
  );

######################################################################

has 'bold' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^!]?)!!([^!]?)',
  );

######################################################################

has 'bold_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '!!([^!]+?)!!',
  );

######################################################################

has 'italics' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^~]?)~~([^~]?)',
  );

######################################################################

has 'italics_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '~~([^~]+?)~~',
  );

######################################################################

has 'fixedwidth' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^\|]?)\|\|([^\|]?)',
  );

######################################################################

has 'fixedwidth_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\|\|([^\|]+?)\|\|',
  );

######################################################################

has 'underline' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^_]?)__([^_]?)',
  );

######################################################################

has 'underline_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '__([^_]+?)__',
  );

######################################################################

has 'superscript' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^\^]?)\^\^([^\^]?)',
  );

######################################################################

has 'superscript_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\^\^([^\^]+?)\^\^',
  );

######################################################################

has 'subscript' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^\,]?)\,\,([^\,]?)',
  );

######################################################################

has 'subscript_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\,\,([^\,]+?)\,\,',
  );

######################################################################

has 'start_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^([a-zA-Z_]+)::(\S+:)?\s*(.*?)\s*(\#(.*))?$',

   # $1 = element name
   # $2 = args
   # $3 = element value
   # $4
   # $5 = comment text
  );

######################################################################

has 'title_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^title::\s*(.*?)\s*(\#(.*))?$',

   # $1 = title text
   # $2
   # $3 = comment text

   # NOTE: This syntax means you can't put a '#' in title text.
  );

######################################################################

has 'id_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(id|label)::\s*(.*?)\s*(\#(.*))?$',

   # $1 = id or label
   # $2 = id value
   # $3 = comment
   # $4 = comment content
  );

######################################################################

has 'author_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^author::\s*(.*?)\s*(\#(.*))?$',

   # $1 = author value
   # $2
   # $3 = comment text
  );

######################################################################

has 'date_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^date::\s*(.*?)\s*(\#(.*))?$',

   # $1 = date value
   # $2
   # $3 = comment text
  );

######################################################################

has 'revision_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^revision::\s*(.*?)\s*(\#(.*))?$',

   # $1 = revision value
   # $2
   # $3 = comment text
  );

######################################################################

has 'document_file_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^document_file::\s*(.*?)\s*(\#(.*))?$',

   # $1 = filespec
   # $2
   # $3 = comment text
  );

######################################################################

has 'fragment_file_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^fragment_file::\s*(.*?)\s*(\#(.*))?$',

   # $1 = filespec
   # $2
   # $3 = comment text
  );

######################################################################

has 'entity_file_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^entity_file::\s*(.*?)\s*(\#(.*))?$',

   # $1 = filespec
   # $2
   # $3 = comment text
  );

######################################################################

has 'reference_file_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^reference_file::\s*(.*?)\s*(\#(.*))?$',

   # $1 = filespec
   # $2
   # $3 = comment text
  );

######################################################################

has 'script_file_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^script_file::\s*(.*?)\s*(\#(.*))?$',

   # $1 = filespec
   # $2
   # $3 = comment text
  );

######################################################################

has 'insert_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^insert::\s*(.*?)(\((.*)\))?\s*(\#(.*))?$',

   # $1 = value
   # $2
   # $3 = args
   # $4
   # $5 = comment text
  );

######################################################################

has 'insert_ins_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^insert_ins::\s*(.*)',

   # $1 = value
  );

######################################################################

has 'insert_gen_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^insert_gen::\s*(.*)',

   # $1 = value
  );

######################################################################

has 'insert_string' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '(.*?)\((.*)\)',

   # $1 = value
   # $2 = division ID
  );

######################################################################

has 'template_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^include::((.*?)=(.*?):)+\s+(.*?)\s*(#(.*))?$',

   # $1
   # $2 = variable name
   # $3 = variable value
   # $4 = template filespec
   # $5 =
   # $6 = comment text
  );

######################################################################

has 'generate_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^generate::\s*([\w\-]+)(\([\w\-]+\))?\s*(\#(.*))?$',

   # $1 = generated content type
   # $2
   # $3 = division ID
   # $4
   # $5 = comment text
  );

######################################################################

has 'include_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\*+\s+)?include::([\w\-\*\$]+:)*\s+(.+?)(\s+FROM\s+(.+?))?\s*(\#(.*))?$',
   #            1                 2                 3    4          5         6  7

   # $1 = leading asterisks
   # $2 = options
   # $3 = $id or $filespec
   # $4
   # $5 = filespec
   # $6
   # $7 = comment text
  );

######################################################################

has 'csvfile_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^csvfile::\s+(.*?)\s*$',

   # $1 = csv filename
  );

######################################################################

has 'script_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^script::(\S+?:)?\s*(.*?)\s*(\#(.*))?$',

   # $1 = option
   # $2 = filespec
   # $3
   # $4 = comment text
  );

######################################################################

has 'outcome_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^outcome::(.*?):(.*?):(.*?):\s*(.+)\s*(\#(.*))?$',

   # $1 = date (yyyy-mm-dd)
   # $2 = entity ID
   # $3 = status color (green, yellow, red, grey)
   # $4 = outcome description
   # $5
   # $6 = comment text
  );

######################################################################

has 'review_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^review::(.*?):(.*?):(.*?):\s*(.+)\s*(\#(.*))?$',

   # $1 = date (yyyy-mm-dd)
   # $2 = entity ID
   # $3 = status color (green, yellow, red, grey)
   # $4 = review description
   # $5
   # $6 = comment text
  );

######################################################################

has 'index_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^index::(\S+:)?\s*(.*?)\s*(\#(.*))?$',

   # $1 = begin or end
   # $2 = index term
   # $3
   # $4 = comment text
  );

######################################################################

has 'definition_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^([a-zA-Z_]+)::\s*(.*?)\s*(\{(.*?)\})?\s*=\s*(.*?)\s*(\#(.*))?\s*$',

   # $1 = element name
   # $2 = defined term
   # $3
   # $4 = alt namespace
   # $5 = definition text
   # $6
   # $7 = comment text
  );

######################################################################

has 'glossary_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^glossary::\s*(.*?)\s*(\{(.*?)\})?\s*=\s*(.*?)\s*(\#(.*))?$',

   # $1 = glossary term
   # $2
   # $3 = alt namespace
   # $4 = definition text
   # $5
   # $6 = comment text
  );

######################################################################

has 'variable_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[var:([^\]]+)(:([^\]]+))?\]',

   # $1 = variable name
   # $2
   # $3 = alt namespace
  );

######################################################################

has 'variable_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^var::\s*(.*?)\s*(\{(.*?)\})?\s*=\s*(.*?)\s*(\#(.*))?$',

   # $1 = variable name
   # $2
   # $3 = alt namespace
   # $4 = variable value
   # $5
   # $6 = comment text
  );

######################################################################

has 'acronym_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^acronym::\s*(.*?)\s*(\{(.*?)\})?\s*=\s*(.*?)\s*(\#(.*))?$',

   # $1 = acronym
   # $2
   # $3 = alt namespace
   # $4 = acronym definition
   # $5
   # $6 = comment text
  );

######################################################################

has 'file_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^file::\s*(.+?)\s*(\#(.*))?\s*$',

   # $1 = filespec
   # $2
   # $3 = comment text
  );

######################################################################

has 'image_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(image|logo_image_(left|center|right|small))::\s*(.*?)\s*(\#(.*))?\s*$',

   # $1 = image type
   # $2
   # $3 = filespec
   # $4
   # $5 = comment text
  );

######################################################################

has 'note_element' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(note|footnote)::([^\s\:]+):(([^\s\:]+):)?\s*(.*?)\s*(\#(.*))?$',

   # $1 = note type (note or footnote)
   # $2 = tag
   # $3
   # $4 = division ID (optional)
   # $5 = note text
   # $6
   # $7 => comment text
  );

######################################################################

has 'lookup_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(lookup|l):([^\]]+?):([\w\-\.]+)\]',

   # $1
   # $2 => $property_name
   # $3 => $division_id
  );

######################################################################

has 'gloss_term_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(g|G|gls|Gls):(([^\s\]]+?):)?([^\]]+?)\]',
  );

# $1 => tag (used as capitalization indicator)
# $2 => namespace
# $3 =>
# $4 => glossary term

######################################################################

has 'begin_gloss_term_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(g|G|gls|Gls):',
  );

######################################################################

has 'gloss_def_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[def:(([^\s\]]+?):)?([^\]]+?)\]',
  );

######################################################################

has 'begin_gloss_def_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[def:',
  );

######################################################################

has 'begin_acronym_term_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(a|ac|acs|acl):',
  );

######################################################################

has 'acronym_term_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(a|ac|acs|acl):(([^\s\]]+?):)?([^\]]+?)\]',
  );

######################################################################

has 'cross_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(ref|r):\s*([^\s\]]+?)\s*\]',
  );

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

# $1 => tag (not significant)
# $2 => referenced ID

######################################################################

has 'begin_page_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(page|pg):',
  );

######################################################################

has 'url_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[url:\s*([^\s\|\]]+?)(\|(.*))?\s*\]',
  );

# $1 => URL
# $3 => link text

######################################################################

has 'footnote_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[f:(\S+):(\S+)\]',
  );

# $1 => section ID
# $2 => footnote number

######################################################################

has 'index_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(index|i):\s*([^\]]+?)\s*\]',
  );

# $1 => tag (not significant)
# $2 => index entry text

######################################################################

has 'thepage_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[thepage\]',
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

######################################################################

has 'thedate_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[thedate\]',
  );

######################################################################

has 'linebreak_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[linebreak\]',
  );

######################################################################

has 'status_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[status:\s*([^\s\]]+?)\s*\]',
  );


# $1 = ID or color

######################################################################

has 'citation_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(cite|c):\s*([^\s\]]+?)\s*(,\s*(.*))?\s*\]',
  );

# $1 => tag (not significant)
# $2 => id of cited source
# $3 =>
# $4 => additional details (usually of citation location)

######################################################################

has 'begin_citation_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(cite|c):',
  );

######################################################################

has 'file_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[file:\s*([^\]]+?)\s*\]',
  );

######################################################################

has 'path_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[path:\s*([^\]]+?)\s*\]',
  );

######################################################################

has 'user_entered_text' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(enter|en):\s*([^\]]+?)\s*\]',
  );

# $1 => tag (not significant)
# $2 => user entered text

######################################################################

has 'command_ref' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[cmd:\s*([^\]]+?)\s*\]',
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

has 'keystroke_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[\[([^\]]+?)\]\]',
  );

######################################################################

has 'left_arrow_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '<-([^-]?)',
  );

######################################################################

has 'right_arrow_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^-]?)->',
  );

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

has 'open_dblquote_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\`\`',
  );

######################################################################

has 'close_dblquote_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\'\'',
  );

######################################################################

has 'open_sglquote_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\`',
  );

######################################################################

has 'close_sglquote_symbol' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\'',
  );

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

######################################################################

has 'inline_tag' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '(\[(\w+)\])',
  );

######################################################################

has 'valid_inline_tags' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '(linebreak|pagebreak|clearpage|section|theversion|thepage|pagecount|thesection|therevision|copyright|thedate|tm|c|rtm|email)',
  );

######################################################################

has 'literal' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\{lit:(.*?)\}',
  );

######################################################################

has 'xml_tag' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '<([^>]+)>',
  );

######################################################################

has 'email_addr' =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[email:\s*([^\s\|\]]+?)(\|(.*))?\s*\]',
   # default => '\b([a-zA-Z0-9._]+@[a-zA-Z0-9._]+\.[a-zA-Z0-9._]+)\b',
  );

# $1 => Email address

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

# has 'non_substring' =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    # default => '([_,!~]?[A-Za-z\d\s><#\:\-\.\?\+\=\;\(\)\{\}\*\@\/\'\"\n]+)',
#    default => '([|^_,!~`\'\-]?[^|^_,!~\[`\'\-]+)',
#   );

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

=head1 METHODS

=head2 start_document

=head2 end_document

=head2 comment_line

=head2 comment_marker

=head2 start_conditional

=head2 end_conditional

=head2 end_table_row

=head2 start_region

=head2 end_region

=head2 start_environment

=head2 end_environmnent

=head2 start_section

=head2 list_item

=head2 bull_list_item

=head2 enum_list_item

=head2 def_list_item

=head2 paragraph_text

=head2 indented_text

=head2 blank_line

=head2 non_blank_line

=head2 table_cell

=head2 bold

=head2 italics

=head2 fixedwidth

=head2 underline

=head2 superscript

=head2 subscript

=head2 start_element

=head2 title_element

=head2 id_element

=head2 author_element

=head2 date_element

=head2 revision_element

=head2 document_file_element

=head2 fragment_file_element

=head2 entity_file_element

=head2 reference_file_element

=head2 script_file_element

=head2 insert_element

=head2 insert_ins_element

=head2 insert_gen_element

=head2 insert_string

=head2 template_element

=head2 generate_element

=head2 include_element

=head2 csvfile_element

=head2 script_element

=head2 outcome_element

=head2 review_element

=head2 index_element

=head2 definition_element

=head2 glossary_element

=head2 variable_ref

=head2 variable_element

=head2 acronym_element

=head2 file_element

=head2 image_element

=head2 note_element

=head2 lookup_ref

=head2 gloss_term_ref

=head2 begin_gloss_term_ref

=head2 gloss_def_ref

=head2 begin_gloss_def_ref

=head2 begin_acronym_term_ref

=head2 acronym_term_ref

=head2 cross_ref

=head2 begin_cross_ref

=head2 id_ref

=head2 begin_id_ref

=head2 page_ref

=head2 begin_page_ref

=head2 url_ref

=head2 footnote_ref

=head2 index_ref

=head2 thepage_ref

=head2 theversion_ref

=head2 therevision_ref

=head2 thedate_ref

=head2 status_ref

=head2 citation_ref

=head2 begin_citation_ref

=head2 file_ref

=head2 path_ref

=head2 user_entered_text

=head2 command_ref

=head2 take_note_symbol

=head2 smiley_symbol

=head2 frowny_symbol

=head2 keystroke_symbol

=head2 left_arrow_symbol

=head2 right_arrow_symbol

=head2 latex_symbol

=head2 tex_symbol

=head2 copyright_symbol

=head2 trademark_symbol

=head2 reg_trademark_symbol

=head2 open_dblquote_symbol

=head2 close_dblquote_symbol

=head2 open_sglquote_symbol

=head2 close_sglquote_symbol

=head2 section_symbol

=head2 emdash_symbol

=head2 inline_tag

=head2 valid_inline_tags

=head2 literal

=head2 xml_tag

=head2 email_addr

=head2 valid_date

=head2 valid_status

=head2 valid_description

=head2 valid_ontology_rule_type

=head2 valid_cardinality_value

=head2 key_value_pair

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
