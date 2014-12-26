#!/usr/bin/perl

######################################################################
#
#     replace-string.pl
#
#     $Id: replace-string.pl 15137 2013-07-07 15:33:50Z don.johnson $
#
#---------------------------------------------------------------------
# USAGE
#
#     perl replace-string.pl <old> <new>
#
#---------------------------------------------------------------------
# DESCRIPTION
#
#     This script replaces an old string with a new string globally.
#
######################################################################

use File::Find;
use File::Slurp;

my $old = shift; # old string
my $new = shift; # new string

my @directories =
  (
   '../../allocations/',
   '../../files/',
   '../../incl/',
   '../../problems/',
   '../../results/',
   '../../roles/',
   '../../solutions/',
   '../../tasks/',
   '../../tests/',
  );

die "Specify old and new strings please." if not $old or not $new;

find(\&replace, @directories);

######################################################################

sub replace {

  my $file = $_;
  next if not $file =~ /(.txt|.csv)$/;
  my $text = read_file($file);

  if ($text =~ s/$old/$new/g) {
    print "replaced $old with $new in $file\n";
    write_file($file,$text);
  }

}

######################################################################
