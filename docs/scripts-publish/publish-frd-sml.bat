::####################################################################
::
:: publish-frd-sml.bat
::
::     Publish the Structured Manuscript Language (SML) Functional
::     Requirements Document (FRD)
::
::     $Date: 2012-09-24 05:45:45 -0600 (Mon, 24 Sep 2012) $
::
::     $Revision: 10056 $
::
::     $Author: don.johnson $
::
::####################################################################

@echo off

set doc=frd-sml

set begin=%DATE% %TIME%
echo BEGIN: %begin%

call list-all-items.bat %doc% problems

call publish-html.bat %doc%
call publish-pdf.bat  %doc%

echo BEGIN: %begin%
echo END:   %DATE% %TIME%

