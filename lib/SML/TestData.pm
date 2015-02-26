#!/usr/bin/perl

# $Id$

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

has library =>
  (
   is      => 'ro',
   isa     => 'SML::Library',
   reader  => 'get_library',
   lazy    => 1,
   builder => '_build_library',
  );

######################################################################

has formatter_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_formatter_test_case_list',
   lazy    => 1,
   builder => '_build_formatter_test_case_list',
  );

######################################################################

has part_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_part_test_case_list',
   lazy    => 1,
   builder => '_build_part_test_case_list',
  );

######################################################################

has cross_reference_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_cross_reference_test_case_list',
   lazy    => 1,
   builder => '_build_cross_reference_test_case_list',
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

has acronym_list_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_acronym_list_test_case_list',
   lazy    => 1,
   builder => '_build_acronym_list_test_case_list',
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

has library_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_library_test_case_list',
   lazy    => 1,
   builder => '_build_library_test_case_list',
  );

######################################################################

has parser_test_case_list =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   reader  => 'get_parser_test_case_list',
   lazy    => 1,
   builder => '_build_parser_test_case_list',
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

sub _build_library {

  use SML::Library;

  return SML::Library->new(config_filename=>'library.conf');
}

######################################################################

sub _build_formatter_test_case_list {

  my $self = shift;

  return
    [
    ];
}

######################################################################

sub _build_part_test_case_list {

  my $self = shift;

  return
    [
     {
      name     => 'part_test_1',
      part_id  => 'introduction',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       has_part => 1,
       get_part => 'SML::Section',
      },
     },

     {
      name     => 'part_test_2',
      part_id  => 'problem-1',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       has_part => 1,
       get_part => 'SML::Entity',
      },
     },

     {
      name     => 'part_test_3',
      part_id  => 'bogus_id',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       has_part => 0,
      },
     },

    ];
}

######################################################################

sub _build_cross_reference_test_case_list {

  my $self = shift;

  return
    [
    ];
}

######################################################################

