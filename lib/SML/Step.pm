#!/usr/bin/perl

package SML::Step;                      # ci-000465

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Element';                 # ci-000386

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Step');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'step',
  );

######################################################################

has number =>
  (
   is        => 'ro',
   isa       => 'Int',
   reader    => 'get_number',
   writer    => 'set_number',
   predicate => 'has_number',
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

# NONE

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Step> - an item in a step list.

=head1 VERSION

This documentation refers to L<"SML::Step"> version 2.0.0.

=head1 SYNOPSIS

  extends SML::ListItem

  my $eli = SML::Step->new();

=head1 DESCRIPTION

A enumerated list item is an item in a enumerated list.

=head1 METHODS

=head2 get_name

=head2 get_type

=head2 get_value

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
