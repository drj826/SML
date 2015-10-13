#!/usr/bin/perl

# $Id: Fragment.pm 255 2015-04-01 16:07:27Z drj826@gmail.com $

package SML::Fragment;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use English qw( -no_match_vars );
use File::Basename;
use Cwd;
use Carp;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Fragment');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has 'id' =>
  (
   isa       => 'Str',
   reader    => 'get_id',
   writer    => 'set_id',
   default   => '',
  );

######################################################################

has 'file' =>
  (
   isa      => 'SML::File',
   reader   => 'get_file',
   required => 1,
  );

######################################################################

has 'line_list' =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_line_list',
   writer    => '_set_line_list',
   default   => sub {[]},
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

# sub add_resource {

#   my $self     = shift;
#   my $resource = shift;

#   my $filespec = $resource->get_filespec;

#   $self->_get_resource_hash->{$filespec} = $resource;

#   return scalar keys %{ $self->_get_resource_hash }; # resource count
# }

######################################################################

# sub has_resource {

#   my $self     = shift;
#   my $filespec = shift;

#   if ( exists $self->_get_resource_hash->{$filespec} )
#     {
#       return 1;
#     }

#   else
#     {
#       return 0;
#     }
# }

######################################################################

# sub get_resource {

#   my $self     = shift;
#   my $filespec = shift;

#   if ( exists $self->_get_resource_hash->{$filespec} )
#     {
#       return $self->_get_resource_hash->{$filespec};
#     }

#   else
#     {
#       # $logger->error("CAN'T GET RESOURCE \'$filespec\'");
#       return 0;
#     }
# }

######################################################################

