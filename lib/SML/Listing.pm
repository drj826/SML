#!/usr/bin/perl

# $Id: Listing.pm 77 2015-01-31 17:48:03Z drj826@gmail.com $

package SML::Listing;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Listing');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'LISTING',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_content {

  # Return the plain text content of the listing.

  my $self = shift;

  my $library = $self->get_library;
  my $id      = $self->get_id;

  if ( $library->has_property($id,'file') )
    {
      my $list = $library->get_property_value_list($id,'file');

      # just take the first value, ignore the rest
      my $filespec = $list->[0];

      my $file = SML::File->new
	(
	 filespec => $filespec,
	 library  => $library,
	);

      return $file->get_text;
    }

  else
    {
      my $text = q{};

      foreach my $part (@{ $self->get_narrative_part_list })
	{
	  my $name = $part->get_name;

	  next if $name eq 'BEGIN_DIVISION';
	  next if $name eq 'END_DIVISION';

	  $text .= $part->get_content;
	}

      return $text;
    }

  return 0;
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Listing> - an environment that instructs the publishing
application to insert a listing into the document.

=head1 VERSION

This documentation refers to L<"SML::Listing"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::Division

  my $lis = SML::Listing->new();

=head1 DESCRIPTION

An SML listing is an environment that instructs the publishing
application to insert a listing into the document.

=head1 METHODS

=head2 get_name

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
