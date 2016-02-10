#!/usr/bin/perl

package SML::Definition;                # ci-000415

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Element';                 # ci-000386

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Definition');

######################################################################

=head1 NAME

SML::Definition - definition of a term in a namespace

=head1 SYNOPSIS

  SML::Definition->new
    (
      name    => $name,
      library => $library,
    );

  $definition->get_term;                       # Str
  $definition->set_term($term);                # Bool
  $definition->has_term;                       # Bool

  $definition->get_namespace;                  # Str
  $definition->set_namespace($namespace);      # Bool
  $definition->has_namespace;                  # Bool

  $definition->get_definition;                 # Str
  $definition->set_definition($definition);    # Bool
  $definition->hash_definition;                # Bool

  $definition->get_term_string;                # SML::String
  $definition->set_term_string($string);       # Bool
  $definition->has_term_string;                # Bool

  $definition->get_definition_string;          # SML::String
  $definition->set_definition_string($string); # Bool
  $definition->has_definition_string;          # Bool

  $definition->already_used;                   # Bool
  $definition->set_already_used;               # Bool

  $definition->get_bookmark;                   # Str

=head1 DESCRIPTION

A definition is an element that defines a term within a namespace.
The namespace is like a context.  The same term might have different
definitions in different namespaces.

This definition class is used for:

=over 4

=item

glossary definitions

=item

acronym definitions

=item

variable definitions

=item

attribute definitions

=back

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has term =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_term',
   writer    => 'set_term',
   predicate => 'has_term',
  );

=head2 get_term

Return a scalar text value which is the term being defined.  This
value may contain SML markup.

  my $term = $definition->get_term;

For example, I<CI> is the term being defined in the following
acronym definition:

  acronym:: CI {IEEE} = configuration item

=head2 set_term

Set the specified term as the term being defined in the definition.

  my $result = $definition->set_term($term);

=head2 has_term

Return 1 if this definition has a term.

  my $result = $definition->has_term;

=cut

######################################################################

has namespace =>
  (
   is        => 'ro',
   isa       => 'Maybe[Str]',
   reader    => 'get_namespace',
   writer    => 'set_namespace',
   predicate => 'has_namespace',
   default   => q{},
  );

=head2 get_namespace

Return a scalar text value which is the namespace of the term being
defined.

  my $namespace = $definition->get_namespace;

For example, I<IEEE> is the namespace of the term being defined in the
following acronym definition:

  acronym:: CI {IEEE} = configuration item

=head2 set_namespace

Set the specified namespace as the namespace of the term being defined
in the definition.

  my $result = $definition->set_namespace($namespace);

=head2 has_namespace

Return 1 if this definition has a namespace.

  my $result = $definition->has_namespace;

=cut

######################################################################

has definition =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_definition',
   writer    => 'set_definition',
   predicate => 'has_definition',
  );

=head2 get_definition

Return a scalar text value which is the definition of the term.  This
value may contain SML markup.

  my $definition = $definition->get_definition;

For example, I<configuration item> is the definition of the term in
the following acronym definition:

  acronym:: CI {IEEE} = configuration item

=head2 set_definition

Set the specified definition as the definition of the term.

  my $result = $definition->set_definition($definition);

=head2 has_definition

Return 1 if this definition has a definition.

  my $result = $definition->has_definition;

=cut

######################################################################

has term_string =>
  (
   is        => 'ro',
   isa       => 'SML::String',
   reader    => 'get_term_string',
   writer    => 'set_term_string',
   predicate => 'has_term_string',
  );

=head2 get_term_string

Return an C<SML::String> of the term being defined.

  my $string = $definition->get_term_string;

=head2 set_term_string

Set the specified C<SML::String> as the term string.

  my $result = $definition->set_term_string($string);

=head2 has_term_string

Return 1 if this definition has a term string.

  my $result = $definition->has_term_string;

=cut

######################################################################

has definition_string =>
  (
   is        => 'ro',
   isa       => 'SML::String',
   reader    => 'get_definition_string',
   writer    => 'set_definition_string',
   predicate => 'has_definition_string',
  );

=head2 get_definition_string

Return an C<SML::String> which is the definition of the term.

  my $string = $definition->get_definition_string;

=head2 set_definition_string

Set the specified C<SML::String> as the definition string.

  my $result = $definition->set_definition_string($string);

=head2 has_definition_string

Return 1 if this definition has a definition string.

  my $result = $definition->has_definition_string;

=cut

######################################################################

has already_used =>
  (
   is      => 'ro',
   isa     => 'Bool',
   reader  => 'already_used',
   writer  => 'set_already_used',
   default => '0',
  );

=head2 already_used

Return 1 if this definition has already been used in the rendered
document or section.  This boolean value is often used for acronym
definitions.  A document designer may want the first use of an acronym
to be fully spelled out but subsequent uses to be displayed in short
form.  The presentation logic (like a templating system) can read and
set this boolean value to track whether the definition (i.e. an
acronym definition) has already been used in the document.

  my $used = $definition->already_used;

=head2 set_already_used

Set the state of this boolean to the specified value.

  my $result = $definition->set_already_used(1);

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_bookmark {

  my $self = shift;

  my $term      = $self->get_term;
  my $namespace = $self->get_namespace || q{};

  $term      = lc($term);               # lowercase
  $namespace = lc($namespace);          # lowercase

  $term      =~ s/\s+/_/g;              # spaces to underscores
  $namespace =~ s/\s+/_/g;              # spaces to underscores

  my $bookmark;

  if ( $namespace )
    {
      $bookmark = "$term:$namespace";
    }

  else
    {
      $bookmark = "$term";
    }

  return $bookmark;
}

=head2 get_bookmark

Return a string suitable for use as an HTML hyperlink bookmark.

  my $bookmark = $definition->get_bookmark.

=cut

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
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
