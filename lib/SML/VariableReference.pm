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

=head1 NAME

SML::VariableReference - reference a variable

=head1 SYNOPSIS

  SML::VariableReference->new
    (
      variable_name   => $variable_name,
      namespace       => $namespace,
      library         => $library,
      containing_part => $part,
    );

  $ref->get_variable_name;              # Str
  $ref->get_namespace;                  # Str

=head1 DESCRIPTION

An C<SML::VariableReference> extends C<SML::String> to represent a
reference to a previously defined variable.

=head1 METHODS

=cut

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

=head2 get_variable_name

Return a scalar text value which is the referenced variable name.

  my $name = $ref->get_variable_name;

=cut

######################################################################

has namespace =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_namespace',
   default  => '',
  );

=head2 get_namespace

Return a scalar text value which is the namespace of the referenced
variable.

  my $namespace = $ref->get_namespace;

=cut

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
