::####################################################################
::
:: old2new.bat - Convert library in SML v1 format to SML v2 format.
::
::####################################################################

@echo off

set perl=..\..\..\..\perl\perl\bin\perl.exe
set script=old2new.pl

%perl% %script%

pause