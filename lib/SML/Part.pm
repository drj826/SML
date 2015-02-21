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

  # Return the number of parts in the part list.

  my $self = shift;

  return scalar @{ $self->get_part_list };
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

  my $self     = shift;
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
  # $config->{DEBUG}        = 'dirs';
  $config->{RECURSION}    = 1;

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

no Moose;
__PACKAGE__->meta->make_immutable;
1;
