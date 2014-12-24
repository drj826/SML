::####################################################################
::
:: continuously-publish.bat
::
::     Continuously publish all Engineering Library documents. This
::     script executes an infinte loop (for convenience).
::
::     $Date: 2012-09-17 20:09:32 -0600 (Mon, 17 Sep 2012) $
::
::     $Revision: 9903 $
::
::     $Author: don.johnson $
::
::####################################################################

@echo off

set svn=..\..\..\svn\svn.exe

:begin

set begin=%DATE% %TIME%
echo BEGIN: %begin%

echo updating working copy from SVN repository...
cd ..
call %svn% update

echo publishing all documents...
cd scripts-publish
call publish-all-documents.bat

cd scripts-publish

echo BEGIN: %begin%
echo END:   %DATE% %TIME%

goto begin
