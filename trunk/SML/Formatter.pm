#!/Usr/bin/perl

package SML::Formatter;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

# use Template;
use Text::Wrap;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.formatter');

######################################################################
######################################################################
##
## Attributes
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub format_block {

  my $self  = shift;
  my $block = shift;
  my $style = shift || 'DEFAULT' ;
  my $text  = q{};

  return $text;
}

######################################################################

sub format_division {

  my $self     = shift;
  my $division = shift;
  my $style    = shift || 'DEFAULT' ;
  my $text     = q{};

  return $text;
}

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

C<SML::Formatter> - generates output text from SML content objects.

=head1 VERSION

This documentation refers to L<"SML::Formatter"> version 2.0.0.

=head1 SYNOPSIS

  my $fmtr = SML::Formatter->new();

=head1 DESCRIPTION

A formatter generates output text from SML content objects.

=head1 METHODS

=head2 format_block

=head2 format_division

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
