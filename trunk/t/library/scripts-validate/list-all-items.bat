::####################################################################
::
:: list-all-items.bat
::
::     $Date: 2012-11-26 09:19:14 -0700 (Mon, 26 Nov 2012) $
::
::     $Revision: 11510 $
::
::     $Author: don.johnson $
::
::####################################################################

set doc=%1
set item=%2

set perl=..\..\..\perl\perl\bin\perl.exe
set script=scripts\include_related.pl

cd ..

echo generating auto\%doc%-%item%.txt

%perl% %script% --%item% --all --tree > auto\%doc%-%item%.txt

cd scripts-validate
