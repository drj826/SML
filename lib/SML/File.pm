#!/usr/bin/perl

package SML::File;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Resource';

use namespace::autoclean;

use Cwd;
use Carp;
use File::Spec;
use File::Basename;
use Digest::SHA qw(sha1);
use Digest::MD5 qw(md5_hex);

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.File');

use SML::Svninfo;

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has filespec =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_filespec',
   required => 1,
  );

######################################################################

has filename =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_filename',
   lazy     => 1,
   builder  => '_build_filename',
  );

######################################################################

has library =>
  (
   is       => 'ro',
   isa      => 'SML::Library',
   reader   => 'get_library',
   required => 1,
  );

######################################################################

has directories =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_directories',
   lazy     => 1,
   builder  => '_build_directories',
  );

######################################################################

has path =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_path',
   lazy     => 1,
   builder  => '_build_path',
  );

######################################################################

has text =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_text',
   lazy     => 1,
   builder  => '_build_text',
  );

######################################################################

has line_list =>
  (
   is       => 'ro',
   isa      => 'ArrayRef',
   reader   => 'get_line_list',
   lazy     => 1,
   builder  => '_build_line_list',
  );

######################################################################

has sha_digest =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_sha_digest',
   lazy     => 1,
   builder  => '_build_sha_digest',
  );

######################################################################

has md5_digest =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_md5_digest',
   lazy     => 1,
   builder  => '_build_md5_digest',
  );

######################################################################

has svninfo =>
  (
   is       => 'ro',
   isa      => 'SML::Svninfo',
   reader   => 'get_svninfo',
   writer   => 'set_svninfo',
  );

######################################################################

has valid =>
  (
   is       => 'ro',
   isa      => 'Bool',
   reader   => 'is_valid',
   writer   => '_set_valid',
   lazy     => 1,
   builder  => '_validate',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has from_line =>
  (
   is        => 'ro',
   isa       => 'SML::Line',
   reader    => '_get_from_line',
   predicate => '_has_from_line',
  );

# SML content may be "included from" other files using a special
# "include" mechanism.  If *this* file has been included using this
# mechanism, this `from_line' is the line that included the file.

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub BUILD {

  my $self = shift;

  my $library = $self->get_library;
  my $options = $library->get_options;

  if ( $options->use_svn )
    {
      my $filespec = $self->get_filespec;
      my $svninfo  = SML::Svninfo->new(filespec=>$filespec);

      $self->set_svninfo($svninfo);
    }

  return 1;
}

######################################################################

sub _validate {

  my $self = shift;

  my $path     = $self->get_path;
  my $filename = $self->get_filename;
  my $filespec = File::Spec->catdir($path,$filename);
  my $valid    = 1;

  if ( not -e $filespec )
    {
      $valid = 0;
    }

  elsif ( not -r $filespec )
    {
      $valid = 0;
    }

  else
    {
      # File is valid.
    }


  $self->_set_valid($valid);

  return $valid;
}

######################################################################

sub _build_filename {

  my $self = shift;

  my $filespec = $self->get_filespec;

  my ($filename,$directories,$suffix) = fileparse($filespec);

  return $filename;
}

######################################################################

sub _build_directories {

  my $self = shift;

  my $filespec = $self->get_filespec;

  my ($filename,$directories,$suffix) = fileparse($filespec);

  return $directories;
}

######################################################################

sub _build_path {

  my $self = shift;

  my $filespec = $self->get_filespec;
  my $cwd      = getcwd;

  my ($filename,$directories,$suffix) = fileparse($filespec);

  return File::Spec->catdir($cwd,$directories);
}

######################################################################

sub _build_text {

  use File::Slurp;

  my $self = shift;

  my $filespec = $self->get_filespec;
  my $library  = $self->get_library;
  my $path     = $library->get_directory_path;

  if ( not -f "$path/$filespec" )
    {
      my $cwd = getcwd();
      $logger->error("NO SUCH FILE \'$filespec\' from $cwd");
      return 0;
    }

  return read_file("$path/$filespec");
}

######################################################################

sub _build_line_list {

  my $self = shift;

  my $filespec  = $self->get_filespec;
  my $raw_list  = [];
  my $line_list = [];

  open my $fh, "<", $filespec or die "Can't open $filespec: $!\n";
  @{ $raw_list } = <$fh>;
  close $fh;

  my $i = 0;
  foreach my $text (@{ $raw_list })
    {
      ++ $i;
      my $line = SML::Line->new
	(
	 content => $text,
	 file    => $self,
	 num     => $i,
	);
      push(@{ $line_list },$line);
    }

  return $line_list;
}

######################################################################

sub _build_sha_digest {

  my $self = shift;

  my $sha = Digest::SHA->new;

  my $filespec = $self->get_filespec;

  if ( not -r $filespec )
    {
      my $cwd = getcwd();
      $logger->error("CAN'T BUILD SHA DIGEST, BAD FILESPEC \'$filespec\' from $cwd");
    }

  $sha->addfile($filespec);

  return $sha->hexdigest;
}

######################################################################

sub _build_md5_digest {

  my $self = shift;

  my $filespec = $self->get_filespec;
  my $digest   = q{};

  my $md5 = Digest::MD5->new;
  open my $fh, "<", "$filespec" or die "Couldn't open $filespec\n";
  $md5->addfile($fh);
  close $fh or croak("Couldn't close $filespec");

  return $md5->hexdigest;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::File> - an L<"SML::Resource"> that represents a persisted file
in a filesystem.

=head1 VERSION

This documentation refers to L<"SML::File"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::Resource

  my $file = SML::File->new();

=head1 DESCRIPTION

A L<"SML::File"> is an L<"SML::Resource"> that represents a persisted
file in a filesystem.

=head1 METHODS

=head2 get_filespec

The filespec is the string representing the file location as passed to
the constructor.  In the case of a FILE element for instance:

  FILE:: problems/rq-000001.txt
         ----------------------
                   ^
                   |
                filespec

=head2 get_filename

The filename is the name of the file including the suffix.  In the
case of a FILE element for instance:

  FILE:: problems/rq-000001.txt
                  -------------
                       ^
                       |
                    filename

=head2 get_directories

This 'directories' attribute is that portion of the filespec
representing the directories in the path containing the file.  In the
case of a FILE element for instance:

  FILE:: problems/rq-000001.txt
         ---------
             ^
             |
        directories

=head2 get_path

The path is the FULL path to the file (as opposed to any relative path
to the file).  This path is built at object construction time by
appending the 'directories' attribute to the current working directory
(cwd).  For instance:

  /users/drj/work/library/ + problems/
  ------------------------   ---------
             ^                  ^
             |                  |
            cwd            directories


  /users/drj/work/library/problems/
  ---------------------------------
                 ^
                 |
               path

=head2 get_sha_digest

=head2 get_md5_digest

=head2 get_svn_info

=head2 get_fragment

=head2 has_been_parsed

This boolean attribute represents whether the contents of the file
have been parsed into the library.

=head2 is_valid

This boolean attribute represents whether the file is valid (exists
and is readable).

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
