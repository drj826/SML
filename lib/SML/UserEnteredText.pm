#!/usr/bin/perl

# $Id: UserEnteredText.pm 268 2015-05-11 12:01:01Z drj826@gmail.com $

package SML::UserEnteredText;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.UserEnteredText');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'USER_ENTERED_TEXT',
  );

######################################################################

has 'tag' =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_tag',
   required => 1,
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

C<SML::UserEnteredText> - a string that represents text entered by a
user

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [enter:1-800-555-1234]

  my $ref = SML::UserEnteredText->new
              (
                tag             => $tag,        # 'enter'
                content         => $content,    # '1-800-555-1234'
                library         => $library,
                containing_part => $part,
              );

=head1 DESCRIPTION

Extends C<SML::String> to represent text entered by a user

=head1 METHODS

=head2 get_tag

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
