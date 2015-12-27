#!/usr/bin/perl

# $Id: Audio.pm 77 2015-01-31 17:48:03Z drj826@gmail.com $

package SML::Audio;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Division';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Audio');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'AUDIO',
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Audio> - an environment that instructs the publishing
application to insert an audio clip into the document.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Division

  my $audio = SML::Audio->new
                (
                  id      => $id,
                  library => $library,
                );

=head1 DESCRIPTION

An SML audio environment instructs the publishing application to
insert an audio clip into the document.

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
