::####################################################################
::
:: build-release.bat
::
::     Automatically build all documents for release.
::
::     $Date: 2012-09-17 20:09:32 -0600 (Mon, 17 Sep 2012) $
::
::     $Revision: 9903 $
::
::     $Author: don.johnson $
::
::####################################################################

set perl=..\..\..\..\perl\perl\bin\perl.exe

%perl% build-release.pl
