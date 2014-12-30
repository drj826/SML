#!/usr/bin/perl

package SML::ListItem;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Block';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.listitem');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'listitem',
  );

######################################################################

has '+type' =>
  (
   default => 'listitem',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_value {

  # Strip the item indicator from the beginning of the listitem
  # content.

  my $self   = shift;
  my $sml    = SML->instance;
  my $syntax = $sml->get_syntax;

  $_ = $self->get_content || q{};

  chomp;

  if ( /$syntax->{'list_item'}/xms )
    {
      my $util = $sml->get_util;

      return $util->trim_whitespace($2);
    }

  else
    {
      $logger->error("CAN'T GET LISTITEM VALUE");
      return 0;
    }
};

######################################################################

sub start_html {

  my $self = shift;
  my $html = shift;

  return '<li>' . $html;

}

######################################################################

sub end_html {

  my $self = shift;
  my $html = shift;

  return $html . '</li>';

}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Listitem> - a block of text that represents one item in a
sequence or hierarchy of items.

=head1 VERSION

This documentation refers to L<"SML::Listitem"> version 2.0.0.

=head1 SYNOPSIS

  my $item = SML::Listitem->new();

=head1 DESCRIPTION

An listitem is a block of text that represents one item in a sequence
or hierarchy of items.

=head1 METHODS

=head2 get_name

=head2 get_type

=head2 get_value

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
