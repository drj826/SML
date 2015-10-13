#!/usr/bin/perl

# $Id: BulletListItem.pm 230 2015-03-21 17:50:52Z drj826@gmail.com $

package SML::BulletListItem;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::ListItem';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.BulletListItem');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'BULLET_LIST_ITEM',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub get_value {

  # Strip the 'bullet' off the beginning of the list item.

  my $self = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;
  my $text    = $self->get_content || q{};

  $text =~ s/[\r\n]*$//;                # chomp;

  if ( $text =~ /$syntax->{'bull_list_item'}/xms )
    {
      my $util = $library->get_util;

      return $util->trim_whitespace($2);
    }

  else
    {
      $logger->error("This should never happen");
      return 0;
    }
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::BulletListItem> - an item in a bullet list.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::ListItem

  my $item = SML::BulletListItem->new
               (
                 library => $library,
               );

=head1 DESCRIPTION

A bullet list item is an item in a bullet list.

=head1 METHODS

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
