#!/usr/bin/perl

# $Id: Options.pm 262 2015-04-02 22:37:20Z drj826@gmail.com $

package SML::Options;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Config::General;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Options');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has 'config_filespec' =>
  (
   isa     => 'Str',
   reader  => 'get_config_filespec',
   default => 'sml.conf'
  );

######################################################################

has 'gui' =>
  (
   isa     => 'Bool',
   reader  => 'using_gui',
   default => 0,
   writer  => 'set_using_gui',
  );

######################################################################

has 'verbose' =>
  (
   isa     => 'Bool',
   reader  => 'be_verbose',
   default => 0,
   writer  => 'set_be_verbose',
  );

######################################################################

has 'scripts' =>
  (
   isa     => 'Bool',
   reader  => 'run_scripts',
   default => 1,
   writer  => 'set_run_scripts',
  );

######################################################################

has 'use_svn' =>
  (
   isa     => 'Bool',
   reader  => 'use_svn',
   default => 0,
   writer  => 'set_use_svn',
  );

######################################################################

has 'svn' =>
  (
   isa     => 'Str',
   reader  => 'get_svn_executable',
   default => 'svn.exe',
   writer  => 'set_svn_executable',
  );

######################################################################

has 'pdflatex' =>
  (
   isa     => 'Str',
   reader  => 'get_pdflatex_executable',
   default => 'pdflatex.exe',
   writer  => 'set_pdflatex_executable',
);

######################################################################

has 'pdflatex_args' =>
  (
   isa     => 'Str',
   reader  => 'get_pdflatex_args',
   default => '--main-memory=50000000 --extra-mem-bot=50000000',
   writer  => 'set_pdflatex_args',
);

######################################################################

has 'bibtex' =>
  (
   isa     => 'Str',
   reader  => 'get_bibtex_executable',
   default => 'bibtex.exe',
   writer  => 'set_bibtex_executable',
  );

######################################################################

has 'makeindex' =>
  (
   isa     => 'Str',
   reader  => 'get_makeindex_executable',
   default => 'makeindex.exe',
   writer  => 'set_makeindex_executable',
  );

######################################################################

has 'convert' =>
  (
   isa     => 'Str',
   reader  => 'get_convert_executable',
   default => 'convert.exe',
   writer  => 'set_convert_executable',
  );

######################################################################

has 'trigger_resource_updates' =>
  (
   isa       => 'Bool',
   reader    => 'trigger_resource_updates',
   default   => 0,
   writer    => 'set_trigger_resource_updates',
   clearer   => 'clear_trigger_resource_updates',
   predicate => 'has_trigger_resource_updates',
  );

# If 'trigger_resource_updates' is true, the application should update
# the RESOURCES division in each SML document resource.  The purpose
# of this function is to trigger a change in a resource whenever
# another resource used by that resource is changed.

######################################################################

has 'use_formal_status' =>
  (
   isa       => 'Bool',
   reader    => 'use_formal_status',
   writer    => 'set_use_formal_status',
   clearer   => 'clear_use_formal_status',
   predicate => 'has_use_formal_status',
   default   => 0,
  );

# If 'use_formal_status' is true, the application should ONLY set the
# status of an entity based on outcome statements.

######################################################################

has 'MAX_SEC_DEPTH' =>
  (
   isa     => 'Int',
   reader  => 'get_MAX_SEC_DEPTH',
   writer  => 'set_MAX_SEC_DEPTH',
   default => 6,
  );

######################################################################

has 'MAX_RESOLVE_INCLUDES' =>
  (
   isa     => 'Int',
   reader  => 'get_MAX_RESOLVE_INCLUDES',
   writer  => 'set_MAX_RESOLVE_INCLUDES',
   default => 20,
  );

######################################################################

has 'MAX_RUN_SCRIPTS' =>
  (
   isa     => 'Int',
   reader  => 'get_MAX_RUN_SCRIPTS',
   writer  => 'set_MAX_RUN_SCRIPTS',
   default => 20,
  );

######################################################################

has 'MAX_RESOLVE_CONDITIONALS' =>
  (
   isa     => 'Int',
   reader  => 'get_MAX_RESOLVE_CONDITIONALS',
   writer  => 'set_MAX_RESOLVE_CONDITIONALS',
   default => 10,
  );

