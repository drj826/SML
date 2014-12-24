#!/usr/bin/perl

# build_release.pl

# $Id: build-release.pl 7442 2012-04-20 13:00:45Z don.johnson $

my $svn        = "../../../svn/svn.exe";
my $comment    = "[SML-build] Automatic updates to inline revision numbers of included files";
my $buildstart = localtime();

publish_all_documents();

while ( modified_files_exist() ) {
  commit_updates();
  publish_all_documents();
}

my $buildend = localtime();

print "BUILD START: $buildstart\n";
print "BUILD END:   $buildend\n";

######################################################################

sub publish_all_documents {

  my $starttime = localtime();

  print "PUBLISH ALL START: $starttime\n";

  print "Updating working copy from SVN repository...\n";
  chdir("..");
  system("$svn update");
  chdir("scripts-publish");

  print "Publishing all documents...\n";
  system("publish-all-documents.bat");

  my $endtime = localtime();

  print "PUBLISH ALL START: $starttime\n";
  print "PUBLISH ALL END:   $endtime\n";
}

######################################################################

sub commit_updates {

  print "Committing modified files...\n";
  chdir("..");
  system("$svn commit -m \"$comment\"");
  chdir("scripts-publish");

}

######################################################################

sub modified_files_exist {

  # Return 1 if modified files exist, otherwise return 0. Modified
  # files exist if ANY line of output from the 'svn status' command
  # begins with an 'M'.

  chdir("..");
  my $output = `$svn status`;
  my @output = split(/\n/,$output);
  foreach my $line (@output) {
    if ( $line =~ /^M/ ) {
      chdir("scripts-publish");
      print "There are modified files to be committed...\n";
      return 1;
    }
  }
  chdir("scripts-publish");
  print "There are no modified files.\n";
  return 0;

}

######################################################################
