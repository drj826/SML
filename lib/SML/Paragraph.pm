#!/usr/bin/perl

package SML::Paragraph;                 # ci-000425

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Block';                   # ci-000387

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Paragraph');

######################################################################

=head1 NAME

SML::Paragraph - a block of text that expresses a thought

=head1 SYNOPSIS

  SML::Paragraph->new(library=>$library);

=head1 DESCRIPTION

An C<SML::Paragraph> is a block of text that expresses a thought.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has value =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_value',
   writer    => 'set_value',
   predicate => 'has_value',
  );

=head2 get_value

Return a scalar text value which is the content of the paragraph.

  my $text = $paragraph->get_value;

This is the raw text of the paragraph.  This can be different than
'content' because when the paragraph is the first block of a table
cell the leading markup must be stripped.

=head2 set_value($value)

Set the value of a paragraph.

  $paragraph->set_value($text);

=head2 has_value

Return 1 if the paragraph has a value.

  my $result = $paragraph->has_value;

=cut

######################################################################

has value_string =>
  (
   is        => 'ro',
   isa       => 'SML::String',
   reader    => 'get_value_string',
   writer    => 'set_value_string',
   predicate => 'has_value_string',
  );

=head2 get_value_string

Return an C<SML::String> of the content of the paragraph.

  my $string = $paragraph->get_value_string;

This is the C<SML::String> produced by parsing the raw text of the
paragraph.

=head2 set_value_string($string)

Set the value string of a paragraph.

  $paragraph->set_value_string($string);

=head2 has_value_string

Return 1 if the paragraph has a value string.

  my $result = $paragraph->has_value_string;

=cut

######################################################################
######################################################################
##
## Public Methods
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
