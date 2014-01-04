#!/usr/bin/perl

######################################################################
#
#  include_related.pl
#
#     $Id: include_related.pl 15143 2013-07-07 17:39:45Z don.johnson $
#
#---------------------------------------------------------------------
# USAGE (execution)
#
#     perl include_related.pl --problems    -- my-document.txt
#     perl include_related.pl --solutions   -- my-document.txt
#     perl include_related.pl --tests       -- my-document.txt
#     perl include_related.pl --results     -- my-document.txt
#     perl include_related.pl --tasks       -- my-document.txt
#     perl include_related.pl --roles       -- my-document.txt
#     perl include_related.pl --allocations -- my-document.txt
#     perl include_related.pl --assignments -- my-document.txt
#
#---------------------------------------------------------------------
# USAGE (in SML document)
#
#     script: perl include_related.pl --problems -- my-document.txt
#
#---------------------------------------------------------------------
# OPTIONS
#
#     --all         - include all entities in library (default)
#
#     --file <file> - include entities related to <file>
#
#     --hide        - hide included files
#
#     --flat        - no section hierarchy (default)
#
#     --tree        - arrange items in section hierarchy
#
#     --entity <id> - use <id> as top node of hierarchy (implies --all)
#
#     --depth       - number of levels to represent in the section hierarchy
#
#     --problems    - emit include statements for problems
#
#     --solutions   - emit include statements for solutions
#
#     --tests       - emit include statements for tests
#
#     --results     - emit include statements for results
#
#     --tasks       - emit include statements for tasks
#
#     --roles       - emit include statements for roles
#
#     --allocations - emit include statements for allocations
#
#     --assignments - emit include statements for assignments
#
#---------------------------------------------------------------------
# DESCRIPTION
#
#     This script produces "include" statements for all related items
#     of a given type for a specified document.  It recursively
#     ferrets out *all* related items even if they are many
#     generations removed from the initial document.
#
#     This script ignores items mentioned within comments, hidden
#     divisions, and revision log entries.
#
#     This script saves authors the trouble of manually determining
#     all the related items and manually adding include statements to
#     their document.
#
#     This script is unique to the Vetting Operations Engineering
#     Library of SML documents.
#
#     This script assumes that:
#
#     1. Each item is stored in a separate file in a directory named
#        for the item type (Problems, Solutions, Tests, Results,
#        Tasks, Roles) and that the file name matches the file label
#        (plus a .txt filename extension)
#
#     2. This script assumes labels adhere to the following syntax:
#
#        rq-nnnnnn => requirement         => problem
#        uc-nnnnnn => use case            => problem
#
#        ba-nnnnnn => baseline            => solution
#        ci-nnnnnn => configuration item  => solution
#        do-nnnnnn => document            => solution
#        pt-nnnnnn => part                => solution
#
#        tc-nnnnnn => test case           => test
#        td-nnnnnn => test data           => test
#
#        ca-nnnnnn => CM audit result     => result
#        qr-nnnnnn => QA audit result     => result
#        rr-nnnnnn => req review result   => result
#        tr-nnnnnn => test result         => result
#        ts-nnnnnn => task status         => result
#
#        ta-nnnnnn => task                => task
#
#        ro-nnnnnn => role                => role
#
#        al-nnnnnn => allocation          => allocation
#
#        as-nnnnnn => assignment          => assignment
#
######################################################################

use strict;
use Getopt::Long      qw(:config no_ignore_case);

my @to_be_read = ();     # files to be read
my %read       = ();     # files read
my %include    = ();     # items to include
my %order      = ();     # order of items in document
my $i          = 0;      # count number of items
my %opt        = ();     # command-line options

my %title      = ();     # 'title'  data structure
my %parent     = ();     # 'parent' data structure
my %parts      = ();     # 'parts'  data structure

# Get command line options
#
GetOptions (

    "all"         => \$opt{'all'},
    "file=s"      => \$opt{'file'},

    "hide"        => \$opt{'hide'},

    "flat"        => \$opt{'flat'},
    "tree"        => \$opt{'tree'},
    "entity=s"    => \$opt{'entity'},
    "depth=i"     => \$opt{'depth'},

    "problems"    => \$opt{'problem'},
    "solutions"   => \$opt{'solution'},
    "tests"       => \$opt{'test'},
    "results"     => \$opt{'result'},
    "tasks"       => \$opt{'task'},
    "roles"       => \$opt{'role'},
    "allocations" => \$opt{'allocation'},
    "assignments" => \$opt{'assignment'},

);

