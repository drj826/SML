#!/usr/bin/perl

use lib "..";
use SML::Library;
use File::Basename;
use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

my $filespec    = shift;

# ASSUME: document ID is the filename without the file extension
#
my $filename    = basename($filespec);
my @part        = split(/\./,$filename);
my $extension   = pop @part;
my $id          = join('.', @part);

my $config_filename = 'library.conf';
my $library         = SML::Library->new(config_filename=>$config_filename);
my $parser          = $library->get_parser;
my $fragment        = $parser->parse($filespec);

$fragment->validate;

print $fragment->as_sml;

# my $document    = $library->get_document($id);
# print $document->as_sml;

# print $library->summarize_content;
