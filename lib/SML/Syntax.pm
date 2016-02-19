#!/usr/bin/perl

package SML::Syntax;                    # ci-000433

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Syntax');

=head1 NAME

SML::Syntax - regular expressions that define SML syntax

=head1 SYNOPSIS

  SML::Syntax->new();

  # NON-REFERENCE STRINGS

  $syntax->bold
  $syntax->bold_string;
  $syntax->italics;
  $syntax->italics_string;
  $syntax->fixedwidth;
  $syntax->fixedwidth_string;
  $syntax->underline;
  $syntax->underline_string;
  $syntax->superscript;
  $syntax->superscript_string;
  $syntax->subscript;
  $syntax->subscript_string;
  $syntax->keystroke_symbol
  $syntax->user_entered_text;
  $syntax->xml_tag
  $syntax->sglquote_string;
  $syntax->dblquote_string;

  # EXTERNAL REFERENCE STRINGS

  $syntax->file_ref;
  $syntax->path_ref;
  $syntax->url_ref;
  $syntax->command_ref;
  $syntax->email_addr;

  # INTERNAL REFERENCE STRINGS

  $syntax->lookup_ref;
  $syntax->cross_ref;
  $syntax->begin_cross_ref;
  $syntax->title_ref;
  $syntax->begin_title_ref;
  $syntax->id_ref;
  $syntax->begin_id_ref;
  $syntax->page_ref;
  $syntax->begin_page_ref;
  $syntax->footnote_ref;
  $syntax->index_ref;
  $syntax->citation_ref;
  $syntax->begin_citation_ref;
  $syntax->variable_ref;
  $syntax->gloss_term_ref;
  $syntax->begin_gloss_term_ref;
  $syntax->gloss_def_ref;
  $syntax->begin_gloss_def_ref;
  $syntax->acronym_term_ref;
  $syntax->begin_acronym_term_ref;
  $syntax->status_ref;
  $syntax->priority_ref;

  # OTHER STRINGS

  $syntax->literal;

  # REPLACEMENT SYMBOLS

  $syntax->thepage_ref;
  $syntax->thedate_ref;
  $syntax->pagecount_ref;
  $syntax->thesection_ref;
  $syntax->theversion_ref;
  $syntax->therevision_ref;

  # OTHER SYMBOLS

  $syntax->linebreak_symbol;
  $syntax->pagebreak_symbol;
  $syntax->clearpage_symbol;
  $syntax->take_note_symbol;
  $syntax->smiley_symbol;
  $syntax->frowny_symbol;
  $syntax->left_arrow_symbol;
  $syntax->right_arrow_symbol;
  $syntax->latex_symbol;
  $syntax->tex_symbol;
  $syntax->copyright_symbol;
  $syntax->trademark_symbol;
  $syntax->reg_trademark_symbol;
  $syntax->section_symbol;

  # BLOCKS

  $syntax->paragraph_text;
  $syntax->list_item;
  $syntax->bull_list_item;
  $syntax->enum_list_item;
  $syntax->def_list_item;
  $syntax->indented_text;
  $syntax->comment_line;

  # ELEMENTS

  $syntax->element;
  $syntax->title_element;
  $syntax->include_element;
  $syntax->plugin_element;
  $syntax->csvfile_element;
  $syntax->script_element;
  $syntax->outcome_element;
  $syntax->review_element;
  $syntax->index_element;
  $syntax->file_element;
  $syntax->image_element;
  $syntax->definition_element;
  $syntax->glossary_element;
  $syntax->variable_element;
  $syntax->attr_element;
  $syntax->acronym_element;
  $syntax->footnote_element;
  $syntax->step_element;
  $syntax->ver_element;

  # DIVISION SYNTAX

  $syntax->start_division;
  $syntax->end_division;
  $syntax->start_section;
  $syntax->table_cell;
  $syntax->end_table_row;

  # OTHER REGULAR EXPRESSIONS

  $syntax->blank_line;
  $syntax->non_blank_line;
  $syntax->inline_tag;
  $syntax->svn_date_field;
  $syntax->svn_revision_field;
  $syntax->svn_author_field;
  $syntax->index_entry;

  # VALIDATION REGULAR EXPRESSIONS

  $syntax->valid_inline_tags;
  $syntax->valid_date;
  $syntax->valid_status;
  $syntax->valid_error_level;
  $syntax->valid_proprity;
  $syntax->valid_background_color;
  $syntax->valid_horizontal_justification;
  $syntax->valid_fontsize;
  $syntax->valid_description;
  $syntax->valid_ontology_rule_type;
  $syntax->valid_multiplicity_value;
  $syntax->key_value_pair;

=head1 DESCRIPTION

An C<SML::Syntax> object represents the regular expressions used to
express document structure and content.

