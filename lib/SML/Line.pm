#!/usr/bin/perl

package SML::Line;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Line');

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

######################################################################

has file =>
  (
   is        => 'ro',
   isa       => 'SML::File',
   reader    => 'get_file',
   predicate => 'has_file',
  );

# This is the file object from which the line came.  Not all lines
# come from files.  Lines can come from script output or other
# generated sources.  Therefore it's OK if this attribute is
# undefined.

######################################################################

has num =>
  (
   is       => 'ro',
   isa      => 'Int',
   reader   => 'get_num',
);

# This is the line number.  If the line came from a file it is the
# line number in the file.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_filespec {

  # Return the name of the file (name.ext) from which this line came.

  my $self = shift;

  my $file = $self->get_file;

  if ( ref $file and $file->isa('SML::File') )
    {
      return $file->get_filespec;
    }

  else
    {
      return 'NO-FILE';
    }
}

######################################################################

sub get_location {

  # Return the location (filespec + line number) from which this line
  # originated.

  my $self = shift;

  my $filespec = $self->get_filespec;
  my $num      = $self->get_num;

  if ( $filespec and $num )
    {
      return "$filespec:$num";
    }

  else
    {
      return 'UNKNOWN LOCATION';
    }
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Line> - A single line of raw text from an SML file.

=head1 VERSION

This documentation refers to L<"SML::Line"> version 2.0.0.

=head1 SYNOPSIS

  my $line = SML::Line->new(content=>$content);

=head1 DESCRIPTION

A single line of raw text from an SML file.  A line has content, a
line number, and knows what file it came from.

=head1 METHODS

=head2 get_content

=head2 get_file

=head2 get_num

=head2 get_filespec

=head2 get_location

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
