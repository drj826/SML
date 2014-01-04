::####################################################################
::
:: publish-sml.bat
::
::     Publish the Structured Manuscript Language (SML) user guide
::
::     $Date: 2011-09-12 06:41:00 -0600 (Mon, 12 Sep 2011) $
::
::     $Revision: 3683 $
::
::     $Author: don.johnson $
::
::####################################################################

@echo off

set doc=sml

set begin=%DATE% %TIME%
echo BEGIN: %begin%

call publish-html.bat %doc%
call publish-pdf.bat  %doc%

echo BEGIN: %begin%
echo END:   %DATE% %TIME%
