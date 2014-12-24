::####################################################################
::
:: publish-pdf.bat
::
::     Publish a PDF rendition of a document.
::
::     $Date: 2012-10-20 19:35:43 -0600 (Sat, 20 Oct 2012) $
::
::     $Revision: 10688 $
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
--nouse_svn ^
--svn %svn% ^
--convert %convert% ^
--pdflatex %pdflatex% ^
--bibtex %bibtex% ^
--makeindex %makeindex% ^
--render pdf ^
--render csv ^
-- %doc%.txt

cd scripts-publish
