::####################################################################
::
:: replace-string.bat
::
::####################################################################

@echo off

set perl=..\..\..\..\perl\perl\bin\perl.exe
set script=replace-string.pl

%perl% %script% %1 %2

pause