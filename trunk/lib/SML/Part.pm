#!/usr/bin/perl

# $Id$

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

has 'id' =>
  (
   isa       => 'Str',
   reader    => 'get_id',
   writer    => 'set_id',
   default   => '',
  );

######################################################################

has 'id_path' =>
  (
   isa      => 'Str',
   reader   => 'get_id_path',
   lazy     => 1,
   builder  => '_build_id_path',
  );

######################################################################

has 'type' =>
  (
   isa      => 'Str',
   reader   => 'get_type',
   default  => 'part',
  );

######################################################################

has 'name' =>
  (
   isa      => 'Str',
   reader   => 'get_name',
   required => 1,
  );

######################################################################

has 'content' =>
  (
   isa       => 'Str',
   reader    => 'get_content',
   writer    => 'set_content',
   clearer   => '_clear_content',
   lazy      => 1,
   builder   => '_build_content',
  );

######################################################################

has 'part_list' =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_part_list',
   writer    => '_set_part_list',
   clearer   => '_clear_part_list',
   predicate => '_has_part_list',
   default   => sub {[]},
  );

# The 'part_list' is the array of strings within this block.  All of
# the content of a block can be represented by an array of strings.
# Strings can contain substrings (a string within a string).

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

sub has_content {

  my $self = shift;

  if ( $self->get_content )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub has_parts {

  # Return the number of parts in the part list.  This is typically
  # used within a conditional to determine whether or not this part
  # has parts.

  my $self = shift;

  return scalar @{ $self->get_part_list };
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

  if ( $self->has_parts )
    {
      foreach my $part (@{ $self->get_part_list })
	{
	  if ( $part->get_id eq $id )
	    {
	      return 1;
	    }

	  elsif ( $part->has_parts )
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

  if ( $self->has_parts )
    {
      foreach my $part (@{ $self->get_part_list })
	{
	  if ( $part->get_id eq $id )
	    {
	      return $part;
	    }

	  elsif ( $part->has_parts )
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

sub get_containing_section {

  # Return the section to which this part belongs.

  my $self = shift;

  $logger->debug("get_containing_section: $self");

  if ( $self->isa('SML::Section') )
    {
      return $self;
    }

  my $division = $self->get_containing_division;

  $logger->debug("  containing division: $division");

  while ( ref $division and not $division->isa('SML::Fragment') )
    {
      if ( $division->isa('SML::Section') )
	{
	  return $division;
	}

      else
	{
	  $division = $division->get_containing_division;
	  $logger->debug("  next division: $division");
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

  my $sml          = SML->instance;
  my $util         = $sml->get_util;
  my $library      = $util->get_library;
  my $template_dir = $library->get_template_dir;
  my $name         = $self->get_name;
  my $input        = "$name.tt";
  my $text         = q{};

  $logger->debug("render: $rendition $style using $input");

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

  return $text;
}

######################################################################

sub dump_part_structure {

  my $self   = shift;
  my $indent = shift || q{};

  # use Data::Dumper;
  # return Dumper($self);

  my $structure = q{};

  $structure .= $indent . $self->get_name . " (" . $self->get_content . ")\n";
  # $structure .= $indent . $self->get_name . "\n";;

  $indent = $indent . '  ';

  foreach my $part (@{ $self->get_part_list })
    {
      $structure .= $part->dump_part_structure($indent);
    }

  return $structure;
}

######################################################################

sub get_library {

  my $sml  = SML->instance;
  my $util = $sml->get_util;

  return $util->get_library;
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
