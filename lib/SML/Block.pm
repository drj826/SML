#!/usr/bin/perl

package SML::Block;

use Moose;

extends 'SML::Part';

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use lib "..";

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Block');

use Cwd;

######################################################################

=head1 NAME

SML::Block - a block of SML formatted text

=head1 SYNOPSIS

  SML::Block->new
    (
      name    => $name,                           # Str
      library => $library,                        # SML::Library
    );

  $block->get_line_list;                          # ArrayRef
  $block->get_containing_division;                # SML::Division
  $block->set_containing_division($division);     # Bool
  $block->has_containing_division;                # Bool
  $block->has_valid_syntax;                       # Bool
  $block->has_valid_semantics;                    # Bool
  $block->add_line($line);                        # Bool
  $block->add_part($part);                        # Bool
  $block->get_first_line;                         # SML::Line
  $block->get_location;                           # Str
  $block->is_in_a($division_name);                # Bool

=head1 DESCRIPTION

A block is one or more contiguous whole lines of text.  Blocks are
separated by blank lines and therefore cannot contain blank lines.
Blocks may contain inline text elements

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has line_list =>
  (
   is        => 'ro',
   isa       => 'ArrayRef',
   reader    => 'get_line_list',
   default   => sub {[]},
  );

=head2 get_line_list

Return an ArrayRef to a list of lines in this block.

  my $list = $block->get_line_list;

=cut

######################################################################

has containing_division =>
  (
   is        => 'ro',
   isa       => 'SML::Division',
   reader    => 'get_containing_division',
   writer    => 'set_containing_division',
   predicate => 'has_containing_division',
  );

# The division that contains this block.

after 'set_containing_division' => sub {
  my $self = shift;
  my $cd   = $self->get_containing_division;
  $logger->trace("..... containing division for \'$self\' now: \'$cd\'");
};

=head2 get_containing_division

Return the L<SML::Division> that contains this block.

  my $division = $block->get_containing_division;

=head2 set_containing_division

Set the specified division to be the one that contains this block.

  my $result = $block->set_containing_division($division);

=head2 has_containing_division

Return 1 if this block has a containing division.

  my $result = $block->has_containing_division;

=cut

######################################################################

has has_been_parsed =>
  (
   is      => 'ro',
   isa     => 'Bool',
   reader  => 'has_been_parsed',
   writer  => 'set_has_been_parsed',
   default => 0,
  );

=head2 has_been_parsed

Return 1 if this block has been parsed into strings. This boolean
value tracks whether the block has been parsed into strings.  There's
no reason to perform the unnecessary work of parsing the same block
over and over again.

  my $result = $block->has_been_parsed;

=head2 set_has_been_parsed

Set the value of 'has_been_parsed' to the specified value.

  $block->set_has_been_parsed(1);

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_line {

  my $self = shift;
  my $line = shift;

  unless ( ref $line and $line->isa('SML::Line') )
    {
      $logger->("CAN'T ADD LINE \'$line\' is not a line");
      return 0;
    }

  push @{ $self->get_line_list }, $line;

  return 1;
}

=head2 add_line

Add a line to this block.  Return 1 if successful.

  my $result = $block->add_line($line);

=cut

######################################################################

sub add_part {

  my $self = shift;
  my $part = shift;

  unless ( ref $part and $part->isa('SML::String') )
    {
      $logger->error("CAN'T ADD PART \'$part\' is not a string");
      return 0;
    }

  # $part->set_containing_block( $self );

  push @{ $self->get_part_list }, $part;

  $logger->trace("add part $part");

  return 1;
}

=head2 add_part

Add a part to this block.  Return 1 if successful.  An L<SML::String>
is the only type of part that can be added to a block.

  my $result = $block->add_part($string);

=cut

######################################################################

sub get_first_line {

  my $self = shift;

  if ( defined $self->get_line_list->[0] )
    {
      return $self->get_line_list->[0];
    }

  # $logger->error("FIRST LINE DOESN'T EXIST");
  return 0;
}

=head2 get_first_line

Return the first line (an L<SML::Line>) of this block.

  my $line = $block->get_first_line;

=cut

######################################################################

sub get_location {

  my $self = shift;

  my $line = $self->get_first_line;

  if ( ref $line and $line->isa('SML::Line') )
    {
      return $line->get_location;
    }

  return 'UNKNOWN LOCATION';
}

=head2 get_location

Return the location (<filespec>:<line number>) of the first line of
this block.

  my $location = $block->get_location;

=cut

######################################################################

sub is_in_a {

  my $self = shift;
  my $name = shift;

  my $division = $self->get_containing_division || q{};

  while ( $division )
    {
      if ( $division->isa($name) )
	{
	  return 1;
	}

      elsif ( $division->has_containing_division )
	{
	  $division = $division->get_containing_division;
	}

      else
	{
	  return 0;
	}
    }

  return 0;
}

=head2 is_in_a

Return 1 if this block is in a division with the specified name (even
if it is buried several divisions deep).

  my $result = $block->is_in_a($name);

=cut

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

sub _build_content {

  my $self  = shift;
  my $lines = [];

  if ( $self->get_name eq 'empty_block' )
    {
      return q{};
    }

  foreach my $line (@{ $self->get_line_list })
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp

      push @{ $lines }, $text;
    }

  my $content = join(q{ }, @{ $lines });

  # trim whitespace from end of content
  $content =~ s/\s*$//;

  return $content;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

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
