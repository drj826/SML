#!/usr/bin/perl

package SML::Value;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Value');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has element =>
  (
   is        => 'ro',
   isa       => 'SML::Element',
   reader    => 'get_element',
   predicate => 'has_element',
  );

# If the value is asserted by an element in the manuscript, this is
# the element.  The value of this element may be a complex string.

######################################################################

has from_manuscript =>
  (
   is      => 'ro',
   isa     => 'Bool',
   reader  => 'is_from_manuscript',
   default => 0,
  );

# Set this boolean to 1 if the value is asserted by an element in the
# manuscript or to 0 if the value was inferred by the reasoner or any
# other mechanism.

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Value> - an environment that instructs the publishing
application to insert an value clip into the document.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Division

  my $value = SML::Value->new
                (
                  id      => $id,
                  library => $library,
                );

=head1 DESCRIPTION

An SML value environment instructs the publishing application to
insert an value clip into the document.

=head1 METHODS

=head2 get_name

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