sub extract_division_lines {

  my $self      = shift;
  my $target_id = shift; # ID of division to be extracted

  my $library            = $self->get_library;
  my $syntax             = $library->get_syntax;
  my $lines              = [];  # Extracted lines
  my $div_stack          = [];  # stack of division names
  my $in_comment         = 0;   # in a comment division?
  my $in_target_division = 0;   # in the division targeted for extraction?
  my $target_name        = q{}; # problem, solution, table, section...
  my $current_env_name   = q{}; # name of current environment (if any)
  my $in_section         = 0;   # currently in a section?

  foreach my $line (@{ $self->get_line_list })
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp;

      if ( $text =~ /$syntax->{comment_marker}/ )
	{
	  # If already in a comment division...
	  if ( $in_comment ) {

	    # End the comment division
	    $in_comment = 0;

	  }

	  # Otherwise...
	  else {

	    # Start a new comment division
	    $in_comment = 1;
	  }

	  # If in target division...
	  if ( $in_target_division )
	    {
	      # Remember this line
	      push @{ $lines }, $line;
	    }
	}

      elsif ( $text =~ /$syntax->{start_region}/xms and not $in_comment )
	{
	  my $region_name = $2;
	  push @{ $div_stack }, $region_name;

	  # If not already in the target division...
	  if ( not $in_target_division )
	    {
	      # Initialize lines.
	      $lines = [];
	    }

	  # Remember this line
	  push @{ $lines }, $line;
	}

      elsif ( $text =~ /$syntax->{end_region}/xms and not $in_comment )
	{
	  my $region_name = $2;

	  # If this is the end of the division being extracted...
	  if (
	      $in_target_division
	      and
	      scalar @{ $div_stack }
	      and
	      $target_name eq $div_stack->[-1]
	     )
	    {
	      # Remember this line
	      push @{ $lines }, $line;

	      # Return lines
	      return $lines;
	    }

	  my $name = pop @{ $div_stack };

	  # Detect unbalanced (i.e. improperly nested ) divisions
	  #
	  if ( $name ne $region_name )
	    {
	      my $location = $line->get_location;
	      $logger->error("UNBALANCED DIVISIONS IN FRAGMENT at $location");
	    }

	  # Remember this line
	  push @{ $lines }, $line;

	}

      elsif ( $text =~ /$syntax->{start_environment}/xms and not $in_comment )
	{
	  my $found_env_name = $2;

	  # Detect whether this is the start or end of the environment.
	  if ( $found_env_name eq $current_env_name )
	    {
	      # END ENVIRONMENT
	      $current_env_name = q{};

	      # If this is the end of the division being extracted...
	      if (
		  $in_target_division
		  and
		  $target_name eq $div_stack->[-1]
		 )
		{
		  # Remember this line
		  push @{ $lines }, $line;

		  # RETURN LINES
		  return $lines;
		}

	      # Pop the division stack
	      pop @{ $div_stack };
	    }

	  else
	    {
	      # BEGIN ENVIRONMENT
	      $current_env_name = $found_env_name;

	      # Push onto the division stack
	      push @{ $div_stack }, $current_env_name;

	      # If not already in the target division...
	      if ( not $in_target_division )
		{
		  # Initialize lines.
		  $lines = [];
		}

	      # Remember this line
	      push @{ $lines }, $line;

	    }
	}

      elsif ( $text =~ /$syntax->{start_section}/xms and not $in_comment )
	{
	  # If not already in a section...
	  if ( not $in_section )
	    {
	      # We're now in a section.
	      $in_section = 1;

	      # Push division stack
	      push @{ $div_stack }, 'section';
	    }

	  # If not already in the target division...
	  if ( not $in_target_division )
	    {
	      # Initialize lines
	      $lines = [];
	    }

	  # If this is the end of the division being extracted...
	  if (
	      $in_target_division
	      and
	      $target_name eq $div_stack->[-1]
	     )
	    {
	      # Return lines
	      return $lines;
	    }

	  # Remember this line
	  push @{ $lines }, $line;
	}

      elsif ( $text =~ /$syntax->{id_element}/xms and not $in_comment )
	{
	  my $found_id = $2;

	  if ( $found_id eq $target_id )
	    {
	      # We are in the target division
	      $in_target_division = 1;
	    }

	  # Remember this line
	  push @{ $lines }, $line;

	  # Remember the name of the current division
	  $target_name = $div_stack->[-1];
	}

      else
	{
	  # Remember this line
	  push @{ $lines }, $line;
	}
    }

  return $lines;
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has 'included_from_line' =>
  (
   isa      => 'SML::Line',
   reader   => '_get_included_from_line',
  );

######################################################################

