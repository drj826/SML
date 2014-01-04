::####################################################################
::
:: new2old.bat - Convert library in SML v2 format to SML v1 format.
::
::####################################################################

@echo off

set perl=..\..\..\..\perl\perl\bin\perl.exe
set script=new2old.pl

%perl% %script%

pause