=head1 METHODS

=cut

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

has bold =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^!]?)!!([^!]?)',
  );

=head2 bold

Regular expression that indicates the beginning or end of a bold
string.

  $1 = prechar
  $2 = postchar

=cut

######################################################################

has bold_string =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '!!([^!]+?)!!',
  );

=head2 bold_string

Regular expression that matches a bold string.

  $1 = text

Example:

  !!a bold string!!
    -------------
          $1

=cut

######################################################################

has italics =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^~]?)~~([^~]?)',
  );

=head2 italics

Regular expression that indicates the beginning or end of an italics
string.

  $1 = prechar
  $2 = postchar

=cut

######################################################################

has italics_string =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '~~([^~]+?)~~',
  );

=head2 italics_string

Regular expression that matches an italics string.

  $1 = text

Example:

  ~~an italicized string~~
    --------------------
             $1

=cut

######################################################################

has fixedwidth =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^\|]?)\|\|([^\|]?)',
  );

=head2 fixedwidth

Regular expression that indicates the beginning or end of a fixedwidth
string.

  $1 = prechar
  $2 = postchar

=cut

######################################################################

has fixedwidth_string =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\|\|([^\|]+?)\|\|',
  );

=head2 fixedwidth_string

Regular expression that matches a fixed width string.

  $1 = text

Example:

  ||a fixed width string||
    --------------------
             $1

=cut

######################################################################

has underline =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^_]?)__([^_]?)',
  );

=head2 underline

Regular expression that indicates the beginning or end of an underline
string.

  $1 = prechar
  $2 = postchar

=cut

######################################################################

has underline_string =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '__([^_]+?)__',
  );

=head2 underline_string

Regular expression that matches an underline string.

  $1 = text

Example:

  __an underlined string__
    --------------------
             $1

=cut

######################################################################

has superscript =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^\^]?)\^\^([^\^]?)',
  );

=head2 superscript

Regular expression that indicates the beginning or end of a superscript
string.

  $1 = prechar
  $2 = postchar

=cut

######################################################################

has superscript_string =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\^\^([^\^]+?)\^\^',
  );

=head2 superscript_string

Regular expression that matches a superscript string.

  $1 = text

Example:

  x^^2^^

=cut

######################################################################

has subscript =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^\,]?)\,\,([^\,]?)',
  );

=head2 subscript

Regular expression that indicates the beginning or end of a subscript
string.

  $1 = prechar
  $2 = postchar

=cut

######################################################################

has subscript_string =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\,\,([^\,]+?)\,\,',
  );

=head2 subscript_string

Regular expression that matches a subscript string.

  $1 = text

Example:

  a,,o,,

=cut

######################################################################

has keystroke_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[\[([^\]]+?)\]\]',
  );

=head2 keystroke_symbol

Regular expression that matches a keystroke symbol.

  $1 = key

Example:

  [[ESC]]
    ---
    $1

represents an 'escape' keystroke.

=cut

######################################################################

has user_entered_text =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(enter|en):\s*([^\]]+?)\s*\]',
  );

=head2 user_entered_text

Regular expression that matches user entered text.

  $1 = tag (not significant)
  $2 = user entered text

Example:

  [enter:username]
   ----- --------
     $1     $2

=cut

######################################################################

has xml_tag =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '<([^>]+)>',
  );

=head2 xml_tag

Regular expression that matches an XML tag.

  $1 = tag content

Example:

  <html>
   ----
    $1

=cut

######################################################################

has sglquote_string =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => q{`([^`']*?)'},
  );

=head2 sglquote_string

A string enclosed in single quotes.

  $1 = quoted string

Example:

  `single quoted string'
   --------------------
            $1

=cut

######################################################################

has dblquote_string =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => q{``([^`']*?)''},
  );

=head2 dblquote_string

A string enclosed in double quotes.

  $1 = quoted string

Example:

  ``double quoted string''
    --------------------
              $1

=cut

#---------------------------------------------------------------------
# EXTERNAL REFERENCE STRINGS
#---------------------------------------------------------------------

has file_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[file:\s*([^\]]+?)\s*\]',
  );

=head2 file_ref

A reference to a file.

  $1 = filespec

Example:

  [file:/etc/inittab]
        ------------
             $1

=cut

######################################################################

has path_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[path:\s*([^\]]+?)\s*\]',
  );

=head2 path_ref

A reference to a file path.

  $1 = path

Example:

  [path:/usr/local/bin]
        --------------
              $1

=cut

######################################################################

has url_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[url:\s*([^\s\|\]]+?)(\|(.*))?\s*\]',
  );

=head2 url_ref

A reference to a URL.

  $1 = URL
  $3 = link text