my $max_depth = $opt{'depth'} || 6;   # maximum section depth

#---------------------------------------------------------------------
# file
#
if ( $opt{'file'} ) {

  my $file = $opt{'file'};

  if (-r $file) {
    push @to_be_read, $file;
  } else {
    die "$file not readable";
  }

}

#---------------------------------------------------------------------
# all
#
elsif ( $opt{'all'} ) {

  if ($opt{'problem'}) {
    opendir(PROBLEMS,"Problems") or die "can't opendir Problems: $!";
    while (defined(my $file = readdir(PROBLEMS))) {

      if (    $file =~ /^rq-\d\d\d\d\d\d.txt$/
	   or $file =~ /^uc-\d\d\d\d\d\d.txt$/
	 ) {
	push @to_be_read, "problems/$file";
      }
    }
    closedir(PROBLEMS);
  }

  if ($opt{'solution'}) {
    opendir(SOLUTIONS,"Solutions") or die "can't opendir Solutions: $!";
    while (defined(my $file = readdir(SOLUTIONS))) {

      if (    $file =~ /^ba-\d\d\d\d\d\d.txt$/
	   or $file =~ /^ci-\d\d\d\d\d\d.txt$/
           or $file =~ /^do-\d\d\d\d\d\d.txt$/
	   or $file =~ /^pt-\d\d\d\d\d\d.txt$/
	 ) {
	push @to_be_read, "solutions/$file";
      }
    }
    closedir(SOLUTIONS);
  }

  if ($opt{'test'}) {
    opendir(TESTS,"Tests") or die "can't opendir Tests: $!";
    while (defined(my $file = readdir(TESTS))) {

      if (    $file =~ /^tc-\d\d\d\d\d\d.txt$/
	   or $file =~ /^td-\d\d\d\d\d\d.txt$/
	 ) {
	push @to_be_read, "tests/$file";
      }
    }
    closedir(TESTS);
  }

  if ($opt{'result'}) {
    opendir(RESULTS,"Results") or die "can't opendir Results: $!";
    while (defined(my $file = readdir(RESULTS))) {

      if (    $file =~ /^ca-\d\d\d\d\d\d.txt$/
	   or $file =~ /^qr-\d\d\d\d\d\d.txt$/
	   or $file =~ /^rr-\d\d\d\d\d\d.txt$/
	   or $file =~ /^tr-\d\d\d\d\d\d.txt$/
	   or $file =~ /^ts-\d\d\d\d\d\d.txt$/
	 ) {
	push @to_be_read, "results/$file";
      }
    }
    closedir(RESULTS);
  }

  if ($opt{'task'}) {
    opendir(TASKS,"Tasks") or die "can't opendir Tasks: $!";
    while (defined(my $file = readdir(TASKS))) {

      if ( $file =~ /^ta-\d\d\d\d\d\d.txt$/ ) {
	push @to_be_read, "tasks/$file";
      }
    }
    closedir(TASKS);
  }

  if ($opt{'role'}) {
    opendir(ROLES,"Roles") or die "can't opendir Roles: $!";
    while (defined(my $file = readdir(ROLES))) {

      if ( $file =~ /^ro-\d\d\d\d\d\d.txt$/ ) {
	push @to_be_read, "roles/$file";
      }
    }
    closedir(ROLES);
  }

  if ($opt{'allocation'}) {
    opendir(ALLOCATIONS,"Allocations") or die "can't opendir Allocations: $!";
    while (defined(my $file = readdir(ALLOCATIONS))) {

      if ( $file =~ /^al-\d\d\d\d\d\d.txt$/ ) {
	push @to_be_read, "allocations/$file";
      }
    }
    closedir(ALLOCATIONS);
  }

  if ($opt{'assignment'}) {
    opendir(ASSIGNMENTS,"Assignments") or die "can't opendir Assignments: $!";
    while (defined(my $file = readdir(ASSIGNMENTS))) {

      if ( $file =~ /^as-\d\d\d\d\d\d.txt$/ ) {
	push @to_be_read, "assignments/$file";
      }
    }
    closedir(ASSIGNMENTS);
  }

}

