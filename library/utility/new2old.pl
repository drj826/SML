#!/usr/bin/perl

# new2old.pl - Convert library in SML v2 format to SML v1 format.

use lib "../../../";
use SML::Util;
use SML::Library;
use SML::File;

my $util       = SML::Util->new;
my $lib_config = '../library.conf';
my $library    = SML::Library->new(config_filespec=>$lib_config);
my $lib_path   = $library->get_directory_path;

$util->walk_directory($lib_path, \&convert);

######################################################################

sub convert {

  my $filespec = shift;

  return if $filespec =~ /\/app/;
  return if $filespec =~ /\/.svn/;
  return if $filespec !~ /.txt$/;

  my $file        = SML::File->new(filespec=>$filespec);
  my $filename    = $file->get_filename;
  my $directories = $file->get_directories;
  my $path        = $file->get_path;

  # Remove DOCUMENT markers (only if the text file is in the top level
  # library directory)
  if ( $directories eq "$lib_path/" )
    {
      remove_document_markers($file);
    }

  # Downcase reserved words.
  downcase_reserved_words($file);

  # Update file references to be relative to document file.

  return 1;
}

######################################################################

sub remove_document_markers {

  my $file         = shift;
  my $filespec     = $file->get_filespec;
  my $oldlines     = $file->get_lines;
  my $newlines     = [];
  my $begin_marker = '>>>DOCUMENT';
  my $end_marker   = '<<<DOCUMENT';

  foreach my $line (@{ $oldlines })
    {
      if ($line =~ /^$begin_marker/)
	{
	  next;
	}

      elsif ($line =~ /^$end_marker/)
	{
	  next;
	}

      else
	{
	  push @{ $newlines }, $line;
	}
    }

  write_lines($filespec,$newlines);

  print "removed DOCUMENT markers from $filespec\n";

  return 1;
}

######################################################################

sub downcase_reserved_words {

  my $file         = shift;
  my $filespec     = $file->get_filespec;
  my $oldlines     = $file->get_lines;
  my $newlines     = [];
  my $change_count = 0;

  my $reserved_conditional_keywords =
    [
     'CONDITIONAL',
    ];

  my $reserved_comment_keywords =
    [
     'COMMENT',
    ];

  my $reserved_region_keywords =
    [
     'DEMO',
     'EXERCISE',
     'QUOTATION',
     'SLIDE',
     'KEYPOINTS',
     # 'RESOURCES',
    ];

  my $reserved_environment_keywords =
    [
     'HEADER',
     'FOOTER',
     'ATTACHMENT',
     'REVISIONS',
     'EPIGRAPH',
     'FIGURE',
     'PREFORMATTED',
     'SIDEBAR',
     'LISTING',
     'SOURCE',
     'TABLE',
     'TABLEROW',
     'TABLECELL',
     'BARETABLE',
     'AUDIO',
     'VIDEO',
     'ASSERTION',
    ];

  foreach my $line (@{ $oldlines })
    {
      foreach my $keyword (@{ $reserved_conditional_keywords })
	{
	  my $lc_keyword = lc($keyword);

	  if ($line =~ /^(\?){3,}$keyword/)
	    {
	      $line =~ s/^((\?){3,})$keyword/$1$lc_keyword/;
	      ++$change_count;
	    }
	}

      foreach my $keyword (@{ $reserved_comment_keywords })
	{
	  my $lc_keyword = lc($keyword);

	  if ($line =~ /^(#){3,}$keyword/)
	    {
	      $line =~ s/^((#){3,})$keyword/$1$lc_keyword/;
	      ++$change_count;
	    }
	}

      foreach my $keyword (@{ $reserved_region_keywords })
	{
	  my $lc_keyword = lc($keyword);

	  if ($line =~ /^(>){3,}$keyword/)
	    {
	      $line =~ s/^((>){3,})$keyword/$1$lc_keyword/;
	      ++$change_count;
	    }

	  elsif ($line =~ /^(<){3,}$keyword/)
	    {
	      $line =~ s/^((<){3,})$keyword/$1$lc_keyword/;
	      ++$change_count;
	    }
	}

      foreach my $keyword (@{ $reserved_environment_keywords })
	{
	  my $lc_keyword = lc($keyword);

	  if ($line =~ /^(-){3,}$keyword/)
	    {
	      $line =~ s/^((-){3,})$keyword/$1$lc_keyword/;
	      ++$change_count;
	    }
	}

      push @{ $newlines }, $line;
    }

  write_lines($filespec,$newlines);

  if ($change_count)
    {
      print "downcased $change_count reserved keywords in $filespec\n";
    }

  return 1;
}

######################################################################

sub write_lines {

  my $filespec = shift;
  my $lines    = shift;

  open my $fh, ">", $filespec or die "Couldn't open $filespec";
  foreach my $line (@{ $lines })
    {
      print $fh $line;
    }
  close $fh;

  return 1;
}

######################################################################
