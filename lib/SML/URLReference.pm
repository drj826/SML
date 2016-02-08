#!/usr/bin/perl

package SML::URLReference;              # ci-000470

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.URLReference');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has url =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_url',
   required => 1,
  );

######################################################################

has '+name' =>
  (
   default => 'URL_REF',
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

C<SML::URLReference> - a string that represents a URL

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [url:http://www.cnn.com/|Cable News Network]

  my $ref = SML::URLReference->new
                (
                  url             => $url,        # 'http://www.cnn.com/'
                  content         => $content,    # 'Cable News Network'
                  library         => $library,
                  containing_part => $part,
                );

  my $string = $url->get_url;   # 'http://www.cnn.com/'

=head1 DESCRIPTION

Extends C<SML::String> to represent a URL.

=head1 METHODS

=head2 get_url

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
