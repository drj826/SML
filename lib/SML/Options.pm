#!/usr/bin/perl

package SML::Options;                   # ci-000382

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Config::General;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Options');

######################################################################

=head1 NAME

SML::Options - a set of SML options

=head1 SYNOPSIS

  SML::Options->new();

  $options->get_config_filespec;                  # Str
  $options->resolve_scripts;                      # Bool
  $options->resolve_plugins;                      # Bool
  $options->use_svn;                              # Bool
  $options->get_svn_executable;                   # Str
  $options->set_svn_executable($svn);             # Bool
  $options->use_git;                              # Bool
  $options->set_use_git(1);                       # Bool
  $options->get_git_executable;                   # Str
  $options->set_git_executable($git);             # Bool
  $options->get_pdflatex_executable;              # Str
  $options->set_pdflatex_executable($pdflatex);   # Bool
  $options->get_pdflatex_args;                    # Str
  $options->set_pdflatex_args($args);             # Bool
  $options->get_bibtex_executable;                # Str
  $options->set_bibtex_executable($bibtex);       # Bool
  $options->get_makeindex_executable;             # Str
  $options->set_makeindex_executable($makeindex); # Bool
  $options->get_convert_executable;               # Str
  $options->set_convert_executable($convert);     # Bool
  $options->use_formal_status;                    # Bool
  $options->set_use_formal_status(1);             # Bool
  $options->get_MAX_SEC_DEPTH;                    # Int
  $options->set_MAX_SEC_DEPTH($depth);            # Bool
  $options->get_MAX_RESOLVE_INCLUDES;             # Int
  $options->set_MAX_RESOLVE_INCLUDES($count);     # Bool
  $options->get_MAX_RESOLVE_SCRIPTS;              # Int
  $options->set_MAX_RESOLVE_SCRIPTS($count);      # Bool
  $options->get_MAX_RESOLVE_PLUGINS;              # Int
  $options->set_MAX_RESOLVE_PLUGINS($count);      # Bool

=head1 DESCRIPTION

A set of SML options that remembers the location of certain library
executable programs and controls certain library functions.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has config_filespec =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_config_filespec',
   default   => 'library.conf'
  );

=head2 get_config_filespec

Return a scalar text value which is the filespec to the library
configuration file.

  my $filespec = $options->get_config_filespec;

=cut

######################################################################

has resolve_scripts =>
  (
   is        => 'ro',
   isa       => 'Bool',
   reader    => 'resolve_scripts',
   default   => 1,
   writer    => 'set_resolve_scripts',
  );

=head2 resolve_scripts

Return 1 if the library is configured to resolve scripts.  This value
can be set in the library configuration file.

  my $result = $options->resolve_scripts;

=head2 set_resolve_scripts($bool)

Set the boolean value that determines whether or not scripts are
resolved.

  $options->set_resolve_scripts(1);

=cut

######################################################################

has resolve_plugins =>
  (
   is        => 'ro',
   isa       => 'Bool',
   reader    => 'resolve_plugins',
   default   => 1,
   writer    => 'set_resolve_plugins',
  );

=head2 resolve_plugins

Return 1 if the library is configured to resolve plugins. This value
can be set in the library configuration file.

  my $result = $options->resolve_plugins;

=head2 set_resolve_plugins($bool)

Set the boolean value that determines whether or not plugins are
resolved.

  $options->set_resolve_plugins(1);

=cut

######################################################################

has use_svn =>
  (
   is        => 'ro',
   isa       => 'Bool',
   reader    => 'use_svn',
   default   => 0,
   writer    => 'set_use_svn',
  );

=head2 use_svn

Return 1 if the library is configured to use SVN (i.e. subversion) as
a version control system.  This value can be set in the library
configuration file.

  my $result = $options->use_svn;

=head2 set_use_svn

Set the boolean value that determines whether or not the library uses
SVN as a version control system.

  $options->set_use_svn(1);

=cut

######################################################################

has svn_executable =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_svn_executable',
   default   => 'svn.exe',
   writer    => 'set_svn_executable',
  );

=head2 get_svn_executable

Return the scalar text value which is the location of the SVN
executable.

  my $svn = $options->get_svn_executable;

=head2 set_svn_executable

Set the location of the SVN executable.

  $options->set_svn_executable($svn);

=cut

######################################################################

has use_git =>
  (
   is        => 'ro',
   isa       => 'Bool',
   reader    => 'use_git',
   default   => 0,
   writer    => 'set_use_git',
  );

=head2 use_git

Return 1 if the library is configured to use git as a version control
system.  This value can be set in the library configuration file.

  my $result = $options->use_git;

