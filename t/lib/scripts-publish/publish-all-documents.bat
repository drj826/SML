::####################################################################
::
:: publish-all-documents.bat
::
::     Publish All SML Documents
::
::     $Date: 2012-09-24 05:45:45 -0600 (Mon, 24 Sep 2012) $
::
::     $Revision: 10056 $
::
::     $Author: don.johnson $
::
::####################################################################

@echo off

set begin=%DATE% %TIME%
echo BEGIN: publish-all-documents %begin%

::====================================================================
:: Publish/SML User's Guide and Quick Reference
::====================================================================

set doc=sml

echo.
echo ----------------------------------------------------------------------
echo publish %doc%
echo ----------------------------------------------------------------------

call publish-html-noshow.bat %doc%
call publish-pdf-noshow.bat  %doc%

set doc=ref

echo.
echo ----------------------------------------------------------------------
echo publish %doc%
echo ----------------------------------------------------------------------

call publish-html-noshow.bat %doc%
call publish-pdf-noshow.bat  %doc%

::====================================================================
:: Functional Requirements Documents (FRD)
::====================================================================

set doc=frd-sml

echo.
echo ----------------------------------------------------------------------
echo publish %doc%
echo ----------------------------------------------------------------------

call list-all-items.bat %doc% problems

call publish-html-noshow.bat %doc%
call publish-pdf-noshow.bat  %doc%

::====================================================================
:: Software Design Document (SDD) - Publish
::====================================================================

set doc=sdd-sml

echo.
echo ----------------------------------------------------------------------
echo publish %doc%
echo ----------------------------------------------------------------------

call list-all-items.bat %doc% problems
call list-all-items.bat %doc% solutions
call list-all-items.bat %doc% allocations
call list-all-items.bat %doc% tests

call publish-html-noshow.bat %doc%
call publish-pdf-noshow.bat  %doc%

::====================================================================
:: Test and Evaluation Document (TED) 
::====================================================================

set doc=ted-sml

echo.
echo ----------------------------------------------------------------------
echo publish %doc%
echo ----------------------------------------------------------------------

call list-all-items.bat %doc% problems
call list-all-items.bat %doc% solutions
call list-all-items.bat %doc% allocations
call list-all-items.bat %doc% roles
call list-all-items.bat %doc% tests
call list-all-items.bat %doc% results

call publish-html-noshow.bat %doc%
call publish-pdf-noshow.bat  %doc%

::====================================================================
:: All Items
::====================================================================

set doc=all-items

echo.
echo ----------------------------------------------------------------------
echo publish %doc%
echo ----------------------------------------------------------------------

call list-all-items.bat %doc% problems
call list-all-items.bat %doc% solutions
call list-all-items.bat %doc% allocations
call list-all-items.bat %doc% tests
call list-all-items.bat %doc% results
call list-all-items.bat %doc% tasks
call list-all-items.bat %doc% roles

call publish-html-noshow.bat %doc%
call publish-pdf-noshow.bat %doc%

echo BEGIN: publish-all-documents %begin%
echo END:   publish-all-documents %DATE% %TIME%
