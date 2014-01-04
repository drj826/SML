#!/usr/bin/perl

# old2new.pl - Convert library in SML v1 format to SML v2 format.

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

  # Add DOCUMENT markers (only if the text file is in the top level
  # library directory)
  if ( $directories eq "$lib_path/" )
    {
      add_document_markers($file);
    }

  # Upcase reserved words.
  upcase_reserved_words($file);

  # Update file references to be relative to containing file.

  return 1;
}

######################################################################

sub add_document_markers {

  my $file         = shift;
  my $filespec     = $file->get_filespec;
  my $oldlines     = $file->get_lines;
  my $newlines     = [];
  my $begin_marker = '>>>DOCUMENT';
  my $end_marker   = '<<<DOCUMENT';
  my $closed       = 0;

  push @{ $newlines }, "$begin_marker\n";

  foreach my $line (@{ $oldlines })
    {
      if ($line =~ /^>>>RESOURCES/)
	{
	  push @{ $newlines }, "$end_marker\n";
	  $closed = 1;
	}

      push @{ $newlines }, $line;
    }

  if (not $closed)
    {
      push @{ $newlines }, "$end_marker\n";
    }

  write_lines($filespec,$newlines);

  print "added DOCUMENT markers to $filespec\n";

  return 1;
}

######################################################################

sub upcase_reserved_words {

  my $file         = shift;
  my $filespec     = $file->get_filespec;
  my $oldlines     = $file->get_lines;
  my $newlines     = [];
  my $change_count = 0;

  my $reserved_conditional_keywords =
    [
     'conditional',
    ];

  my $reserved_comment_keywords =
    [
     'comment',
    ];

  my $reserved_region_keywords =
    [
     'demo',
     'exercise',
     'quotation',
     'slide',
     'keypoints',
     'resources',
    ];

  my $reserved_environment_keywords =
    [
     'header',
     'footer',
     'attachment',
     'revisions',
     'epigraph',
     'figure',
     'preformatted',
     'sidebar',
     'listing',
     'source',
     'table',
     'tablerow',
     'tablecell',
     'baretable',
     'audio',
     'video',
     'assertion',
    ];

  foreach my $line (@{ $oldlines })
    {
      foreach my $keyword (@{ $reserved_conditional_keywords })
	{
	  my $uc_keyword = uc($keyword);

	  if ($line =~ /^(\?){3,}$keyword/)
	    {
	      $line =~ s/^((\?){3,})$keyword/$1$uc_keyword/;
	      ++$change_count;
	    }
	}

      foreach my $keyword (@{ $reserved_comment_keywords })
	{
	  my $uc_keyword = uc($keyword);

	  if ($line =~ /^(#){3,}$keyword/)
	    {
	      $line =~ s/^((#){3,})$keyword/$1$uc_keyword/;
	      ++$change_count;
	    }
	}

      foreach my $keyword (@{ $reserved_region_keywords })
	{
	  my $uc_keyword = uc($keyword);

	  if ($line =~ /^(>){3,}$keyword/)
	    {
	      $line =~ s/^((>){3,})$keyword/$1$uc_keyword/;
	      ++$change_count;
	    }

	  elsif ($line =~ /^(<){3,}$keyword/)
	    {
	      $line =~ s/^((<){3,})$keyword/$1$uc_keyword/;
	      ++$change_count;
	    }
	}

      foreach my $keyword (@{ $reserved_environment_keywords })
	{
	  my $uc_keyword = uc($keyword);

	  if ($line =~ /^(-){3,}$keyword/)
	    {
	      $line =~ s/^((-){3,})$keyword/$1$uc_keyword/;
	      ++$change_count;
	    }
	}

      push @{ $newlines }, $line;
    }

  write_lines($filespec,$newlines);

  if ($change_count)
    {
      print "upcased $change_count reserved keywords in $filespec\n";
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
