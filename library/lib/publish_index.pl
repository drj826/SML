use Log::Log4perl;
Log::Log4perl->init("../conf/log.conf");

use lib "../../lib";

use SML::Library;

my $library = SML::Library->new(config_filename=>'library.conf');

$library->publish_index;

1;
