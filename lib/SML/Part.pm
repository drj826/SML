#!/usr/bin/perl

# $Id: Part.pm 282 2015-07-11 12:54:24Z drj826@gmail.com $

package SML::Part;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Part');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has name =>
  (
   isa      => 'Str',
   reader   => 'get_name',
   required => 1,
  );

######################################################################

has library =>
  (
   isa      => 'SML::Library',
   reader   => 'get_library',
   required => 1,
  );

######################################################################

has id =>
  (
   isa       => 'Str',
   reader    => 'get_id',
   writer    => 'set_id',
   default   => '',
  );

######################################################################

has content =>
  (
   isa       => 'Str',
   reader    => 'get_content',
   writer    => 'set_content',
   predicate => 'has_content',
   clearer   => '_clear_content',
   lazy      => 1,
   builder   => '_build_content',
  );

# This is the raw SML text content of the part.

######################################################################

has container =>
  (
   isa       => 'SML::Part',
   reader    => 'get_container',
   writer    => 'set_container',
   predicate => 'has_container',
  );

# This is the part that contains this one.

######################################################################

has part_list =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_part_list',
   writer    => '_set_part_list',
   clearer   => '_clear_part_list',
   predicate => '_has_part_list',
   default   => sub {[]},
  );

# The 'part_list' is the array of parts within this part.

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub init {

  # Clear the content and empty the part list.

  my $self = shift;

  $self->_clear_content;
  $self->_clear_part_list;
  $self->_set_part_list([]);

  return 1;
}

######################################################################

