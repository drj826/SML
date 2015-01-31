#!/usr/bin/perl

# $Id: TestData.pm 11633 2012-12-04 23:07:21Z don.johnson $

package SML::TestData;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.TestData');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has library_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_library_test_case_list',
   lazy    => 1,
   builder => '_build_library_test_case_list',
  );

######################################################################

has block_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_block_test_case_list',
   lazy    => 1,
   builder => '_build_block_test_case_list',
  );

######################################################################

has string_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_string_test_case_list',
   lazy    => 1,
   builder => '_build_string_test_case_list',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _build_library_test_case_list {

  my $self = shift;

  return
    [
     {
      name            => 'library test case 1',
      config_filename => 'library.conf',
      expected =>
      {
       get_id           => 'sml_engineering_library',
       get_name         => 'SML Engineering Library',
       get_revision     => '/\d+/',
       get_sml          => 'SML',
       get_parser       => 'SML::Parser',
       get_reasoner     => 'SML::Reasoner',
       get_formatter    => 'SML::Formatter',
       get_glossary     => 'SML::Glossary',
       get_acronym_list => 'SML::AcronymList',
       get_references   => 'SML::References',
      },
     },
    ];
}

######################################################################

sub _build_block_test_case_list {

  my $self = shift;

  return
    [
     {
      name  => 'cross_reference_1',
      sml   => '[ref:introduction]',
      latex => "Section~\\vref{introduction}\n\n",
      html  => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
      xml   => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'cross_reference_2',
      sml   => '[r:introduction]',
      latex => "Section~\\vref{introduction}\n\n",
      html  => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
      xml   => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'cross_reference_3',
      sml   => '[ref:system-model]',
      latex => "Section~\\vref{system-model}\n\n",
      html  => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
      xml   => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'cross_reference_4',
      sml   => '[r:system-model]',
      latex => "Section~\\vref{system-model}\n\n",
      html  => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
      xml   => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'url_reference_1',
      sml   => '[url:http://www.cnn.com/]',
      latex => "\\urlstyle{sf}\\url{http://www.cnn.com/}\n\n",
      html  => "<a href=\"http://www.cnn.com/\">http://www.cnn.com/</a>\n\n",
      xml   => "<a href=\"http://www.cnn.com/\">http://www.cnn.com/</a>\n\n",
     },

     {
      name  => 'footnote_reference_1',
      sml   => '[f:introduction:1]',
      latex => "\\footnote{This is a footnote.}\n\n",
      html  => "<span style=\"font-size: 8pt;\"><sup><a href=\"#footnote.introduction.1\">1<\/a><\/sup><\/span>\n\n",
      xml   => "<span style=\"font-size: 8pt;\"><sup><a href=\"#footnote.introduction.1\">1<\/a><\/sup><\/span>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'glossary_reference_1',
      sml   => '[g:sml:document]',
      latex => "\\gls{document:sml}\n\n",
      html  => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
      xml   => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'glossary_reference_2',
      sml   => '[G:sml:document]',
      latex => "\\Gls{document:sml}\n\n",
      html  => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
      xml   => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'glossary_reference_3',
      sml   => '[gls:sml:document]',
      latex => "\\gls{document:sml}\n\n",
      html  => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
      xml   => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'glossary_reference_4',
      sml   => '[Gls:sml:document]',
      latex => "\\Gls{document:sml}\n\n",
      html  => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
      xml   => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'acronym_reference_1',
      sml   => '[ac:sml:TLA]',
      latex => "\\ac{TLA:sml}\n\n",
      html  => "<a href=\"td-000020.acronyms.html#tla:sml\">TLA</a>\n\n",
      xml   => "<a href=\"td-000020.acronyms.html#tla:sml\">TLA</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'acronym_reference_2',
      sml   => '[acs:sml:TLA]',
      latex => "\\acs{TLA:sml}\n\n",
      html  => "<a href=\"td-000020.acronyms.html#tla:sml\">TLA</a>\n\n",
      xml   => "<a href=\"td-000020.acronyms.html#tla:sml\">TLA</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'acronym_reference_3',
      sml   => '[acl:sml:TLA]',
      latex => "\\acl{TLA:sml}\n\n",
      html  => "<a href=\"td-000020.acronyms.html#tla:sml\">Three Letter Acronym</a>\n\n",
      xml   => "<a href=\"td-000020.acronyms.html#tla:sml\">Three Letter Acronym</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'index_reference_1',
      sml   => '[i:structured manuscript language]',
      latex => "structured manuscript language \\index{structured manuscript language}\n\n",
      html  => "structured manuscript language\n\n",
      xml   => "structured manuscript language\n\n",
     },

     {
      name  => 'index_reference_2',
      sml   => '[index:structured manuscript language]',
      latex => "structured manuscript language \\index{structured manuscript language}\n\n",
      html  => "structured manuscript language\n\n",
      xml   => "structured manuscript language\n\n",
     },

     {
      name  => 'id_reference_1',
      sml   => '[id:introduction]',
      latex => "\\hyperref[introduction]{introduction}\n\n",
      html  => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
      xml   => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'thepage_reference_1',
      sml   => '[thepage]',
      latex => "\\thepage\n\n",
      html  => "\n\n",
      xml   => "\n\n",
     },

     {
      name  => 'page_reference_1',
      sml   => '[page:introduction]',
      latex => "p. \\pageref{introduction}\n\n",
      html  => "<a href=\"td-000020-1.html#Section.1\">link</a>\n\n",
      xml   => "<a href=\"td-000020-1.html#Section.1\">link</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'page_reference_2',
      sml   => '[pg:introduction]',
      latex => "p. \\pageref{introduction}\n\n",
      html  => "<a href=\"td-000020-1.html#Section.1\">link</a>\n\n",
      xml   => "<a href=\"td-000020-1.html#Section.1\">link</a>\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name    => 'version_reference_1',
      sml     => '[version]',
      latex   => "2.0\n\n",
      html    => "2.0\n\n",
      xml     => "2.0\n\n",
      success => 'valid version reference passes validation',
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name    => 'revision_reference_1',
      sml     => '[revision]',
      latex   => "4444\n\n",
      html    => "4444\n\n",
      xml     => "4444\n\n",
      success => 'valid revision reference passes validation',
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name    => 'date_reference_1',
      sml     => '[date]',
      latex   => "2012-09-11\n\n",
      html    => "2012-09-11\n\n",
      xml     => "2012-09-11\n\n",
      success => 'valid date reference passes validation',
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name    => 'status_reference_1',
      sml     => '[status:td-000020]',
      latex   => "\\textcolor{fg-yellow}{\$\\blacksquare\$}\n\n",
      html    => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
      xml     => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
      success => 'valid status reference passes validation',
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name    => 'status_reference_2',
      sml     => '[status:grey]',
      latex   => "\\textcolor{fg-grey}{\$\\blacksquare\$}\n\n",
      html    => "<image src=\"status_grey.png\" border=\"0\"/>\n\n",
      xml     => "<image src=\"status_grey.png\" border=\"0\"/>\n\n",
      success => 'valid status reference passes validation',
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name    => 'status_reference_3',
      sml     => '[status:green]',
      latex   => "\\textcolor{fg-green}{\$\\blacksquare\$}\n\n",
      html    => "<image src=\"status_green.png\" border=\"0\"/>\n\n",
      xml     => "<image src=\"status_green.png\" border=\"0\"/>\n\n",
      success => 'valid status reference passes validation',
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name    => 'status_reference_4',
      sml     => '[status:yellow]',
      latex   => "\\textcolor{fg-yellow}{\$\\blacksquare\$}\n\n",
      html    => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
      xml     => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
      success => 'valid status reference passes validation',
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name    => 'status_reference_5',
      sml     => '[status:red]',
      latex   => "\\textcolor{fg-red}{\$\\blacksquare\$}\n\n",
      html    => "<image src=\"status_red.png\" border=\"0\"/>\n\n",
      xml     => "<image src=\"status_red.png\" border=\"0\"/>\n\n",
      success => 'valid status reference passes validation',
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'citation_reference_1',
      sml   => '[cite:cms15]',
      latex => "\\cite{cms15}\n\n",
      html  => "[<a href=\"td-000020.source.html#cms15\">cms15</a>]\n\n",
      xml   => "[<a href=\"td-000020.source.html#cms15\">cms15</a>]\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'citation_reference_2',
      sml   => '[cite:cms15, pg 44]',
      latex => "\\cite[pg 44]{cms15}\n\n",
      html  => "[<a href=\"td-000020.source.html#cms15\">cms15, pg 44</a>]\n\n",
      xml   => "[<a href=\"td-000020.source.html#cms15\">cms15, pg 44</a>]\n\n",
      no_doc_error => 'NOT IN DOCUMENT CONTEXT',
     },

     {
      name  => 'file_reference_1',
      sml   => '[file:app.ini]',
      latex => "\\path{app.ini}\n\n",
      html  => "<tt>app.ini</tt>\n\n",
      xml   => "<tt>app.ini</tt>\n\n",
     },

     {
      name  => 'file_reference_2',
      sml   => '[file:My Document.doc]',
      latex => "\\path{My Document.doc}\n\n",
      html  => "<tt>My Document.doc</tt>\n\n",
      xml   => "<tt>My Document.doc</tt>\n\n",
     },

     {
      name  => 'path_reference_1',
      sml   => '[path:/path/to/folder]',
      latex => "\\path{/path/to/folder}\n\n",
      html  => "<tt>/path/to/folder</tt>\n\n",
      xml   => "<tt>/path/to/folder</tt>\n\n",
     },

     {
      name  => 'path_reference_2',
      sml   => '[path:/path/to/my folder]',
      latex => "\\path{/path/to/my folder}\n\n",
      html  => "<tt>/path/to/my folder</tt>\n\n",
      xml   => "<tt>/path/to/my folder</tt>\n\n",
     },

     {
      name  => 'path_reference_3',
      sml   => '[path:C:\path\to\my folder\]',
      latex => "\\path{C:\\path\\to\\my folder}\$\\backslash\$\n\n",
      html  => "<tt>C:\\path\\to\\my folder\\</tt>\n\n",
      xml   => "<tt>C:\\path\\to\\my folder\\</tt>\n\n",
     },

     {
      name  => 'user_entered_text_1',
      sml   => '[enter:USERNAME]',
      latex => "\\textbf{\\texttt{USERNAME}}\n\n",
      html  => "<b><tt>USERNAME</tt></b>\n\n",
      xml   => "<b><tt>USERNAME</tt></b>\n\n",
     },

     {
      name  => 'command_reference_1',
      sml   => '[cmd:pwd]',
      latex => "\\path{pwd}\n\n",
      html  => "<tt>pwd</tt>\n\n",
      xml   => "<tt>pwd</tt>\n\n",
     },

     {
      name  => 'command_reference_2',
      sml   => '[cmd:ls -al | grep -i bin | sort]',
      latex => "\\path{ls -al | grep -i bin | sort}\n\n",
      html  => "<tt>ls -al | grep -i bin | sort</tt>\n\n",
      xml   => "<tt>ls -al | grep -i bin | sort</tt>\n\n",
     },

     {
      name  => 'literal_xml_tag_1',
      sml   => '<html>',
      latex => "<html>\n\n",
      html  => "&lt;html&gt;\n\n",
      xml   => "&lt;html&gt;\n\n",
     },

     {
      name  => 'literal_xml_tag_2',
      sml   => '<para style="indented">',
      latex => "<para style=\"indented\">\n\n",
      html  => "&lt;para style=\"indented\"&gt;\n\n",
      xml   => "&lt;para style=\"indented\"&gt;\n\n",
     },

     {
      name  => 'literal_string_1',
      sml   => '{lit:[cite:Goossens94]}',
      latex => '[cite:Goossens94]',
      html  => '[cite:Goossens94]',
      xml   => '[cite:Goossens94]',
     },

     {
      name  => 'email_address_1',
      sml   => 'joe@example.com',
      latex => "joe\@example.com\n\n",
      html  => "<a href=\"mailto:joe\@example.com\">joe\@example.com</a>\n\n",
      xml   => "<a href=\"mailto:joe\@example.com\">joe\@example.com</a>\n\n",
     },

     {
      name  => 'take_note_symbol',
      sml   => '[[take_note]]',
      latex => "\\marginpar{\\Huge\\Writinghand}\n\n",
      html  => "<b>(take note!)</b>\n\n",
      xml   => "<b>(take note!)</b>\n\n",
     },

     {
      name  => 'smiley_symbol',
      sml   => ':-)',
      latex => "\\large\\Smiley\n\n",
      html  => "(smiley)\n\n",
      xml   => "(smiley)\n\n",
     },

     {
      name  => 'frowny_symbol',
      sml   => ':-(',
      latex => "\\large\\Frowny\n\n",
      html  => "(frowny)\n\n",
      xml   => "(frowny)\n\n",
     },

     {
      name  => 'keystroke_symbol_1',
      sml   => '[[Enter]]',
      latex => "\\keystroke{Enter}\n\n",
      html  => "<span class=\"keystroke\">Enter</span>\n\n",
      xml   => "<span class=\"keystroke\">Enter</span>\n\n",
     },

     {
      name  => 'keystroke_symbol_2',
      sml   => '[[Ctrl]]-[[Alt]]-[[Del]]',
      latex => "\\keystroke{Ctrl}-\\keystroke{Alt}-\\keystroke{Del}\n\n",
      html  => "<span class=\"keystroke\">Ctrl</span>-<span class=\"keystroke\">Alt</span>-<span class=\"keystroke\">Del</span>\n\n",
      xml   => "<span class=\"keystroke\">Ctrl</span>-<span class=\"keystroke\">Alt</span>-<span class=\"keystroke\">Del</span>\n\n",
     },

     {
      name  => 'left_arrow_symbol',
      sml   => '<-',
      latex => "\$\\leftarrow\$\n",
      html  => "&larr;\n",
      xml   => "&larr;\n",
     },

     {
      name  => 'right_arrow_symbol',
      sml   => '->',
      latex => "\$\\rightarrow\$\n\n",
      html  => "&rarr;\n\n",
      xml   => "&rarr;\n\n",
     },

     {
      name  => 'latex_symbol',
      sml   => 'LaTeX',
      latex => "\\LaTeX{}\n\n",
      html  => "LaTeX\n\n",
      xml   => "LaTeX\n\n",
     },

     {
      name  => 'tex_symbol',
      sml   => 'TeX',
      latex => "\\TeX{}\n\n",
      html  => "TeX\n\n",
      xml   => "TeX\n\n",
     },

     {
      name  => 'copyright_symbol',
      sml   => '[c]',
      latex => "\\tiny\$^{\\copyright}\$\\normalsize\n\n",
      html  => "&copy;\n\n",
      xml   => "&copy;\n\n",
     },

     {
      name  => 'trademark_symbol',
      sml   => '[tm]',
      latex => "\\tiny\$^{\\texttrademark}\$\\normalsize\n\n",
      html  => "&trade;\n\n",
      xml   => "&trade;\n\n",
     },

     {
      name  => 'reg_trademark_symbol',
      sml   => '[r]',
      latex => "\\tiny\$^{\\textregistered}\$\\normalsize\n\n",
      html  => "&reg;\n\n",
      xml   => "&reg;\n\n",
     },

     {
      name  => 'open_dblquote_symbol',
      sml   => '``',
      latex => "\`\`\n\n",
      html  => "&ldquo;\n\n",
      xml   => "&ldquo;\n\n",
     },

     {
      name  => 'close_dblquote_symbol',
      sml   => '\'\'',
      latex => "\'\'\n\n",
      html  => "&rdquo;\n\n",
      xml   => "&rdquo;\n\n",
     },

     {
      name  => 'open_sglquote_symbol',
      sml   => '`',
      latex => "\`\n\n",
      html  => "&lsquo;\n\n",
      xml   => "&lsquo;\n\n",
     },

     {
      name  => 'close_sglquote_symbol',
      sml   => '\'',
      latex => "\'\n\n",
      html  => "&rsquo;\n\n",
      xml   => "&rsquo;\n\n",
     },

     {
      name  => 'section_symbol',
      sml   => '[section]',
      latex => "{\\S}\n\n",
      html  => "&sect;\n\n",
      xml   => "&sect;\n\n",
     },

     {
      name  => 'emdash_symbol',
      sml   => '--',
      latex => "--\n\n",
      html  => "&mdash;\n",
      xml   => "&mdash;\n",
     },

     {
      name  => 'bold',
      sml   => '!!bold text!!',
      latex => "\\textbf{bold text}\n\n",
      html  => "<b>bold text</b>\n\n",
      xml   => "<b>bold text</b>\n\n",
     },

     {
      name  => 'italic',
      sml   => '~~italicized text~~',
      latex => "\\textit{italicized text}\n\n",
      html  => "<i>italicized text</i>\n\n",
      xml   => "<i>italicized text</i>\n\n",
     },

     {
      name  => 'underline',
      sml   => '__underlined text__',
      latex => "\\underline{underlined text}\n\n",
      html  => "<u>underlined text</u>\n\n",
      xml   => "<u>underlined text</u>\n\n",
     },

     {
      name  => 'fixedwidth',
      sml   => '||fixedwidth text||',
      latex => "\\texttt{fixedwidth text}\n\n",
      html  => "<tt>fixedwidth text</tt>\n\n",
      xml   => "<tt>fixedwidth text</tt>\n\n",
     },

     {
      name  => 'superscript',
      sml   => '^^superscripted text^^',
      latex => "\\textsuperscript{superscripted text}\n\n",
      html  => "<sup>superscripted text</sup>\n\n",
      xml   => "<sup>superscripted text</sup>\n\n",
     },

     {
      name  => 'subscript',
      sml   => ',,subscripted text,,',
      latex => "\\subscript{subscripted text}\n\n",
      html  => "<sub>subscripted text</sub>\n\n",
      xml   => "<sub>subscripted text</sub>\n\n",
     },

     {
      name    => 'valid_bold_block',
      sml     => 'This is a valid !!bold!! block',
      success => 'valid bold markup passes validation',
     },

     {
      name    => 'invalid_bold_block',
      sml     => 'This is an INVALID !!bold block',
      warning => 'INVALID BOLD MARKUP',
     },

     {
      name    => 'valid_italics_block',
      sml     => 'This is a valid ~~italics~~ block',
      success => 'valid italics markup passes validation',
     },

     {
      name    => 'invalid_italics_block',
      sml     => 'This is an INVALID ~~italics block',
      warning => 'INVALID ITALICS MARKUP',
     },

     {
      name    => 'valid_fixedwidth_block',
      sml     => 'This is a valid ||fixed-width|| block',
      success => 'valid fixed-width markup passes validation',
     },

     {
      name    => 'invalid_fixedwidth_block',
      sml     => 'This is an INVALID ||fixed-width block',
      warning => 'INVALID FIXED-WIDTH MARKUP',
     },

     {
      name    => 'valid_underline_block',
      sml     => 'This is a valid __underline__ block',
      success => 'valid underline markup passes validation',
     },

     {
      name    => 'invalid_underline_block',
      sml     => 'This is an INVALID __underline block',
      warning => 'INVALID UNDERLINE MARKUP',
     },

     {
      name    => 'valid_superscript_block',
      sml     => 'This is a valid ^^superscript^^ block',
      success => 'valid superscript markup passes validation',
     },

     {
      name    => 'invalid_superscript_block',
      sml     => 'This is an INVALID ^^superscript block',
      warning => 'INVALID SUPERSCRIPT MARKUP',
     },

     {
      name    => 'valid_subscript_block',
      sml     => 'This is a valid ,,subscript,, block',
      success => 'valid subscript markup passes validation',
     },

     {
      name    => 'invalid_subscript_block',
      sml     => 'This is an INVALID ,,subscript block',
      warning => 'INVALID SUBSCRIPT MARKUP',
     },

     {
      name    => 'valid_cross_reference_1',
      sml     => 'Here is a valid cross reference: [ref:introduction].',
      success => 'valid cross reference 1 passes validation',
     },

     {
      name    => 'valid_cross_reference_2',
      sml     => 'Here is a valid cross reference: [r:introduction].',
      success => 'valid cross reference 2 passes validation',
     },

     {
      name    => 'invalid_cross_reference_1',
      sml     => 'Here is an INVALID cross reference: [ref:bogus].',
      warning => 'INVALID CROSS REFERENCE',
     },

     {
      name    => 'invalid_cross_reference_2',
      sml     => 'Here is an INVALID cross reference: [r:bogus].',
      warning => 'INVALID CROSS REFERENCE',
     },

     {
      name    => 'incomplete_cross_reference_1',
      sml     => 'Here is an incomplete cross reference: [ref:introduction.',
      warning => 'INVALID CROSS REFERENCE SYNTAX',
     },

     {
      name    => 'incomplete_cross_reference_2',
      sml     => 'Here is an incomplete cross reference: [r:introduction.',
      warning => 'INVALID CROSS REFERENCE SYNTAX',
     },

     {
      name    => 'valid_id_reference',
      sml     => 'Here is a valid id reference: [id:introduction].',
      success => 'valid ID reference passes validation',
     },

     {
      name    => 'invalid_id_reference',
      sml     => 'Here is an INVALID id reference: [id:bogus].',
      warning => 'INVALID ID REFERENCE',
     },

     {
      name    => 'incomplete_id_reference',
      sml     => 'Here is an incomplete id reference: [id:introduction.',
      warning => 'INVALID ID REFERENCE SYNTAX',
     },

     {
      name    => 'valid_page_reference_1',
      sml     => 'Here is a valid page reference: [page:introduction].',
      success => 'valid page reference 1 passes validation',
     },

     {
      name    => 'valid_page_reference_2',
      sml     => 'Here is a valid page reference: [pg:introduction].',
      success => 'valid page reference 2 passes validation',
     },

     {
      name    => 'invalid_page_reference_1',
      sml     => 'Here is an INVALID page reference: [page:bogus].',
      warning => 'INVALID PAGE REFERENCE',
     },

     {
      name    => 'invalid_page_reference_2',
      sml     => 'Here is an INVALID page reference: [pg:bogus].',
      warning => 'INVALID PAGE REFERENCE',
     },

     {
      name    => 'incomplete_page_reference_1',
      sml     => 'Here is an incomplete page reference: [page:introduction.',
      warning => 'INVALID PAGE REFERENCE SYNTAX',
     },

     {
      name    => 'incomplete_page_reference_2',
      sml     => 'Here is an incomplete page reference: [pg:introduction.',
      warning => 'INVALID PAGE REFERENCE SYNTAX',
     },

     {
      name    => 'invalid_glossary_term_reference_1',
      sml     => '[g:sml:bogus]',
      warning => 'TERM NOT IN GLOSSARY',
     },

     {
      name    => 'incomplete_glossary_term_reference_1',
      sml     => '[g:sml:bogus',
      warning => 'INVALID GLOSSARY TERM REFERENCE SYNTAX',
     },

     {
      name    => 'invalid_glossary_def_reference_1',
      sml     => '[def:sml:bogus]',
      warning => 'DEFINITION NOT IN GLOSSARY',
     },

     {
      name    => 'incomplete_glossary_def_reference_1',
      sml     => '[def:sml:bogus',
      warning => 'INVALID GLOSSARY DEFINITION REFERENCE SYNTAX',
     },

     {
      name    => 'invalid_acronym_reference_1',
      sml     => '[ac:sml:bogus]',
      warning => 'ACRONYM NOT IN ACRONYM LIST',
     },

     {
      name    => 'incomplete_acronym_reference_1',
      sml     => '[ac:sml:bogus',
      warning => 'INVALID ACRONYM REFERENCE SYNTAX',
     },

     {
      name    => 'invalid_source_citation_1',
      sml     => '[cite:bogus]',
      warning => 'INVALID SOURCE CITATION',
     },

     {
      name    => 'incomplete_source_citation_1',
      sml     => '[cite:bogus',
      warning => 'INVALID SOURCE CITATION SYNTAX',
     },

     {
      name      => 'get_name_path_test_1',
      testfile  => 'library/testdata/td-000020.txt',
      config    => 'library.conf',
     },

    ];
}

######################################################################

sub _build_string_test_case_list {

  my $self = shift;

  return
    [
     {
      name  => 'simple string',
      value => 'This is a simple string.',
     },
    ];
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;
