#!/usr/bin/perl

# $Id: Block.pm 255 2015-04-01 16:07:27Z drj826@gmail.com $

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

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_line {

  # Add a line to this block.

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

######################################################################

sub add_part {

  # Only a string can be part of a block.

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

######################################################################

sub get_first_line {

  # Return the first line of this block.

  my $self = shift;

  if ( defined $self->get_line_list->[0] )
    {
      return $self->get_line_list->[0];
    }

  else
    {
      # $logger->error("FIRST LINE DOESN'T EXIST");
      return 0;
    }
}

######################################################################

sub get_location {

  # Return the location (filespec + line number) of the first line of
  # this block.

  my $self = shift;

  my $line = $self->get_first_line;

  if ( ref $line and $line->isa('SML::Line') )
    {
      return $line->get_location;
    }

  else
    {
      return 'UNKNOWN LOCATION';
    }

}

######################################################################

sub is_in_a {

  # Return 1 if this block is "in a" division of "type" (even if it is
  # buried several divisions deep).

  my $self = shift;
  my $type = shift;

  my $division = $self->get_containing_division || q{};

  while ( $division )
    {
      if ( $division->isa($type) )
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

=head1 NAME

C<SML::Block> - one or more contiguous L<"SML::Line">s.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Part

  my $block = SML::Block->new
                (
                  name    => $name,
                  library => $library,
                );

  my $list     = $block->get_line_list;
  my $division = $block->get_containing_division;
  my $boolean  = $block->set_containing_division($division);
  my $boolean  = $block->has_containing_division;
  my $boolean  = $block->has_valid_syntax;
  my $boolean  = $block->has_valid_semantics;
  my $boolean  = $block->add_line($line);
  my $boolean  = $block->add_part($part);
  my $line     = $block->get_first_line;
  my $string   = $block->get_location;
  my $boolean  = $block->is_in_a($division_name);

=head1 DESCRIPTION

A block is one or more contiguous whole lines of text.  Blocks are
separated by blank lines and therefore cannot contain blank lines.
Blocks may contain inline text elements

=head1 METHODS

=head2 get_name_path

=head2 get_line_list

=head2 get_containing_division

=head2 set_containing_division($division)

=head2 has_containing_division

=head2 has_valid_syntax

=head2 has_valid_semantics

=head2 add_line($line)

=head2 add_part($part)

=head2 get_first_line

=head2 get_location

=head2 is_in_a($division_type)

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
