#!/usr/bin/perl

package SML::Source;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Environment';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.source');

######################################################################
######################################################################
##
## Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'source',
  );

######################################################################

has 'author' =>
  (
   isa    => 'Str',
   reader => 'get_author',
  );

######################################################################

has 'date' =>
  (
   isa    => 'Str',
   reader => 'get_date',
  );

######################################################################

has 'address' =>
  (
   isa    => 'Str',
   reader => 'get_address',
  );

######################################################################

has 'annote' =>

  (
   isa    => 'Str',
   reader => 'get_annote',
  );

######################################################################

has 'booktitle' =>
  (
   isa    => 'Str',
   reader => 'get_booktitle',
  );

######################################################################

has 'chapter' =>
  (
   isa    => 'Str',
   reader => 'get_chapter',
  );

######################################################################

has 'crossref' =>
  (
   isa    => 'Str',
   reader => 'get_crossref',
  );

######################################################################

has 'edition' =>
  (
   isa    => 'Str',
   reader => 'get_edition',
  );

######################################################################

has 'editor' =>
  (
   isa    => 'Str',
   reader => 'get_editor',
  );

######################################################################

has 'howpublished' =>
  (
   isa    => 'Str',
   reader => 'get_howpublished',
  );

######################################################################

has 'institution' =>
  (
   isa    => 'Str',
   reader => 'get_institution',
  );

######################################################################

has 'journal' =>
  (
   isa    => 'Str',
   reader => 'get_journal',
  );

######################################################################

has 'key' =>
  (
   isa    => 'Str',
   reader => 'get_key',
  );

######################################################################

has 'month' =>
  (
   isa    => 'Str',
   reader => 'get_month',
  );

######################################################################

has 'note' =>
  (
   isa    => 'Str',
   reader => 'get_note',
  );

######################################################################

has 'organization' =>
  (
   isa    => 'Str',
   reader => 'get_organization',
  );

######################################################################

has 'pages' =>
  (
   isa    => 'Str',
   reader => 'get_pages',
  );

######################################################################

has 'publisher' =>
  (
   isa    => 'Str',
   reader => 'get_publisher',
  );

######################################################################

has 'school' =>
  (
   isa    => 'Str',
   reader => 'get_school',
  );

######################################################################

has 'series' =>
  (
   isa    => 'Str',
   reader => 'get_series',
  );

######################################################################

has 'source' =>
  (
   isa    => 'Str',
   reader => 'get_source',
  );

######################################################################

has 'subtitle' =>
  (
   isa    => 'Str',
   reader => 'get_subtitle',
  );

######################################################################

has 'source_type' =>
  (
   isa    => 'Str',
   reader => 'get_source_type',
  );

######################################################################

has 'volume' =>
  (
   isa    => 'Str',
   reader => 'get_volume',
  );

######################################################################

has 'year' =>
  (
   isa    => 'Str',
   reader => 'get_year',
  );

######################################################################

has 'appearance' =>
  (
   isa    => 'Str',
   reader => 'get_appearance',
  );

######################################################################

has 'color' =>
  (
   isa    => 'Str',
   reader => 'get_color',
  );

######################################################################

has 'icon' =>
  (
   isa    => 'Str',
   reader => 'get_icon',
  );

######################################################################

has 'mimetype' =>
  (
   isa    => 'Str',
   reader => 'get_mimetype',
  );

######################################################################

has 'file' =>
  (
   isa    => 'Str',
   reader => 'get_file',
  );

######################################################################

has 'number' =>
  (
   isa    => 'Str',
   reader => 'get_number',
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Source> - an environment that describes a cite-able
bibliographic source.

=head1 VERSION

This documentation refers to L<"SML::Source"> version 2.0.0.

=head1 SYNOPSIS

  my $src = SML::Source->new();

=head1 DESCRIPTION

An SML source is an environment that describes a cite-able
bibliographic source.

=head1 METHODS

=head2 get_name

=head2 get_author

=head2 get_date

=head2 get_address

=head2 get_annote

=head2 get_booktitle

=head2 get_chapter

=head2 get_crossref

=head2 get_edition

=head2 get_editor

=head2 get_howpublished

=head2 get_institution

=head2 get_journal

=head2 get_key

=head2 get_month

=head2 get_note

=head2 get_organization

=head2 get_pages

=head2 get_publisher

=head2 get_school

=head2 get_series

=head2 get_source

=head2 get_subtitle

=head2 get_source_type

=head2 get_volume

=head2 get_year

=head2 get_appearance

=head2 get_color

=head2 get_icon

=head2 get_mimetype

=head2 get_file

=head2 get_number

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
