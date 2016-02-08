#!/usr/bin/perl

package SML::Symbol;                    # ci-000467

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Symbol');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has preceding_character =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_preceding_character',
   default => '',
  );

# This is the single character immediately preceding

######################################################################

has following_character =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_following_character',
   default => '',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

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

C<SML::Symbol> - a special character not represented by 7-bit ASCII

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  my $symbol = SML::Symbol->new
              (
                content         => $content,
                library         => $library,
                containing_part => $part,
              );

  my $string = $symbol->get_preceding_character;
  my $string = $symbol->get_following_character;

=head1 DESCRIPTION

Extends C<SML::String> to represent a symbol not represented by 7-bit
ACSII.

=head1 METHODS

=head2 get_preceding_character

=head2 get_following_character

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
