#!/usr/bin/perl

# $Id: Narrative.pm 9805 2012-09-10 15:37:54Z don.johnson $

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

package SML::Narrative v2.0.0;

# DEPRECATE ?

# A narrative is the division of a SML document, region, or
# environment that immediately follows the preamble and goes to the
# end of the document, region, or environment.

use Moose;
use namespace::autoclean;

extends 'SML::Division';

has '+type', default => 'division';
has '+name', default => 'narrative';

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;
