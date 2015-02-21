#!/usr/bin/perl

# $Id$

package SML::PreformattedBlock;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Block';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.PreformattedBlock');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+type' =>
  (
   default => 'block',
  );

######################################################################

has '+name' =>
  (
   default => 'preformatted',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub validate_bold_markup {

  # Assume all preformatted blocks have valid bold markup.

  return 1;
}

######################################################################

sub validate_italics_markup {

  # Assume all preformatted blocks have valid italics markup.

  return 1;
}

######################################################################

sub validate_fixedwidth_markup {

  # Assume all preformatted blocks have valid fixed-width markup.

  return 1;
}

######################################################################

sub validate_underline_markup {

  # Assume all preformatted blocks have valid underline markup.

  return 1;
}

######################################################################

sub validate_superscript_markup {

  # Assume all preformatted blocks have valid superscript markup.

  return 1;
}

######################################################################

sub validate_subscript_markup {

  # Assume all preformatted blocks have valid subscript markup.

  return 1;
}

######################################################################

sub validate_inline_tags {

  # Assume all preformatted blocks have valid inline tags.

  return 1;
}

######################################################################

sub validate_cross_refs {

  # Assume all preformatted blocks have valid cross references.

  return 1;
}

######################################################################

sub validate_id_refs {

  # Assume all preformatted blocks have valid ID references.

  return 1;
}

######################################################################

sub validate_page_refs {

  # Assume all preformatted blocks have valid page references.

  return 1;
}

######################################################################

sub validate_theversion_refs {

  # Assume all preformatted blocks have valid version references.

  return 1;
}

######################################################################

sub validate_therevision_refs {

  # Assume all preformatted blocks have valid revision references.

  return 1;
}

######################################################################

sub validate_thedate_refs {

  # Assume all preformatted blocks have valid date references.

  return 1;
}

######################################################################

sub validate_status_refs {

  # Assume all preformatted blocks have valid status references.

  return 1;
}

######################################################################

sub validate_glossary_term_refs {

  # Assume all preformatted blocks have valid glossary term
  # references.

  return 1;
}

######################################################################

sub validate_glossary_def_refs {

  # Assume all preformatted blocks have valid glossary definition
  # references.

  return 1;
}

######################################################################

sub validate_acronym_refs {

  # Assume all preformatted blocks have valid acronym references.

  return 1;
}

######################################################################

sub validate_source_citations {

  # Assume all preformatted blocks have valid source citations.

  return 1;
}

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _build_content {

  my $self    = shift;
  my $content = '';

  foreach my $line (@{ $self->get_line_list })
    {
      $content .= $line->get_content;
    }

  return $content;

}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::PreformattedBlock> - a block of text to be formatted as
preformatted text.

=head1 VERSION

This documentation refers to L<"SML::PreformattedBlock"> version
2.0.0.

=head1 SYNOPSIS

  my $pfb = SML::PreformattedBlock->new();

=head1 DESCRIPTION

A block of text to be formatted as preformatted text.

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
