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

  SML::Line->new
    (
      file    => $file,
      num     => $num,
      content => $content,
    );

  SML::Line->new
    (
      plugin  => $plugin,
      num     => $num,
      content => $content,
    );

  SML::Line->new
    (
      script  => $script,
      num     => $num,
      content => $content,
    );

  $line->get_content;                   # Str
  $line->get_file;                      # SML::File
  $line->has_file;                      # Bool
  $line->get_plugin;                    # Str
  $line->has_plugin;                    # Bool
  $line->get_script;                    # Str
  $line->has_script;                    # Bool
  $line->get_num;                       # Int
  $line->get_location;                  # Str

=head1 DESCRIPTION

A single line of raw text. A line has content, a line number, and
knows what file, plugin, or script it came from.

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

has plugin =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_plugin',
   predicate => 'has_plugin',
  );

=head2 get_plugin

Return the plugin from which the line came.

  my $plugin = $line->get_plugin;

This is the plugin that produced the line.  This string includes the
plugin name and args spearated by a colon:

  Parts2Sections:rq-000123

=head2 has_script

Return 1 if this line came from a plugin.

  my $result = $line->has_plugin;

=cut

######################################################################

has script =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_script',
   predicate => 'has_script',
  );

=head2 get_script

Return the script from which the line came.

  my $script = $line->get_script;

This is the script that produced the line.  This string includes the
script name and args spearated by a colon.

=head2 has_script

Return 1 if this line came from a script.

  my $result = $line->has_script;

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

  if ( $self->has_file )
    {
      my $file     = $self->get_file;
      my $filename = $file->get_filename;
      my $num      = $self->get_num;

      return "$filename:$num";
    }

  elsif ( $self->has_plugin )
    {
      my $plugin = $self->get_plugin;
      my $num    = $self->get_num;

      return "$plugin:$num";
    }

  elsif ( $self->has_script )
    {
      my $script = $self->get_script;
      my $num    = $self->get_num;

      return "$script:$num";
    }

  else
    {
      $logger->error("LINE FROM UNKNOWN LOCATION");

      return 'UNKNOWN LOCATION';
    }
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
