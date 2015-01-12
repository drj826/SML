#!/usr/bin/perl

package SML::Paragraph;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Block';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Paragraph');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'PARAGRAPH',
  );

######################################################################

has '+type' =>
  (
   default => 'paragraph',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

# sub start_html {

#   my $self = shift;
#   my $html = shift;

#   return '<p>' . $html;
# }

######################################################################

# sub end_html {

#   my $self = shift;
#   my $html = shift;

#   return $html . '</p>';
# }

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Paragraph> - a block of text that represents one item in a
sequence or hierarchy of items.

=head1 VERSION

This documentation refers to L<"SML::Paragraph"> version 2.0.0.

=head1 SYNOPSIS

  my $para = SML::Paragraph->new();

=head1 DESCRIPTION

An paragraph is a block of text that represents one item in a sequence
or hierarchy of items.

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
