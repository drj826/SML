::####################################################################
::
:: publish-ref.bat
::
::     Publish the SML Quick Reference Guide
::
::     $Date: 2011-10-28 20:12:48 -0600 (Fri, 28 Oct 2011) $
::
::     $Revision: 441 $
::
::     $Author: Don Johnson $
::
::####################################################################

@echo off

set doc=ref

set begin=%DATE% %TIME%
echo BEGIN: %begin%

call publish-html.bat %doc%
call publish-pdf.bat  %doc%

echo BEGIN: %begin%
echo END:   %DATE% %TIME%