=head2 set_use_git

Set the boolean value that determines whether or not the library uses
git as a version control system.

  $options->set_use_git(1);

=cut

######################################################################

has git_executable =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_git_executable',
   default   => 'git.exe',
   writer    => 'set_git_executable',
  );

=head2 get_git_executable

Return the scalar text value which is the location of the git
executable.

  my $git = $options->get_git_executable;

=head2 set_git_executable

Set the location of the git executable.

  $options->set_git_executable($git);

=cut

######################################################################

has pdflatex_executable =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_pdflatex_executable',
   default   => 'pdflatex.exe',
   writer    => 'set_pdflatex_executable',
);

=head2 get_pdflatex_executable

Return the scalar text value which is the location of the pdflatex
executable.

  my $pdflatex = $options->get_pdflatex_executable;

=head2 set_pdflatex_executable

Set the location of the pdflatex executable.

  $options->set_pdflatex_executable($pdflatex);

=cut

######################################################################

has pdflatex_args =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_pdflatex_args',
   default   => '--main-memory=50000000 --extra-mem-bot=50000000',
   writer    => 'set_pdflatex_args',
);

=head2 get_pdflatex_args

Return the scalar text value which represents the arguments to be
passed to pdflatex.

  my $pdflatex = $options->get_pdflatex_args;

=head2 set_pdflatex_args

Set the arguments to be passed to pdflatex.

  $options->set_pdflatex_args($pdflatex);

=cut

######################################################################

has bibtex_executable =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_bibtex_executable',
   default   => 'bibtex.exe',
   writer    => 'set_bibtex_executable',
  );

=head2 get_bibtex_executable

Return the scalar text value which is the location of the bibtex
executable.

  my $bibtex = $options->get_bibtex_executable;

=head2 set_bibtex_executable

Set the location of the bibtex executable.

  $options->set_bibtex_executable($bibtex);

=cut

######################################################################

has makeindex_executable =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_makeindex_executable',
   default   => 'makeindex.exe',
   writer    => 'set_makeindex_executable',
  );

=head2 get_makeindex_executable

Return the scalar text value which is the location of the makeindex
executable.

  my $makeindex = $options->get_makeindex_executable;

=head2 set_makeindex_executable

Set the location of the makeindex executable.

  $options->set_makeindex_executable($makeindex);

=cut

######################################################################

has convert_executable =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_convert_executable',
   default   => 'convert.exe',
   writer    => 'set_convert_executable',
  );

=head2 get_convert_executable

Return the scalar text value which is the location of the convert
executable.

  my $convert = $options->get_convert_executable;

=head2 set_convert_executable

Set the location of the convert executable.

  $options->set_convert_executable($convert);

=cut

######################################################################

has use_formal_status =>
  (
   is        => 'ro',
   isa       => 'Bool',
   reader    => 'use_formal_status',
   writer    => 'set_use_formal_status',
   # clearer   => 'clear_use_formal_status',
   # predicate => 'has_use_formal_status',
   default   => 0,
  );

=head2 use_formal_status

Return 1 if you want to use "formal" status of entities in your
library.  If 'use_formal_status' is true, the application should ONLY
set the status of an entity based on outcome statements.

  my $result = $options->use_formal_status;

=head2 set_use_formal_status

Set the boolean value that tell the library whether or not to use
formal entity status.

  $options->set_use_formal_status(1);

=cut

######################################################################

has MAX_SEC_DEPTH =>
  (
   is        => 'ro',
   isa       => 'Int',
   reader    => 'get_MAX_SEC_DEPTH',
   writer    => 'set_MAX_SEC_DEPTH',
   default   => 6,
  );

=head2 get_MAX_SEC_DEPTH

Return an integer which is the maximum allowable section depth for
documents in the library.

  my $max = $options->get_MAX_SEC_DEPTH;

=head2 set_MAX_SEC_DEPTH

Set the integer value which is the maximum allowable section depth for
documents in the library.

  $options->set_MAX_SEC_DEPTH($depth);

=cut

######################################################################

has MAX_RESOLVE_INCLUDES =>
  (
   is        => 'ro',
   isa       => 'Int',
   reader    => 'get_MAX_RESOLVE_INCLUDES',
   writer    => 'set_MAX_RESOLVE_INCLUDES',
   default   => 20,
  );

=head2 get_MAX_RESOLVE_INCLUDES

Return an integer which is the maximum allowable number of times the
application will resolve include statements in library documents.
This maximum is designed to prevent infinite loops.

  my $max = $options->get_MAX_RESOLVE_INCLUDES;

=head2 set_MAX_RESOLVE_INCLUDES

