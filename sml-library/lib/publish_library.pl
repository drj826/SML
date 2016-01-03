use Log::Log4perl;
Log::Log4perl->init("../conf/log.conf");

use lib "../../lib";

use SML::Library;

my $library = SML::Library->new(config_filename=>'library.conf');

$library->get_all_entities;

$library->publish('sml-ug', 'html','default');
$library->publish('sml-frd','html','default');
$library->publish('sml-sdd','html','default');
$library->publish('sml-ted','html','default');

$library->publish_library_pages;
$library->publish_index;

1;
