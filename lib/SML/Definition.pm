#!/usr/bin/perl

# $Id: Definition.pm 235 2015-03-23 20:21:38Z drj826@gmail.com $

package SML::Definition;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Element';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Definition');

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

######################################################################

has namespace =>
  (
   is        => 'ro',
   isa       => 'Maybe[Str]',
   reader    => 'get_namespace',
   writer    => 'set_namespace',
   predicate => 'has_namespace',
  );

######################################################################

has definition =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_definition',
   writer    => 'set_definition',
   predicate => 'has_definition',
  );

######################################################################

has term_string =>
  (
   is        => 'ro',
   isa       => 'SML::String',
   reader    => 'get_term_string',
   writer    => 'set_term_string',
   predicate => 'has_term_string',
  );

######################################################################

has definition_string =>
  (
   is        => 'ro',
   isa       => 'SML::String',
   reader    => 'get_definition_string',
   writer    => 'set_definition_string',
   predicate => 'has_definition_string',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_bookmark {

  # Return a string suitable for use as an HTML hyperlink bookmark.

  my $self = shift;

  my $term      = $self->get_term;
  my $namespace = $self->get_namespace || q{};

  $term      = lc($term);               # lowercase
  $namespace = lc($namespace);          # lowercase

  $term      =~ s/\s+/_/g;              # spaces to underscores
  $namespace =~ s/\s+/_/g;              # spaces to underscores

  if ( $namespace )
    {
      return "$term:$namespace";
    }

  else
    {
      return "$term";
    }
}

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

# sub _build_term {

#   my $self = shift;

#   my $library = $self->get_library;
#   my $syntax  = $library->get_syntax;
#   my $text    = $self->get_content;

#   $text =~ s/[\r\n]*$//;                # chomp;

#   if ( $text =~ /$syntax->{definition_element}/xms )
#     {
#       return $2;
#     }

#   else
#     {
#       $logger->error("DEFINITION SYNTAX ERROR term not found");
#       return q{};
#     }
# }

######################################################################

# sub _build_namespace {

#   my $self = shift;

#   my $library = $self->get_library;
#   my $syntax  = $library->get_syntax;
#   my $text    = $self->get_content;

#   $text =~ s/[\r\n]*$//;                # chomp;

#   if ( $text =~ /$syntax->{definition_element}/xms )
#     {
#       return $4 || q{};
#     }

#   else
#     {
#       $logger->error("DEFINITION SYNTAX ERROR");
#       return q{};
#     }
# }

######################################################################

# sub _build_definition {

#   my $self = shift;

#   my $library = $self->get_library;
#   my $syntax  = $library->get_syntax;
#   my $text    = $self->get_content;

#   $text =~ s/[\r\n]*$//;                # chomp;

#   if ( $text =~ /$syntax->{definition_element}/xms )
#     {
#       return $5;
#     }

#   else
#     {
#       $logger->error("DEFINITION SYNTAX ERROR value not found");
#       return q{};
#     }
# }

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Definition> - an element that defines an
term/namespace/definition triple.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Element

  my $definition = SML::Definition->new
                     (
                       name    => $name,
                       library => $library,
                     );

  my $string = $definition->get_term;
  my $string = $definition->get_namespace;
  my $string = $definition->get_definition;

=head1 DESCRIPTION

A definition is an element that defines an term/namespace/definition
triple.

=head1 METHODS

=head2 get_term

=head2 get_namespace

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
