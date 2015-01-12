#!/usr/bin/perl

package SML::Formatter;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Template;
use Text::Wrap;
use File::Copy::Recursive qw( dircopy );

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Formatter');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub publish_html_by_section {

  my $self         = shift;
  my $document     = shift;
  my $template_dir = shift;
  my $output_dir   = shift;

  if (
      not ref $document
      or
      not $document->isa('SML::Document')
     )
    {
      $logger->error("NOT A DOCUMENT $document");
      return 0;
    }

  if ( not -d $template_dir )
    {
      $logger->error("NOT A DIRECTORY $template_dir");
      return 0;
    }

  my $id = $document->get_id;

  my $tt_config =
    {
     INCLUDE_PATH => $template_dir,
     OUTPUT_PATH  => $output_dir,
    };

  my $tt = Template->new($tt_config) || die "$Template::ERROR\n";

  my $vars =
    {
     document => $document,
    };

  foreach my $page ('titlepage','toc','glossary','index','references')
    {
      my $outfile = "$id.$page.html";
      $logger->info("formatting $outfile");
      $tt->process("$page.tt",$vars,$outfile) || die $tt->error(), "\n";
    }

  foreach my $section (@{ $document->get_section_list })
    {
      my $num = $section->get_number;

      my $outfile = "$id.$num.html";

      my $vars =
	{
	 document => $document,
	 section  => $section,
	};

      $logger->info("formatting $outfile");
      $tt->process('section.tt',$vars,$outfile)
	|| die $tt->error(), "\n";
    }

  if ( -d "$template_dir/images" )
    {
      dircopy("$template_dir/images","$output_dir/images")
	|| die "Couldn't copy images directory";
    }

  return 1;
}

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Formatter> - generates output text from SML content objects.

=head1 VERSION

This documentation refers to L<"SML::Formatter"> version 2.0.0.

=head1 SYNOPSIS

  my $fmtr = SML::Formatter->new();

=head1 DESCRIPTION

A formatter generates output text from SML content objects.

=head1 METHODS

=head2 format

  $fmtr->format($document);                # render HTML
  $fmtr->format($document,'HTML');         # render HTML
  $fmtr->format($document,'HTML','FANCY'); # render fancy HTML

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
