#!/usr/bin/perl

# $Id: Document.t 15151 2013-07-08 21:01:16Z don.johnson $

# Document.pm (ci-000005) unit tests

use lib "..";
use Test::More tests => 6;
use Test::Exception;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

use Test::Log4perl;
my $t1logger = Test::Log4perl->get_logger('sml.document');

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $testdata =
  {

   invalid_non_unique_id =>
   {
    testfile  => 'library/testdata/td-000070.txt',
    docid     => 'td-000070',
    warning_1 => 'INVALID NON-UNIQUE ID',
    warning_2 => 'THE DOCUMENT IS NOT VALID',
   },

  };

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Document;
  use_ok( 'SML::Document' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Document->new(id=>'doc');
isa_ok( $obj, 'SML::Document' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'is_valid',

   'get_name',
   'get_author',
   'get_date',
   'get_revision',
   'get_acronym_definition',
   'get_note',
   'get_index_term',
   'get_html_outfile_for',
   'get_html_status_icon',
   'get_latex_status_icon',
   'get_lookup_hash',
   'get_section_list',
   'get_note_hash',
   'get_outcome_hash',
   'get_review_hash',
   'get_define_hash',
   'get_source_hash',
   'get_previous_hash',
   'get_index_hash',
   'get_table_data_hash',
   'get_baretable_data_hash',
   'get_html_glossary_filename',
   'get_html_acronyms_filename',
   'get_html_sources_filename',
   'get_glossary',
   'get_acronym_list',
   'get_references',

   'has_note',
   'has_index_term',
   'has_glossary_term',
   'has_acronym',
   'has_source',

   'add_note',
   'add_index_term',

   'validate',
   'validate_id_uniqueness',

   'as_latex',
   'as_csv',
   'as_xml',
   'start_html',
   'end_html',
   'replace_division_id',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed attributes?
#---------------------------------------------------------------------

my @attributes =
  (
   'subtitle',
   'description',
   'editor',
   'translator',
   'publisher',
   'publisher_location',
   'publisher_logo',
   'publisher_address',
   'edition',
   'biographical_note',
   'copyright',
   'full_copyright',
   'publication_year',
   'isbn',
   'issn',
   'cip_data',
   'permissions',
   'grants',
   'paper_durability',
   'dedication',
   'epigraph',
   'epigraph_source',
   'doctype',
   'fontsize',
   'organization',
   'version',
   'classification',
   'classified_by',
   'classif_reason',
   'declassify_on',
   'handling_caveat',
   'priority',
   'status',
   'attr',
   'use_formal_status',
   'effort_units',
   'var',
   'logo_image_left',
   'logo_image_center',
   'logo_image_right',
   'header_left',
   'header_left_odd',
   'header_left_even',
   'header_center',
   'header_center_odd',
   'header_center_even',
   'header_right',
   'header_right_odd',
   'header_right_even',
   'footer_left',
   'footer_left_odd',
   'footer_left_even',
   'footer_center',
   'footer_center_odd',
   'footer_center_even',
   'footer_right',
   'footer_right_odd',
   'footer_right_even',
   'DEFAULT_RENDITION',
   'MAX_SEC_DEPTH',
   'MAX_ID_HIERARCHY_DEPTH',
   'MAX_PASS_TWO_ITERATIONS',
   'pass_two_count',
   'using_longtable',
   'using_supertabular',
   'get_text_line_list',
  );

can_ok( $obj, @attributes );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
   '_build_glossary',
   '_build_acronym_list',
   '_build_references',
   '_build_html_glossary_filename',
   '_build_html_acronyms_filename',
   '_build_html_sources_filename',
   '_render_html_navigation_pane',
   '_render_html_title_page',
   '_render_html_table_of_contents',
   '_render_html_list_of_revisions',
   '_render_html_list_of_recent_updates',
   '_render_html_list_of_slides',
   '_render_html_list_of_sidebars',
   '_render_html_list_of_quotations',
   '_render_html_list_of_demonstrations',
   '_render_html_list_of_exercises',
   '_render_html_list_of_listings',
   '_render_html_list_of_to_do_items',
   '_render_html_list_of_tables',
   '_render_html_list_of_figures',
   '_render_html_list_of_attachments',
   '_render_html_list_of_footnotes',
   '_render_html_glossary',
   '_render_html_list_of_acronyms',
   '_render_html_changelog',
   '_render_html_list_of_references',
   '_render_html_index',
   '_render_html_document_section',
   '_render_html_copyright_page',
  );

can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

warning_ok( 'invalid_non_unique_id' );

######################################################################

sub warning_ok {

  my $testid = shift;

  my $testfile  = $testdata->{$testid}{testfile};
  my $docid     = $testdata->{$testid}{docid};
  my $warning_1 = $testdata->{$testid}{warning_1};
  my $warning_2 = $testdata->{$testid}{warning_2};

  my $config    = 'library.conf';
  my $library   = SML::Library->new(config_filename=>$config);
  my $parser    = $library->get_parser;

  my $t1logger  = Test::Log4perl->get_logger('sml.document');

  Test::Log4perl->start( ignore_priority => "info" );
  $t1logger->warn(qr/$warning_1/);
  $t1logger->warn(qr/$warning_2/);

  my $fragment = $parser->parse($testfile);
  my $document = $library->get_document($docid);

  # act
  $document->validate;

  # assert
  Test::Log4perl->end("WARNING: $warning_1 ($testid)");

}

######################################################################
