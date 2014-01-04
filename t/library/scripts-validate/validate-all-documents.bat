::####################################################################
::
:: validate-all-documents.bat
::
::     Validate all documents in library.  Display errors and warnings.
::
::     $Date: 2012-09-24 05:46:29 -0600 (Mon, 24 Sep 2012) $
::
::     $Revision: 10057 $
::
::     $Author: don.johnson $
::
::####################################################################

@echo off

set begin=%DATE% %TIME%
echo BEGIN: validate-all-documents %begin%

::====================================================================
:: User's Guide and Quick Reference
::====================================================================

set doc=sml

echo.
echo ----------------------------------------------------------------------
echo validate %doc% (user guide)
echo ----------------------------------------------------------------------

call validate-doc.bat %doc%

set doc=ref

echo.
echo ----------------------------------------------------------------------
echo validate %doc%
echo ----------------------------------------------------------------------

call validate-doc.bat %doc%

::====================================================================
:: Functional Requirements Documents (FRD)
::====================================================================

set doc=frd-sml

echo.
echo ----------------------------------------------------------------------
echo validate %doc% (functional requirements document)
echo ----------------------------------------------------------------------

call list-all-items.bat %doc% problems

call validate-doc.bat %doc%

::====================================================================
:: Software Design Document (SDD)
::====================================================================

set doc=sdd-sml

echo.
echo ----------------------------------------------------------------------
echo validate %doc% (software design document)
echo ----------------------------------------------------------------------

call list-all-items.bat %doc% problems
call list-all-items.bat %doc% solutions
call list-all-items.bat %doc% allocations
call list-all-items.bat %doc% tests

call validate-doc.bat %doc%

::====================================================================
:: All Items
::====================================================================

set doc=all-items

echo.
echo ----------------------------------------------------------------------
echo validate %doc%
echo ----------------------------------------------------------------------

call list-all-items.bat %doc% problems
call list-all-items.bat %doc% solutions
call list-all-items.bat %doc% allocations
call list-all-items.bat %doc% tests
call list-all-items.bat %doc% results
call list-all-items.bat %doc% tasks
call list-all-items.bat %doc% roles

call validate-doc.bat %doc%

echo BEGIN: validate-all-documents %begin%
echo END:   validate-all-documents %DATE% %TIME%

pause