Example:

  [url:http://www.cnn.com/]
       -------------------
                $1

  [url:http://www.cnn.com/|CNN News]
       ------------------- --------
                $1            $2

=cut

######################################################################

has command_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[cmd:\s*([^\]]+?)\s*\]',
  );

=head2 command_ref

A command you would type on the command line.

  $1 = command

Example:

  [cmd:cat /etc/passwd | grep root]
       ---------------------------
                   $1

=cut

######################################################################

has email_addr =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[email:\s*([^\s\|\]]+?)(\|(.*))?\s*\]',
   # default => '\b([a-zA-Z0-9._]+@[a-zA-Z0-9._]+\.[a-zA-Z0-9._]+)\b',
  );

=head2 email_addr

An email address.

  $1 = email_addr
  $3 = content

Example:

  [email:drj826@acm.org]
         --------------
               $1

  [email:drj826@acm.org|Don Johnson]
         -------------- -----------
               $1           $2

=cut

#---------------------------------------------------------------------
# INTERNAL REFERENCE STRINGS
#---------------------------------------------------------------------

has lookup_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(lookup|l):([^\]]+?):([\w\-\.]+)\]',
  );

=head2 lookup_ref

Look up a property value.

  $1 = element name
  $2 = target property name
  $3 = target division id

Example:

  [lookup:title:rq-000123]
   ------ ----- ---------
     $1    $2       $3

=cut

######################################################################

has cross_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(ref|r):\s*([^\s\]]+?)\s*\]',
  );

=head2 cross_ref

Cross reference a division.

  $1 = tag
  $2 = target_id

Example:

  [ref:rq-000123]
       ---------
           $2

=cut

######################################################################

has begin_cross_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(ref|r):',
  );

=head2 begin_cross_ref

Match the beginning of a cross reference.

=cut

######################################################################

has title_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(title|t):\s*([^\s\]]+?)\s*\]',
  );

=head2 title_ref

Reference a title.

  $1 = tag
  $2 = target_id

Example:

  [title:rq-000123]
         ---------
             $2

=cut

######################################################################

has begin_title_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(title|t):',
  );

=head2 begin_title_ref

Match the beginning of a title reference.

  $1 = tag

=cut

######################################################################

has id_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[id:\s*([^\s\]]+?)\s*\]',
  );

=head2 id_ref

Reference an ID.

  $1 = id

Example:

  [id:rq-000123]
      ---------
          $1

=cut

######################################################################

has begin_id_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[id:',
  );

=head2 begin_id_ref

Match the beginning of an ID reference.

=cut

######################################################################

has page_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(page|pg):\s*([^\s\]]+?)\s*\]',
  );

=head2 page_ref

Reference the page containing an ID.

  $1 = tag
  $2 = target_id

Example:

  [page:rq-000123]
        ---------
            $2

=cut

######################################################################

has begin_page_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(page|pg):',
  );

=head2 begin_page_ref

Match the beginning of a page reference.

=cut

######################################################################

has footnote_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[f:(\S+):(\S+)\]',
  );

=head2 footnote_ref

Reference a footnote.

  $1 = section ID
  $2 = footnote number

Example:

  [f:introduction:1]

=cut

######################################################################

has index_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(index|i):\s*([^\]]+?)\s*\]',
  );

=head2 index_ref

Reference an index entry.

  $1 = tag (not significant)
  $2 = index entry text

Example:

  [index:configuration item]

  [i:configuration item]

=cut

######################################################################

has citation_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(cite|c):\s*([^\s\]]+?)\s*(,\s*(.*))?\s*\]',
  );

=head2 citation_ref

Cite a source.

  $1 = tag
  $2 = source_id
  $4 = details (usually citation location details)

for example:

  [cite:Lamport96]

  [cite:Lamport96,pp 26-29]

  [c:cmmi]

=cut

######################################################################

has begin_citation_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(cite|c):',
  );

=head2 begin_citation_ref

Match the beginning of a citation reference.

  $1 = tag

=cut

######################################################################

has variable_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[var:([^\]]+)(:([^\]]+))?\]',
  );

=head2 variable_ref

Reference a variable value.

  $1 = variable name
  $3 = namespace

Example:

  [var:head_count]

=cut

######################################################################

has gloss_term_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(g|G|gls|Gls):(([^\s\]]+?):)?([^\]]+?)\]',
  );

=head2 gloss_term_ref

Reference a glossary term.

  $1 = tag (used as capitalization indicator)
  $3 = namespace
  $4 = glossary term

Example:

  [gls:IEEE:configuration item]      <-- normal case
   --- ---- ------------------
   $1   $2          $3

  [g:IEEE:configuration item]        <-- normal case

  [Gls:IEEE:configuration item]      <-- title case

  [G:IEEE:configuration item]        <-- title case