#---------------------------------------------------------------------
# neither file or all specified
#
else {
  print "ERROR: specify either (1) a file, or (2) --all\n";
}

#---------------------------------------------------------------------
# read all related files
#
while (@to_be_read) {
  foreach my $file (shift @to_be_read) {
    readFile($file);
  }
}

#---------------------------------------------------------------------
# render output
#
#     Allocations and assignments do not exist in hierarchies.
#     Therefore, don't render them as trees (section hierarchies).
#
if ($opt{'tree'} and not $opt{'allocation'} and not $opt{'assignment'}) {
  render_tree();
} else {
  render_flat();
}

######################################################################

sub render_flat {

  # Render a simple 'flat' list of include statements.

  for my $type (qw/problem solution test result task role allocation assignment/) {

    # my $utype = ucfirst($type);
    my $utype = $type;

    if ($opt{$type}) {
      foreach my $item (sort by_doc_order keys %{ $include{$type} } ) {
	my $source = $include{$type}{$item};
	if ($opt{'hide'}) {
	  print "include::hide:$type: ../${utype}s/$item.txt # <-- $source\n";
	} else {
	  print "include:: ../${utype}s/$item.txt # <-- $source\n";
	}
      }
    }
  }
}

######################################################################

sub render_tree {

  # Render a hierarchical section structure of include statements.

  for my $type (qw/problem solution test result task role allocation assignment/) {

    # my $utype = ucfirst($type);
    my $utype = $type;

    if ($opt{$type}) {

      # Make an ordered list of toplevel items.
      #
      my @toplevelitems = ();

      # If the user specified an entity ID as an argument, it is the
      # only toplevel item.
      #
      if ($opt{'entity'}) {
	push @toplevelitems, $opt{'entity'};
      }

      # Otherwise, make a list of all toplevel items (i.e. any item
      # that doesn't have a parent item).
      #
      else {
	foreach my $item ( sort by_doc_order keys %{ $include{$type} } ) {
	  next if not $item =~ /^\w\w\-\d\d\d\d\d\d$/;
	  my $item_parent = $parent{$item} || '';
	  if (not $item_parent or not $title{$item_parent}) {
	    push @toplevelitems, $item;
	  }
	}
      }

      foreach my $item (@toplevelitems)	{

	# If this item has parts, render it as a subtree.
	#
	if (defined $parts{$item} and keys %{ $parts{$item} }) {
	  render_subtree($item);
	}

	# Otherwise, render a single toplevel section
	#
	else {
	  my $title  = $title{$item};
	  my $source = $include{$type}{$item};
	  my $line   = '';

	  if ($opt{'hide'}) {
	    $line = "include::hide:$type: ../${utype}s/$item.txt # <-- $source";
	  } elsif ($opt{'entity'}) {
	    $line = "include::item=$item: tmpl/item-summary.txt # <-- $source";
	  } else {
	    $line = "include:: ../${utype}s/$item.txt # <-- $source";
	  }

	  print "* $title ($item)\n\n"; # bug here?  always one asterisk?
	  print "$line\n\n";
	}
      }
    }
  }
}

######################################################################

