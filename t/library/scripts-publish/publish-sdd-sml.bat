::####################################################################
::
:: publish-sdd-sml.bat
::
::     Publish the ``SML'' Data Format Software Design Document (SDD)
::
::     $Date: 2011-10-28 20:12:48 -0600 (Fri, 28 Oct 2011) $
::
::     $Revision: 441 $
::
::     $Author: Don Johnson $
::
::####################################################################

@echo off

set doc=sdd-sml

set begin=%DATE% %TIME%
echo BEGIN: %begin%

call list-all-items.bat %doc% problems
call list-all-items.bat %doc% solutions
call list-all-items.bat %doc% roles
call list-all-items.bat %doc% allocations
call list-all-items.bat %doc% tests

call publish-html.bat %doc%
call publish-pdf.bat  %doc%

echo BEGIN: %begin%
echo END:   %DATE% %TIME%