=cut

######################################################################

has begin_gloss_term_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(g|G|gls|Gls):',
  );

=head2 begin_gloss_term_ref

Match the beginning of a glossary term reference.

  $1 = tag (used as capitalization indicator)

=cut

######################################################################

has gloss_def_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[def:(([^\s\]]+?):)?([^\]]+?)\]',
  );

=head2 gloss_def_ref

Reference a glossary definition.

  $2 = namespace
  $3 = term

Example:

  [def:IEEE:acceptance testing]
   --- ---- ------------------
   $1   $2          $3

=cut

######################################################################

has begin_gloss_def_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[def:',
  );

=head2 begin_gloss_def_ref

Match the beginning of a glossary definition reference.

=cut

######################################################################

has acronym_term_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(a|ac|acs|acl):(([^\s\]]+?):)?([^\]]+?)\]',
  );

=head2 acronym_term_ref

Reference an acronym in the acronym list.

  $1 = tag
  $3 = namespace
  $4 = acronym

Example:

  [acs:CMMI:IPPD]      <-- render short form
   --- ---- ----
   $1   $2   $3

  [acl:CMMI:IPPD]      <-- render long form

  [ac:CMMI:IPPD]       <-- long form if first use

  [a:CMMI:IPPD]        <-- long form if first use

=cut

######################################################################

has begin_acronym_term_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[(a|ac|acs|acl):',
  );

=head2 begin_acronym_term_ref

Match the beginning of an acronym term reference.

=cut

######################################################################

has status_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[status:\s*([^\s\]]+?)\s*\]',
  );

=head2 status_ref

State a status or reference the status of an entity.  Valid status
values are: green, yellow, red, or grey.

  $1 = entity_id (or color)

Example:

  [status:red]

  [status:rq-000123]

=cut

######################################################################

has priority_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[priority:\s*([^\s\]]+?)\s*\]',
  );

=head2 priority_ref

State a priority or reference the priority of an entity.  Valid
priority values are: low, medium, high, or critical.

  $1 = entity_id (or color)

Example:

  [priority:critical]
            --------
               $1

  [priority:rq-000123]

=cut

#---------------------------------------------------------------------
# OTHER STRINGS
#---------------------------------------------------------------------

has literal =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\{lit:(.*?)\}',
  );

=head2 literal

Present a literal string.

  $1 = literal text

Example:

  {lit:__init__.py}

=cut

#---------------------------------------------------------------------
# REPLACEMENT SYMBOLS
#---------------------------------------------------------------------

has thepage_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[thepage\]',
  );

=head2 thepage_ref

Reference the current page.

  [thepage]

=cut

######################################################################

has thedate_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[thedate\]',
  );

=head2 thedate_ref

Reference today's date. This is the current date (i.e. today's date)
and not the value of the document's date property.

  [thedate]

=cut

######################################################################

has pagecount_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[pagecount\]',
  );

=head2 pagecount_ref

Reference the document total page count.  This is useful in headers or
footers where you want to say this is page 15 of 132.

  [pagecount]

=cut

######################################################################

has thesection_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[thesection\]',
  );

=head2 thesection_ref

Reference the current section number.

  [thesection]

=cut

######################################################################

has theversion_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[theversion\]',
  );

=head2 theversion_ref

Reference the current version.

  [theversion]

=cut

######################################################################

has therevision_ref =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[therevision\]',
  );

=head2 therevision_ref

Reference the current revision number (if any).

  [therevision]

=cut

#---------------------------------------------------------------------
# OTHER SYMBOLS
#---------------------------------------------------------------------

has linebreak_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[linebreak\]',
  );

=head2 linebreak_symbol

Insert a line break into the flow of text.

  [linebreak]

=cut

######################################################################

has pagebreak_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[pagebreak\]',
  );

=head2 pagebreak_symbol

Insert a page break into the flow of text.  This only has meaning in
renditions with fixed page sizes like PDF.

  [pagebreak]

=cut

######################################################################

has clearpage_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[clearpage\]',
  );

=head2 clearpage_symbol

Insert a "clear page" directive into the flow of text.  This has
meaning in LaTeX renditions.  It forces a page break and flushes all
pending floats from the stack.

  [clearpage]

=cut

######################################################################

has take_note_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[take_note\]',
  );

=head2 take_note_symbol

Insert a "take note" symbol in the margin.  This is typically a tiny
finger pointing to a portion of the text the author wishes to draw the
reader's attention to.

  [take_note]

=cut

######################################################################

has smiley_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => ':-\)',
  );

=head2 smiley_symbol

Insert a smiley face symbol in the text.

  :-)

=cut

######################################################################

has frowny_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => ':-\(',
  );

=head2 frowny_symbol

