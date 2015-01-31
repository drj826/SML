#!/usr/bin/perl

package SML::Resource;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Resource');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has 'tier' =>
  (
   isa       => 'Int',
   reader    => 'get_tier',
   writer    => '_set_tier',
   clearer   => '_clear_tier',
   predicate => '_set_tier',
   default   => 1,
  );

# The 'tier' of a resource represents how close it is to the main
# document resource (i.e. file).  The main document file is tier 1.
# Files included by the main file are tier 2.  Files included by tier
# 2 files are tier 3 file, and so on.

######################################################################

has 'resource_hash' =>
  (
   isa       => 'HashRef',
   reader    => 'get_resource_hash',
   writer    => 'set_resource_hash',
   clearer   => 'clear_resource_hash',
   predicate => 'has_resource_hash',
   default   => sub {{}},
  );

# This is a hash of resources (i.e. files), used directly by *this*
# resource. It is indexed by filespec.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_resource {

  my $self      = shift;
  my $resource  = shift;
  my $filespec  = $resource->get_filespec;

  # !!! BUG HERE !!!
  #
  # SML::Resource does not provide 'get_filespec' method?

  $self->get_resource_hash->{$filespec} = $resource;

  return 1;
}

######################################################################

sub has_resource {

  my $self     = shift;
  my $filespec = shift;

  if ( exists $self->get_resource_hash->{$filespec} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_resource {

  my $self     = shift;
  my $filespec = shift;

  if ( exists $self->get_resource_hash->{$filespec} )
    {
      return $self->get_resource_hash->{$filespec};
    }

  else
    {
      $logger->error("CAN'T GET RESOURCE \'$filespec\'");
      return 0;
    }
}

######################################################################

sub validate {

  my $self = shift;

  return 1;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Resource> - a file or other data source external to the
document file upon which the document depends such as a fragment file,
attachment file, image file, script file, etc.

=head1 VERSION

This documentation refers to L<"SML::Resource"> version 2.0.0.

=head1 SYNOPSIS

  my $rsrc = SML::Resource->new();

=head1 DESCRIPTION

A resource is a file or other data source external to the document
file upon which the document depends such as a fragment file,
attachement file, image file, script file, etc.

=head1 METHODS

=head2 get_tier

=head2 get_resource_hash

=head2 add_resource

=head2 has_resource

=head2 get_resource

=head2 validate

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
