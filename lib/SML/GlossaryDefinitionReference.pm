#!/usr/bin/perl

package SML::GlossaryDefinitionReference;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.GlossaryDefinitionReference');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has term =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_term',
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
   default => 'GLOSS_DEF_REF',
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

C<SML::GlossaryDefinitionReference> - a reference to the definition of
a term in the glossary

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [def:ieee:configuration item]

  my $ref = SML::GlossaryDefinitionReference->new
              (
                term            => $term,       # 'configuration item'
                namespace       => $namespace,  # 'ieee'
                library         => $library,
                containing_part => $part,
              );

  my $string = $ref->get_term;       # 'configuration item'
  my $string = $ref->get_namespace;  # 'ieee'

=head1 DESCRIPTION

Extends C<SML::String> to represent a reference to a glossary term
definition.

=head1 METHODS

=head2 get_term

=head2 get_namespace

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