sub _build_block_test_case_list {

  my $self = shift;

  return
    [
     {
      name     => 'cross_reference_1',
      content  => '[ref:introduction]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020-1.html#SECTION.1\">Section 1</a>\n\n",
       },
       latex =>
       {
	default => "Section~\\vref{introduction}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020-1.xml#SECTION.1\">Section 1</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'cross_reference_2',
      content  => '[r:introduction]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020-1.html#SECTION.1\">Section 1</a>\n\n",
       },
       latex =>
       {
	default => "Section~\\vref{introduction}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020-1.xml#SECTION.1\">Section 1</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'cross_reference_3',
      content  => '[ref:system-model]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020-2.html#SECTION.2\">Section 2</a>\n\n",
       },
       latex =>
       {
	default => "Section~\\vref{system-model}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'cross_reference_4',
      content  => '[r:system-model]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020-2.html#SECTION.2\">Section 2</a>\n\n",
       },
       latex =>
       {
	default => "Section~\\vref{system-model}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020-2.html#Section.2\">Section 2</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'url_reference_1',
      content  => '[url:http://www.cnn.com/]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"http://www.cnn.com/\">http://www.cnn.com/</a>\n\n",
       },
       latex =>
       {
	default => "\\urlstyle{sf}\\url{http://www.cnn.com/}\n\n",
       },
       xml =>
       {
	default => "<a href=\"http://www.cnn.com/\">http://www.cnn.com/</a>\n\n",
       },
      },
     },

     {
      name     => 'footnote_reference_1',
      content  => '[f:introduction:1]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<span style=\"font-size: 8pt;\"><sup><a href=\"#footnote.introduction.1\">1<\/a><\/sup><\/span>\n\n",
       },
       latex =>
       {
	default => "\\footnote{This is a footnote.}\n\n",
       },
       xml =>
       {
	default => "<span style=\"font-size: 8pt;\"><sup><a href=\"#footnote.introduction.1\">1<\/a><\/sup><\/span>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'glossary_reference_1',
      content  => '[g:sml:document]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
       },
       latex =>
       {
	default => "\\gls{document:sml}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'glossary_reference_2',
      content  => '[G:sml:document]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
       },
       latex =>
       {
	default => "\\Gls{document:sml}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'glossary_reference_3',
      content  => '[gls:sml:document]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
       },
       latex =>
       {
	default => "\\gls{document:sml}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020.glossary.html#document:sml\">document</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'glossary_reference_4',
      content  => '[Gls:sml:document]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
       },
       latex =>
       {
	default => "\\Gls{document:sml}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020.glossary.html#document:sml\">Document</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'acronym_reference_1',
      content  => '[a:sml:TLA]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a>\n\n",
       },
       latex =>
       {
	default => "\\ac{TLA:sml}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'acronym_reference_2',
      content  => '[ac:sml:TLA]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a>\n\n",
       },
       latex =>
       {
	default => "\\acs{TLA:sml}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'acronym_reference_3',
      content  => '[acs:sml:TLA]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a>\n\n",
       },
       latex =>
       {
	default => "\\acs{TLA:sml}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020.acronyms.html#TLA:sml\">TLA</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'acronym_reference_3',
      content  => '[acl:sml:TLA]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020.acronyms.html#TLA:sml\">Three Letter Acronym</a>\n\n",
       },
       latex =>
       {
	default => "\\acl{TLA:sml}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020.acronyms.html#TLA:sml\">Three Letter Acronym</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'index_reference_1',
      content  => '[i:structured manuscript language]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "structured manuscript language\n\n",
       },
       latex =>
       {
	default => "structured manuscript language \\index{structured manuscript language}\n\n",
       },
       xml =>
       {
	default => "structured manuscript language\n\n",
       },
      },
     },

     {
      name     => 'index_reference_2',
      content  => '[index:structured manuscript language]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "structured manuscript language\n\n",
       },
       latex =>
       {
	default => "structured manuscript language \\index{structured manuscript language}\n\n",
       },
       xml =>
       {
	default => "structured manuscript language\n\n",
       },
      },
     },

     {
      name     => 'id_reference_1',
      content  => '[id:introduction]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020-1.html#SECTION.1\">Section 1</a>\n\n",
       },
       latex =>
       {
	default => "\\hyperref[introduction]{introduction}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020-1.html#SECTION.1\">Section 1</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'thepage_reference_1',
      content  => '[thepage]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "\n\n",
       },
       latex =>
       {
	default => "\\thepage\n\n",
       },
       xml =>
       {
	default => "\n\n",
       },
      },
     },

     {
      name     => 'page_reference_1',
      content  => '[page:introduction]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020-1.html#SECTION.1\">link</a>\n\n",
       },
       latex =>
       {
	default => "p. \\pageref{introduction}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020-1.html#SECTION.1\">link</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'page_reference_2',
      content  => '[pg:introduction]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<a href=\"td-000020-1.html#SECTION.1\">link</a>\n\n",
       },
       latex =>
       {
	default => "p. \\pageref{introduction}\n\n",
       },
       xml =>
       {
	default => "<a href=\"td-000020-1.html#SECTION.1\">link</a>\n\n",
       },
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'version_reference_1',
      content  => '[theversion]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "2.0\n\n",
       },
       latex =>
       {
	default => "2.0\n\n",
       },
       xml =>
       {
	default => "2.0\n\n",
       },
       success => 'valid version reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'revision_reference_1',
      content  => '[therevision]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "4444\n\n",
       },
       latex =>
       {
	default => "4444\n\n",
       },
       xml =>
       {
	default => "4444\n\n",
       },
       success => 'valid revision reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'date_reference_1',
      content  => '[thedate]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "2012-09-11\n\n",
       },
       latex =>
       {
	default => "2012-09-11\n\n",
       },
       xml =>
       {
	default => "2012-09-11\n\n",
       },
       success => 'valid date reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_1',
      content  => '[status:td-000020]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
       },
       latex =>
       {
	default => "\\textcolor{fg-yellow}{\$\\blacksquare\$}\n\n",
       },
       xml =>
       {
	default => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_2',
      content  => '[status:grey]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<image src=\"status_grey.png\" border=\"0\"/>\n\n",
       },
       latex =>
       {
	default => "\\textcolor{fg-grey}{\$\\blacksquare\$}\n\n",
       },
       xml =>
       {
	default => "<image src=\"status_grey.png\" border=\"0\"/>\n\n",
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_3',
      content  => '[status:green]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<image src=\"status_green.png\" border=\"0\"/>\n\n",
       },
       latex =>
       {
	default => "\\textcolor{fg-green}{\$\\blacksquare\$}\n\n",
       },
       xml =>
       {
	default => "<image src=\"status_green.png\" border=\"0\"/>\n\n",
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_4',
      content  => '[status:yellow]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
       },
       latex =>
       {
	default => "\\textcolor{fg-yellow}{\$\\blacksquare\$}\n\n",
       },
       xml =>
       {
	default => "<image src=\"status_yellow.png\" border=\"0\"/>\n\n",
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_5',
      content  => '[status:red]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<image src=\"status_red.png\" border=\"0\"/>\n\n",
       },
       latex =>
       {
	default => "\\textcolor{fg-red}{\$\\blacksquare\$}\n\n",
       },
       xml =>
       {
	default => "<image src=\"status_red.png\" border=\"0\"/>\n\n",
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name     => 'status_reference_6',
      content  => '[status:problem-1]',
      filename => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       html =>
       {
	default => "<image src=\"status_green.png\" border=\"0\"/>\n\n",
       },
       latex =>
       {
	default => "\\textcolor{fg-green}{\$\\blacksquare\$}\n\n",
       },
       xml =>
       {
	default => "<image src=\"status_green.png\" border=\"0\"/>\n\n",
       },
       success => 'valid status reference passes validation',
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name    => 'citation_reference_1',
      content => '[cite:cms15]',
      expected =>
      {
       latex => "\\cite{cms15}\n\n",
       html  => "[<a href=\"td-000020.source.html#cms15\">cms15</a>]\n\n",
       xml   => "[<a href=\"td-000020.source.html#cms15\">cms15</a>]\n\n",
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name    => 'citation_reference_2',
      content => '[cite:cms15, pg 44]',
      expected =>
      {
       latex => "\\cite[pg 44]{cms15}\n\n",
       html  => "[<a href=\"td-000020.source.html#cms15\">cms15, pg 44</a>]\n\n",
       xml   => "[<a href=\"td-000020.source.html#cms15\">cms15, pg 44</a>]\n\n",
       error =>
       {
	no_doc => 'NOT IN DOCUMENT CONTEXT',
       },
      },
     },

     {
      name    => 'file_reference_1',
      content => '[file:app.ini]',
      expected =>
      {
       latex => "\\path{app.ini}\n\n",
       html  => "<tt>app.ini</tt>\n\n",
       xml   => "<tt>app.ini</tt>\n\n",
      },
     },

     {
      name    => 'file_reference_2',
      content => '[file:My Document.doc]',
      expected =>
      {
       latex => "\\path{My Document.doc}\n\n",
       html  => "<tt>My Document.doc</tt>\n\n",
       xml   => "<tt>My Document.doc</tt>\n\n",
      },
     },

     {
      name    => 'path_reference_1',
      content => '[path:/path/to/folder]',
      expected =>
      {
       latex => "\\path{/path/to/folder}\n\n",
       html  => "<tt>/path/to/folder</tt>\n\n",
       xml   => "<tt>/path/to/folder</tt>\n\n",
      },
     },

     {
      name    => 'path_reference_2',
      content => '[path:/path/to/my folder]',
      expected =>
      {
       latex => "\\path{/path/to/my folder}\n\n",
       html  => "<tt>/path/to/my folder</tt>\n\n",
       xml   => "<tt>/path/to/my folder</tt>\n\n",
      },
     },

     {
      name    => 'path_reference_3',
      content => '[path:C:\path\to\my folder\]',
      expected =>
      {
       latex => "\\path{C:\\path\\to\\my folder}\$\\backslash\$\n\n",
       html  => "<tt>C:\\path\\to\\my folder\\</tt>\n\n",
       xml   => "<tt>C:\\path\\to\\my folder\\</tt>\n\n",
      },
     },

     {
      name    => 'user_entered_text_1',
      content => '[enter:USERNAME]',
      expected =>
      {
       latex => "\\textbf{\\texttt{USERNAME}}\n\n",
       html  => "<b><tt>USERNAME</tt></b>\n\n",
       xml   => "<b><tt>USERNAME</tt></b>\n\n",
      },
     },

     {
      name    => 'command_reference_1',
      content => '[cmd:pwd]',
      expected =>
      {
       latex => "\\path{pwd}\n\n",
       html  => "<tt>pwd</tt>\n\n",
       xml   => "<tt>pwd</tt>\n\n",
      },
     },

     {
      name    => 'command_reference_2',
      content => '[cmd:ls -al | grep -i bin | sort]',
      expected =>
      {
       latex => "\\path{ls -al | grep -i bin | sort}\n\n",
       html  => "<tt>ls -al | grep -i bin | sort</tt>\n\n",
       xml   => "<tt>ls -al | grep -i bin | sort</tt>\n\n",
      },
     },

     {
      name    => 'literal_xml_tag_1',
      content => '<html>',
      expected =>
      {
       latex => "<html>\n\n",
       html  => "&lt;html&gt;\n\n",
       xml   => "&lt;html&gt;\n\n",
      },
     },

     {
      name    => 'literal_xml_tag_2',
      content => '<para style="indented">',
      expected =>
      {
       latex => "<para style=\"indented\">\n\n",
       html  => "&lt;para style=\"indented\"&gt;\n\n",
       xml   => "&lt;para style=\"indented\"&gt;\n\n",
      },
     },

     {
      name    => 'literal_string_1',
      content => '{lit:[cite:Goossens94]}',
      expected =>
      {
       latex => '[cite:Goossens94]',
       html  => '[cite:Goossens94]',
       xml   => '[cite:Goossens94]',
      },
     },

     {
      name    => 'email_address_1',
      content => 'joe@example.com',
      expected =>
      {
       latex => "joe\@example.com\n\n",
       html  => "<a href=\"mailto:joe\@example.com\">joe\@example.com</a>\n\n",
       xml   => "<a href=\"mailto:joe\@example.com\">joe\@example.com</a>\n\n",
      },
     },

     {
      name    => 'take_note_symbol',
      content => '[[take_note]]',
      expected =>
      {
       latex => "\\marginpar{\\Huge\\Writinghand}\n\n",
       html  => "<b>(take note!)</b>\n\n",
       xml   => "<b>(take note!)</b>\n\n",
      },
     },

     {
      name    => 'smiley_symbol',
      content => ':-)',
      expected =>
      {
       latex => "\\large\\Smiley\n\n",
       html  => "(smiley)\n\n",
       xml   => "(smiley)\n\n",
      },
     },

     {
      name    => 'frowny_symbol',
      content => ':-(',
      expected =>
      {
       latex => "\\large\\Frowny\n\n",
       html  => "(frowny)\n\n",
       xml   => "(frowny)\n\n",
      },
     },

     {
      name    => 'keystroke_symbol_1',
      content => '[[Enter]]',
      expected =>
      {
       latex => "\\keystroke{Enter}\n\n",
       html  => "<span class=\"keystroke\">Enter</span>\n\n",
       xml   => "<span class=\"keystroke\">Enter</span>\n\n",
      },
     },

     {
      name    => 'keystroke_symbol_2',
      content => '[[Ctrl]]-[[Alt]]-[[Del]]',
      expected =>
      {
       latex => "\\keystroke{Ctrl}-\\keystroke{Alt}-\\keystroke{Del}\n\n",
       html  => "<span class=\"keystroke\">Ctrl</span>-<span class=\"keystroke\">Alt</span>-<span class=\"keystroke\">Del</span>\n\n",
       xml   => "<span class=\"keystroke\">Ctrl</span>-<span class=\"keystroke\">Alt</span>-<span class=\"keystroke\">Del</span>\n\n",
      },
     },

     {
      name    => 'left_arrow_symbol',
      content => '<-',
      expected =>
      {
       latex => "\$\\leftarrow\$\n",
       html  => "&larr;\n",
       xml   => "&larr;\n",
      },
     },

     {
      name    => 'right_arrow_symbol',
      content => '->',
      expected =>
      {
       latex => "\$\\rightarrow\$\n\n",
       html  => "&rarr;\n\n",
       xml   => "&rarr;\n\n",
      },
     },

     {
      name    => 'latex_symbol',
      content => 'LaTeX',
      expected =>
      {
       latex => "\\LaTeX{}\n\n",
       html  => "LaTeX\n\n",
       xml   => "LaTeX\n\n",
      },
     },

     {
      name    => 'tex_symbol',
      content => 'TeX',
      expected =>
      {
       latex => "\\TeX{}\n\n",
       html  => "TeX\n\n",
       xml   => "TeX\n\n",
      },
     },

     {
      name    => 'copyright_symbol',
      content => '[c]',
      expected =>
      {
       latex => "\\tiny\$^{\\copyright}\$\\normalsize\n\n",
       html  => "&copy;\n\n",
       xml   => "&copy;\n\n",
      },
     },

     {
      name    => 'trademark_symbol',
      content => '[tm]',
      expected =>
      {
       latex => "\\tiny\$^{\\texttrademark}\$\\normalsize\n\n",
       html  => "&trade;\n\n",
       xml   => "&trade;\n\n",
      },
     },

     {
      name    => 'reg_trademark_symbol',
      content => '[r]',
      expected =>
      {
       latex => "\\tiny\$^{\\textregistered}\$\\normalsize\n\n",
       html  => "&reg;\n\n",
       xml   => "&reg;\n\n",
      },
     },

     {
      name    => 'open_dblquote_symbol',
      content => '``',
      expected =>
      {
       latex => "\`\`\n\n",
       html  => "&ldquo;\n\n",
       xml   => "&ldquo;\n\n",
      },
     },

     {
      name    => 'close_dblquote_symbol',
      content => '\'\'',
      expected =>
      {
       latex => "\'\'\n\n",
       html  => "&rdquo;\n\n",
       xml   => "&rdquo;\n\n",
      },
     },

     {
      name    => 'open_sglquote_symbol',
      content => '`',
      expected =>
      {
       latex => "\`\n\n",
       html  => "&lsquo;\n\n",
       xml   => "&lsquo;\n\n",
      },
     },

     {
      name    => 'close_sglquote_symbol',
      content => '\'',
      expected =>
      {
       latex => "\'\n\n",
       html  => "&rsquo;\n\n",
       xml   => "&rsquo;\n\n",
      },
     },

     {
      name    => 'section_symbol',
      content => '[section]',
      expected =>
      {
       latex => "{\\S}\n\n",
       html  => "&sect;\n\n",
       xml   => "&sect;\n\n",
      },
     },

     {
      name    => 'emdash_symbol',
      content => '--',
      expected =>
      {
       latex => "--\n\n",
       html  => "&mdash;\n",
       xml   => "&mdash;\n",
      },
     },

     {
      name    => 'bold',
      content => '!!bold text!!',
      expected =>
      {
       latex => "\\textbf{bold text}\n\n",
       html  => "<b>bold text</b>\n\n",
       xml   => "<b>bold text</b>\n\n",
      },
     },

     {
      name    => 'italic',
      content => '~~italicized text~~',
      expected =>
      {
       latex => "\\textit{italicized text}\n\n",
       html  => "<i>italicized text</i>\n\n",
       xml   => "<i>italicized text</i>\n\n",
      },
     },

     {
      name    => 'underline',
      content => '__underlined text__',
      expected =>
      {
       latex => "\\underline{underlined text}\n\n",
       html  => "<u>underlined text</u>\n\n",
       xml   => "<u>underlined text</u>\n\n",
      },
     },

     {
      name    => 'fixedwidth',
      content => '||fixedwidth text||',
      expected =>
      {
       latex => "\\texttt{fixedwidth text}\n\n",
       html  => "<tt>fixedwidth text</tt>\n\n",
       xml   => "<tt>fixedwidth text</tt>\n\n",
      },
     },

     {
      name    => 'superscript',
      content => '^^superscripted text^^',
      expected =>
      {
       latex => "\\textsuperscript{superscripted text}\n\n",
       html  => "<sup>superscripted text</sup>\n\n",
       xml   => "<sup>superscripted text</sup>\n\n",
      },
     },

     {
      name    => 'subscript',
      content => ',,subscripted text,,',
      expected =>
      {
       latex => "\\subscript{subscripted text}\n\n",
       html  => "<sub>subscripted text</sub>\n\n",
       xml   => "<sub>subscripted text</sub>\n\n",
      },
     },

     {
      name    => 'valid_bold_block',
      content => 'This is a valid !!bold!! block',
      expected =>
      {
       success => 'valid bold markup passes validation',
      },
     },

     {
      name    => 'invalid_bold_block',
      content => 'This is an INVALID !!bold block',
      expected =>
      {
       warning => 'INVALID BOLD MARKUP',
      },
     },

     {
      name    => 'valid_italics_block',
      content => 'This is a valid ~~italics~~ block',
      expected =>
      {
       success => 'valid italics markup passes validation',
      },
     },

     {
      name    => 'invalid_italics_block',
      content => 'This is an INVALID ~~italics block',
      expected =>
      {
       warning => 'INVALID ITALICS MARKUP',
      },
     },

     {
      name    => 'valid_fixedwidth_block',
      content => 'This is a valid ||fixed-width|| block',
      expected =>
      {
       success => 'valid fixed-width markup passes validation',
      },
     },

     {
      name    => 'invalid_fixedwidth_block',
      content => 'This is an INVALID ||fixed-width block',
      expected =>
      {
       warning => 'INVALID FIXED-WIDTH MARKUP',
      },
     },

     {
      name    => 'valid_underline_block',
      content => 'This is a valid __underline__ block',
      expected =>
      {
       success => 'valid underline markup passes validation',
      },
     },

     {
      name    => 'invalid_underline_block',
      content => 'This is an INVALID __underline block',
      expected =>
      {
       warning => 'INVALID UNDERLINE MARKUP',
      },
     },

     {
      name    => 'valid_superscript_block',
      content => 'This is a valid ^^superscript^^ block',
      expected =>
      {
       success => 'valid superscript markup passes validation',
      },
     },

     {
      name    => 'invalid_superscript_block',
      content => 'This is an INVALID ^^superscript block',
      expected =>
      {
       warning => 'INVALID SUPERSCRIPT MARKUP',
      },
     },

     {
      name    => 'valid_subscript_block',
      content => 'This is a valid ,,subscript,, block',
      expected =>
      {
       success => 'valid subscript markup passes validation',
      },
     },

     {
      name    => 'invalid_subscript_block',
      content => 'This is an INVALID ,,subscript block',
      expected =>
      {
       warning => 'INVALID SUBSCRIPT MARKUP',
      },
     },

     {
      name    => 'valid_cross_reference_1',
      content => 'Here is a valid cross reference: [ref:introduction].',
      expected =>
      {
       success => 'valid cross reference 1 passes validation',
      },
     },

     {
      name    => 'valid_cross_reference_2',
      content => 'Here is a valid cross reference: [r:introduction].',
      expected =>
      {
       success => 'valid cross reference 2 passes validation',
      },
     },

     {
      name    => 'invalid_cross_reference_1',
      content => 'Here is an INVALID cross reference: [ref:bogus].',
      expected =>
      {
       warning => 'INVALID CROSS REFERENCE',
      },
     },

     {
      name    => 'invalid_cross_reference_2',
      content => 'Here is an INVALID cross reference: [r:bogus].',
      expected =>
      {
       warning => 'INVALID CROSS REFERENCE',
      },
     },

     {
      name    => 'incomplete_cross_reference_1',
      content => 'Here is an incomplete cross reference: [ref:introduction.',
      expected =>
      {
       warning => 'INVALID CROSS REFERENCE SYNTAX',
      },
     },

     {
      name    => 'incomplete_cross_reference_2',
      content => 'Here is an incomplete cross reference: [r:introduction.',
      expected =>
      {
       warning => 'INVALID CROSS REFERENCE SYNTAX',
      },
     },

     {
      name    => 'valid_id_reference',
      content => 'Here is a valid id reference: [id:introduction].',
      expected =>
      {
       success => 'valid ID reference passes validation',
      },
     },

     {
      name    => 'invalid_id_reference',
      content => 'Here is an INVALID id reference: [id:bogus].',
      expected =>
      {
       warning => 'INVALID ID REFERENCE',
      },
     },

     {
      name    => 'incomplete_id_reference',
      content => 'Here is an incomplete id reference: [id:introduction.',
      expected =>
      {
       warning => 'INVALID ID REFERENCE SYNTAX',
      },
     },

     {
      name    => 'valid_page_reference_1',
      content => 'Here is a valid page reference: [page:introduction].',
      expected =>
      {
       success => 'valid page reference 1 passes validation',
      },
     },

     {
      name    => 'valid_page_reference_2',
      content => 'Here is a valid page reference: [pg:introduction].',
      expected =>
      {
       success => 'valid page reference 2 passes validation',
      },
     },

     {
      name    => 'invalid_page_reference_1',
      content => 'Here is an INVALID page reference: [page:bogus].',
      expected =>
      {
       warning => 'INVALID PAGE REFERENCE',
      },
     },

     {
      name    => 'invalid_page_reference_2',
      content => 'Here is an INVALID page reference: [pg:bogus].',
      expected =>
      {
       warning => 'INVALID PAGE REFERENCE',
      },
     },

     {
      name    => 'incomplete_page_reference_1',
      content => 'Here is an incomplete page reference: [page:introduction.',
      expected =>
      {
       warning => 'INVALID PAGE REFERENCE SYNTAX',
      },
     },

     {
      name    => 'incomplete_page_reference_2',
      content => 'Here is an incomplete page reference: [pg:introduction.',
      expected =>
      {
       warning => 'INVALID PAGE REFERENCE SYNTAX',
      },
     },

     {
      name    => 'invalid_glossary_term_reference_1',
      content => '[g:sml:bogus]',
      expected =>
      {
       warning => 'TERM NOT IN GLOSSARY',
      },
     },

     {
      name    => 'incomplete_glossary_term_reference_1',
      content => '[g:sml:bogus',
      expected =>
      {
       warning => 'INVALID GLOSSARY TERM REFERENCE SYNTAX',
      },
     },

     {
      name    => 'invalid_glossary_def_reference_1',
      content => '[def:sml:bogus]',
      expected =>
      {
       warning => 'DEFINITION NOT IN GLOSSARY',
      },
     },

     {
      name    => 'incomplete_glossary_def_reference_1',
      content => '[def:sml:bogus',
      expected =>
      {
       warning => 'INVALID GLOSSARY DEFINITION REFERENCE SYNTAX',
      },
     },

     {
      name    => 'invalid_acronym_reference_1',
      content => '[ac:sml:bogus]',
      expected =>
      {
       warning => 'ACRONYM NOT IN ACRONYM LIST',
      },
     },

     {
      name    => 'incomplete_acronym_reference_1',
      content => '[ac:sml:bogus',
      expected =>
      {
       warning => 'INVALID ACRONYM REFERENCE SYNTAX',
      },
     },

     {
      name    => 'invalid_source_citation_1',
      content => '[cite:bogus]',
      expected =>
      {
       warning => 'INVALID SOURCE CITATION',
      },
     },

     {
      name    => 'incomplete_source_citation_1',
      content => '[cite:bogus',
      expected =>
      {
       warning => 'INVALID SOURCE CITATION SYNTAX',
      },
     },

     {
      name     => 'get_name_path_test_1',
      testfile => 'td-000020.txt',
      config   => 'library.conf',
     },

    ];
}

