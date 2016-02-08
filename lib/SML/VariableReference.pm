#!/usr/bin/perl

package SML::VariableReference;         # ci-000472

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.VariableReference');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has variable_name =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_variable_name',
   required => 1,
  );

######################################################################

has namespace =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_namespace',
   default  => '',
  );

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'VARIABLE_REF',
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

C<SML::VariableReference> - a reference to a previously defined
variable

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [var:conference-2:head-count]

  my $ref = SML::VariableReference->new
              (
                variable_name   => $variable_name,   # 'head-count'
                namespace       => $namespace,       # 'conference-2'
                library         => $library,
                containing_part => $part,
              );

  my $string = $ref->get_variable_name;   # 'head-count'
  my $string = $ref->get_namespace;       # 'conference-2'

=head1 DESCRIPTION

Extends C<SML::String> to represent a reference to a previously
defined variable.

=head1 METHODS

=head2 get_filespec

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
