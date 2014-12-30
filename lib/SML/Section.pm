#!/usr/bin/perl

package SML::Section;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Division';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.section');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

# has '+type' =>
#   (
#    default => 'division',
#   );

######################################################################

has '+name' =>
  (
   default => 'SECTION',
  );

######################################################################

has '+id' =>
  (
   required => 1,
  );

######################################################################

# has '+number' =>
#   (
#    default   => '1',
#   );

######################################################################

has 'depth' =>
  (
   isa      => 'Int',
   reader   => 'get_depth',
   required => 1,
  );

######################################################################

has 'sectype' =>
  (
   isa     => 'Str',
   reader  => 'get_sectype',
   default => 'Section',
  );

######################################################################

has 'top_number' =>
  (
   isa       => 'Str',
   reader    => 'get_top_number',
   writer    => 'set_top_number',
   clearer   => 'clear_top_number',
   predicate => 'has_top_number',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Section> - an element of document structure, that begins with a
section heading, and contains information about a specific topic.

=head1 VERSION

This documentation refers to L<"SML::Section"> version 2.0.0.

=head1 SYNOPSIS

  my $sec = SML::Section->new();

=head1 DESCRIPTION

An SML section is an element of document structure, that begins with a
section heading, and contains information about a specific topic.
Authors may create section headings at different levels to create a
hierarchy of sections to organize document content.

=head1 METHODS

=head2 get_type

=head2 get_name

=head2 get_id

=head2 get_depth

=head2 get_sectype

=head2 get_number

=head2 get_top_number

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
