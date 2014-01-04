::####################################################################
::
:: validate-doc.bat
::
::     Validate the syntax and semantics of an SML document.
::
::     $Date: 2012-11-26 09:19:14 -0700 (Mon, 26 Nov 2012) $
::
::     $Revision: 11510 $
::
::     $Author: don.johnson $
::
::####################################################################

set doc=%1

set perl=..\..\..\perl\perl\bin\perl.exe
set validate=utility\validate_document.pl

cd ..

%perl% %validate% %doc%.txt

cd scripts-validate
