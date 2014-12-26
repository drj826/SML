::####################################################################
::
:: list-all-items.bat
::
::     $Date: 2012-03-02 18:23:46 -0700 (Fri, 02 Mar 2012) $
::
::     $Revision: 6451 $
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

cd scripts-publish
