#!/usr/bin/perl

package SML::Source;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';

use namespace::autoclean;

use File::Basename;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Source');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'SOURCE',
  );

######################################################################

has author =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_author',
   writer    => 'set_author',
   predicate => 'has_author',
  );

######################################################################

has date =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_date',
   writer    => 'set_date',
   predicate => 'has_date',
  );

######################################################################

has address =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_address',
   writer    => 'set_address',
   predicate => 'has_address',
  );

######################################################################

has annote =>

  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_annote',
   writer    => 'set_annote',
   predicate => 'has_annote',
  );

######################################################################

has booktitle =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_booktitle',
   writer    => 'set_booktitle',
   predicate => 'has_booktitle',
  );

######################################################################

has chapter =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_chapter',
   writer    => 'set_chapter',
   predicate => 'has_chapter',
  );

######################################################################

has crossref =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_crossref',
   writer    => 'set_crossref',
   predicate => 'has_crossref',
  );

######################################################################

has edition =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_edition',
   writer    => 'set_edition',
   predicate => 'has_edition',
  );

######################################################################

has editor =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_editor',
   writer    => 'set_editor',
   predicate => 'has_editor',
  );

######################################################################

has howpublished =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_howpublished',
  );

######################################################################

has institution =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_institution',
  );

######################################################################

has journal =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_journal',
  );

######################################################################

has key =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_key',
  );

######################################################################

has month =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_month',
  );

######################################################################

has note =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_note',
  );

######################################################################

has organization =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_organization',
  );

######################################################################

has pages =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_pages',
  );

######################################################################

has publisher =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_publisher',
  );

######################################################################

has school =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_school',
  );

######################################################################

has series =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_series',
  );

######################################################################

has source =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_source',
  );

######################################################################

has subtitle =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_subtitle',
  );

######################################################################

has source_type =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_source_type',
  );

######################################################################

has volume =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_volume',
  );

######################################################################

has year =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_year',
  );

######################################################################

has appearance =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_appearance',
  );

######################################################################

has color =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_color',
  );

######################################################################

has icon =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_icon',
  );

######################################################################

has mimetype =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_mimetype',
  );

######################################################################

has file =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_file',
  );

######################################################################

has number =>
  (
   is     => 'ro',
   isa    => 'Str',
   reader => 'get_number',
  );

######################################################################

has basename =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_basename',
   builder => '_build_basename',
   lazy    => 1,
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

  my $self = shift;

  my $library = $self->get_library;
  my $id      = $self->get_id;
  my $ps      = $library->get_property_store;

  if ( $ps->has_property($id,'file') )
    {
      my $filespec = $ps->get_property_text($id,'file');

      return basename($filespec);
    }

  else
    {
      return 0;
    }
}

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

  extends SML::Division

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

=head2 get_basename

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
