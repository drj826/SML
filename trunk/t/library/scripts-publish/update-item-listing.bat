::####################################################################
::
:: update-item-listing.bat
::
::     Update an item listing file associated with a document.
::
::     $Date: 2012-09-24 05:45:45 -0600 (Mon, 24 Sep 2012) $
::
::     $Revision: 10056 $
::
::     $Author: don.johnson $
::
::####################################################################

set doc=%1
set item=%2

set perl=..\..\..\perl\perl\bin\perl.exe
set script=files\scripts\include_related.pl

cd ..

echo generating %doc%-%item%.txt...
%perl% %script% --%item% --tree --file %doc%.txt > auto\%doc%-%item%.txt

cd scripts-publish
