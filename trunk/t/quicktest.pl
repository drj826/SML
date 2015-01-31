#!/usr/bin/perl

# $Id: quicktest.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use SML;
use SML::File;
use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

my $list =
  [
   'td-000001.txt',
   'td-000002.txt',
   'td-000003.txt',
   'td-000004.txt',
   'td-000005.txt',
   'td-000006.txt',
   'td-000007.txt',
   'td-000008.txt',
   'td-000009.txt',
   'td-000010.txt',
   'td-000011.txt',
   'td-000012.txt',
   'td-000013.txt',
   'td-000014.txt',
   'td-000015.txt',
   'td-000016.txt',
   'td-000017.txt',
   'td-000018.txt',
   'td-000019.txt',
   'td-000020.txt',
   'td-000021.txt',
   'td-000022.txt',
   'td-000023.txt',
   'td-000024.txt',
   'td-000025.txt',
   'td-000026.txt',
   'td-000027.txt',
   'td-000028.txt',
   'td-000029.txt',
   # 'td-000030.txt',
   # 'td-000031.txt',
   'td-000032.txt',
   'td-000033.txt',
   'td-000034.txt',
   'td-000035.txt',
   'td-000036.txt',
   'td-000037.txt',
   'td-000038.txt',
   'td-000039.txt',
   'td-000040.txt',
   'td-000041.txt',
   'td-000042.txt',
   'td-000043.txt',
   'td-000044.txt',
   'td-000045.txt',
   'td-000046.txt',
   'td-000047.txt',
   'td-000048.txt',
   'td-000049.txt',
   'td-000050.txt',
   'td-000051.txt',
   'td-000052.txt',
   'td-000053.txt',
   'td-000054.txt',
   'td-000055.txt',
   'td-000056.txt',
   'td-000057.txt',
   'td-000058.txt',
   'td-000059.txt',
   'td-000060.txt',
   'td-000061.txt',
   'td-000062.txt',
   'td-000063.txt',
   'td-000064.txt',
   'td-000065.txt',
   'td-000066.txt',
   'td-000067.txt',
   'td-000068.txt',
   'td-000069.txt',
   'td-000070.txt',
   'td-000071.txt',
   'td-000072.txt',
   'td-000073.txt',
   'td-000074.txt',
   'td-000075.txt',
   'td-000076.txt',
   'td-000077.txt',
  ];

foreach my $thing (@{$list})
  {
    do_stuff($thing);
  }

######################################################################

sub do_stuff {

  my $thing = shift;

  print "============================================================\n";
  print "$thing\n";

  my $library = SML::Library->new(config_filename=>'library.conf');
  my $parser  = $library->get_parser;

  $parser->parse($thing);

  print $library->summarize_content;
}

######################################################################

1;