######################################################################

sub _build_string_test_case_list {

  my $self = shift;

  return
    [
     {
      name     => 'plain_string_1',
      content  => 'This is a plain string.',
      expected =>
      {
       type    => 'part',
       name    => 'string',
       content => 'This is a plain string.',
       has_parts => 0,
       html =>
       {
	default => 'This is a plain string.',
       },
      },
     },

     {
      name     => 'bold_string_1',
      content  => '!!this is bold!!',
      expected =>
      {
       type    => 'part',
       name    => 'bold_string',
       content => 'this is bold',
       has_parts => 1,
       html =>
       {
	default => '<b>this is bold</b>',
       },
      },
     },

     {
      name     => 'italics_string_1',
      content  => '~~this is italics~~',
      expected =>
      {
       type    => 'part',
       name    => 'italics_string',
       content => 'this is italics',
       has_parts => 1,
       html =>
       {
	default => '<i>this is italics</i>',
       },
      },
     },

     {
      name     => 'fixed_width_string_1',
      content  => '||this is fixed width||',
      expected =>
      {
       type    => 'part',
       name    => 'fixedwidth_string',
       content => 'this is fixed width',
       has_parts => 1,
       html =>
       {
	default => '<tt>this is fixed width</tt>',
       },
      },
     },

     {
      name     => 'underline_string_1',
      content  => '__this is underlined__',
      expected =>
      {
       type    => 'part',
       name    => 'underline_string',
       content => 'this is underlined',
       has_parts => 1,
       html =>
       {
	default => '<u>this is underlined</u>',
       },
      },
     },

     {
      name     => 'superscript_string_1',
      content  => '^^this is superscripted^^',
      expected =>
      {
       type    => 'part',
       name    => 'superscript_string',
       content => 'this is superscripted',
       has_parts => 1,
       html =>
       {
	default => '<sup>this is superscripted</sup>',
       },
      },
     },

     {
      name     => 'subscript_string_1',
      content  => ',,this is subscripted,,',
      expected =>
      {
       type    => 'part',
       name    => 'subscript_string',
       content => 'this is subscripted',
       has_parts => 1,
       html =>
       {
	default => '<sub>this is subscripted</sub>',
       },
      },
     },

     {
      name     => 'linebreak_symbol_1',
      content  => '[linebreak]',
      expected =>
      {
       type    => 'part',
       name    => 'linebreak_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '<br/>',
       },
      },
     },

     {
      name     => 'user_entered_text_1',
      content  => '[enter:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'user_entered_text',
       content => 'bogus',
       has_parts => 0,
       html =>
       {
	default => '<b><tt>bogus</tt></b>',
       },
      },
     },

     {
      name     => 'user_entered_text_2',
      content  => '[en:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'user_entered_text',
       content => 'bogus',
       has_parts => 0,
       html =>
       {
	default => '<b><tt>bogus</tt></b>',
       },
      },
     },

     {
      name     => 'file_reference_1',
      content  => '[file:bogus.txt]',
      expected =>
      {
       type    => 'part',
       name    => 'file_ref',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '<tt>bogus.txt</tt>',
       },
      },
     },

     {
      name     => 'path_reference_1',
      content  => '[path:path/to/bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'path_ref',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '<tt>path/to/bogus</tt>',
       },
      },
     },

     {
      name     => 'url_reference_1',
      content  => '[url:http://www.google.com/]',
      expected =>
      {
       type    => 'part',
       name    => 'url_ref',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '<a href="http://www.google.com/">http://www.google.com/</a>',
       },
      },
     },

     {
      name     => 'url_reference_2',
      content  => '[url:http://www.google.com/|google]',
      expected =>
      {
       type    => 'part',
       name    => 'url_ref',
       content => 'google',
       has_parts => 0,
       html =>
       {
	default => '<a href="http://www.google.com/">google</a>',
       },
      },
     },

     {
      name     => 'command_reference_1',
      content  => '[cmd:ls -al | grep bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'command_ref',
       content => 'ls -al | grep bogus',
       has_parts => 0,
       html =>
       {
	default => '<tt>ls -al | grep bogus</tt>',
       },
      },
     },

     {
      name     => 'smiley_symbol_1',
      content  => ':-)',
      expected =>
      {
       type    => 'part',
       name    => 'smiley_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&#9786;',
       },
      },
     },

     {
      name     => 'frowny_symbol_1',
      content  => ':-(',
      expected =>
      {
       type    => 'part',
       name    => 'frowny_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&#9785;',
       },
      },
     },

     {
      name     => 'keystroke_symbol_1',
      content  => '[[ESC]]',
      expected =>
      {
       type    => 'part',
       name    => 'keystroke_symbol',
       content => 'ESC',
       has_parts => 1,
       html =>
       {
	default => '<span class="keystroke">ESC</span>',
       },
      },
     },

     {
      name     => 'left_arrow_symbol_1',
      content  => '<-',
      expected =>
      {
       type    => 'part',
       name    => 'left_arrow_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&#8592;',
       },
      },
     },

     {
      name     => 'right_arrow_symbol_1',
      content  => '->',
      expected =>
      {
       type    => 'part',
       name    => 'right_arrow_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&#8594;',
       },
      },
     },

     {
      name     => 'latex_symbol_1',
      content  => 'LaTeX',
      expected =>
      {
       type    => 'part',
       name    => 'latex_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => 'L<sup>a</sup>T<sub>e</sub>X',
       },
      },
     },

     {
      name     => 'tex_symbol_1',
      content  => 'TeX',
      expected =>
      {
       type    => 'part',
       name    => 'tex_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => 'T<sub>e</sub>X',
       },
      },
     },

     {
      name     => 'copyright_symbol_1',
      content  => '[c]',
      expected =>
      {
       type    => 'part',
       name    => 'copyright_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&copy;',
       },
      },
     },

     {
      name     => 'trademark_symbol_1',
      content  => '[tm]',
      expected =>
      {
       type    => 'part',
       name    => 'trademark_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&trade;',
       },
      },
     },

     {
      name     => 'registered_trademark_symbol_1',
      content  => '[rtm]',
      expected =>
      {
       type    => 'part',
       name    => 'reg_trademark_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&reg;',
       },
      },
     },

     {
      name     => 'open_dblquote_symbol_1',
      content  => '``',
      expected =>
      {
       type    => 'part',
       name    => 'open_dblquote_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&#8220;',
       },
      },
     },

     {
      name     => 'close_dblquote_symbol_1',
      content  => '\'\'',
      expected =>
      {
       type    => 'part',
       name    => 'close_dblquote_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&#8221;',
       },
      },
     },

     {
      name     => 'open_sglquote_symbol_1',
      content  => '`',
      expected =>
      {
       type    => 'part',
       name    => 'open_sglquote_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&#8216;',
       },
      },
     },

     {
      name     => 'close_sglquote_symbol_1',
      content  => '\'',
      expected =>
      {
       type    => 'part',
       name    => 'close_sglquote_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&#8217;',
       },
      },
     },

     {
      name     => 'section_symbol_1',
      content  => '[section]',
      expected =>
      {
       type    => 'part',
       name    => 'section_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&sect;',
       },
      },
     },

     {
      name     => 'emdash_symbol_1',
      content  => '--',
      expected =>
      {
       type    => 'part',
       name    => 'emdash_symbol',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '&mdash;',
       },
      },
     },

     {
      name     => 'email_address_1',
      content  => '[email:help@example.com]',
      expected =>
      {
       type    => 'part',
       name    => 'email_addr',
       content => '',
       has_parts => 0,
       html =>
       {
	default => '<a href="mailto:help@example.com">help@example.com</a>',
       },
      },
     },

     {
      name     => 'email_address_2',
      content  => '[email:john.smith@example.com|John Smith]',
      expected =>
      {
       type    => 'part',
       name    => 'email_addr',
       content => 'John Smith',
       has_parts => 0,
       html =>
       {
	default => '<a href="mailto:john.smith@example.com">John Smith</a>',
       },
      },
     },

     {
      name     => 'bold_inside_italics_1',
      content  => '~~this is !!bold!! inside italics~~',
      expected =>
      {
       type    => 'part',
       name    => 'italics_string',
       content => 'this is !!bold!! inside italics',
       has_parts => 3,
       html =>
       {
	default => '<i>this is <b>bold</b> inside italics</i>',
       },
      },
     },

     {
      name     => 'italics_inside_bold_1',
      content  => '!!this is ~~italics~~ inside bold!!',
      expected =>
      {
       type    => 'part',
       name    => 'bold_string',
       content => 'this is ~~italics~~ inside bold',
       has_parts => 3,
       html =>
       {
	default => '<b>this is <i>italics</i> inside bold</b>',
       },
      },
     },

     {
      name     => 'string_with_italics_and_bold_1',
      content  => 'this string has ~~italics~~ and !!bold!!',
      expected =>
      {
       type    => 'part',
       name    => 'string',
       content => 'this string has ~~italics~~ and !!bold!!',
       has_parts => 4,
       html =>
       {
	default => 'this string has <i>italics</i> and <b>bold</b>',
       },
      },
     },

     {
      name     => 'variable_reference_1',
      content  => '[var:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'variable_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'glossary_term_reference_1',
      content  => '[g:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'gloss_term_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'glossary_term_reference_2',
      content  => '[G:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'gloss_term_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'glossary_term_reference_3',
      content  => '[gls:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'gloss_term_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'glossary_term_reference_4',
      content  => '[Gls:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'gloss_term_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'glossary_definition_reference_1',
      content  => '[def:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'gloss_def_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'acronym_term_reference_1',
      content  => '[a:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'acronym_term_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'acronym_term_reference_2',
      content  => '[ac:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'acronym_term_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'acronym_term_reference_3',
      content  => '[acs:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'acronym_term_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'acronym_term_reference_4',
      content  => '[acl:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'acronym_term_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'cross_reference_1',
      content  => '[r:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'cross_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'cross_reference_2',
      content  => '[ref:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'cross_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'id_reference_1',
      content  => '[id:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'id_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'page_reference_1',
      content  => '[page:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'page_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'page_reference_2',
      content  => '[pg:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'page_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'footnote_reference_1',
      content  => '[f:introduction:1]',
      expected =>
      {
       type    => 'part',
       name    => 'footnote_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'index_reference_1',
      content  => '[index:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'index_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'index_reference_2',
      content  => '[i:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'index_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'thepage_symbol_1',
      content  => '[thepage]',
      expected =>
      {
       type    => 'part',
       name    => 'thepage_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'theversion_symbol_1',
      content  => '[theversion]',
      expected =>
      {
       type    => 'part',
       name    => 'theversion_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'therevision_symbol_1',
      content  => '[therevision]',
      expected =>
      {
       type    => 'part',
       name    => 'therevision_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'thedate_symbol_1',
      content  => '[thedate]',
      expected =>
      {
       type    => 'part',
       name    => 'thedate_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'status_reference_1',
      content  => '[status:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'status_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'citation_reference_1',
      content  => '[cite:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'citation_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'citation_reference_2',
      content  => '[c:bogus]',
      expected =>
      {
       type    => 'part',
       name    => 'citation_ref',
       content => '',
       has_parts => 0,
      },
     },

     {
      name     => 'take_note_symbol_1',
      content  => '[take_note]',
      expected =>
      {
       type    => 'part',
       name    => 'take_note_symbol',
       content => '',
       has_parts => 0,
      },
     },

    ];
}

######################################################################

sub _build_acronym_list_test_case_list {

  my $self = shift;

  return
    [
     {
      name        => 'acronym_1',
      content     => 'acronym:: TLA = Three Letter Acronym',
      acronym     => 'TLA',
      description => 'Three Letter Acronym',
      alt         => '',
      expected    =>
      {
       add_ok      => 1,
       has_ok      => 1,
       get_ok      => 1,
      },
     },

     {
      name        => 'acronym_2',
      content     => 'acronym:: FRD {tsa} = (TSA) Functional Requirements Document',
      acronym     => 'FRD',
      description => '(TSA) Functional Requirements Document',
      alt         => 'tsa',
      expected    =>
      {
       add_ok      => 1,
       has_ok      => 1,
       get_ok      => 1,
      }
     },
    ];
}

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

sub _build_parser_test_case_list {

  my $self = shift;

  return
    [
     {
      name     => 'simple_fragment',
      testfile => 'td-000001.txt',
      docid    => 'td-000001',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_comment_division',
      testfile => 'td-000002.txt',
      docid    => 'td-000002',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_comment_line',
      testfile => 'td-000003.txt',
      docid    => 'td-000003',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_conditional_division',
      testfile => 'td-000004.txt',
      docid    => 'td-000004',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_region_division',
      testfile => 'td-000005.txt',
      docid    => 'td-000005',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_environment_division',
      testfile => 'td-000006.txt',
      docid    => 'td-000006',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_lists',
      testfile => 'td-000007.txt',
      docid    => 'td-000007',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_generate_element',
      testfile => 'td-000008.txt',
      docid    => 'td-000008',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_insert_element',
      testfile => 'td-000009.txt',
      docid    => 'td-000009',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_script_element',
      testfile => 'td-000010.txt',
      docid    => 'td-000010',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_image_element',
      testfile => 'td-000011.txt',
      docid    => 'td-000011',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_footnote_element',
      testfile => 'td-000012.txt',
      docid    => 'td-000012',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_glossary_element',
      testfile => 'td-000013.txt',
      docid    => 'td-000013',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_var_element',
      testfile => 'td-000014.txt',
      docid    => 'td-000014',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_acronym_element',
      testfile => 'td-000015.txt',
      docid    => 'td-000015',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_index_element',
      testfile => 'td-000016.txt',
      docid    => 'td-000016',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_index_element',
      testfile => 'td-000017.txt',
      docid    => 'td-000017',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_included_section_style_1',
      testfile => 'td-000018.txt',
      docid    => 'td-000018',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_included_section_style_2',
      testfile => 'td-000019.txt',
      docid    => 'td-000019',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_sections_and_regions',
      testfile => 'td-000020.txt',
      docid    => 'td-000020',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_raw_include_element',
      testfile => 'td-000021.txt',
      docid    => 'td-000021',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_problem_division',
      testfile => 'td-000022.txt',
      expected =>
      {
       should_parse_ok => 1,
       divname  => 'problem',
       title    => 'Sample Problem For `Include\' Tests',
       preamble_size  => 17,
       narrative_size => 8,
      }
     },

     {
      name     => 'fragment_containing_included_entity',
      testfile => 'td-000023.txt',
      docid    => 'td-000023',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'single_paragraph',
      testfile => 'td-000024.txt',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_variable_substitutions',
      testfile => 'td-000025.txt',
      docid    => 'td-000025',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_glossary_term_reference_1',
      testfile => 'td-000026.txt',
      docid    => 'td-000026',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_source_citation',
      testfile => 'td-000028.txt',
      docid    => 'td-000028',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_source_citation',
      testfile => 'td-000029.txt',
      docid    => 'td-000029',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     # {
     #  name     => 'fragment_containing_invalid_begin_region',
     #  testfile => 'td-000030.txt',
     #  docid    => 'td-000030',
     #  expected =>
     #  {
     #   should_parse_ok => 0,
     #  },
     # },

     # {
     #  name     => 'fragment_containing_undefined_region',
     #  testfile => 'td-000031.txt',
     #  docid    => 'td-000031',
     #  expected =>
     #  {
     #   should_parse_ok => 0,
     #  },
     # },

     {
      name     => 'fragment_containing_cross_reference',
      testfile => 'td-000032.txt',
      docid    => 'td-000032',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_cross_reference',
      testfile => 'td-000033.txt',
      docid    => 'td-000033',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_id_reference',
      testfile => 'td-000034.txt',
      docid    => 'td-000034',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_id_reference',
      testfile => 'td-000035.txt',
      docid    => 'td-000035',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_page_reference',
      testfile => 'td-000036.txt',
      docid    => 'td-000036',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_page_reference',
      testfile => 'td-000037.txt',
      docid    => 'td-000037',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_bold_markup',
      testfile => 'td-000038.txt',
      docid    => 'td-000038',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_bold_markup',
      testfile => 'td-000039.txt',
      docid    => 'td-000039',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_italics_markup',
      testfile => 'td-000040.txt',
      docid    => 'td-000040',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_italics_markup',
      testfile => 'td-000041.txt',
      docid    => 'td-000041',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_fixedwidth_markup',
      testfile => 'td-000042.txt',
      docid    => 'td-000042',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_fixedwidth_markup',
      testfile => 'td-000043.txt',
      docid    => 'td-000043',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_underline_markup',
      testfile => 'td-000044.txt',
      docid    => 'td-000044',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_underline_markup',
      testfile => 'td-000045.txt',
      docid    => 'td-000045',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_superscript_markup',
      testfile => 'td-000046.txt',
      docid    => 'td-000046',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_superscript_markup',
      testfile => 'td-000047.txt',
      docid    => 'td-000047',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_subscript_markup',
      testfile => 'td-000048.txt',
      docid    => 'td-000048',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_subscript_markup',
      testfile => 'td-000049.txt',
      docid    => 'td-000049',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_glossary_term_syntax',
      testfile => 'td-000050.txt',
      docid    => 'td-000050',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_glossary_definition_reference',
      testfile => 'td-000051.txt',
      docid    => 'td-000051',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_glossary_definition_reference_syntax',
      testfile => 'td-000052.txt',
      docid    => 'td-000052',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_acronym_reference',
      testfile => 'td-000053.txt',
      docid    => 'td-000053',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_acronym_reference_syntax',
      testfile => 'td-000054.txt',
      docid    => 'td-000054',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_source_citation',
      testfile => 'td-000055.txt',
      docid    => 'td-000055',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_source_citation_syntax',
      testfile => 'td-000056.txt',
      docid    => 'td-000056',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_cross_reference_syntax',
      testfile => 'td-000057.txt',
      docid    => 'td-000057',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_id_reference_syntax',
      testfile => 'td-000058.txt',
      docid    => 'td-000058',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_page_reference_syntax',
      testfile => 'td-000059.txt',
      docid    => 'td-000059',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_template',
      testfile => 'td-000060.txt',
      docid    => 'td-000060',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_default_includes',
      testfile => 'td-000061.txt',
      docid    => 'td-000061',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_source_references',
      testfile => 'td-000062.txt',
      docid    => 'td-000062',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_explicit_declaration_of_infer_only_property',
      testfile => 'td-000063.txt',
      docid    => 'td-000063',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_entity_with_missing_required_property',
      testfile => 'td-000064.txt',
      docid    => 'td-000064',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_file_element',
      testfile => 'td-000065.txt',
      docid    => 'td-000065',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_reference_to_missing_file',
      testfile => 'td-000066.txt',
      docid    => 'td-000066',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_image_element',
      testfile => 'td-000067.txt',
      docid    => 'td-000067',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_reference_to_missing_image_file',
      testfile => 'td-000068.txt',
      docid    => 'td-000068',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_block_content',
      testfile => 'td-000069.txt',
      docid    => 'td-000069',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_invalid_non_unique_id',
      testfile => 'td-000070.txt',
      docid    => 'td-000070',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_baretable',
      testfile => 'td-000071.txt',
      docid    => 'td-000071',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_many_block_and_string_samples',
      testfile => 'td-000072.txt',
      docid    => 'td-000072',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_include_from_subdir',
      testfile => 'td-000073.txt',
      docid    => 'td-000073',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_divisions_for_extraction',
      testfile => 'td-000074.txt',
      docid    => 'td-000074',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_listing_environment',
      testfile => 'td-000075.txt',
      expected =>
      {
       should_parse_ok => 1,
       divname  => 'LISTING',
       title    => 'Sample Listing',
       preamble_size  => 5,
       narrative_size => 32,
      }
     },

     {
      name     => 'fragment_containing_section',
      testfile => 'td-000076.txt',
      expected =>
      {
       should_parse_ok => 1,
       divname  => 'SECTION',
       title    => 'Section Fragment',
       preamble_size  => 1,
      }
     },

     {
      name     => 'fragment_containing_glossary_term_reference_2',
      testfile => 'td-000077.txt',
      docid    => 'td-000077',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

     {
      name     => 'fragment_containing_title_with_linebreak',
      testfile => 'td-000078.txt',
      docid    => 'td-000078',
      expected =>
      {
       should_parse_ok => 1,
      },
     },

    ];
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;
