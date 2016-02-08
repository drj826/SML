#!/usr/bin/perl

package SML;                            # ci-000002

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

SML - use SML software

=head1 SYNOPSIS

  use SML;

=head1 DESCRIPTION

Structured Manuscript Language (SML) is a minimalistic descriptive
markup language designed to be: human readable, customizable, easy to
edit, easy to automatically generate, able to express and validate
semantic relationships, and contain all information necessary to
publish professional documentation from plain text manuscripts.

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012,2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