Insert a frowny face symbol in the text.

  :-(

=cut

######################################################################

has left_arrow_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '<-([^-]?)',
  );

=head2 left_arrow_symbol

Insert a left arrow into the text.

  $1 = postchar

  <-

=cut

# !!! BUG HERE !!!
#
# Won't this regular expression capture the character to the right of
# the left arrow symbol and that character will be lost?  The code
# that uses this regular expression needs to do something with the
# captured character to the right of the symbol.

######################################################################

has right_arrow_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '([^-]?)->',
  );

=head2 right_arrow_symbol

Insert a right arrow into the text.

  $1 = postchar

  ->

=cut

# !!! BUG HERE !!!
#
# Won't this regular expression capture the character to the left of
# the right arrow symbol and that character will be lost?  The code
# that uses this regular expression needs to do something with the
# captured character to the left of the symbol.

######################################################################

has latex_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\bLaTeX\b',
  );

=head2 latex_symbol

Insert a LaTeX symbol.

  LaTeX

=cut

######################################################################

has tex_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\bTeX\b',
  );

=head2 tex_symbol

Insert a TeX symbol.

  TeX

=cut

######################################################################

has copyright_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[c\]',
  );

=head2 copyright_symbol

Insert a copyright symbol.

  [c]

=cut

######################################################################

has trademark_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[tm\]',
  );

=head2 trademark_symbol

Insert a trademark symbol.

  [tm]

=cut

######################################################################

has reg_trademark_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[rtm\]',
  );

=head2 reg_trademark_symbol

Insert a registered trademark symbol.

  [rtm]

=cut

######################################################################

has section_symbol =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\[section\]',
  );

=head2 section_symbol

Insert a section symbol.

  [section]

=cut

######################################################################

# has emdash_symbol =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    default => '([^\-])?--([^\-])?',
#   );

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

has paragraph_text =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(:{1,2}\S*:?\s*)?([^\s#].*)$',
  );

=head2 paragraph_text

Match paragraph text.

  $1 = table cell markup (begin table cell)
  $2 = paragraph text

A paragraph can be just about any block of text.  The two main
exceptions are (1) a block of text that begins with one or more white
spaces is pre-formatted text, and (2) a block of text that begins with
a '#' is a comment.  The default regular expression above represents
these two exceptions.

The first block of a table cell may be a paragraph.  In this case the
paragraph text will be preceded by the table cell syntax.

There are other exceptions not represented by the default regular
expression above.  For instance a block of text that begins with a
'-', '+', or '=' (followed by one or more spaces) is a list item and a
block of text that begins with a '*' (followed by one or more spaces)
is a section heading. Parser logic is used to distinguish these blocks
from paragraph text.  The parser will detect that a block is one of
these before detecting that a block is a just a plain paragraph.

=cut

######################################################################

has list_item =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\s*)([\-\+\=])\s+(.*)',
  );

=head2 list_item

A list item (bullet, enumerated, or definition).

  $1 = indent
  $2 = bullet character
  $3 = item text

Examples:

  - bullet list item

  + enumerated list item

  = term = definition list item

=cut

######################################################################

has bull_list_item =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\s*)\-\s+(.*)',
  );

=head2 bull_list_item

A bullet list item.

  $1 = leading whitespace
  $2 = value

Example:

      - bullet list item
  ----  ----------------
   $1           $2

=cut

######################################################################

has enum_list_item =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\s*)\+\s+(.*)',
  );

=head2 enum_list_item

An enumerated list item.

  $1 = leading whitespace
  $2 = value

Example:

      + enumerated list item
  ----  --------------------
   $1            $2

=cut

######################################################################

has def_list_item =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^\=\s+(.*?)\s+\=\s+(.*?)\s*$',
  );

=head2 def_list_item

A definition list item.

  $1 = term
  $2 = definition

Example:

  = term = definition of term...
    ----   ---------------------
     $1              $2

=cut

######################################################################

has indented_text =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^\s+\S+',
  );

=head2 indented_text

Match any indented text.

=cut

######################################################################

has comment_line =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^#',
  );

=head2 comment_line

Match a comment line.

  # A comment line is one that begins with a '#'

=cut

# !!! BUG HERE !!!
#
# Improve comment line syntax to allow leading whitespace.

#---------------------------------------------------------------------
# ELEMENTS
#---------------------------------------------------------------------

has element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^([a-zA-Z_]+)::(\S+:)?\s*(.*?)(\s*\#(.*))?$',
   #            1             2         3    4     5
  );

=head2 element

Regular expression to match an element.

  $1 = element name
  $2 = element args
  $3 = element value
  $5 = comment text

Examples:

  title:: Document Title
  -----   --------------
    $1          $3

  column::1:head: Column Header
  ------  ------  -------------
    $1      $2          $3

  is_part_of:: ci-000510 # SML Perl Modules
  ----------   ---------   ----------------
    $1             $3              $5