has 'resource_hash' =>
  (
   isa       => 'HashRef',
   reader    => '_get_resource_hash',
   default   => sub {{}},
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub BUILD {

  my $self = shift;

  my $file     = $self->get_file;
  my $filespec = $file->get_filespec;
  my $from     = $self->_get_included_from_line;
  my $lines    = $self->_read_file($file,$from);
  my $library  = $self->get_library;
  my $util     = $library->get_util;

  $self->_set_line_list($lines);
  $self->set_id($filespec);

  $library->add_fragment($self);

  return 1;
}

######################################################################

sub _read_file {

  # Read a file, return an array of SML::Line objects.

  # 1. Receive a SML::File object.
  # 2. Read the file, create a SML::Line object for each line.
  # 3. Return ref to array of line objects.

  my $self          = shift;
  my $file          = shift;
  my $included_from = shift;

  my $library       = $self->get_library;
  my $syntax        = $library->get_syntax;
  my $util          = $library->get_util;
  my $options       = $util->get_options;
  my $filespec      = $file->get_filespec;
  my $filename      = $file->get_filename;
  my $directories   = $file->get_directories;
  my $startdir      = getcwd();
  my $lines         = [];

  chdir($directories);

  if ( not -r $filename )
    {
      my $cwd = getcwd();

      if ( defined $included_from )
	{
	  $file->set_valid(0);
	  my $location = $included_from->get_location;
	  $logger->error("FILE NOT READABLE \'$filename\' (directories: $directories) at $location (from dir $cwd)");
	  $self->set_valid(0);
	}

      else
	{
	  $file->set_valid(0);
	  $logger->error("FILE NOT READABLE \'$filename\' (directories: $directories) (from dir $cwd)");
	  $self->set_valid(0);
	}

      return $lines;
    }

  open my $fh, "<", "$filename" or croak("Can't open $filename");

  while ( my $text = <$fh> )
    {
      # chomp;  # DON'T CHOMP HERE !!!

      $logger->trace("line: \'$text\'");

      my $line = undef;

      if ( defined $included_from )
	{
	  $line = SML::Line->new
	    (
	     file          => $file,
	     num           => $INPUT_LINE_NUMBER,
	     content       => $text,
	     included_from => $included_from,
	    );

	  push( @{ $lines },$line );
	}

      else
	{
	  $line = SML::Line->new
	    (
	     file          => $file,
	     num           => $INPUT_LINE_NUMBER,
	     content       => $text,
	    );

	  push( @{ $lines },$line );
	}

      # Look for 'include statements' and 'resource files' (other
      # files used by this one)
      #
      if ( $text =~ /$syntax->{include_element}/xms )
	{
	  my $include_spec = q{};

	  if ( $3 and $5 )
	    {
	      $include_spec = $5;
	    }

	  elsif ( $3 )
	    {
	      $include_spec = $3;
	    }

	  my $included_file = SML::File->new(filespec=>$include_spec);

	  if ( not $included_file->validate )
	    {
	      my $location = $line->get_location;
	      $logger->error("FILE NOT VALID \'$include_spec\' at $location");

	      $self->set_valid(0);
	    }

	  $file->add_resource($included_file);
	  $library->add_resource($included_file);

	  my $fragment = SML::Fragment->new
	    (
	     file          => $included_file,
	     included_from => $line,
	     library       => $library,
	    );
	}

      elsif ( $text =~ /$syntax->{file_element}/xms )
	{
	  my $resource_spec = $1;
	  my $resource = SML::File->new(filespec=>$resource_spec);

	  if ( -f $resource_spec )
	    {
	      $file->add_resource($resource);
	      $library->add_resource($resource);
	    }

	  else
	    {
	      my $cwd = getcwd;
	      my $location = $line->get_location;
	      $logger->warn("FILE NOT FOUND \'$resource_spec\' at $location (from $cwd)");
	    }
	}

      elsif ( $text =~ /$syntax->{image_element}/xms )
	{
	  my $resource_spec = $3;
	  my $resource = SML::File->new(filespec=>$resource_spec);

	  if ( $resource->validate )
	    {
	      $file->add_resource($resource);
	      $library->add_resource($resource);
	    }

	  else
	    {
	      my $location = $line->get_location;
	      $logger->warn("IMAGE FILE NOT FOUND \'$resource_spec\' at $location");
	    }
	}

      elsif ( $text =~ /$syntax->{template_element}/ )
	{
	  my $resource_spec = $4;
	  my $resource = SML::File->new(filespec=>$resource_spec);
	  $file->add_resource($resource);
	  $library->add_resource($resource);
	}
    }

  close $fh or croak("Couldn't close filehandle");

  chdir($startdir);

  return $lines;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Fragment> - A piece of SML formatted text stored in a file

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Division

  my $fragment = SML::Fragment->new
                   (
                     file    => $file,
                     library => $library,
                     name    => $name,
                   );

  my $file = $fragment->get_file;
  my $list = $fragment->get_line_list;

  my $list = $fragment->extract_division_lines($id);

=head1 DESCRIPTION

A C<SML::Fragment> is a piece of SML formatted text.  It could be a
short as a single L<"SML::Line"> or as long as an entire
L<"SML::Document">.

=head1 METHODS

=head2 get_file

=head2 get_line_list

=head2 extract_division_lines

Extract the lines of a division with the specified ID.  Divisions that
may be extracted include: region, environment, section.  Note that
subsections belonging to a section will NOT be extracted.

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012,2013 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
