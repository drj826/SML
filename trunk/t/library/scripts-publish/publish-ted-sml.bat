::####################################################################
::
:: publish-ted-sml.bat
::
::     Publish the ``SML'' Test and Evaluation Document (TED)
::
::     $Date: 2012-09-24 05:45:45 -0600 (Mon, 24 Sep 2012) $
::
::     $Revision: 10056 $
::
::     $Author: don.johnson $
::
::####################################################################

@echo off

set doc=ted-sml

set begin=%DATE% %TIME%
echo BEGIN: %begin%

call list-all-items.bat %doc% problems
call list-all-items.bat %doc% solutions
call list-all-items.bat %doc% allocations
call list-all-items.bat %doc% roles
call list-all-items.bat %doc% tests
call list-all-items.bat %doc% results

call publish-html.bat %doc%
call publish-pdf.bat  %doc%

echo BEGIN: %begin%
echo END:   %DATE% %TIME%