=cut

######################################################################

has title_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(title)::([^\s\:]+:)?\s*(.*?)$',
  );

=head2 title_element

A title of a division.

  $1 = element name  (always 'title')
  $2 = element args
  $3 = element value (title text)

Example:

  title:: Retroencabulator Waneshaft Bearing
  -----   ----------------------------------
    $1                    $3

=cut

######################################################################

has include_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\*+\s+)?include::([\w\-\*\$]+:)*\s+(.+?)\s*(\#(.*))?$',
   #            1                 2                 3       4  5
  );

=head2 include_element

Include a division.

  $1 = leading asterisks
  $2 = args
  $3 = division ID
  $5 = comment text

Examples:

  include:: rq-000123 # Parse Text Into Objects
            ---------   -----------------------
                $3                $5

  include::flat: rq-000123
           ----  ---------
            $2       $3

  include::hide: rq-000123
           ----  ---------
            $2       $3

  **** include:: rq-000123
  ----           ---------
   $1                $3

=cut

######################################################################

has plugin_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\*+\s+)?plugin::([\w\-\*\$]+:)*\s*(\S+)?\s*(.*)?$',
   #            1                2                 3        4
  );

=head2 plugin_element

Run a plugin and insert the results into the document.

  $1 = leading asterisks
  $2 = args
  $3 = plugin name
  $4 = plugin arguments

Examples:

  plugin:: Pod2Txt ../SML/lib/SML/Syntax.pm
           ------- ------------------------
              $3              $4

  **** plugin:: Parts2Sections ci-000503
  ----          -------------- ---------
   $1                  $3          $4

=cut

######################################################################

has csvfile_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^csvfile::\s+(.*?)\s*$',
  );

=head2 csvfile_element

Read in property values from a CSV file.

  $1 = csv filename

Example:

  csvfile:: files/csv/ci-properties.csv

=cut

# !!! BUG HERE !!!
#
# SML::Parser doesn't yet know what to do with a csvfile element.

######################################################################

has script_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\*+\s+)?script::(\S+?:)?\s*(.*?)$',
   #            1                2          3
  );

=head2 script_element

Run a script and place the output in the document.

  $1 = leading asterisks
  $2 = args
  $3 = command

Example:

  script:: nmap -A -T4 scanme.nmap.org
           ---------------------------
                       $3

=cut

######################################################################

has outcome_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(outcome)::(.*?):(.*?):(.*?):\s*(.*)$',
  );

=head2 outcome_element

Record the outcome of a formal test or audit.

  $1 = element name (always 'outcome')
  $2 = date         (yyyy-mm-dd)
  $3 = entity ID
  $4 = status color (green, yellow, red, grey)
  $5 = outcome description

Example:

  outcome::2016-02-18:rq-000123:green: This requirement is OK.
  -------  ---------- --------- -----  -----------------------
    $1         $2         $3     $4              $5

=cut

######################################################################

has review_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(review)::(.*?):(.*?):(.*?):\s*(.*)$',
  );

=head2 review_element

Record the outcome of a review.

  $1 = element name (always 'review')
  $2 = date         (yyyy-mm-dd)
  $3 = entity ID
  $4 = status color (green, yellow, red, grey)
  $5 = review description

Example:

  review::2016-02-18:rq-000123:green: This requirement is OK.
  ------  ---------- --------- -----  -----------------------
    $1        $2         $3     $4              $5

=cut

######################################################################

has index_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(index)::((\S+):)?\s*(.*)$',
  );

=head2 index_element

Add terms to the index.

  $1 = element name  (always 'index')
  $3 = element arg   ('begin' or 'end')
  $4 = element value (index entry)

Example:

  index:: ci-000004; SML Core Software
  -----   ----------------------------
    $1                 $4

  index:: table of contents!font size
  -----   ---------------------------
    $1                 $4

=cut

######################################################################

has file_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^file::\s*(.+?)\s*(\#(.*))?\s*$',
  );

=head2 file_element

Insert the contents of a file.

  $1 = filespec
  $3 = comment text

Example:

  file:: /etc/inittab
         ------------
              $3

=cut

######################################################################

has image_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(image|logo_image_(left|center|right|small))::\s*(.*?)\s*(\#(.*))?\s*$',
  );

=head2 image_element

Insert an image.

  $1 = element_name
  $3 = filespec
  $5 = comment text

Example:

  image:: files/images/logo.png
  -----   ---------------------
    $1             $3

=cut

######################################################################

has definition_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^([a-zA-Z_]+)::\s*(.*?)\s*(\{(.*?)\})?\s*=\s*(.*?)\s*(\#(.*))?\s*$',
  );