Set the integer value which is the maximum number of times to resolve
includes statements in documents in the library.

  $options->set_MAX_RESOLVE_INCLUDES($depth);

=cut

######################################################################

has MAX_RESOLVE_SCRIPTS =>
  (
   is        => 'ro',
   isa       => 'Int',
   reader    => 'get_MAX_RESOLVE_SCRIPTS',
   writer    => 'set_MAX_RESOLVE_SCRIPTS',
   default   => 20,
  );

=head2 get_MAX_RESOLVE_SCRIPTS

Return an integer which is the maximum allowable number of times the
application will resolve script statements in library documents.  This
maximum is designed to prevent infinite loops.

  my $max = $options->get_MAX_RESOLVE_SCRIPTS;

=head2 set_MAX_RESOLVE_SCRIPTS

Set the integer value which is the maximum number of times to resolve
script statements in documents in the library.

  $options->set_MAX_RESOLVE_SCRIPTS($depth);

=cut

######################################################################

has MAX_RESOLVE_PLUGINS =>
  (
   is        => 'ro',
   isa       => 'Int',
   reader    => 'get_MAX_RESOLVE_PLUGINS',
   writer    => 'set_MAX_RESOLVE_PLUGINS',
   default   => 20,
  );

=head2 get_MAX_RESOLVE_PLUGINS

Return an integer which is the maximum allowable number of times the
application will resolve plugin statements in library documents.  This
maximum is designed to prevent infinite loops.

  my $max = $options->get_MAX_RESOLVE_PLUGINS;

=head2 set_MAX_RESOLVE_PLUGINS

Set the integer value which is the maximum number of times to resolve
plugin statements in documents in the library.

  $options->set_MAX_RESOLVE_PLUGINS($depth);

=cut

######################################################################

# has MAX_PARSE_LINES =>
#   (
#    is        => 'ro',
#    isa       => 'Int',
#    reader    => 'get_MAX_PARSE_LINES',
#    writer    => 'set_MAX_PARSE_LINES',
#    default   => 20,
#   );

######################################################################

# has MAX_SUBSTITUTE_VARIABLES =>
#   (
#    is        => 'ro',
#    isa       => 'Int',
#    reader    => 'get_MAX_SUBSTITUTE_VARIABLES',
#    writer    => 'set_MAX_SUBSTITUTE_VARIABLES',
#    default   => 20,
#   );

######################################################################

# has MAX_RESOLVE_LOOKUPS =>
#   (
#    is        => 'ro',
#    isa       => 'Int',
#    reader    => 'get_MAX_RESOLVE_LOOKUPS',
#    writer    => 'set_MAX_RESOLVE_LOOKUPS',
#    default   => 20,
#   );

######################################################################
######################################################################
##
## Public Methods
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

sub BUILD {

  my $self = shift;

  my $config_file = $self->get_config_filespec;

  use FindBin qw($Bin);

  my $dir_list =
    [
     "$Bin",
     "$Bin/conf",
     "$Bin/..",
     "$Bin/../conf",
     "$Bin/../..",
     "$Bin/../../conf",
    ];

  my $config_filespec;

  foreach my $dir (@{ $dir_list })
    {
      if ( -r "$dir/$config_file" )
	{
	  $logger->debug("options config filespec: $dir/$config_file");

	  $config_filespec = "$dir/$config_file";

	  last;
	}
    }

  unless ( $config_filespec )
    {
      foreach my $dir (@{ $dir_list })
	{
	  $logger->error("checked: $dir");
	}

      $logger->error("CAN'T FIND OPTIONS CONFIGURATION FILE");
    }


  if ( -f $config_filespec )
    {
      my $config = Config::General->new("$config_filespec");
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
	$self->set_use_svn($config{'use_svn'});
      }

      if ($config{'svn'}) {
	$self->set_svn_executable($config{'svn'});
      }

      if ($config{'use_git'}) {
	$self->set_use_git($config{'use_git'});
      }

      if ($config{'git'}) {
	$self->set_git_executable($config{'git'});
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

      if ($config{'MAX_RESOLVE_SCRIPTS'}) {
	$self->set_MAX_RESOLVE_SCRIPTS($config{'MAX_RESOLVE_SCRIPTS'});
      }

      if ($config{'MAX_RESOLVE_PLUGINS'}) {
	$self->set_MAX_RESOLVE_PLUGINS($config{'MAX_RESOLVE_PLUGINS'});
      }

      if ($config{'MAX_PARSE_LINES'}) {
	$self->set_MAX_PARSE_LINES($config{'MAX_PARSE_LINES'});
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

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012-2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
