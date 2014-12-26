#!/usr/bin/perl

######################################################################
#
# generate_library_catalog.pl
#
#     Generate a library catalog file for the Vetting Operations
#     Engineering Library.
#
######################################################################

use lib "../../../publish";

use Log::Log4perl;
Log::Log4perl->init("gen-lib-cat-log.conf");
my $logger = Log::Log4perl::get_logger('gen-lib-cat');

use Config::General;
my $config_file = "generate_library_catalog.conf";
if ( not -f $config_file )
  {
    die "Couldn't read $config_file\n";
  }
else
  {
    $config = new Config::General($config_file);
    %config = $config->getall;
  }

my $library_dir  = $config{'library_dir'};
my $fragment_dir = $config{'fragment_dir'};
my $auto_dir     = $config{'auto_dir'};
my $id           = $config{'library_id'};
my $title        = $config{'library_title'};
my $catalog_file = $config{'catalog_file'};

my $entity_type_directories =
  [
   'allocations',
   'assignments',
   'problems',
   'results',
   'roles',
   'solutions',
   'tasks',
   'tests',
  ];

$logger->info("generating $library_dir/$catalog_file");

open FILE, ">$library_dir/$catalog_file"
  or die "Couldn't open file: $!";

#---------------------------------------------------------------------
# begin catalog file
#
print FILE <<"END_OF_TEXT";
>>>LIBRARY

title:: $title

id:: $id

author:: \$Author: \$

date:: \$Date: \$

revision:: \$Revision: \$

END_OF_TEXT

#---------------------------------------------------------------------
# list document files
#
$logger->info("listing document files...");
opendir(LIBRARY,"$library_dir")
  or die "Can't open dir: $!";

while (defined(my $file = readdir(LIBRARY)))
  {
    if ( $file =~ /^.*.txt$/ ) {

      next if $file eq 'catalog.txt';
      next if $file eq 'README.txt';

      print FILE "document_file:: $file\n";
    }
  }

print FILE "\n";
closedir LIBRARY;

#---------------------------------------------------------------------
# list fragment files
#
$logger->info("listing fragment files...");
opendir(FRAGMENTS,"$library_dir/$fragment_dir")
  or die "Can't open dir: $!";

while (defined(my $file = readdir(FRAGMENTS)))
  {
    if ( $file =~ /^.*.txt$/ ) {
      print FILE "fragment_file:: incl/$file\n";
    }
  }

print FILE "\n";
closedir FRAGMENTS;


#---------------------------------------------------------------------
# list auto files
#
$logger->info("listing auto files...");
opendir(AUTO,"$library_dir/$auto_dir")
  or die "Can't open dir: $!";

while (defined(my $file = readdir(AUTO)))
  {
    if ( $file =~ /^.*.txt$/ ) {
      print FILE "fragment_file:: auto/$file\n";
    }
  }

print FILE "\n";
closedir AUTO;


#---------------------------------------------------------------------
# list entity files
#
for my $dir (@{ $entity_type_directories })
  {
    $logger->info("listing entity files from $dir...");
    next if not -d "$library_dir/$dir";
    opendir(DIR,"$library_dir/$dir")
      or die "Can't open dir: $!";

    while (defined(my $file = readdir(DIR)))
      {
	if ( $file =~ /^.*.txt$/ ) {

	  next if $file =~ /template.txt$/;
	  next if $file eq 'README.txt';

	  print FILE "entity_file:: $dir/$file\n";
	}
      }

    print FILE "\n";
    closedir DIR;
  }

#---------------------------------------------------------------------
# end catalog file
#
print FILE <<"END_OF_TEXT";
<<<LIBRARY
END_OF_TEXT

close FILE;

######################################################################