=head2 definition_element

Define a term.

  $1 = element name
  $2 = defined term
  $4 = namespace
  $5 = definition text
  $7 = comment text

Example:

  acronym:: TLA = Three Letter Acronym
  -------   ---   --------------------
     $1      $2            $5


  acronym:: COTS {CMMI} = commercial off the shelf
  -------   ----  ----    ------------------------
     $1      $2    $4               $5

=cut

######################################################################

has glossary_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(glossary)::([^\s\:]+:)?\s*((.*?)\s*(\{(.*?)\})?\s*=\s*(.*))$',
  );

=head2 glossary_element

Define a glossary term.

  $1 = element name  (always 'glossary')
  $2 = element args
  $3 = element value (term {namespace} = definition)
  $4 = glossary term
  $6 = namespace
  $7 = definition text

Example:

  glossary:: configuration item = A system thingy...
  --------   ------------------   ------------------
     $1              $4                   $7

=cut

######################################################################

has variable_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(var)::([^\s\:]+:)?\s*((.*?)\s*(\{(.*?)\})?\s*=\s*(.*))$',
  );

=head2 variable_element

Define a variable value.

  $1 = element name   (always 'var')
  $2 = element args
  $3 = element value  (term {namespace} = definition)
  $4 = variable name  (term)
  $6 = namespace      (OPTIONAL)
  $7 = variable value (definition)

Example:

  var:: head_count = 26,345
  ---   ----------   ------
   $1       $4         $7

=cut

######################################################################

has attr_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(attr)::([^\s\:]+:)?\s*((.*?)\s*(\{(.*?)\})?\s*=\s*(.*))$',
  );

=head2 attr_element

Define an attribute.

  $1 = element name   (always 'attr')
  $2 = element args
  $3 = element value  (term {namespace} = definition)
  $4 = variable name  (term)
  $6 = namespace      (OPTIONAL)
  $7 = variable value (definition)

Example:

  attr:: hair color = blonde
  ----   ----------   ------
   $1        $4         $7

=cut

######################################################################

has acronym_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(acronym)::([^\s\:]+:)?\s*((.*?)\s*(\{(.*?)\})?\s*=\s*(.*))$',
  );

=head2 acronym_element

Define an acronym.

  $1 = element name (always 'acronym')
  $2 = element args
  $3 = element value (acronym {namespace} = definition)
  $4 = acronym term
  $6 = namespace
  $7 = acronym definition

Example:

  acronym:: TLA = Three Letter Acronym
  -------   ---   --------------------
     $1      $4            $7


  acronym:: COTS {CMMI} = commercial off the shelf
  -------   ----  ----    ------------------------
     $1      $4    $6               $7

=cut

######################################################################

has footnote_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(footnote)::([^\s\:]+):\s*(.*)?$',
  );

=head2 footnote_element

A footnote.

  $1 = element name  (always 'footnote')
  $2 = element args  (note number)
  $3 = element value (note text)

Example:

  footnote::1: Some assembly required, batteries not included.
  --------  -  -----------------------------------------------
     $1     $2                      $3

=cut

######################################################################

has step_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(step)::([^\s\:]+:)?\s*(.*)$',
  );

=head2 step_element

An item in a step list.

  $1 = element name (always 'step')
  $2 = element args
  $3 = element value (step description)

Example:

  step:: Check power and ground.
  ----   -----------------------
   $1              $3

=cut

######################################################################

has ver_element =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^ver::\s+(.+?)\s+=\s+(.+?)\s+=\s+(.*)$',
   #                    1           2           3
  );

=head2 ver_element

An entry in a version history.

  $1 = version
  $2 = date
  $3 = description

Example:

  ver:: 1.5 = 2012-03-23 = Updated glossary organization.
        ---   ----------   ------------------------------
         $1       $2                   $3

=cut

#---------------------------------------------------------------------
# DIVISION SYNTAX
#---------------------------------------------------------------------

has start_division =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^>{3}(\w+)(\.([\w\-]+))?',
  );

=head2 start_division

Start a division.

  $1 = division name
  $3 = division ID

Example:

  >>>DOCUMENT.sml-ug
     -------- ------
        $1      $3

=cut

######################################################################

has end_division =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^<{3}(\w+)',
  );

=head2 end_division

End a division.

  $1 = division name

Example:

  <<<DOCUMENT
     --------
        $1

=cut

######################################################################

has start_section =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\*+)(\.([-\w]+))?\s+(.*?)\s*$',
  );

=head2 start_section

Start a section.

  $1 = 1 or more '*'
  $3 = section ID
  $4 = section heading

Example:

  **** Turbo Encabulator Unilateral Phase Detractors
  ---- ---------------------------------------------
   $1                      $4


  ****.chap_4 Inverse Reactive Current
  ---- ------ ------------------------
   $1    $3             $4

