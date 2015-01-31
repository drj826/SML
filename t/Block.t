#!/usr/bin/perl

# $Id: Block.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 197;
use Test::Exception;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use Test::Log4perl;
my $t1logger = Test::Log4perl->get_logger('sml.Block');
my $t2logger = Test::Log4perl->get_logger('sml.Document');

# create a yyyy-mm-dd date stamp
#
use Date::Pcalc;
my ($yyyy,$mm,$dd) = Date::Pcalc::Today();
$mm = '0' . $mm until length $mm == 2;
$dd = '0' . $dd until length $dd == 2;
my $date = "$yyyy-$mm-$dd";

my $config_filename = 'library.conf';
my $library         = SML::Library->new(config_filename=>$config_filename);
my $parser          = $library->get_parser;
my $fragment        = undef;
my $block           = undef;          # SML::Block object
my $line            = undef;          # SML::Line object
my $testid          = '';             # Test Data ID
my $content         = '';             # content string
my $html            = '';             # HTML string
my $error           = '';             # expected error

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   cross_reference_1 =>
   {
    sml   => '[ref:introduction]',
    latex => "Section~\\vref{introduction}\n\n",
    html  => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
    xml   => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   cross_reference_2 =>
   {
    sml   => '[r:introduction]',
    latex => "Section~\\vref{introduction}\n\n",
    html  => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
    xml   => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   cross_reference_3 =>
   {
    sml   => '[ref:system-model]',
    latex => "Section~\\vref{system-model}\n\n",
    html  => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
    xml   => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   cross_reference_4 =>
   {
    sml   => '[r:system-model]',
    latex => "Section~\\vref{system-model}\n\n",
    html  => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
    xml   => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   url_reference_1 =>
   {
    sml   => '[url:http://www.cnn.com/]',
    latex => "\\urlstyle{sf}\\url{http://www.cnn.com/}\n\n",
    html  => "<a href=\"http://www.cnn.com/\">http://www.cnn.com/</a>\n\n",
    xml   => "<a href=\"http://www.cnn.com/\">http://www.cnn.com/</a>\n\n",
   },

   footnote_reference_1 =>
   {
    sml   => '[f:introduction:1]',
    latex => "\\footnote{This is a footnote.}\n\n",
    html  => "<span style=\"font-size: 8pt;\"><sup><a href=\"#footnote.introduction.1\">1<\/a><\/sup><\/span>\n\n",
    xml   => "<span style=\"font-size: 8pt;\"><sup><a href=\"#footnote.introduction.1\">1<\/a><\/sup><\/span>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   glossary_reference_1 =>
   {
    sml   => '[g:sml:document]',
    latex => "\\gls{document:sml}\n\n",
    html  => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
    xml   => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   glossary_reference_2 =>
   {
    sml   => '[G:sml:document]',
    latex => "\\Gls{document:sml}\n\n",
    html  => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
    xml   => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   glossary_reference_3 =>
   {
    sml   => '[gls:sml:document]',
    latex => "\\gls{document:sml}\n\n",
    html  => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
    xml   => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   glossary_reference_4 =>
   {
    sml   => '[Gls:sml:document]',
    latex => "\\Gls{document:sml}\n\n",
    html  => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
    xml   => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   acronym_reference_1 =>
   {
    sml   => '[ac:sml:TLA]',
    latex => "\\ac{TLA:sml}\n\n",
    html  => "<a href=\"td-000020.acronyms.html#tla:sml\">TLA</a>\n\n",
    xml   => "<a href=\"td-000020.acronyms.html#tla:sml\">TLA</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   acronym_reference_2 =>
   {
    sml   => '[acs:sml:TLA]',
    latex => "\\acs{TLA:sml}\n\n",
    html  => "<a href=\"td-000020.acronyms.html#tla:sml\">TLA</a>\n\n",
    xml   => "<a href=\"td-000020.acronyms.html#tla:sml\">TLA</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   acronym_reference_3 =>
   {
    sml   => '[acl:sml:TLA]',
    latex => "\\acl{TLA:sml}\n\n",
    html  => "<a href=\"td-000020.acronyms.html#tla:sml\">Three Letter Acronym</a>\n\n",
    xml   => "<a href=\"td-000020.acronyms.html#tla:sml\">Three Letter Acronym</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   index_reference_1 =>
   {
    sml   => '[i:structured manuscript language]',
    latex => "structured manuscript language \\index{structured manuscript language}\n\n",
    html  => "structured manuscript language\n\n",
    xml   => "structured manuscript language\n\n",
   },

   index_reference_2 =>
   {
    sml   => '[index:structured manuscript language]',
    latex => "structured manuscript language \\index{structured manuscript language}\n\n",
    html  => "structured manuscript language\n\n",
    xml   => "structured manuscript language\n\n",
   },

   id_reference_1 =>
   {
    sml   => '[id:introduction]',
    latex => "\\hyperref[introduction]{introduction}\n\n",
    html  => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
    xml   => "<a href=\"td-000020-1.html#Section.1\">Section 1</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   thepage_reference_1 =>
   {
    sml   => '[thepage]',
    latex => "\\thepage\n\n",
    html  => "\n\n",
    xml   => "\n\n",
   },

   page_reference_1 =>
   {
    sml   => '[page:introduction]',
    latex => "p. \\pageref{introduction}\n\n",
    html  => "<a href=\"td-000020-1.html#Section.1\">link</a>\n\n",
    xml   => "<a href=\"td-000020-1.html#Section.1\">link</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   page_reference_2 =>
   {
    sml   => '[pg:introduction]',
    latex => "p. \\pageref{introduction}\n\n",
    html  => "<a href=\"td-000020-1.html#Section.1\">link</a>\n\n",
    xml   => "<a href=\"td-000020-1.html#Section.1\">link</a>\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   version_reference_1 =>
   {
    sml     => '[version]',
    latex   => "2.0\n\n",
    html    => "2.0\n\n",
    xml     => "2.0\n\n",
    success => 'valid version reference passes validation',
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   revision_reference_1 =>
   {
    sml     => '[revision]',
    latex   => "4444\n\n",
    html    => "4444\n\n",
    xml     => "4444\n\n",
    success => 'valid revision reference passes validation',
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   date_reference_1 =>
   {
    sml     => '[date]',
    latex   => "2012-09-11\n\n",
    html    => "2012-09-11\n\n",
    xml     => "2012-09-11\n\n",
    success => 'valid date reference passes validation',
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   status_reference_1 =>
   {
    sml     => '[status:td-000020]',
    latex   => "\\textcolor{fg-yellow}{\$\\blacksquare\$}\n\n",
    html    => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
    xml     => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
    success => 'valid status reference passes validation',
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   status_reference_2 =>
   {
    sml     => '[status:grey]',
    latex   => "\\textcolor{fg-grey}{\$\\blacksquare\$}\n\n",
    html    => "<image src=\"status_grey.png\" border=\"0\"/>\n\n",
    xml     => "<image src=\"status_grey.png\" border=\"0\"/>\n\n",
    success => 'valid status reference passes validation',
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   status_reference_3 =>
   {
    sml     => '[status:green]',
    latex   => "\\textcolor{fg-green}{\$\\blacksquare\$}\n\n",
    html    => "<image src=\"status_green.png\" border=\"0\"/>\n\n",
    xml     => "<image src=\"status_green.png\" border=\"0\"/>\n\n",
    success => 'valid status reference passes validation',
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   status_reference_4 =>
   {
    sml     => '[status:yellow]',
    latex   => "\\textcolor{fg-yellow}{\$\\blacksquare\$}\n\n",
    html    => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
    xml     => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
    success => 'valid status reference passes validation',
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   status_reference_5 =>
   {
    sml     => '[status:red]',
    latex   => "\\textcolor{fg-red}{\$\\blacksquare\$}\n\n",
    html    => "<image src=\"status_red.png\" border=\"0\"/>\n\n",
    xml     => "<image src=\"status_red.png\" border=\"0\"/>\n\n",
    success => 'valid status reference passes validation',
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   citation_reference_1 =>
   {
    sml   => '[cite:cms15]',
    latex => "\\cite{cms15}\n\n",
    html  => "[<a href=\"td-000020.source.html#cms15\">cms15</a>]\n\n",
    xml   => "[<a href=\"td-000020.source.html#cms15\">cms15</a>]\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   citation_reference_2 =>
   {
    sml   => '[cite:cms15, pg 44]',
    latex => "\\cite[pg 44]{cms15}\n\n",
    html  => "[<a href=\"td-000020.source.html#cms15\">cms15, pg 44</a>]\n\n",
    xml   => "[<a href=\"td-000020.source.html#cms15\">cms15, pg 44</a>]\n\n",
    no_doc_error => 'NOT IN DOCUMENT CONTEXT',
   },

   file_reference_1 =>
   {
    sml   => '[file:app.ini]',
    latex => "\\path{app.ini}\n\n",
    html  => "<tt>app.ini</tt>\n\n",
    xml   => "<tt>app.ini</tt>\n\n",
   },

   file_reference_2 =>
   {
    sml   => '[file:My Document.doc]',
    latex => "\\path{My Document.doc}\n\n",
    html  => "<tt>My Document.doc</tt>\n\n",
    xml   => "<tt>My Document.doc</tt>\n\n",
   },

   path_reference_1 =>
   {
    sml   => '[path:/path/to/folder]',
    latex => "\\path{/path/to/folder}\n\n",
    html  => "<tt>/path/to/folder</tt>\n\n",
    xml   => "<tt>/path/to/folder</tt>\n\n",
   },

   path_reference_2 =>
   {
    sml   => '[path:/path/to/my folder]',
    latex => "\\path{/path/to/my folder}\n\n",
    html  => "<tt>/path/to/my folder</tt>\n\n",
    xml   => "<tt>/path/to/my folder</tt>\n\n",
   },

   path_reference_3 =>
   {
    sml   => '[path:C:\path\to\my folder\]',
    latex => "\\path{C:\\path\\to\\my folder}\$\\backslash\$\n\n",
    html  => "<tt>C:\\path\\to\\my folder\\</tt>\n\n",
    xml   => "<tt>C:\\path\\to\\my folder\\</tt>\n\n",
   },

   user_entered_text_1 =>
   {
    sml   => '[enter:USERNAME]',
    latex => "\\textbf{\\texttt{USERNAME}}\n\n",
    html  => "<b><tt>USERNAME</tt></b>\n\n",
    xml   => "<b><tt>USERNAME</tt></b>\n\n",
   },

   command_reference_1 =>
   {
    sml   => '[cmd:pwd]',
    latex => "\\path{pwd}\n\n",
    html  => "<tt>pwd</tt>\n\n",
    xml   => "<tt>pwd</tt>\n\n",
   },

   command_reference_2 =>
   {
    sml   => '[cmd:ls -al | grep -i bin | sort]',
    latex => "\\path{ls -al | grep -i bin | sort}\n\n",
    html  => "<tt>ls -al | grep -i bin | sort</tt>\n\n",
    xml   => "<tt>ls -al | grep -i bin | sort</tt>\n\n",
   },

   literal_xml_tag_1 =>
   {
    sml   => '<html>',
    latex => "<html>\n\n",
    html  => "&lt;html&gt;\n\n",
    xml   => "&lt;html&gt;\n\n",
   },

   literal_xml_tag_2 =>
   {
    sml   => '<para style="indented">',
    latex => "<para style=\"indented\">\n\n",
    html  => "&lt;para style=\"indented\"&gt;\n\n",
    xml   => "&lt;para style=\"indented\"&gt;\n\n",
   },

   literal_string_1 =>
   {
    sml   => '{lit:[cite:Goossens94]}',
    latex => '[cite:Goossens94]',
    html  => '[cite:Goossens94]',
    xml   => '[cite:Goossens94]',
   },

   email_address_1 =>
   {
    sml   => 'joe@example.com',
    latex => "joe\@example.com\n\n",
    html  => "<a href=\"mailto:joe\@example.com\">joe\@example.com</a>\n\n",
    xml   => "<a href=\"mailto:joe\@example.com\">joe\@example.com</a>\n\n",
   },

   take_note_symbol =>
   {
    sml   => '[[take_note]]',
    latex => "\\marginpar{\\Huge\\Writinghand}\n\n",
    html  => "<b>(take note!)</b>\n\n",
    xml   => "<b>(take note!)</b>\n\n",
   },

   smiley_symbol =>
   {
    sml   => ':-)',
    latex => "\\large\\Smiley\n\n",
    html  => "(smiley)\n\n",
    xml   => "(smiley)\n\n",
   },

   frowny_symbol =>
   {
    sml   => ':-(',
    latex => "\\large\\Frowny\n\n",
    html  => "(frowny)\n\n",
    xml   => "(frowny)\n\n",
   },

   keystroke_symbol_1 =>
   {
    sml   => '[[Enter]]',
    latex => "\\keystroke{Enter}\n\n",
    html  => "<span class=\"keystroke\">Enter</span>\n\n",
    xml   => "<span class=\"keystroke\">Enter</span>\n\n",
   },

   keystroke_symbol_2 =>
   {
    sml   => '[[Ctrl]]-[[Alt]]-[[Del]]',
    latex => "\\keystroke{Ctrl}-\\keystroke{Alt}-\\keystroke{Del}\n\n",
    html  => "<span class=\"keystroke\">Ctrl</span>-<span class=\"keystroke\">Alt</span>-<span class=\"keystroke\">Del</span>\n\n",
    xml   => "<span class=\"keystroke\">Ctrl</span>-<span class=\"keystroke\">Alt</span>-<span class=\"keystroke\">Del</span>\n\n",
   },

   left_arrow_symbol =>
   {
    sml   => '<-',
    latex => "\$\\leftarrow\$\n",
    html  => "&larr;\n",
    xml   => "&larr;\n",
   },

   right_arrow_symbol =>
   {
    sml   => '->',
    latex => "\$\\rightarrow\$\n\n",
    html  => "&rarr;\n\n",
    xml   => "&rarr;\n\n",
   },

   latex_symbol =>
   {
    sml   => 'LaTeX',
    latex => "\\LaTeX{}\n\n",
    html  => "LaTeX\n\n",
    xml   => "LaTeX\n\n",
   },

   tex_symbol =>
   {
    sml   => 'TeX',
    latex => "\\TeX{}\n\n",
    html  => "TeX\n\n",
    xml   => "TeX\n\n",
   },

   copyright_symbol =>
   {
    sml   => '[c]',
    latex => "\\tiny\$^{\\copyright}\$\\normalsize\n\n",
    html  => "&copy;\n\n",
    xml   => "&copy;\n\n",
   },

   trademark_symbol =>
   {
    sml   => '[tm]',
    latex => "\\tiny\$^{\\texttrademark}\$\\normalsize\n\n",
    html  => "&trade;\n\n",
    xml   => "&trade;\n\n",
   },

   reg_trademark_symbol =>
   {
    sml   => '[r]',
    latex => "\\tiny\$^{\\textregistered}\$\\normalsize\n\n",
    html  => "&reg;\n\n",
    xml   => "&reg;\n\n",
   },

   open_dblquote_symbol =>
   {
    sml   => '``',
    latex => "\`\`\n\n",
    html  => "&ldquo;\n\n",
    xml   => "&ldquo;\n\n",
   },

   close_dblquote_symbol =>
   {
    sml   => '\'\'',
    latex => "\'\'\n\n",
    html  => "&rdquo;\n\n",
    xml   => "&rdquo;\n\n",
   },

   open_sglquote_symbol =>
   {
    sml   => '`',
    latex => "\`\n\n",
    html  => "&lsquo;\n\n",
    xml   => "&lsquo;\n\n",
   },

   close_sglquote_symbol =>
   {
    sml   => '\'',
    latex => "\'\n\n",
    html  => "&rsquo;\n\n",
    xml   => "&rsquo;\n\n",
   },

   section_symbol =>
   {
    sml   => '[section]',
    latex => "{\\S}\n\n",
    html  => "&sect;\n\n",
    xml   => "&sect;\n\n",
   },

   emdash_symbol =>
   {
    sml   => '--',
    latex => "--\n\n",
    html  => "&mdash;\n",
    xml   => "&mdash;\n",
   },

   bold =>
   {
    sml   => '!!bold text!!',
    latex => "\\textbf{bold text}\n\n",
    html  => "<b>bold text</b>\n\n",
    xml   => "<b>bold text</b>\n\n",
   },

   italic =>
   {
    sml   => '~~italicized text~~',
    latex => "\\textit{italicized text}\n\n",
    html  => "<i>italicized text</i>\n\n",
    xml   => "<i>italicized text</i>\n\n",
   },

   underline =>
   {
    sml   => '__underlined text__',
    latex => "\\underline{underlined text}\n\n",
    html  => "<u>underlined text</u>\n\n",
    xml   => "<u>underlined text</u>\n\n",
   },

   fixedwidth =>
   {
    sml   => '||fixedwidth text||',
    latex => "\\texttt{fixedwidth text}\n\n",
    html  => "<tt>fixedwidth text</tt>\n\n",
    xml   => "<tt>fixedwidth text</tt>\n\n",
   },

   superscript =>
   {
    sml   => '^^superscripted text^^',
    latex => "\\textsuperscript{superscripted text}\n\n",
    html  => "<sup>superscripted text</sup>\n\n",
    xml   => "<sup>superscripted text</sup>\n\n",
   },

   subscript =>
   {
    sml   => ',,subscripted text,,',
    latex => "\\subscript{subscripted text}\n\n",
    html  => "<sub>subscripted text</sub>\n\n",
    xml   => "<sub>subscripted text</sub>\n\n",
   },

   valid_bold_block =>
   {
    sml     => 'This is a valid !!bold!! block',
    success => 'valid bold markup passes validation',
   },

   invalid_bold_block =>
   {
    sml     => 'This is an INVALID !!bold block',
    warning => 'INVALID BOLD MARKUP',
   },

   valid_italics_block =>
   {
    sml     => 'This is a valid ~~italics~~ block',
    success => 'valid italics markup passes validation',
   },

   invalid_italics_block =>
   {
    sml     => 'This is an INVALID ~~italics block',
    warning => 'INVALID ITALICS MARKUP',
   },

   valid_fixedwidth_block =>
   {
    sml     => 'This is a valid ||fixed-width|| block',
    success => 'valid fixed-width markup passes validation',
   },

   invalid_fixedwidth_block =>
   {
    sml     => 'This is an INVALID ||fixed-width block',
    warning => 'INVALID FIXED-WIDTH MARKUP',
   },

   valid_underline_block =>
   {
    sml     => 'This is a valid __underline__ block',
    success => 'valid underline markup passes validation',
   },

   invalid_underline_block =>
   {
    sml     => 'This is an INVALID __underline block',
    warning => 'INVALID UNDERLINE MARKUP',
   },

   valid_superscript_block =>
   {
    sml     => 'This is a valid ^^superscript^^ block',
    success => 'valid superscript markup passes validation',
   },

   invalid_superscript_block =>
   {
    sml     => 'This is an INVALID ^^superscript block',
    warning => 'INVALID SUPERSCRIPT MARKUP',
   },

   valid_subscript_block =>
   {
    sml     => 'This is a valid ,,subscript,, block',
    success => 'valid subscript markup passes validation',
   },

   invalid_subscript_block =>
   {
    sml     => 'This is an INVALID ,,subscript block',
    warning => 'INVALID SUBSCRIPT MARKUP',
   },

   valid_cross_reference_1 =>
   {
    sml     => 'Here is a valid cross reference: [ref:introduction].',
    success => 'valid cross reference 1 passes validation',
   },

   valid_cross_reference_2 =>
   {
    sml     => 'Here is a valid cross reference: [r:introduction].',
    success => 'valid cross reference 2 passes validation',
   },

   invalid_cross_reference_1 =>
   {
    sml     => 'Here is an INVALID cross reference: [ref:bogus].',
    warning => 'INVALID CROSS REFERENCE',
   },

   invalid_cross_reference_2 =>
   {
    sml     => 'Here is an INVALID cross reference: [r:bogus].',
    warning => 'INVALID CROSS REFERENCE',
   },

   incomplete_cross_reference_1 =>
   {
    sml     => 'Here is an incomplete cross reference: [ref:introduction.',
    warning => 'INVALID CROSS REFERENCE SYNTAX',
   },

   incomplete_cross_reference_2 =>
   {
    sml     => 'Here is an incomplete cross reference: [r:introduction.',
    warning => 'INVALID CROSS REFERENCE SYNTAX',
   },

   valid_id_reference =>
   {
    sml     => 'Here is a valid id reference: [id:introduction].',
    success => 'valid ID reference passes validation',
   },

   invalid_id_reference =>
   {
    sml     => 'Here is an INVALID id reference: [id:bogus].',
    warning => 'INVALID ID REFERENCE',
   },

   incomplete_id_reference =>
   {
    sml     => 'Here is an incomplete id reference: [id:introduction.',
    warning => 'INVALID ID REFERENCE SYNTAX',
   },

   valid_page_reference_1 =>
   {
    sml     => 'Here is a valid page reference: [page:introduction].',
    success => 'valid page reference 1 passes validation',
   },

   valid_page_reference_2 =>
   {
    sml     => 'Here is a valid page reference: [pg:introduction].',
    success => 'valid page reference 2 passes validation',
   },

   invalid_page_reference_1 =>
   {
    sml     => 'Here is an INVALID page reference: [page:bogus].',
    warning => 'INVALID PAGE REFERENCE',
   },

   invalid_page_reference_2 =>
   {
    sml     => 'Here is an INVALID page reference: [pg:bogus].',
    warning => 'INVALID PAGE REFERENCE',
   },

   incomplete_page_reference_1 =>
   {
    sml     => 'Here is an incomplete page reference: [page:introduction.',
    warning => 'INVALID PAGE REFERENCE SYNTAX',
   },

   incomplete_page_reference_2 =>
   {
    sml     => 'Here is an incomplete page reference: [pg:introduction.',
    warning => 'INVALID PAGE REFERENCE SYNTAX',
   },

   invalid_glossary_term_reference_1 =>
   {
    sml     => '[g:sml:bogus]',
    warning => 'TERM NOT IN GLOSSARY',
   },

   incomplete_glossary_term_reference_1 =>
   {
    sml     => '[g:sml:bogus',
    warning => 'INVALID GLOSSARY TERM REFERENCE SYNTAX',
   },

   invalid_glossary_def_reference_1 =>
   {
    sml     => '[def:sml:bogus]',
    warning => 'DEFINITION NOT IN GLOSSARY',
   },

   incomplete_glossary_def_reference_1 =>
   {
    sml     => '[def:sml:bogus',
    warning => 'INVALID GLOSSARY DEFINITION REFERENCE SYNTAX',
   },

   invalid_acronym_reference_1 =>
   {
    sml     => '[ac:sml:bogus]',
    warning => 'ACRONYM NOT IN ACRONYM LIST',
   },

   incomplete_acronym_reference_1 =>
   {
    sml     => '[ac:sml:bogus',
    warning => 'INVALID ACRONYM REFERENCE SYNTAX',
   },

   invalid_source_citation_1 =>
   {
    sml     => '[cite:bogus]',
    warning => 'INVALID SOURCE CITATION',
   },

   incomplete_source_citation_1 =>
   {
    sml     => '[cite:bogus',
    warning => 'INVALID SOURCE CITATION SYNTAX',
   },

   get_name_path_test_1 =>
   {
    testfile  => 'td-000020.txt',
    config    => 'library.conf',
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Block;
  use_ok( 'SML::Block' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Block->new;
isa_ok( $obj, 'SML::Block' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'has_valid_syntax',
   'has_valid_semantics',

   'get_name',
   'get_type',
   'get_content',
   'get_name_path',
   'get_containing_document',
   'get_first_line',
   'get_location',
   'get_containing_division',
   'get_line_list',

   'add_line',

   'validate_syntax',
   'validate_semantics',

   'validate_bold_markup',
   'validate_italics_markup',
   'validate_fixedwidth_markup',
   'validate_underline_markup',
   'validate_superscript_markup',
   'validate_subscript_markup',
   'validate_inline_tags',

   'validate_cross_refs',
   'validate_id_refs',
   'validate_page_refs',
   'validate_version_refs',
   'validate_revision_refs',
   'validate_date_refs',
   'validate_status_refs',
   'validate_glossary_term_refs',
   'validate_glossary_def_refs',
   'validate_acronym_refs',
   'validate_source_citations',

   'is_in_a',

   'as_sml',
   'as_html',
   'as_latex',
   'start_html',
   'end_html',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
   '_build_content',
   '_render_html_internal_references',
   '_render_html_url_references',
   '_render_html_footnote_references',
   '_render_html_glossary_references',
   '_render_html_acronym_references',
   '_render_html_index_references',
   '_render_html_id_references',
   '_render_html_thepage_references',
   '_render_html_page_references',
   '_render_html_version_references',
   '_render_html_revision_references',
   '_render_html_date_references',
   '_render_html_status_references',
   '_render_html_citation_references',
   '_render_latex_internal_references',
   '_render_latex_url_references',
   '_render_latex_footnote_references',
   '_render_latex_glossary_references',
   '_render_latex_acronym_references',
   '_render_latex_index_references',
   '_render_latex_id_references',
   '_render_latex_thepage_references',
   '_render_latex_page_references',
   '_render_latex_version_references',
   '_render_latex_revision_references',
   '_render_latex_date_references',
   '_render_latex_status_references',
   '_render_latex_citations',
   '_render_html_take_note_symbols',
   '_render_html_smiley_symbols',
   '_render_html_frowny_symbols',
   '_render_html_keystroke_symbols',
   '_render_html_left_arrow_symbols',
   '_render_html_right_arrow_symbols',
   '_render_html_latex_symbols',
   '_render_html_tex_symbols',
   '_render_html_copyright_symbols',
   '_render_html_trademark_symbols',
   '_render_html_reg_trademark_symbols',
   '_render_html_open_double_quote',
   '_render_html_close_double_quote',
   '_render_html_open_single_quote',
   '_render_html_close_single_quote',
   '_render_html_section_symbols',
   '_render_html_emdash',
   '_render_latex_take_note_symbols',
   '_render_latex_smiley_symbols',
   '_render_latex_frowny_symbols',
   '_render_latex_keystroke_symbols',
   '_render_latex_left_arrow_symbols',
   '_render_latex_right_arrow_symbols',
   '_render_latex_latex_symbols',
   '_render_latex_tex_symbols',
   '_render_latex_copyright_symbols',
   '_render_latex_trademark_symbols',
   '_render_latex_reg_trademark_symbols',
   '_render_latex_open_double_quote',
   '_render_latex_close_double_quote',
   '_render_latex_open_single_quote',
   '_render_latex_close_single_quote',
   '_render_latex_section_symbols',
   '_render_latex_emdash',
   '_render_html_underlined_text',
   '_render_html_superscripted_text',
   '_render_html_subscripted_text',
   '_render_html_italicized_text',
   '_render_html_bold_text',
   '_render_html_fixed_width_text',
   '_render_html_file_references',
   '_render_html_path_references',
   '_render_html_user_entered_text',
   '_render_html_commands',
   '_render_html_literal_xml_tags',
   '_render_html_email_addresses',
   '_render_latex_underlined_text',
   '_render_latex_superscripted_text',
   '_render_latex_subscripted_text',
   '_render_latex_italicized_text',
   '_render_latex_bold_text',
   '_render_latex_fixed_width_text',
   '_render_latex_file_references',
   '_render_latex_path_references',
   '_render_latex_user_entered_text',
   '_render_latex_commands',
   '_render_latex_literal_xml_tags',
   '_render_latex_email_addresses',
  );

can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

# references
#
html_ok('cross_reference_1',     'al-000288');
html_ok('cross_reference_2',     'al-000288');
html_ok('cross_reference_3',     'al-000288');
html_ok('cross_reference_4',     'al-000288');
html_ok('url_reference_1',       'al-000289');
html_ok('footnote_reference_1',  'al-000290');
html_ok('glossary_reference_1',  'al-000291');
html_ok('glossary_reference_2',  'al-000291');
html_ok('glossary_reference_3',  'al-000291');
html_ok('glossary_reference_4',  'al-000291');
html_ok('acronym_reference_1',   'al-000292');
html_ok('acronym_reference_2',   'al-000292');
html_ok('acronym_reference_3',   'al-000292');
html_ok('index_reference_1',     'al-000293');
html_ok('index_reference_2',     'al-000293');
html_ok('id_reference_1',        'al-000294');
html_ok('thepage_reference_1',   'al-000295');
html_ok('page_reference_1',      'al-000296');
html_ok('page_reference_2',      'al-000296');
html_ok('version_reference_1',   'al-000297');
html_ok('revision_reference_1',  'al-000298');
html_ok('date_reference_1',      'al-000299');
html_ok('status_reference_1',    'al-000300');
html_ok('status_reference_2',    'al-000300');
html_ok('status_reference_3',    'al-000300');
html_ok('status_reference_4',    'al-000300');
html_ok('status_reference_5',    'al-000300');
html_ok('citation_reference_1',  'al-000301');
html_ok('citation_reference_2',  'al-000301');
html_ok('file_reference_1',      'al-000325');
html_ok('file_reference_2',      'al-000325');
html_ok('path_reference_1',      'al-000326');
html_ok('path_reference_2',      'al-000326');
html_ok('path_reference_3',      'al-000326');

# special symbols
#
html_ok('take_note_symbol',      'al-000302');
html_ok('smiley_symbol',         'al-000303');
html_ok('frowny_symbol',         'al-000304');
html_ok('keystroke_symbol_1',    'al-000305');
html_ok('keystroke_symbol_2',    'al-000305');
html_ok('left_arrow_symbol',     'al-000306');
html_ok('right_arrow_symbol',    'al-000307');
html_ok('latex_symbol',          'al-000308');
html_ok('tex_symbol',            'al-000309');
html_ok('copyright_symbol',      'al-000310');
html_ok('trademark_symbol',      'al-000311');
html_ok('reg_trademark_symbol',  'al-000312');
html_ok('open_dblquote_symbol',  'al-000313');
html_ok('close_dblquote_symbol', 'al-000314');
html_ok('open_sglquote_symbol',  'al-000315');
html_ok('close_sglquote_symbol', 'al-000316');
html_ok('section_symbol',        'al-000317');
html_ok('emdash_symbol',         'al-000318');

# spanned styles
#
html_ok('underline',             'al-000319');
html_ok('superscript',           'al-000320');
html_ok('subscript',             'al-000321');
html_ok('italic',                'al-000322');
html_ok('bold',                  'al-000323');
html_ok('fixedwidth',            'al-000324');
html_ok('user_entered_text_1',   'al-000327');
html_ok('command_reference_1',   'al-000328');
html_ok('command_reference_2',   'al-000328');
html_ok('literal_xml_tag_1',     'al-000329');
html_ok('literal_xml_tag_2',     'al-000329');
# html_ok('literal_string_1',      'al-000410');
html_ok('email_address_1',       'al-000330');

# references
#
latex_ok('cross_reference_1',     'al-000363');
latex_ok('cross_reference_2',     'al-000363');
latex_ok('url_reference_1',       'al-000364');
latex_ok('footnote_reference_1',  'al-000365');
latex_ok('glossary_reference_1',  'al-000366');
latex_ok('glossary_reference_2',  'al-000366');
latex_ok('glossary_reference_3',  'al-000366');
latex_ok('glossary_reference_4',  'al-000366');
latex_ok('acronym_reference_1',   'al-000367');
latex_ok('acronym_reference_2',   'al-000367');
latex_ok('acronym_reference_3',   'al-000367');
latex_ok('index_reference_1',     'al-000368');
latex_ok('index_reference_2',     'al-000368');
latex_ok('id_reference_1',        'al-000369');
latex_ok('thepage_reference_1',   'al-000370');
latex_ok('page_reference_1',      'al-000371');
latex_ok('page_reference_2',      'al-000371');
latex_ok('version_reference_1',   'al-000372');
latex_ok('revision_reference_1',  'al-000373');
latex_ok('date_reference_1',      'al-000374');
latex_ok('status_reference_1',    'al-000375');
latex_ok('status_reference_2',    'al-000375');
latex_ok('status_reference_3',    'al-000375');
latex_ok('status_reference_4',    'al-000375');
latex_ok('status_reference_5',    'al-000375');
latex_ok('citation_reference_1',  'al-000376');
latex_ok('citation_reference_2',  'al-000376');
latex_ok('file_reference_1',      'al-000400');
latex_ok('file_reference_2',      'al-000400');
latex_ok('path_reference_1',      'al-000401');
latex_ok('path_reference_2',      'al-000401');
latex_ok('path_reference_3',      'al-000401');

# special symbols
#
latex_ok('take_note_symbol',      'al-000377');
latex_ok('smiley_symbol',         'al-000378');
latex_ok('frowny_symbol',         'al-000379');
latex_ok('keystroke_symbol_1',    'al-000380');
latex_ok('keystroke_symbol_2',    'al-000380');
latex_ok('left_arrow_symbol',     'al-000381');
latex_ok('right_arrow_symbol',    'al-000382');
latex_ok('latex_symbol',          'al-000383');
latex_ok('tex_symbol',            'al-000384');
latex_ok('copyright_symbol',      'al-000385');
latex_ok('trademark_symbol',      'al-000386');
latex_ok('reg_trademark_symbol',  'al-000387');
latex_ok('open_dblquote_symbol',  'al-000388');
latex_ok('close_dblquote_symbol', 'al-000389');
latex_ok('open_sglquote_symbol',  'al-000390');
latex_ok('close_sglquote_symbol', 'al-000391');
latex_ok('section_symbol',        'al-000392');
latex_ok('emdash_symbol',         'al-000393');

# spanned styles
#
latex_ok('underline',             'al-000394');
latex_ok('superscript',           'al-000395');
latex_ok('subscript',             'al-000396');
latex_ok('italic',                'al-000397');
latex_ok('bold',                  'al-000398');
latex_ok('fixedwidth',            'al-000399');
latex_ok('user_entered_text_1',   'al-000402');
latex_ok('command_reference_1',   'al-000403');
latex_ok('command_reference_2',   'al-000403');
latex_ok('literal_xml_tag_1',     'al-000404');
latex_ok('literal_xml_tag_2',     'al-000404');
latex_ok('email_address_1',       'al-000405');

# validates OK?
#
validate_ok( 'validate_bold_markup',        'valid_bold_block' );
validate_ok( 'validate_italics_markup',     'valid_italics_block' );
validate_ok( 'validate_fixedwidth_markup',  'valid_fixedwidth_block' );
validate_ok( 'validate_underline_markup',   'valid_underline_block' );
validate_ok( 'validate_superscript_markup', 'valid_superscript_block' );
validate_ok( 'validate_subscript_markup',   'valid_subscript_block' );
validate_ok( 'validate_cross_refs',         'valid_cross_reference_1' );
validate_ok( 'validate_cross_refs',         'valid_cross_reference_2' );
validate_ok( 'validate_id_refs',            'valid_id_reference' );
validate_ok( 'validate_page_refs',          'valid_page_reference_1' );
validate_ok( 'validate_page_refs',          'valid_page_reference_2' );
validate_ok( 'validate_version_refs',       'version_reference_1' );
validate_ok( 'validate_revision_refs',      'revision_reference_1' );
validate_ok( 'validate_date_refs',          'date_reference_1' );
validate_ok( 'validate_status_refs',        'status_reference_1' );
validate_ok( 'validate_status_refs',        'status_reference_2' );
validate_ok( 'validate_status_refs',        'status_reference_3' );
validate_ok( 'validate_status_refs',        'status_reference_4' );
validate_ok( 'validate_status_refs',        'status_reference_5' );

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

warning_ok( 'validate_bold_markup',        'invalid_bold_block' );
warning_ok( 'validate_italics_markup',     'invalid_italics_block' );
warning_ok( 'validate_fixedwidth_markup',  'invalid_fixedwidth_block' );
warning_ok( 'validate_underline_markup',   'invalid_underline_block' );
warning_ok( 'validate_superscript_markup', 'invalid_superscript_block' );
warning_ok( 'validate_subscript_markup',   'invalid_subscript_block' );
warning_ok( 'validate_cross_refs',         'invalid_cross_reference_1' );
warning_ok( 'validate_cross_refs',         'invalid_cross_reference_2' );
warning_ok( 'validate_cross_refs',         'incomplete_cross_reference_1' );
warning_ok( 'validate_cross_refs',         'incomplete_cross_reference_2' );
warning_ok( 'validate_id_refs',            'invalid_id_reference' );
warning_ok( 'validate_id_refs',            'incomplete_id_reference' );
warning_ok( 'validate_page_refs',          'invalid_page_reference_1' );
warning_ok( 'validate_page_refs',          'invalid_page_reference_2' );
warning_ok( 'validate_page_refs',          'incomplete_page_reference_1' );
warning_ok( 'validate_page_refs',          'incomplete_page_reference_2' );
warning_ok( 'validate_glossary_term_refs', 'invalid_glossary_term_reference_1' );
warning_ok( 'validate_glossary_term_refs', 'incomplete_glossary_term_reference_1' );
warning_ok( 'validate_glossary_def_refs',  'invalid_glossary_def_reference_1' );
warning_ok( 'validate_glossary_def_refs',  'incomplete_glossary_def_reference_1' );
warning_ok( 'validate_acronym_refs',       'invalid_acronym_reference_1' );
warning_ok( 'validate_acronym_refs',       'incomplete_acronym_reference_1' );
warning_ok( 'validate_source_citations',   'invalid_source_citation_1' );
warning_ok( 'validate_source_citations',   'incomplete_source_citation_1' );

no_doc_error_ok( 'as_html', 'cross_reference_1' );
no_doc_error_ok( 'as_html', 'cross_reference_2' );
no_doc_error_ok( 'as_html', 'cross_reference_3' );
no_doc_error_ok( 'as_html', 'cross_reference_4' );
no_doc_error_ok( 'as_html', 'footnote_reference_1' );
no_doc_error_ok( 'as_html', 'glossary_reference_1' );
no_doc_error_ok( 'as_html', 'glossary_reference_2' );
no_doc_error_ok( 'as_html', 'glossary_reference_3' );
no_doc_error_ok( 'as_html', 'glossary_reference_4' );
no_doc_error_ok( 'as_html', 'acronym_reference_1' );
no_doc_error_ok( 'as_html', 'acronym_reference_2' );
no_doc_error_ok( 'as_html', 'acronym_reference_3' );
no_doc_error_ok( 'as_html', 'id_reference_1' );
no_doc_error_ok( 'as_html', 'page_reference_1' );
no_doc_error_ok( 'as_html', 'page_reference_2' );
no_doc_error_ok( 'as_html', 'version_reference_1' );
no_doc_error_ok( 'as_html', 'revision_reference_1' );
no_doc_error_ok( 'as_html', 'date_reference_1' );
no_doc_error_ok( 'as_html', 'status_reference_1' );
no_doc_error_ok( 'as_html', 'status_reference_2' );
no_doc_error_ok( 'as_html', 'status_reference_3' );
no_doc_error_ok( 'as_html', 'status_reference_4' );
no_doc_error_ok( 'as_html', 'status_reference_5' );

get_name_path_ok('get_name_path_test_1');

######################################################################

sub html_ok {

  my $blockname  = shift;
  my $allocation = shift;

  #-------------------------------------------------------------------
  # Arrange
  #
  my $content  = $testdata->{$blockname}{'sml'}  || "$blockname content not defined";
  my $expected = $testdata->{$blockname}{'html'} || "$blockname expected output not defined";

  my $fragment = $parser->parse('td-000020.txt');
  my $document = $library->get_document('td-000020');
  my $line     = SML::Line->new(content=>$content);
  my $block    = SML::Block->new;

  $block->add_line($line);
  $document->add_part($block);

  #-------------------------------------------------------------------
  # Act
  #
  $html = $block->as_html;

  #-------------------------------------------------------------------
  # Assert
  #
  is($html, $expected, "$date $allocation HTML $blockname renders OK");

}

######################################################################

sub latex_ok {

  my $blockname  = shift;
  my $allocation = shift;

  #-------------------------------------------------------------------
  # Arrange
  #
  my $content  = $testdata->{$blockname}{'sml'}   || "$blockname content not defined";
  my $expected = $testdata->{$blockname}{'latex'} || "$blockname expected output not defined";

  my $fragment = $parser->parse('td-000020.txt');
  my $document = $library->get_document('td-000020');
  my $line     = SML::Line->new(content=>$content);
  my $block    = SML::Block->new;

  $block->add_line($line);
  $document->add_part($block);

  #-------------------------------------------------------------------
  # Act
  #
  $html = $block->as_latex;

  #-------------------------------------------------------------------
  # Assert
  #
  is($html, $expected, "$date $allocation LaTeX $blockname renders OK");

}

######################################################################

sub create_test_block {

  my $content  = shift;
  my $fragment = $parser->parse('td-000020.txt');
  my $document = $library->get_document('td-000020');
  my $line     = SML::Line->new(content=>$content);
  my $block    = SML::Block->new;

  $block->add_line($line);
  $document->add_part($block);

  return $block;
}

######################################################################

sub warning_ok {

  my $method = shift;
  my $testid = shift;

  # arrange
  my $content = $testdata->{$testid}{'sml'};
  my $warning = $testdata->{$testid}{'warning'};
  my $block   = create_test_block($content);

  Test::Log4perl->start( ignore_priority => "info" );
  $t1logger->warn(qr/$warning/);

  # act
  my $result = $block->$method;

  # assert
  Test::Log4perl->end("WARNING: $warning ($testid)");

}

######################################################################

sub validate_ok {

  my $method = shift;
  my $testid = shift;

  my $expected = 1;
  my $content  = $testdata->{$testid}{'sml'};
  my $success  = $testdata->{$testid}{'success'};

  my $block    = create_test_block($content);

  # act
  my $result   = $block->$method;

  # assert
  is($result,$expected, "$success");

}

######################################################################

sub no_doc_error_ok {

  my $method = shift;
  my $testid = shift;

  my $content  = $testdata->{$testid}{'sml'};
  my $error    = $testdata->{$testid}{'no_doc_error'};
  my $line     = SML::Line->new(content=>$content);
  my $block    = SML::Block->new;

  $block->add_line($line);

  Test::Log4perl->start( ignore_priority => "warn" );
  $t1logger->error(qr/$error/);

  # Act
  $html = $block->as_html;

  # Assert
  Test::Log4perl->end("ERROR: $error ($testid)");

}

######################################################################

sub get_name_path_ok {

  my $testid = shift;

  # arrange
  my $testfile   = $testdata->{$testid}{testfile};
  my $config     = $testdata->{$testid}{config};
  my $library    = SML::Library->new(config_filename=>$config);
  my $parser     = $library->get_parser;
  my $fragment   = $parser->parse($testfile);
  my $block_list = $fragment->get_block_list;

  # act
  foreach my $block (@{ $block_list })
    {
      my $path    = $block->get_name_path;
      my $content = $block->get_content;

      # print "$path\n";
    }

  # assert
  my $result   = 1;
  my $expected = 1;
  is($result, $expected, "get_name_path $testid")
}

######################################################################
