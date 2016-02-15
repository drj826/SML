#!/usr/bin/perl

package SML::Line;                      # ci-000385

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Line');

######################################################################

=head1 NAME

SML::Line - A line of text

=head1 SYNOPSIS

  SML::Line->new(content=>$content);

  $line->get_content;                   # Str
  $line->get_file;                      # SML::File
  $line->has_file;                      # Bool
  $line->get_num;                       # Int
  $line->get_location;                  # Str

=head1 DESCRIPTION

A single line of raw text. A line has content, a line number, and
knows what file it came from.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has content =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_content',
   required  => 1,
  );

=head2 get_content

Return a scalar text value of the content of the line.

  my $text = $line->get_content;

=cut

######################################################################

has file =>
  (
   is        => 'ro',
   isa       => 'SML::File',
   reader    => 'get_file',
   predicate => 'has_file',
  );

=head2 get_file

Return the C<SML::File> object for the file from which the line came.

  my $file = $line->get_file;

Not all lines come from files.  Lines can come from script output or
other generated sources.  Therefore it's OK if this attribute is
undefined.

=head2 has_file

Return 1 if this line came from a file.

  my $result = $line->has_file;

=cut

######################################################################

has num =>
  (
   is       => 'ro',
   isa      => 'Int',
   reader   => 'get_num',
);

=head2 get_num

Return an integer number.  This is the line number.  If the line came
from a file it is the line number in the file.

  my $num = $line->get_num;

=cut

######################################################################

has location =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_location',
   lazy    => 1,
   builder => '_build_location',
  );

=head2 get_location

Return a scalar text value that represents the location of the line
(<file>:<line_number>).

  my $location = $line->get_location;

=cut

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
## Private Methods
##
######################################################################
######################################################################

sub _build_location {

  # Return the location (filespec + line number) from which this line
  # originated.

  my $self = shift;

  my $file = $self->get_file;

  unless ( $file )
    {
      return 'UNKNOWN LOCATION';
    }

  my $filename = $file->get_filename;
  my $num      = $self->get_num;

  if ( $filename and $num )
    {
      return "$filename:$num";
    }

  return 'UNKNOWN LOCATION';
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