######################################################################

has 'MAX_GATHER_DATA' =>
  (
   isa     => 'Int',
   reader  => 'get_MAX_GATHER_DATA',
   writer  => 'set_MAX_GATHER_DATA',
   default => 20,
  );

######################################################################

has 'MAX_INSERT_CONTENT' =>
  (
   isa     => 'Int',
   reader  => 'get_MAX_INSERT_CONTENT',
   writer  => 'set_MAX_INSERT_CONTENT',
   default => 20,
  );

######################################################################

has 'MAX_SUBSTITUTE_VARIABLES' =>
  (
   isa     => 'Int',
   reader  => 'get_MAX_SUBSTITUTE_VARIABLES',
   writer  => 'set_MAX_SUBSTITUTE_VARIABLES',
   default => 20,
  );

######################################################################

has 'MAX_RESOLVE_LOOKUPS' =>
  (
   isa     => 'Int',
   reader  => 'get_MAX_RESOLVE_LOOKUPS',
   writer  => 'set_MAX_RESOLVE_LOOKUPS',
   default => 20,
  );

######################################################################

has 'MAX_RESOLVE_TEMPLATES' =>
  (
   isa     => 'Int',
   reader  => 'get_MAX_RESOLVE_TEMPLATES',
   writer  => 'set_MAX_RESOLVE_TEMPLATES',
   default => 20,
  );

######################################################################

has 'MAX_GENERATE_CONTENT' =>
  (
   isa     => 'Int',
   reader  => 'get_MAX_GENERATE_CONTENT',
   writer  => 'set_MAX_GENERATE_CONTENT',
   default => 20,
  );

######################################################################

has 'MAX_ID_HIERARCHY_DEPTH' =>
  (
   isa     => 'Int',
   reader  => 'get_MAX_ID_HIERARCHY_DEPTH',
   writer  => 'set_MAX_ID_HIERARCHY_DEPTH',
   default => 20,
  );

######################################################################

has 'status_icon_grey_filespec' =>
  (
   isa     => 'Str',
   reader  => 'get_status_icon_grey_filespec',
   writer  => 'set_status_icon_grey_filespec',
   default => 'status_grey.png',
  );

######################################################################

has 'status_icon_green_filespec' =>
  (
   isa     => 'Str',
   reader  => 'get_status_icon_green_filespec',
   writer  => 'set_status_icon_green_filespec',
   default => 'status_green.png',
  );

######################################################################

has 'status_icon_yellow_filespec' =>
  (
   isa     => 'Str',
   reader  => 'get_status_icon_yellow_filespec',
   writer  => 'set_status_icon_yellow_filespec',
   default => 'status_yellow.png',
  );

######################################################################

has 'status_icon_red_filespec' =>
  (
   isa     => 'Str',
   reader  => 'get_status_icon_red_filespec',
   writer  => 'set_status_icon_red_filespec',
   default => 'status_red.png',
  );

######################################################################
######################################################################
##
## Public Methods
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

