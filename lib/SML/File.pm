#!/usr/bin/perl

package SML::File;                      # ci-000384

use Moose;

use version; our $VERSION = qv('2.0.0');

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

=head1 NAME

SML::File - a persisted file in a filesystem

=head1 SYNOPSIS

  SML::File->new
    (
      library  => $library,
      filespec => $filespec,
    );

  $file->get_library;                   # SML::Library
  $file->get_filespec;                  # Str
  $file->get_filename;                  # Str
  $file->get_directories;               # Str
  $file->get_path;                      # Str
  $file->get_text;                      # Str
  $file->get_line_list;                 # ArrayRef
  $file->get_sha_digest;                # Str
  $file->get_md5_digest;                # Str
  $file->get_svninfo;                   # SML::Svninfo
  $file->set_svninfo($svninfo);         # Bool

=head1 DESCRIPTION

A C<SML::File> represents a persisted file in a filesystem.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has library =>
  (
   is       => 'ro',
   isa      => 'SML::Library',
   reader   => 'get_library',
   required => 1,
  );

=head2 get_library

Return the C<SML::Library> to which the file belongs.

  my $library = $file->get_library;

=cut

######################################################################

has filespec =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_filespec',
   required => 1,
  );

=head2 get_filespec

Return the scalar text value which is the filespec of this file.

  my $filespec = $file->get_filespec;

The filespec is the string representing the file location as passed to
the constructor.  In the case of a file element for instance:

  file:: problems/rq-000001.txt
         ----------------------
                   ^
                   |
                filespec

=cut

######################################################################

has filename =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_filename',
   lazy     => 1,
   builder  => '_build_filename',
  );

=head2 get_filename

Return the scalar text value which is the filename of this file.

  my $filename = $file->get_filename;

The filename is the name of the file including the suffix.  In the
case of a file element for instance:

  file:: problems/rq-000001.txt
                  -------------
                       ^
                       |
                    filename

=cut

######################################################################

has directories =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_directories',
   lazy     => 1,
   builder  => '_build_directories',
  );

=head2 get_directories

Return the scalar text value which is the "directory" portion of the
filespec.

  my $directories = $file->get_directories;

This 'directories' attribute is that portion of the filespec
representing the directories in the path containing the file.  In the
case of a file element for instance:

  file:: problems/rq-000001.txt
         ---------
             ^
             |
        directories

=cut

######################################################################

has path =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_path',
   lazy     => 1,
   builder  => '_build_path',
  );

=head2 get_path

Return the scalar text value which is the full path to the file.

  my $path = $file->get_path;

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

=cut

######################################################################

has text =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_text',
   lazy     => 1,
   builder  => '_build_text',
  );

=head2 get_text

Return the scalar text value which is the full text of the file content.

  my $text = $file->get_text;

=cut

######################################################################

has line_list =>
  (
   is       => 'ro',
   isa      => 'ArrayRef',
   reader   => 'get_line_list',
   lazy     => 1,
   builder  => '_build_line_list',
  );

=head2 get_line_list

Return an ArrayRef to a list of file lines (i.e. C<SML::Line>
objects).

  my $aref = $file->get_line_list;

=cut

######################################################################

has sha_digest =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_sha_digest',
   lazy     => 1,
   builder  => '_build_sha_digest',
  );

=head2 get_sha_digest

Return a scalar text value which is the SHA1 digest of the file
contents.

  my $digest = $file->get_sha_digest;

=cut

######################################################################

has md5_digest =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_md5_digest',
   lazy     => 1,
   builder  => '_build_md5_digest',
  );

=head2 get_md5_digest

Return a scalar text value which is the MD5 digest of the file
contents.

  my $digest = $file->get_md5_digest;

=cut

######################################################################

has svninfo =>
  (
   is       => 'ro',
   isa      => 'SML::Svninfo',
   reader   => 'get_svninfo',
   writer   => 'set_svninfo',
  );

=head2 get_svninfo

Return an C<SML::Svninfo> object that represents the SVN revision
repository meta-data about this file.

  my $svninfo = $file->get_svninfo;

=head2 set_svninfo

Set the C<SML::Svninfo> object that represents the SVN revision
repository meta-data about this file.

  $file->set_svninfo($svninfo);

=cut

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

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012-2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
