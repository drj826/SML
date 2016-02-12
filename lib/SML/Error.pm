#!/usr/bin/perl

package SML::Error;                     # ci-000446

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Error');

######################################################################

=head1 NAME

SML::Error - an error

=head1 SYNOPSIS

  SML::Error->new
    (
      level    => $level,
      location => $location,
      message  => $message,
    );

  $error->get_level;                    # Str
  $error->get_location;                 # Str
  $error->get_message;                  # Str

=head1 DESCRIPTION

An C<SML::Error> is an error message.  It includes an error level (one
of: WARN, ERROR, or FATAL), a location, and a message.  The location
is a scalar text value that describes where the error took place,
typically the manuscript file and line number.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has level =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_level',
   required => 1,
  );

=head2 get_level

Return the scalar text value of the error level (WARN, ERROR, or
FATAL).

  my $level = $error->get_level;

=cut

######################################################################

has location =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_location',
   default  => q{},
  );

=head2 get_location

Return a scalar text value that represents the manuscript location of
the error (if applicable).

  my $location = $error->get_location;

=cut

######################################################################

has message =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_message',
   required => 1,
  );

=head2 get_message

Return a scalar text value which is the error message itself.

  my $message = $error->get_message;

=cut

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

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012-2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
