use Log::Log4perl;
Log::Log4perl->init("../conf/log.conf");

use lib "../../lib";

use SML::Library;

my $begin = localtime();
print "PUBLISH BEGIN: $begin\n\n";

my $library = SML::Library->new(config_filename=>'library.conf');

$library->get_all_entities;

$library->publish('sml',    'html','default');
$library->publish('frd-sml','html','default');
$library->publish('sdd-sml','html','default');
$library->publish('ted-sml','html','default');

$library->publish_library_pages;
$library->publish_index;

my $end = localtime();
print "PUBLISH BEGIN: $begin\n";
print "PUBLISH END:   $end\n\n";

1;
