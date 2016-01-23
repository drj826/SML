#!/usr/bin/perl

package SML::Figure;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';

use namespace::autoclean;

use File::Basename;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Figure');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'FIGURE',
  );

######################################################################

has image_file_basename =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_image_file_basename',
   builder => '_build_image_file_basename',
   lazy    => 1,
  );

# This is the basename of the image file (if any) which is part of the
# figure.  For instance, if the 'image' property value is:
#
#   files/images/uml_class_model.png
#
# Then this 'image_file_basename' should be:
#
#   uml_class_model.png

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

sub _build_image_file_basename {

  my $self = shift;

  my $library = $self->get_library;
  my $id      = $self->get_id;

  if ( $library->has_property($id,'image') )
    {
      my $list = $library->get_property_value_list($id,'image');

      # just take the first value, ignore any others
      my $image_filespec = $list->[0];

      return basename($image_filespec);
    }

  return 0;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Figure> - an environment that instructs the publishing
application to insert a figure into the document.

=head1 VERSION

This documentation refers to L<"SML::Figure"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::Division

  my $figure = SML::Figure->new();

=head1 DESCRIPTION

A figure is an environment that instructs the publishing application
to insert a figure into the document.

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