sub BUILD {

  my $self        = shift;
  my $config_file = $self->get_config_filespec;

  if ( -f $config_file )
    {
      my $config = Config::General->new("$config_file");
      my %config = $config->getall;

      if ($config{'gui'}) {
	$self->set_gui($config{'gui'});
      }

      if ($config{'verbose'}) {
	$self->set_verbose($config{'verbose'});
      }

      if ($config{'scripts'}) {
	$self->set_scripts($config{'scripts'});
      }

      if ($config{'use_svn'}) {
	$self->set_svn($config{'use_svn'});
      }

      if ($config{'svn'}) {
	$self->set_svn_executable($config{'svn'});
      }

      if ($config{'pdflatex'}) {
	$self->set_pdflatex_executable($config{'pdflatex'});
      }

      if ($config{'pdflatex_args'}) {
	$self->set_pdflatex_args($config{'pdflatex_args'});
      }

      if ($config{'bibtex'}) {
	$self->set_bibtex_executable($config{'bibtex'});
      }

      if ($config{'makeindex'}) {
	$self->set_makeindex_executable($config{'makeindex'});
      }

      if ($config{'convert'}) {
	$self->set_convert_executable($config{'convert'});
      }

      if ($config{'trigger_resource_updates'}) {
	$self->set_trigger_resource_updates($config{'trigger_resource_updates'});
      }

      if ($config{'use_formal_status'}) {
	$self->set_use_formal_status($config{'use_formal_status'});
      }

      if ($config{'MAX_SEC_DEPTH'}) {
	$self->set_MAX_SEC_DEPTH($config{'MAX_SEC_DEPTH'});
      }

      if ($config{'MAX_RESOLVE_INCLUDES'}) {
	$self->set_MAX_RESOLVE_INCLUDES($config{'MAX_RESOLVE_INCLUDES'});
      }

      if ($config{'MAX_RUN_SCRIPTS'}) {
	$self->set_MAX_RUN_SCRIPTS($config{'MAX_RUN_SCRIPTS'});
      }

      if ($config{'MAX_GATHER_DATA'}) {
	$self->set_MAX_GATHER_DATA($config{'MAX_GATHER_DATA'});
      }

      if ($config{'MAX_INSERT_CONTENT'}) {
	$self->set_MAX_INSERT_CONTENT($config{'MAX_INSERT_CONTENT'});
      }

      if ($config{'MAX_SUBSTITUTE_VARIABLES'}) {
	$self->set_MAX_SUBSTITUTE_VARIABLES($config{'MAX_SUBSTITUTE_VARIABLES'});
      }

      if ($config{'MAX_RESOLVE_LOOKUPS'}) {
	$self->set_MAX_RESOLVE_LOOKUPS($config{'MAX_RESOLVE_LOOKUPS'});
      }

      if ($config{'MAX_RESOLVE_TEMPLATES'}) {
	$self->set_MAX_RESOLVE_TEMPLATES($config{'MAX_RESOLVE_TEMPLATES'});
      }

      if ($config{'MAX_GENERATE_CONTENT'}) {
	$self->set_MAX_GENERATE_CONTENT($config{'MAX_GENERATE_CONTENT'});
      }

      if ($config{'MAX_ID_HIERARCHY_DEPTH'}) {
	$self->set_MAX_ID_HIERARCHY_DEPTH($config{'MAX_ID_HIERARCHY_DEPTH'});
      }

      if ($config{'status_grey_icon'}) {
	$self->set_status_grey_icon($config{'status_grey_icon'});
      }

      if ($config{'status_green_icon'}) {
	$self->set_status_green_icon($config{'status_green_icon'});
      }

      if ($config{'status_yellow_icon'}) {
	$self->set_status_yellow_icon($config{'status_yellow_icon'});
      }

      if ($config{'status_red_icon'}) {
	$self->set_status_red_icon($config{'status_red_icon'});
      }

      return 1;
    }

  elsif ( $config_file )
    {
      $logger->info("COULDN'T FIND the config file $config_file");
      return 0;
    }
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Options> - A class to store options.

=head1 VERSION

This documentation refers to L<"SML::Options"> version 2.0.0.

=head1 SYNOPSIS

  my $opt = SML::Options->new();

=head1 DESCRIPTION

A class to store options.

=head1 METHODS

=head2 get_config_filespec

=head2 using_gui

=head2 be_verbose

=head2 run_scripts

=head2 use_svn

=head2 get_svn_executable

=head2 get_pdflatex_executable

=head2 get_pdflatex_args

=head2 get_bibtex_executable

=head2 get_makeindex_executable

=head2 get_convert_executable

=head2 trigger_resource_updates

=head2 use_formal_status

=head2 get_MAX_SEC_DEPTH

=head2 get_MAX_RESOLVE_INCLUDES

=head2 get_MAX_RUN_SCRIPTS

=head2 get_MAX_RESOLVE_CONDITIONALS

=head2 get_MAX_GATHER_DATA

=head2 get_MAX_INSERT_CONTENT

=head2 get_MAX_SUBSTITUTE_VARIABLES

=head2 get_MAX_RESOLVE_LOOKUPS

=head2 get_MAX_RESOLVE_TEMPLATES

=head2 get_MAX_GENERATE_CONTENT

=head2 get_MAX_ID_HIERARCHY_DEPTH

=head2 get_status_icon_grey_filespec

=head2 get_status_icon_green_filespec

=head2 get_status_icon_yellow_filespec

=head2 get_status_icon_red_filespec

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
