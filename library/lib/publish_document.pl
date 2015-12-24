use Log::Log4perl;
Log::Log4perl->init("../conf/log.conf");

use lib "../../lib";

use SML::Library;

my $document_id = shift;

my $library = SML::Library->new(config_filename=>'library.conf');

$library->publish($document_id,'html','default');

1;
