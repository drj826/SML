::####################################################################
::
:: publish-html-noshow.bat
::
::     Publish an HTML rendition of a document.  Do not display
::     published document in browser.
::
::     $Date: 2012-09-17 20:09:32 -0600 (Mon, 17 Sep 2012) $
::
::     $Revision: 9903 $
::
::     $Author: don.johnson $
::
::####################################################################

set doc=%1

set perl=..\..\..\perl\perl\bin\perl.exe
set publish=..\..\..\publish\publish2.pl
set svn=..\..\..\svn\svn.exe
set convert=..\..\..\ImageMagick-6.7.2-Q16\convert.exe

cd ..

::--------------------------------------------------------------------
:: HTML
::
%perl% %publish% ^
--nochangelog ^
--scripts ^
--svn %svn% ^
--convert %convert% ^
--nolaunch_browser ^
--render html ^
-- %doc%.txt

cd scripts-publish
