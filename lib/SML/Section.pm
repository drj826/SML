#!/usr/bin/perl

package SML::Section;                   # ci-000392

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Structure';               # ci-000466

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Section');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'SECTION',
  );

######################################################################

has '+id' =>
  (
   required => 1,
  );

######################################################################

has depth =>
  (
   is       => 'ro',
   isa      => 'Int',
   reader   => 'get_depth',
   required => 1,
  );

######################################################################

# has sectype =>
#   (
#    is       => 'ro',
#    isa      => 'Str',
#    reader   => 'get_sectype',
#    default  => 'Section',
#   );

######################################################################

has top_number =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_top_number',
   writer   => 'set_top_number',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub encloses_division_with_name {

  # Return 1 if this section 'encloses' a division with the specified
  # name.  If the section in question is chapter 3, this means return
  # 1 if any sub-section of chapter 3 contains a division with the
  # specified name.
  #
  # Sections exist in sequences and cannot be nested.  This may seem
  # counterintuitive.  A section may not contain another section?
  # What about sub-sections?  Technically, sections don't *contain*
  # sub-sections.  Sections have properties like depth and number that
  # make them appear nested, when in fact they are not.
  #
  # If you want to know if chapter 3 (or any of its sub-sections)
  # contains a table, you must check each sub-section individually.
  # That's what this method does.
  #
  # This method takes advantage of the way sections are numbered:
  #
  #   3
  #   3.1
  #   3.2
  #   3.2.1
  #   3.2.2
  #
  # It assumes one section 'encloses' another if the section number of
  # the first matches the beginning of the second.  For instance, this
  # method assumes section 3.2 encloses section 3.2.2.

  my $self = shift;
  my $name = shift;

  my $number       = $self->get_number;
  my $document     = $self->get_containing_document;
  my $section_list = $document->get_list_of_divisions_with_name('SECTION');

  foreach my $section (@{ $section_list })
    {
      my $section_number = $section->get_number;

      next unless $section_number =~ /^$number/;

      if ( $section->contains_division_with_name($name) )
	{
	  return 1;
	}
    }

  return 0;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Section> - an element of document structure that begins with a
section heading and contains information about a specific topic.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Division

  my $section = SML::Section->new
                  (
                    depth   => $depth,
                    id      => $id,
                    library => $library,
                  );

  my $integer = $section->get_depth;
  my $string  = $section->get_top_number;

=head1 DESCRIPTION

An SML section is an element of document structure that begins with a
section heading, and contains information about a specific topic.
Authors may create section headings at different levels to create a
hierarchy of sections to organize document content.

=head1 METHODS

=head2 get_depth

=head2 get_sectype

=head2 get_top_number

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
