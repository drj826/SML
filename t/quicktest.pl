use Log::Log4perl;
Log::Log4perl->init("log.test.conf");
my $logger = Log::Log4perl::get_logger('sml.application');

use lib "../lib";

use SML::Library;

my $library = SML::Library->new(config_filename=>'test-library-1.conf');

my $document = $library->get_document('td-000097');

my $structure = $document->dump_part_structure;

$logger->info("STRUCTURE:\n",$structure,"\n");

my $text = $document->render('sml','default');

$logger->info("SML:\n",$text,"\n");

1;