=cut

######################################################################

has table_cell =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^:(:)?(\S+:)?\s*(.*)?$',
  );

=head2 table_cell

Begin a table cell.

  $1 = emphasis indicator
  $2 = arguments
  $3 = paragraph content

Example:

  : column 1, row 1

=cut

######################################################################

has end_table_row =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^-{3}',
  );

=head2 end_table_row

End a table row.

  ---

=cut

#---------------------------------------------------------------------
# OTHER REGEXS
#---------------------------------------------------------------------

has blank_line =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^\s*$',
  );

=head2 blank_line

Match a blank line.

=cut

######################################################################

has non_blank_line =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\S+',
  );

=head2 non_blank_line

Match a non-blank line.

=cut

######################################################################

has inline_tag =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '(\[(\w+)\])',
  );

=head2 inline_tag

Match an inline tag.

=cut

######################################################################

has svn_date_field =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\$Date:\s+((\d+-\d+-\d+)\s(\d+:\d+:\d+)\s(.+?)\s\((.+?)\))\s+\$',
  );

=head2 svn_date_field

Match an SVN date field.

  $1 = value           (2013-07-07 11:42:01 -0600 (Sun, 07 Jul 2013))
  $2 = date            (2013-07-07)
  $3 = time            (11:42:01)
  $4 = timezone offset (-0600)
  $5 = daydate         (Sun, 07 Jul 2013)

Example:

  $Date: 2013-07-07 11:42:01 -0600 (Sun, 07 Jul 2013)$

=cut

######################################################################

has svn_revision_field =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\$Revision:\s+(\d+)\s+\$',
  );

=head2 svn_revision_field

Match an SVN revision field.

  $1 = value (15146)

Example:

  $Revision: 15146$

=cut

######################################################################

has svn_author_field =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\$Author:\s+(.+)\s+\$',
  );

=head2 svn_author_field

Match an SVN author field.

  $1 = value (don.johnson)

Example:

  $Author: don.johnson$

=cut

######################################################################

has index_entry =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(.*?)(!(.*?))?(!(.*))?$',
  );

=head2 index_entry

Match an index entry.

  $1 = entry
  $3 = sub entry
  $5 = sub sub entry

Example:

  Entry!sub-entry!sub-sub-entry

=cut

#---------------------------------------------------------------------
# VALIDATION REGULAR EXPRESSIONS
#---------------------------------------------------------------------

has valid_inline_tags =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '(linebreak|pagebreak|clearpage|section|theversion|thepage|pagecount|thesection|therevision|copyright|thedate|tm|c|rtm|email)',
  );

=head2 valid_inline_tags

Match a valid inline tag.

=cut

######################################################################

has valid_date =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(\d\d\d\d)-(\d\d)-(\d\d)$',
  );

=head2 valid_date

Match a valid date string.

=cut

######################################################################

has valid_status =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(green|yellow|red|grey)$',
  );

=head2 valid_status

Match a valid status value.

=cut

######################################################################

has valid_error_level =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(warn|error|fatal)$',
  );

=head2 valid_error_level

Match a valid error level.

=cut

######################################################################

has valid_priority =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^(low|medium|high|critical)$',
  );

=head2 valid_priority

Match a valid priority.

=cut

######################################################################

has valid_background_color =>
  (
   is => 'ro',
   isa => 'Str',
   default => '(litegrey|grey|darkgrey|blue|green|yellow|red|orange)',
  );

=head2 valid_background_color

Match a valid background color.

=cut

######################################################################

has valid_horizontal_justification =>
  (
   is => 'ro',
   isa => 'Str',
   default => '(left|center|right)',
  );

=head2 valid_horizontal_justification

Match a valid horizontal justification.

=cut

######################################################################

has valid_fontsize =>
  (
   is => 'ro',
   isa => 'Str',
   default => '(tiny|scriptsize|footnotesize|small|normalsize|large|Large|LARGE|huge|Huge)',
  );

=head2 valid_fontsize

Match a valid font size.

=cut

######################################################################

has valid_description =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '\S',
  );

=head2 valid_description

Match a valid description.

=cut

######################################################################

has valid_ontology_rule_type =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '(div|prp|cmp|enu|def)',
  );

=head2 valid_ontology_rule_type

Match a valid ontology rule type.

=cut

######################################################################

has valid_multiplicity_value =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '(1|many)',
  );

=head2 valid_multiplicity_value

Match a valid multiplicity value.

=cut

######################################################################

has key_value_pair =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => '^\s*(.*?)\s*=\s*(.*?)\s*$',
  );

=head2 key_value_pair

Match a key/value pair.

=cut

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