sub contains_parts {

  # Return the number of parts in the part list.  This is typically
  # used within a conditional to determine whether or not this part
  # has parts.

  my $self = shift;

  if ( scalar @{ $self->get_part_list } )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_part {

  # Return 1 if this part contains a part with the specified ID.

  my $self = shift;
  my $id   = shift;

  if ( not $id )
    {
      $logger->logdie("YOU MUST PROVIDE AN ID");
    }

  if ( $self->contains_parts )
    {
      foreach my $part (@{ $self->get_part_list })
	{
	  if ( $part->get_id eq $id )
	    {
	      return 1;
	    }

	  elsif ( $part->contains_parts )
	    {
	      if ( $part->has_part($id) )
		{
		  return 1;
		}
	    }
	}
    }

  return 0;
}

######################################################################

sub get_part {

  # Return the part if this part contains the part with the specified
  # ID.

  my $self = shift;
  my $id   = shift;

  if ( not $id )
    {
      $logger->logdie("YOU MUST PROVIDE AN ID");
    }

  if ( $self->contains_parts )
    {
      foreach my $part (@{ $self->get_part_list })
	{
	  if ( $part->get_id eq $id )
	    {
	      return $part;
	    }

	  elsif ( $part->contains_parts )
	    {
	      if ( my $subpart = $part->get_part($id) )
		{
		  return $subpart;
		}
	    }
	}
    }

  # $logger->error("COULDN'T GET PART $id");
  return 0;
}

######################################################################

sub get_narrative_part_list {

  my $self = shift;

  my $part_list           = $self->get_part_list;
  my $narrative_part_list = [];

  foreach my $part (@{ $part_list })
    {
      if ( $self->is_narrative_part($part) )
	{
	  push(@{ $narrative_part_list }, $part);
	}
    }

  return $narrative_part_list;
}

######################################################################

sub add_part {

  # Add a part to the part list.

  my $self = shift;
  my $part = shift;

  push @{ $self->get_part_list }, $part;

  $logger->trace("add part $part");

  return 1;
}

######################################################################

sub get_containing_document {

  # Return the document to which this part belongs.

  my $self = shift;

  my $division = $self->get_containing_division;

  if ( not defined $division )
    {
      # $logger->error("DIVISION DOESN'T EXIST");
      return 0;
    }

  elsif ( $division->isa('SML::Document') )
    {
      return $division;
    }

  else
    {
      return $division->get_containing_document;
    }
}

######################################################################

sub is_in_section {

  # Return 1 if this part is inside a section.

  my $self = shift;

  my $division = $self->get_containing_division;

  while ( ref $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Section') )
	{
	  return 1;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub is_narrative_part {

  my $self = shift;                     # this part
  my $part = shift;                     # part of this part

  my $name     = $part->get_name;
  my $library  = $self->get_library;
  my $ontology = $library->get_ontology;
  my $type     = ref $part;

  if
    (
     $part->isa('SML::Element')
     and
     not $ontology->property_is_universal($name)
    )
    {
      return 0;
    }

  else
    {
      return 1;
    }
}

######################################################################

sub get_containing_section {

  # Return the section to which this part belongs.

  my $self = shift;

  if ( $self->isa('SML::Section') )
    {
      return $self;
    }

  my $division = $self->get_containing_division;

  while ( ref $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Section') )
	{
	  return $division;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

######################################################################

sub render {

  # Render the part using the specified rendition and style.

  my $self      = shift;
  my $rendition = shift;
  my $style     = shift;

  my $library      = $self->get_library;
  my $util         = $library->get_util;
  my $template_dir = $library->get_template_dir;
  my $name         = $self->get_name;
  my $input        = "$name.tt";
  my $text         = q{};

  $template_dir = "$template_dir/$rendition/$style";

  if ( not -d $template_dir )
    {
      $logger->error("MISSING TEMPLATE DIRECTORY $template_dir");
      return q{};
    }

  my $config = {};

  $config->{INCLUDE_PATH} = $template_dir;
  $config->{RECURSION}    = 1;
  # $config->{DEBUG}        = 'dirs';

  my $tt = Template->new($config) || die "$Template::ERROR\n";

  my $vars = { self => $self };

  $tt->process($input,$vars,\$text);

  $text =~ s/\r\n?/\n/g;

  return $text;
}

######################################################################

sub dump_part_structure {

  my $self   = shift;
  my $indent = shift || q{};

  my $structure = q{};
  my $summary   = substr($self->get_content,0,40);

  $summary =~ s/[\r\n]*$//;     # chomp
  $summary =~ s/[\r\n]+/.../;   # compress newlines

  $structure .= $indent . $self->get_name . " ($summary)\n";

  $indent = $indent . '  ';

  foreach my $part (@{ $self->get_part_list })
    {
      $structure .= $part->dump_part_structure($indent);
    }

  return $structure;
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

  return q{};

}

######################################################################

sub _build_id_path {

  my $self          = shift;
  my $container_ids = [];
  my $id            = $self->get_id;
  my $container     = $self->get_containing_division;

  push @{ $container_ids }, $id;

  while ( ref $container )
    {
      my $container_id = $container->get_id;
      push @{ $container_ids }, $container_id;

      $container = $container->get_containing_division;
    }

  my $id_path = join('.', reverse @{ $container_ids });

  return $id_path;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Part> - a part of a document.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  my $part = SML::Part->new
               (
                 name    => $name,
                 library => $library,
               );

  my $result  = $part->set_id;
  my $id      = $part->get_id;
  my $library = $part->get_library;
  my $name    = $part->get_name;
  my $result  = $part->set_content;
  my $text    = $part->get_content;
  my $list    = $part->get_part_list;
  my $result  = $part->init;
  my $boolean = $part->has_content;
  my $boolean = $part->contains_parts;
  my $boolean = $part->has_part($id);
  my $subpart = $part->get_part($id);
  my $result  = $part->add_part($part);
  my $doc     = $part->get_containing_document;
  my $boolean = $part->is_in_section;
  my $section = $part->get_containing_section;
  my $text    = $part->render($rendition,$style);
  my $text    = $part->dump_part_structure($indent);

=head1 DESCRIPTION

An abstract class that represents a part of a document.  The three
types of parts are L<"SML::Division">, L<"SML::Block">, and
L<"SML::String">

=head1 METHODS

=head2 set_id

=head2 get_id

=head2 get_id_path

=head2 get_library

=head2 get_name

=head2 set_content

=head2 get_content

=head2 get_part_list

=head2 init

=head2 has_content

=head2 contains_parts

=head2 has_part($id)

=head2 get_part($id)

=head2 add_part($part)

=head2 get_containing_document

=head2 is_in_section

=head2 get_containing_section

=head2 render($rendition,$style)

=head2 dump_part_structure($indent)

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
