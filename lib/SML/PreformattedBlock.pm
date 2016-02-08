#!/usr/bin/perl

package SML::PreformattedBlock;         # ci-000427

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Block';                   # ci-000387

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

has '+name' =>
  (
   default => 'PREFORMATTED_BLOCK',
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

  extends SML::Block

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
