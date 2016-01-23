#!/usr/bin/perl

package SML::Image;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Element';

use namespace::autoclean;

use File::Basename;
use Image::Size;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Image');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'image',
  );

######################################################################

has basename =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_basename',
   builder   => '_build_basename',
   lazy      => 1,
  );

######################################################################

has size =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_size',
   builder   => '_build_size',
   lazy      => 1,
  );

######################################################################

has width =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_width',
   builder   => '_build_width',
   lazy      => 1,
  );

######################################################################

has height =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_height',
   builder   => '_build_height',
   lazy      => 1,
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _build_basename {

  # Return a string which is the base filename from the filespec.

  my $self = shift;

  my $image_filespec = $self->get_value;

  return basename($image_filespec);
}

######################################################################

sub _build_size {

  # Return a string that represents the size of the image.  The string
  # has the format <height>x<width>.

  my $self = shift;

  my $filespec = $self->get_value;
  my $library  = $self->get_library;
  my $path     = $library->get_directory_path;

  if ( not -f "$path/$filespec" )
    {
      $logger->error("CAN'T GET IMAGE SIZE.  NO IMAGE FILE \'$path/$filespec\'");
      return 0;
    }

  my ($x,$y) = imgsize("$path/$filespec");

  my $size = $x . "x" . $y;

  return $size;
}

######################################################################

sub _build_width {

  # Return an integer that represents the width of the image in
  # pixels.

  my $self = shift;

  my $size = $self->get_size;

  my ($width,$height) = split(/x/,$size);

  $width = q{} if not $width;

  return $width;
}

######################################################################

sub _build_height {

  # Return an integer that represents the width of the image in
  # pixels.

  my $self = shift;

  my $size = $self->get_size;

  my ($width,$height) = split(/x/,$size);

  $height = q{} if not $height;

  return $height;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Image> - an image element

=head1 VERSION

This documentation refers to L<"SML::Image"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::Element

  my $image = SML::Image->new();

=head1 DESCRIPTION

An image is an element who's value is a filespec to an image file.

=head1 METHODS

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