sub render_subtree {

  my $item   = shift;
  my $depth  = 0;
  my $parent = $parent{$item} || '';
  my $title  = $title{$item};
  my $type   = '';
  my $utype  = '';

  # Determine the type of this item
  #
  if    ( $item =~ /^(rq|uc)-\d\d\d\d\d\d$/          ) { $type = 'problem'    }
  elsif ( $item =~ /^(ba|ci|do|pt)-\d\d\d\d\d\d$/    ) { $type = 'solution'   }
  elsif ( $item =~ /^(tc|td)-\d\d\d\d\d\d$/          ) { $type = 'test'       }
  elsif ( $item =~ /^(ca|qr|rr|tr|ts)-\d\d\d\d\d\d$/ ) { $type = 'result'     }
  elsif ( $item =~ /^(ta)-\d\d\d\d\d\d$/             ) { $type = 'task'       }
  elsif ( $item =~ /^(ro)-\d\d\d\d\d\d$/             ) { $type = 'role'       }
  elsif ( $item =~ /^(al)-\d\d\d\d\d\d$/             ) { $type = 'allocation' }
  elsif ( $item =~ /^(as)-\d\d\d\d\d\d$/             ) { $type = 'assignment' }
  else                                                 { return };

  # $utype = ucfirst($type);
  $utype = $type;

  # Look up the source of this item reference.
  #
  my $source = $include{$type}{$item};

  # Determine the depth of this item in the hierarchy.  If you're
  # including ALL entities in the repository, the depth begins at the
  # topmost entity in a hierarchy.  If you're including a hierarchy
  # RELATIVE to an entity, the depth begins at that entity.
  #
  if ( $item eq $opt{'entity'} ) {
    $depth = 0;
    # print "DEBUG: (item is specified entity) depth of $item is $depth\n";
  }

  elsif ($opt{'entity'}) {
    while ($parent and $title{$parent}) {
      ++ $depth;
      $parent = $parent{$parent} || '';
    }
  }

  elsif (not $parent) {
    $depth = 1;
  }

  else {
    $depth = 1;
    while ($parent and $title{$parent}) {
      ++ $depth;
      $parent = $parent{$parent} || '';
    }
    # print "DEBUG: (item is NOT specified entity) depth of $item is $depth\n";
  }

  # print a section heading if depth is less than or equal to max depth
  #
  if ($depth <= $max_depth) {

    # Build a string of asterisks for section heading
    #
    my $asterisks = '';
    $asterisks .= '*' until length $asterisks >= $depth;

    if ($item eq $opt{'entity'}) {
      $asterisks .= '*';
    } elsif ($opt{'entity'} and not $parent{$opt{'entity'}}) {
      $asterisks .= '*';
    }

    # Print section heading
    my $title = $title{$item};
    print "$asterisks $title ($item)\n\n";

  }

  # print 'include' line
  #
  if ($opt{'hide'}) {
    print "include::hide:$type: ../${utype}s'}/$item.txt # <-- $source\n\n";
  } elsif ($opt{'entity'}) {
    print "include::item=$item: tmpl/item-summary.txt # <-- $source\n\n";
  } else {
    print "include:: ../${utype}s/$item.txt # <-- $source\n\n";
  }

  # render parts
  #
  if (defined $parts{$item} and keys %{ $parts{$item} }) {
    foreach my $part (sort by_doc_order keys %{ $parts{$item} }) {
      render_subtree($part);
    }
  }
}

######################################################################

