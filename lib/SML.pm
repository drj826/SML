#!/usr/bin/perl

package SML;

use Moose;

use version; our $VERSION = qv('2.0.0');

use MooseX::Singleton;
use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.SML');

use SML::Library;

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

# sub get_library {

#   my $self = shift;
#   my $id   = shift;

#   if ( not $id )
#     {
#       $logger->error("YOU MUST SUPPLY THE ID OF THE LIBRARY YOU WANT");
#       return 0;
#     }

#   my $hash = $self->_get_library_hash;

#   if ( exists $hash->{$id} )
#     {
#       return $hash->{$id};
#     }

#   else
#     {
#       $logger->error("LIBRARY DOESN'T EXIST: $id");
#       return 0;
#     }
# }

######################################################################

# sub add_library {

#   my $self    = shift;
#   my $library = shift;

#   if ( not ref $library and $library->isa('SML::Library') )
#     {
#       $logger->error("CAN'T ADD NON-LIBRARY OBJECT: $library");
#       return 0;
#     }

#   my $hash = $self->_get_library_hash;
#   my $id = $library->get_id;

#   $hash->{$id} = $library;

#   return 1;
# }

######################################################################

# sub has_library {

#   my $self = shift;
#   my $id   = shift;

#   if ( not $id )
#     {
#       $logger->error("YOU MUST SUPPLY A LIBRARY ID");
#       return 0;
#     }

#   my $hash = $self->_get_library_hash;

#   if ( exists $hash->{$id} )
#     {
#       return 1;
#     }

#   else
#     {
#       return 0;
#     }
# }

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

# has 'library_hash' =>
#   (
#    isa     => 'HashRef',
#    reader  => '_get_library_hash',
#    default => sub {{}},
#   );

# A hash of libraries keyed by library name.

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

C<SML> - a singleton that represents a customizable Structured Manuscript Language.

=head1 VERSION

This documentation refers to L<SML> version 2.0.0.

=head1 SYNOPSIS

  use SML;

  my $sml = SML->instance;

=head1 DESCRIPTION

Structured Manuscript Language (SML) is a minimalistic descriptive
markup language designed to be: human readable, customizable, easy to
edit, easy to automatically generate, able to express and validate
semantic relationships, and contain all information necessary to
publish professional documentation from plain text manuscripts.

=head1 METHODS

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
