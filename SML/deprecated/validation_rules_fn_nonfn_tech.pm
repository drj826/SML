#!/Usr/bin/perl

# $Id: validation_rules_fn_nonfn_tech.pm 9805 2012-09-10 15:37:54Z don.johnson $

######################################################################
#                                                                    #
#     Copyright (c) 2002-2007, Don Johnson (drj826@acm.org)          #
#     Copyright (c) 2007, Futures, Inc                               #
#     Copyright (c) 2008-2011, Don Johnson (drj826@acm.org)          #
#                                                                    #
#     Distributed under the terms of the Gnu General Public License  #
#     (version 2, 1991)                                              #
#                                                                    #
#     This software is distributed in the hope that it will be       #
#     useful, but WITHOUT ANY WARRANTY; without even the implied     #
#     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR        #
#     PURPOSE.  See the GNU License for more details.                #
#                                                                    #
#     MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS       #
#     DERIVED FROM THIS SOFTWARE MUST BE MADE FREELY AVAILABLE       #
#     UNDER THESE SAME TERMS.                                        #
#                                                                    #
######################################################################

######################################################################
#
#	Required Elements:
#
#	title::
#
#	label::
#
#	owner::
#
#	type::
#		compliance
#		mission
#		business
#		functional
#		non-functional
#		technical
#
#	priority::
#		low
#		routine
#		high
#		critical
#
#	description::
#
#	index::
#		[first 9 characters must equal first 9 characters of label]
#	
#	parent::
#		requirement must exist
#		requirement must be the same type
#	
#	derived_from::
#		requirement must exist
#		requirement must have the following relationship
#			business derived_from mission
#			business derived_from compliance
#			functional derived_from business
#			non-functional derived_from business
#			system derived_from functional
#			system derived_from non-functional
#		
######################################################################

# validate_title

sub ck_title;		# subroutine to check the existence of a title line
sub ck_label;		# subroutine to check the existence of a label line
sub ck_owner;		# subroutine to check the existence of a owner line
sub ck_type;		# subroutine to check the existence of a type line
sub ck_priority;	# subroutine to check the existence of a priority line
sub ck_descr;		# subroutine to check the existence of a description line
sub ck_index;		# subroutine to check the existence of a index line
sub ck_parent;		# subroutine to check the existence of a parent line
sub ck_derived;		# subroutine to check the existence of a derived_from line

use strict;

my(	$file,		# file to be traversed
	$line,		# line in the requirement
	$check,		# number identifying line is OK
	$label);	# label of the requirement

my(	@files,		# array to hold the file names
	@lines);	# array to hold lines of each file
	@actual);	# array to hold actual error instances
	@testfiles);	# array to hold the file names to be tested against

my(%errors)		# hash to hold the error codes

%errors = (title => 'Missing title in the requirement',
	   label => 'Missing label in the requirement',
	   owner => 'No owner identified for the requirement',
	   typex => 'Type does not match one of the 6 acceptable types',
	   priorityx => 'Priority does not match one of the 4 acceptable priorities',
	   type => 'Missing type in the requirement'
	   priority => 'Missing priority in the requirement'
	   descr => 'Missing description in the requirment'
	   index => 'Index missing or does not match label in the requirement'
	   );

opendir(DIR, ".");		# opens the current directory
@files = readdir( DIR);		# populates the @files array
@testviles = readdir( DIR )	# populates the @testfiles array (used for parent
				# and derived_from tests
$check = 0;

foreach $file( @files ){

	if ( $file =~ "rq-" ) {	# checks to see if it is a requirement
	open( FILE, $file );	# opens file for traverse
	
		while( $line = <FILE> ) {	# goes through each line of the file

			ck_title( $file, $line );
			ck_label( $file, $line );
			ck_owner( $file, $line );
			ck_type( $file, $line );
			ck_priority( $file, $line );
			ck_descr( $file, $line );
			ck_index( $file, $line );
			ck_parent( $file, $line );
			ck_derived( $file, $line );
			
		}	# end while( $line = <FILE> )
	
	
	}	# end if ( $file =~ "rq-" )

}	# end foreach $file( @files )

#===============================================================================

#-------------------------------------------------------------------------------
#
#	sub-routine: ck_title
#
#	author: woody woods
#
#	date: 16 Nov 2011
#
#	purpose: this sub-routine checks the line to see if there is a 'title'
#		in the line. If not, it checks to see if the file has already
#		passed through the line.
#		If not, it pushes the error onto the @actual
#
#-------------------------------------------------------------------------------

sub ck_title {

	my( 	$title, 
		$newfile 
		$oldfile
		$check );
	
	$newfile = $file;
	if ( $newfile != $oldfile ) {
	
		check = 0;
	
	} # end if ( $newfile != $oldfile )
	
	if ( $line =~ /title/ ) {

		push( @actual, $file " has title" )
		check = 1;
		$oldfile = $newfile;
			
	}
	elseif ( check == 1 ) {
		
		check = 1;
		
	}
	else {
		
		push( @actual, $file "=> " $errors{ 'title' };
		
	}	# end if ( $line =~ /title/ )
	
}	# end of ck_title

#-------------------------------------------------------------------------------

	