sub readFile {

  my $file   = shift;
  my %in     = ();

  my $itemlabel  = '';
  my $parent     = '';
  my $title      = '';

  my $seen_itemlabel = 0;
  my $seen_parent    = 0;
  my $seen_title     = 0;

  open FILE, "<$file" || die "file $file not readable";

  # Read file; discover labels
  #
 LINE:
  while (<FILE>) {

    #-----------------------------------------------------------------
    # look for comment block marker
    #
    if (/^(#){3,}comment\s*$/) {
      if ($in{'comment'}) {
        $in{'comment'} = 0;
      } else {
        $in{'comment'} = 1;
      }
      next LINE;
    }

    #-----------------------------------------------------------------
    # look for revision division marker
    #
    if (/^(-){3,}revisions\s*$/) {
      if ($in{'revisions'}) {
        $in{'revisions'} = 0;
      } else {
        $in{'revisions'} = 1;
      }
      next LINE;
    }

    #-----------------------------------------------------------------
    # elsif line is comment line, in comment block, or in revisions
    #
    elsif (/^#/ or $in{'comment'} or $in{'revisions'}) {
      next LINE;
    }

    #-----------------------------------------------------------------
    # elsif line has a line-ending comment, ignore the comment part
    #
    elsif (/^(.*?)#(.*)$/) {
      $_ = $1;
    }

    #-----------------------------------------------------------------
    # elsif line is label statement
    #
    elsif (/^label::\s+(.*?)\s*$/ and not $seen_itemlabel) {
      $itemlabel      = $1;
      $seen_itemlabel = 1;
    }

    #-----------------------------------------------------------------
    # elsif line is parent statement
    #
    elsif (/^parent::\s+(.*?)\s*$/ and not $seen_parent) {
      $parent      = $1;
      $seen_parent = 1;
    }

    #-----------------------------------------------------------------
    # elsif line is title statement
    #
    elsif (/^title::\s+(.*?)\s*$/ and not $seen_title) {
      $title       = $1;
      $seen_title  = 1;
      $in{'title'} = 1;
    }

    # look for end of title
    elsif ( $in{'title'} and ( /^\s*$/ or /^[\w\-]+::/ ) ) {
      $in{'title'} = 0;
    }

    # look for title continuation line
    elsif ( $in{'title'} ) {
      my $string = $_;
      $string = trim_whitespace($string);
      $string = compress_whitespace($string);
      $title .= " $string";
    }

    #-----------------------------------------------------------------
    # elsif line is include statement
    #
    elsif (/^include::(.*:)?(\$r(\w*)\$:)?(.*:)?\s+(.*?)\s*(#(.*))?$/) {
      my $included_file = $5;
      push(@to_be_read,$included_file) if not $read{$included_file};
    }

    #-----------------------------------------------------------------
    # look for labels
    #
    while (/((rq|uc|ba|ci|do|pt|tc|td|ca|qr|rr|tr|ts|ta|ro|al|as)-\d\d\d\d\d\d)/) {

      my $label = $1;
      s/(rq|uc|ba|ci|do|pt|tc|td|ca|qr|rr|tr|ts|ta|ro|al|as)-\d\d\d\d\d\d//;

      ++ $i;

      $order{$label} = $i if not defined $order{$label};

      my $related_file = '';

      # problems
      #
      if ($label =~ /^(rq|uc)/) {
	$include{'problem'}{$label} = "$file:$."
	  if not defined $include{'problem'}{$label};
	$related_file = "problems/$label.txt";
      }

      # solutions
      #
      elsif ($label =~ /^(ba|ci|do|pt)/) {
	$include{'solution'}{$label} = "$file:$."
	  if not defined $include{'solution'}{$label};
	$related_file = "solutions/$label.txt";
      }

      # tests
      #
      elsif ($label =~ /^(tc|td)/) {
	$include{'test'}{$label} = "$file:$."
	  if not defined $include{'test'}{$label};
	$related_file = "tests/$label.txt";
      }

      # results
      #
      elsif ($label =~ /^(ca|qr|rr|tr|ts)/) {
	$include{'result'}{$label} = "$file:$."
	  if not defined $include{'result'}{$label};
	$related_file = "results/$label.txt";
      }

      # tasks
      #
      elsif ($label =~ /^(ta)/) {
	$include{'task'}{$label} = "$file:$."
	  if not defined $include{'task'}{$label};
	$related_file = "tasks/$label.txt";
      }

      # roles
      #
      elsif ($label =~ /^(ro)/) {
	$include{'role'}{$label} = "$file:$."
	  if not defined $include{'role'}{$label};
	$related_file = "roles/$label.txt";
      }

      # allocations
      #
      elsif ($label =~ /^(al)/) {
	$include{'allocation'}{$label} = "$file:$."
	  if not defined $include{'allocation'}{$label};
	$related_file = "allocations/$label.txt";
      }

      # assignments
      #
      elsif ($label =~ /^(as)/) {
	$include{'assignment'}{$label} = "$file:$."
	  if not defined $include{'assignment'}{$label};
	$related_file = "assignments/$label.txt";
      }

      push(@to_be_read,$related_file) if not $read{$related_file};

    }

  }

  close FILE;

  $read{$file} = 1;

  # If this is an 'entity' file, remember the title and part structure
  # of this label.
  #
  if ( $file =~ /\w\w\-\d\d\d\d\d\d.txt/ and $itemlabel ) {

    if ($title) {
      $title{$itemlabel} = $title;
    }

    if ($parent) {
      $parent{$itemlabel} = $parent;
      $parts{$parent}{$itemlabel} = 1;
    }
  }
}

######################################################################

sub by_doc_order {

  # Sort by document order

  return $order{$a} <=> $order{$b}
}

######################################################################

sub trim_whitespace {

  # Trim leading and trailing whitespace from a line of text.

  my $text = shift;

  $text =~ s/^\s*//m;            # ignore leading whitespace
  $text =~ s/\s*$//m;            # ignore trailing whitespace

  return $text;
}

######################################################################

sub compress_whitespace {

  # Compress multiple whitespaces within a string into a single
  # whitespace.

  my $text = shift;

  $text =~ s/\s+/ /g;

  return $text;
}

######################################################################
