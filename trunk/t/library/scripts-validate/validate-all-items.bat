::####################################################################
::
:: validate-all-items.bat
::
::     $Date: 2011-11-17 06:20:57 -0700 (Thu, 17 Nov 2011) $
::
::     $Revision: 4919 $
::
::     $Author: don.johnson $
::
::####################################################################

@echo off

set doc=all-items

call list-all-items.bat %doc% problems
call list-all-items.bat %doc% solutions
call list-all-items.bat %doc% allocations
call list-all-items.bat %doc% tests
call list-all-items.bat %doc% results
call list-all-items.bat %doc% tasks
call list-all-items.bat %doc% roles

call validate-doc.bat %doc%

pause
