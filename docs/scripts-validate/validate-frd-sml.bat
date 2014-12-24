::####################################################################
::
:: validate-frd-sml.bat
::
::     $Date: 2012-09-24 05:46:29 -0600 (Mon, 24 Sep 2012) $
::
::     $Revision: 10057 $
::
::     $Author: don.johnson $
::
::####################################################################

@echo off

set doc=frd-sml

set begin=%DATE% %TIME%
echo BEGIN: %begin%

call list-all-items.bat %doc% problems

call validate-doc.bat %doc%

echo BEGIN: %begin%
echo END:   %DATE% %TIME%

pause
