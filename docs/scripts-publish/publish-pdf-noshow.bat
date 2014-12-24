::####################################################################
::
:: publish-pdf-noshow.bat
::
::     Publish a PDF rendition of a document. Don't display published
::     PDF document.
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
set pdflatex=..\..\..\..\..\app\miktex\miktex\bin\pdflatex
set bibtex=..\..\..\..\..\app\miktex\miktex\bin\bibtex
set makeindex=..\..\..\..\..\app\miktex\miktex\bin\makeindex

cd ..

::--------------------------------------------------------------------
:: PDF
::
%perl% %publish% ^
--nochangelog ^
--scripts ^
--svn %svn% ^
--convert %convert% ^
--pdflatex %pdflatex% ^
--bibtex %bibtex% ^
--makeindex %makeindex% ^
--nolaunch_pdfview ^
--render pdf ^
--render csv ^
-- %doc%.txt

cd scripts-publish
