::####################################################################
::
:: publish-all-items.bat
::
::     $Date: 2012-03-02 18:42:34 -0700 (Fri, 02 Mar 2012) $
::
::     $Revision: 6463 $
::
::     $Author: don.johnson $
::
::####################################################################

@echo off

set doc=all-items

set begin=%DATE% %TIME%
echo BEGIN: %begin%

call list-all-items.bat %doc% problems
call list-all-items.bat %doc% solutions
call list-all-items.bat %doc% allocations
call list-all-items.bat %doc% tests
call list-all-items.bat %doc% results
call list-all-items.bat %doc% tasks
call list-all-items.bat %doc% roles

call publish-html.bat %doc%
call publish-pdf.bat %doc%

echo BEGIN: %begin%
echo END:   %DATE% %TIME%
